// Firebase Cloud Messaging Service Worker for Flutter Web
// This file MUST be in the /web root and served from the domain root

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBtR5Lg303aZzJFv3h9L3zYHw8SGPYB_a4',
  appId: '1:254914817750:web:c61c65807a0411f3bda377',
  messagingSenderId: '254914817750',
  projectId: 'doctorio-4de05',
  authDomain: 'doctorio-4de05.firebaseapp.com',
  storageBucket: 'doctorio-4de05.firebasestorage.app',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.data?.title || payload.notification?.title || 'Flash Care';
  const notificationOptions = {
    body: payload.data?.body || payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');
  event.notification.close();
  event.waitUntil(
    clients.openWindow('/')
  );
});
