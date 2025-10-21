"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onAttendanceWrite = exports.onPaymentWrite = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
async function recomputeStudentAggregates(userId, studentId) {
    const teacherRef = db.collection('teachers').doc(userId);
    const studentRef = teacherRef.collection('students').doc(studentId);
    // Aggregate attendances
    let sessionsCount = 0;
    let bookletsCount = 0;
    let totalCharges = 0;
    const attendancesSnap = await db
        .collectionGroup('attendances')
        .where(admin.firestore.FieldPath.documentId(), '==', studentId)
        .where('ownerId', '==', userId)
        .get();
    for (const attDoc of attendancesSnap.docs) {
        const att = attDoc.data();
        if (att.present) {
            sessionsCount += 1;
            totalCharges += (att.sessionCharge || 0) + (att.bookletCharge || 0);
            const sessionRef = attDoc.ref.parent.parent;
            const sessionSnap = await sessionRef.get();
            if (sessionSnap.exists && sessionSnap.get('hasBooklet')) {
                bookletsCount += 1;
            }
        }
    }
    // Aggregate payments
    let totalPaid = 0;
    const paymentsSnap = await teacherRef
        .collection('payments')
        .where('studentId', '==', studentId)
        .get();
    for (const p of paymentsSnap.docs) {
        totalPaid += p.get('amount') || 0;
    }
    const remaining = Math.max(0, totalCharges - totalPaid);
    await studentRef.update({
        'aggregates.sessionsCount': sessionsCount,
        'aggregates.bookletsCount': bookletsCount,
        'aggregates.totalCharges': totalCharges,
        'aggregates.totalPaid': totalPaid,
        'aggregates.remaining': remaining,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
exports.onPaymentWrite = functions.firestore
    .document('teachers/{userId}/payments/{paymentId}')
    .onWrite(async (change, context) => {
    const { userId } = context.params;
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;
    const studentId = (after?.studentId || before?.studentId);
    if (!studentId)
        return;
    await recomputeStudentAggregates(userId, studentId);
});
exports.onAttendanceWrite = functions.firestore
    .document('teachers/{userId}/sessions/{sessionId}/attendances/{studentId}')
    .onWrite(async (change, context) => {
    const { userId, studentId } = context.params;
    await recomputeStudentAggregates(userId, studentId);
});
//# sourceMappingURL=index.js.map