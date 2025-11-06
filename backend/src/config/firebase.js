const admin = require('firebase-admin');

let firebaseInitialized = false;

const initializeFirebase = () => {
  if (firebaseInitialized) {
    return admin;
  }

  try {
    const serviceAccount = {
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    firebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized');
    return admin;
  } catch (error) {
    console.error('❌ Error initializing Firebase:', error);
    throw error;
  }
};

// Send notification to single user
const sendNotificationToUser = async (fcmToken, title, body, data = {}) => {
  if (!fcmToken) {
    throw new Error('FCM token is required');
  }

  const message = {
    notification: {
      title: title,
      body: body
    },
    data: data,
    token: fcmToken,
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      }
    }
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ Notification sent successfully:', response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    return { success: false, error: error.message };
  }
};

// Send to multiple users (batch)
const sendNotificationToMultiple = async (tokens, title, body, data = {}) => {
  if (!tokens || tokens.length === 0) {
    return { success: false, message: 'No tokens provided' };
  }

  // Filter out invalid tokens
  const validTokens = tokens.filter(t => t && t.trim().length > 0);

  if (validTokens.length === 0) {
    return { success: false, message: 'No valid tokens found' };
  }

  const message = {
    notification: { title, body },
    data: data,
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      }
    }
  };

  try {
    // Firebase supports max 500 tokens per batch
    const batchSize = 500;
    let totalSuccess = 0;
    let totalFailure = 0;

    for (let i = 0; i < validTokens.length; i += batchSize) {
      const batch = validTokens.slice(i, i + batchSize);
      const response = await admin.messaging().sendEachForMulticast({
        ...message,
        tokens: batch
      });

      totalSuccess += response.successCount;
      totalFailure += response.failureCount;

      // Log failures
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(`Failed to send to token ${batch[idx]}:`, resp.error);
          }
        });
      }
    }

    console.log(`✅ Sent ${totalSuccess} notifications, ${totalFailure} failed`);
    return {
      success: true,
      sent: totalSuccess,
      failed: totalFailure
    };
  } catch (error) {
    console.error('❌ Error sending batch notifications:', error);
    return { success: false, error: error.message };
  }
};

module.exports = {
  initializeFirebase,
  sendNotificationToUser,
  sendNotificationToMultiple,
  admin
};
