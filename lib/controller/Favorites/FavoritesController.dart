// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:radar/data/model/reel_model_api.dart';


// class FavoritesController extends GetxController {
//   final RxBool isLoading = false.obs;
//   final RxBool hasError = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxList<Reel> favoriteReels = <Reel>[].obs;
  
//   @override
//   void onInit() {
//     super.onInit();
//     loadFavorites();
//   }
  
//   void loadFavorites() {
//     isLoading.value = true;
//     hasError.value = false;
    
//     // محاكاة تأخير طلب API
//     Future.delayed(Duration(seconds: 1), () {
//       try {
//         // قائمة البيانات الثابتة المتوافقة مع النموذج الجديد
//         List<Reel> staticFavorites = [
//           Reel(
//             id: '1', 
//             title: 'مناظر طبيعية في المملكة',
//             ownerName: 'أحمد محمد',
//             ownerNumber: '+966 50 123 4567',
//             description: 'فيديو رائع عن أجمل المناظر الطبيعية في المملكة العربية السعودية #سياحة #طبيعة',
//             type: 'REEL',
//             intervalHours: 24,
//             endValidationDate: DateTime.now().add(Duration(days: 30)),
//             createdAt: DateTime.now().subtract(Duration(days: 2)),
//             updatedAt: DateTime.now().subtract(Duration(days: 2)),
//             mediaUrls: [
//               ReelMedia(
//                 url: 'http://anycode-sy.com/media/reel-win/videos/converted/ANYCODE-reel6-2025-02-27-21-44-26_cnau3r/ANYCODE-reel6-2025-02-27-21-44-26_cnau3r.m3u8',
//                 poster: 'http://anycode-sy.com/media/reel-win/images/ANYCODE-reel6-2025-02-27-21-44-26_cnau3r_poster.webp',
//                 type: 'VIDEO'
//               )
//             ],
//             interests: [
//               Interest(id: '1', name: 'سياحة'),
//               Interest(id: '2', name: 'طبيعة')
//             ],
//             counts: ReelCounts(likedBy: 1245, viewedBy: 5670, whatsappedBy: 230),
//             isLiked: true,
//             isWatched: true,
//             isWhatsapped: false,
//           ),
//           Reel(
//             id: '2', 
//             title: 'رحلة إلى الأردن',
//             ownerName: 'سارة أحمد',
//             ownerNumber: '+962 77 987 6543',
//             description: 'صورة من رحلتي إلى الأردن، وادي رم مكان مذهل يستحق الزيارة #سفر #سياحة #الأردن',
//             type: 'POST',
//             intervalHours: 48,
//             endValidationDate: DateTime.now().add(Duration(days: 45)),
//             createdAt: DateTime.now().subtract(Duration(hours: 5)),
//             updatedAt: DateTime.now().subtract(Duration(hours: 5)),
//             mediaUrls: [
//               ReelMedia(
//                 url: 'https://picsum.photos/id/29/800/800',
//                 poster: 'https://picsum.photos/id/29/800/800',
//                 type: 'IMAGE'
//               )
//             ],
//             interests: [
//               Interest(id: '3', name: 'سفر'),
//               Interest(id: '4', name: 'الأردن')
//             ],
//             counts: ReelCounts(likedBy: 876, viewedBy: 2340, whatsappedBy: 120),
//             isLiked: true,
//             isWatched: true,
//             isWhatsapped: true,
//           ),
//           Reel(
//             id: '3', 
//             title: 'شرح تطبيق رادار',
//             ownerName: 'محمد العتيبي',
//             ownerNumber: '+966 55 555 5555',
//             description: 'شرح مبسط لكيفية استخدام تطبيق رادار للربح من مشاهدة الفيديوهات #تعليم #ربح #ريل_وين',
//             type: 'REEL',
//             intervalHours: 12,
//             endValidationDate: DateTime.now().add(Duration(days: 60)),
//             createdAt: DateTime.now().subtract(Duration(days: 7)),
//             updatedAt: DateTime.now().subtract(Duration(days: 6)),
//             mediaUrls: [
//               ReelMedia(
//                 url: 'https://example.com/video3.mp4',
//                 poster: 'https://picsum.photos/id/65/800/800',
//                 type: 'VIDEO'
//               )
//             ],
//             interests: [
//               Interest(id: '5', name: 'تعليم'),
//               Interest(id: '6', name: 'ربح')
//             ],
//             counts: ReelCounts(likedBy: 2567, viewedBy: 10230, whatsappedBy: 520),
//             isLiked: true,
//             isWatched: true,
//             isWhatsapped: false,
//           ),
//           Reel(
//             id: '4', 
//             title: 'وصفة الكيكة الإسفنجية',
//             ownerName: 'فاطمة الشمري',
//             ownerNumber: '+966 54 321 7890',
//             description: 'وصفة سهلة وسريعة لتحضير الكيكة الإسفنجية بالشوكولاتة #وصفات #طبخ #حلويات',
//             type: 'REEL',
//             intervalHours: 24,
//             endValidationDate: DateTime.now().add(Duration(days: 20)),
//             createdAt: DateTime.now().subtract(Duration(days: 1)),
//             updatedAt: DateTime.now().subtract(Duration(days: 1)),
//             mediaUrls: [
//               ReelMedia(
//                 url: 'https://example.com/video4.mp4',
//                 poster: 'https://picsum.photos/id/102/800/800',
//                 type: 'VIDEO'
//               )
//             ],
//             interests: [
//               Interest(id: '7', name: 'طبخ'),
//               Interest(id: '8', name: 'وصفات'),
//               Interest(id: '9', name: 'حلويات')
//             ],
//             counts: ReelCounts(likedBy: 3421, viewedBy: 9870, whatsappedBy: 765),
//             isLiked: true,
//             isWatched: false,
//             isWhatsapped: false,
//           ),
//           Reel(
//             id: '5', 
//             title: 'نصائح للتصوير الفوتوغرافي',
//             ownerName: 'عبدالله القحطاني',
//             ownerNumber: '+966 56 111 2222',
//             description: 'نصائح مهمة للمبتدئين في التصوير الفوتوغرافي #تصوير #كاميرا #نصائح',
//             type: 'POST',
//             intervalHours: 36,
//             endValidationDate: DateTime.now().add(Duration(days: 15)),
//             createdAt: DateTime.now().subtract(Duration(days: 15)),
//             updatedAt: DateTime.now().subtract(Duration(days: 15)),
//             mediaUrls: [
//               ReelMedia(
//                 url: 'https://picsum.photos/id/250/800/800',
//                 poster: 'https://picsum.photos/id/250/800/800',
//                 type: 'IMAGE'
//               )
//             ],
//             interests: [
//               Interest(id: '10', name: 'تصوير'),
//               Interest(id: '11', name: 'نصائح')
//             ],
//             counts: ReelCounts(likedBy: 1670, viewedBy: 4320, whatsappedBy: 210),
//             isLiked: true,
//             isWatched: true,
//             isWhatsapped: false,
//           ),
//           Reel(
//             id: '6', 
//             title: 'معرض الكتاب بالرياض 2023',
//             ownerName: 'نورة السالم',
//             ownerNumber: '+966 59 999 8888',
//             description: 'جولة في معرض الكتاب بالرياض لعام 2023 مع أهم الإصدارات #كتب #معرض_الكتاب #ثقافة',
//             type: 'REEL',
//             intervalHours: 24,
//             endValidationDate: DateTime.now().add(Duration(days: 30)),
//             createdAt: DateTime.now().subtract(Duration(hours: 12)),
//             updatedAt: DateTime.now().subtract(Duration(hours: 10)),
//             mediaUrls: [
//               ReelMedia(
//                 url: 'https://example.com/video6.mp4',
//                 poster: 'https://picsum.photos/id/24/800/800',
//                 type: 'VIDEO'
//               )
//             ],
//             interests: [
//               Interest(id: '12', name: 'كتب'),
//               Interest(id: '13', name: 'ثقافة')
//             ],
//             counts: ReelCounts(likedBy: 950, viewedBy: 3100, whatsappedBy: 180),
//             isLiked: true,
//             isWatched: true,
//             isWhatsapped: true,
//           ),
//         ];
        
//         // تحديث القائمة
//         favoriteReels.clear();
//         favoriteReels.addAll(staticFavorites);
        
//         isLoading.value = false;
//       } catch (e) {
//         hasError.value = true;
//         errorMessage.value = 'حدث خطأ أثناء تحميل المفضلة: ${e.toString()}';
//         isLoading.value = false;
//       }
//     });
//   }
  
//   void removeFromFavorites(String reelId) {
//     // احذف الريل من المفضلة
//     favoriteReels.removeWhere((reel) => reel.id == reelId);
    
//     Get.snackbar(
//       'تمت الإزالة',
//       'تمت إزالة العنصر من المفضلة',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.black.withOpacity(0.7),
//       colorText: Colors.white,
//       margin: EdgeInsets.all(8),
//       duration: Duration(seconds: 2),
//     );
    
//     // هنا يمكنك إضافة طلب API لإزالة المفضلة
//   }
  
//   void playReel(Reel reel) {
//     // انتقل إلى صفحة الريلز وقم بتشغيل الريل المحدد
//     // TODO: تنفيذ المنطق الخاص بالانتقال إلى الريل المحدد
//     Get.toNamed('/reels', arguments: {'reelId': reel.id});
//   }
// }
