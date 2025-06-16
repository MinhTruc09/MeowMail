importScripts('https://www.gstatic.com/firebasejs/10.4.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.4.0/firebase-messaging-compat.js');

firebase.initializeApp({
 apiKey: 'AIzaSyCUl-wYyUNTi3axuAK0BJXU-G_gpG_KF6M',
    appId: '1:164434614544:web:7a71fcfac3f1b6d78a6d95',
    messagingSenderId: '164434614544',
    projectId: 'mmail-1e27d',
    authDomain: 'mmail-1e27d.firebaseapp.com',
    storageBucket: 'mmail-1e27d.firebasestorage.app',
    measurementId: 'G-BJDGHL3YZG',
});
const messaging = firebase.messaging();