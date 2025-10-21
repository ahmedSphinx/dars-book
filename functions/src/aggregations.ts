import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * Recomputes student aggregates from scratch
 */
async function recomputeStudentAggregates(userId: string, studentId: string): Promise<void> {
  const teacherRef = db.collection('teachers').doc(userId);
  const studentRef = teacherRef.collection('students').doc(studentId);

  // Sum sessions (attendances)
  let sessionsCount = 0;
  let bookletsCount = 0;
  let totalCharges = 0.0;

  const attendanceQuery = await db
    .collectionGroup('attendances')
    .where(admin.firestore.FieldPath.documentId().toString(), '==', studentId)
    .where('ownerId', '==', userId)
    .get();

  for (const attDoc of attendanceQuery.docs) {
    const att = attDoc.data();
    const present = att.present || false;
    if (!present) continue;
    
    sessionsCount += 1;
    const sessionCharge = att.sessionCharge || 0.0;
    const bookletCharge = att.bookletCharge || 0.0;
    totalCharges += sessionCharge + bookletCharge;

    // Check if session has booklet
    const sessionRef = attDoc.ref.parent.parent;
    if (sessionRef) {
      const sessionSnap = await sessionRef.get();
      const hasBooklet = sessionSnap.data()?.hasBooklet || false;
      if (hasBooklet) bookletsCount += 1;
    }
  }

  // Sum payments
  let totalPaid = 0.0;
  const paymentsSnap = await teacherRef
    .collection('payments')
    .where('studentId', '==', studentId)
    .get();
  
  for (const p of paymentsSnap.docs) {
    totalPaid += p.data().amount || 0.0;
  }

  const remaining = Math.max(0, totalCharges - totalPaid);

  await studentRef.update({
    'aggregates.sessionsCount': sessionsCount,
    'aggregates.bookletsCount': bookletsCount,
    'aggregates.totalCharges': totalCharges,
    'aggregates.totalPaid': totalPaid,
    'aggregates.remaining': remaining,
    'updatedAt': admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Triggered when a payment is created, updated, or deleted
 */
export const onPaymentWrite = functions.firestore
  .document('teachers/{userId}/payments/{paymentId}')
  .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const { userId } = context.params as { userId: string };
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;
    const studentId = (after?.studentId || before?.studentId) as string | undefined;
    
    if (!studentId) return;
    
    try {
      await recomputeStudentAggregates(userId, studentId);
      console.log(`Updated aggregates for student ${studentId} after payment change`);
    } catch (error) {
      console.error(`Error updating aggregates for student ${studentId}:`, error);
    }
  });

/**
 * Triggered when an attendance is created, updated, or deleted
 */
export const onAttendanceWrite = functions.firestore
  .document('teachers/{userId}/sessions/{sessionId}/attendances/{studentId}')
  .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const { userId, studentId } = context.params as { userId: string; studentId: string };
    
    try {
      await recomputeStudentAggregates(userId, studentId);
      console.log(`Updated aggregates for student ${studentId} after attendance change`);
    } catch (error) {
      console.error(`Error updating aggregates for student ${studentId}:`, error);
    }
  });

/**
 * Manual trigger to recompute all students for a teacher
 */
export const recomputeAllStudents = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  
  try {
    const studentsSnap = await db
      .collection('teachers')
      .doc(userId)
      .collection('students')
      .get();

    const promises = studentsSnap.docs.map(doc => 
      recomputeStudentAggregates(userId, doc.id)
    );

    await Promise.all(promises);
    
    return { success: true, count: studentsSnap.size };
  } catch (error) {
    console.error('Error recomputing all students:', error);
    throw new functions.https.HttpsError('internal', 'Failed to recompute students');
  }
});
