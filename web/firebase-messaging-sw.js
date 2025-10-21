// Import Firebase scripts for messaging
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
// Note: Replace these values with your actual Firebase config
firebase.initializeApp({
  apiKey: "AIzaSyDL68_MR3OKIo3XvLkMdw3qKgjAwR2H1eQ",
  authDomain: "my-pro-fcc67.firebaseapp.com",
  projectId: "my-pro-fcc67",
  storageBucket: "my-pro-fcc67.firebasestorage.app",
  messagingSenderId: "670966149763",
  appId: "1:670966149763:web:b65ba24c5f281a4e4a61b6"
});

// Initialize Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || 'HealHub';
  const notificationOptions = {
    body: payload.notification?.body || 'لديك إشعار جديد',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'healhub-notification',
    requireInteraction: true,
    actions: [
      {
        action: 'open',
        title: 'فتح التطبيق'
      },
      {
        action: 'close',
        title: 'إغلاق'
      }
    ]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');

  event.notification.close();

  if (event.action === 'open' || !event.action) {
    // Open the app
    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
        // Check if there's already a window/tab open with the target URL
        for (var i = 0; i < clientList.length; i++) {
          var client = clientList[i];
          // If we find an existing client, focus it
          if (client.url.includes(self.location.origin) && 'focus' in client) {
            return client.focus();
          }
        }
        // If no existing client is found, open a new window/tab
        if (clients.openWindow) {
          return clients.openWindow('/');
        }
      })
    );
  }
});

