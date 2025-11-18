// filepath: d:\TADUYTHUYEN\Clothes_try_on_app_AR\app_be\src\common\firebase.ts
import * as admin from 'firebase-admin';
// Đảm bảo đường dẫn này chính xác
import * as serviceAccount from '../config/firebase-admin-key.json';

// Kiểm tra để tránh khởi tạo lại
if (!admin.apps.length) {
  admin.initializeApp({
    // Ép kiểu serviceAccount thành admin.ServiceAccount
    credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
    storageBucket: 'arprj-30321.firebasestorage.app',
  });
}

export const storage = admin.storage();
export const bucket = storage.bucket();
