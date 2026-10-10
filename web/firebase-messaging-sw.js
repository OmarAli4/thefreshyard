importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Firebase config (can be left mostly empty for basic receiving, but required to initialize)
// Replace these with your actual Firebase project config if you want web background notifications to work perfectly.
firebase.initializeApp({
  apiKey: "AIzaSyBkvDF3mQLewJpdWpbcMaw81_AbAfp5jqA",
  projectId: "thefreshyard-45b7e",
  messagingSenderId: "825455455996",
  appId: "1:825455455996:web:YOUR_WEB_APP_ID" // Ideally replaced with actual web app ID if fully supporting web
});

const messaging = firebase.messaging();

// Optional: Background message handler
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
