const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Helper to send notification
async function sendNotificationToUser(uid, notification) {
  const userDoc = await admin.firestore().collection('users').doc(uid).get();
  const fcmToken = userDoc.data()?.fcmToken;
  if (fcmToken) {
    await admin.messaging().send({
      token: fcmToken,
      notification,
      data: notification.data || {},
    });
  }
}

// 1. New chat message
exports.notifyOnNewChatMessage = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;

    // Get chat doc to find participants
    const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
    const participants = chatDoc.data()?.participants || [];
    for (const uid of participants) {
      if (uid !== message.senderId) {
        await sendNotificationToUser(uid, {
          title: 'New Message',
          body: message.text || 'You have a new message',
          data: { type: 'chat', chatId }
        });
      }
    }
  });

// 2. Check-in request status changed
exports.notifyOnCheckInStatusChange = functions.firestore
  .document('check_in_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status !== after.status) {
      const clientId = after.clientId;
      let body = '';
      if (after.status === 'approved') {
        body = 'Your check-in was approved!';
      } else if (after.status === 'rejected') {
        body = 'Your check-in was rejected.';
      } else if (after.status === 'checked_out') {
        body = 'You have checked out.';
      }
      if (body) {
        await sendNotificationToUser(clientId, {
          title: 'Check-In Update',
          body,
          data: { type: 'checkin', status: after.status }
        });
      }
    }
  });

// 3. New service request (notify receptionist)
exports.notifyOnNewServiceRequest = functions.firestore
  .document('service_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();
    const hotelId = request.hotelId;
    // Find receptionist by hotelId (assuming user doc for receptionist has uid == hotelId)
    await sendNotificationToUser(hotelId, {
      title: 'New Service Request',
      body: `New request: ${request.serviceType}`,
      data: { type: 'service_request', requestId: context.params.requestId }
    });
  });

// 4. Service request status changed (notify client)
exports.notifyOnServiceRequestStatusChange = functions.firestore
  .document('service_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status !== after.status) {
      const clientId = after.clientId;
      let body = '';
      if (after.status === 'accepted') {
        body = 'Your service request was accepted!';
      } else if (after.status === 'denied') {
        body = 'Your service request was denied.';
      } else if (after.status === 'completed') {
        body = 'Your service request was completed!';
      }
      if (body) {
        await sendNotificationToUser(clientId, {
          title: 'Service Request Update',
          body,
          data: { type: 'service_request', status: after.status }
        });
      }
    }
  });

exports.sendChatNotification = functions.https.onCall(async (data, context) => {
  const { token, title, body, dataPayload } = data;
  const message = {
    token,
    notification: { title, body },
    data: dataPayload || {},
  };
  try {
    await admin.messaging().send(message);
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
