enum StatusRequest {
  none,           // لا يوجد حالة
  loading,        // جاري التحميل
  success,        // نجاح
  failure,        // فشل عام
  serverfailure,  // خطأ في الخادم
  offlinefailure, // لا يوجد اتصال
  badRequest,     // طلب غير صحيح
  unauthorized,   // غير مصرح
  forbidden,      // ممنوع
  notFound,       // غير موجود
  error,          // خطأ عام
}