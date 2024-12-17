// functions/src/auth/onUserStatusChange.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onUserStatusChange = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();

    if (newData.status === previousData.status) {
      return null;
    }

    const user = await admin.firestore()
      .collection('users')
      .doc(context.params.userId)
      .get();

    const fcmToken = user.data()?.fcmToken;
    if (!fcmToken) return null;

    const message = {
      notification: {
        title: 'Account Status Update',
        body: `Your account status has been updated to ${newData.status}`,
      },
      data: {
        type: 'STATUS_UPDATE',
        status: newData.status,
      },
      token: fcmToken,
    };

    return admin.messaging().send(message);
  });

