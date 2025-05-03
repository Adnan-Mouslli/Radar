// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:radar/controller/Favorites/FavoritesController.dart';
// import 'package:radar/core/theme/app_colors.dart';
// import 'package:radar/core/theme/app_fonts.dart';
// import 'package:radar/data/model/reel_model_api.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:radar/view/pages/skeletons_/FavoritesScreenSkeleton.dart';

// class FavoritesScreen extends StatelessWidget {
//   final FavoritesController controller = Get.put(FavoritesController());
  
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.black,
//     body: SafeArea(
//       child: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value) {
//                 return const FavoritesScreenSkeleton();
//               } else if (controller.hasError.value) {
//                 return _buildErrorState();
//               } else if (controller.favoriteReels.isEmpty) {
//                 return _buildEmptyState();
//               } else {
//                 return _buildFavoritesList();
//               }
//             }),
//           ),
//         ],
//       ),
//     ),
//   );
// }
  
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Text(
//             'المفضلة',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: AppFonts.bold,
//             ),
//           ),
//           Spacer(),
//           IconButton(
//             onPressed: () => controller.loadFavorites(),
//             icon: Icon(
//               Icons.refresh,
//               color: Colors.white,
//             ),
//             tooltip: 'تحديث',
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             color: Colors.red,
//             size: 60,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             controller.errorMessage.value,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () => controller.loadFavorites(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             icon: const Icon(Icons.refresh),
//             label: const Text(
//               "إعادة المحاولة",
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FaIcon(
//             FontAwesomeIcons.heart,
//             color: Colors.white.withOpacity(0.3),
//             size: 70,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'لا توجد عناصر في المفضلة',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: AppFonts.medium,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'أضف المحتوى المفضل لديك بالضغط على زر الإعجاب',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.6),
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 30),
//           ElevatedButton.icon(
//             onPressed: () => Get.toNamed('/reels'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             icon: FaIcon(FontAwesomeIcons.play, size: 16),
//             label: Text(
//               'استكشف الريلز',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: AppFonts.medium,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildFavoritesList() {
//     return ListView.builder(
//       padding: EdgeInsets.all(12),
//       itemCount: controller.favoriteReels.length,
//       itemBuilder: (context, index) {
//         final reel = controller.favoriteReels[index];
//         return _buildFavoriteItem(reel);
//       },
//     );
//   }
  
//   Widget _buildFavoriteItem(Reel reel) {
//     // التعامل مع الصور المصغرة باستخدام النموذج الجديد
//     final String? thumbnailUrl = reel.mediaUrls.isNotEmpty 
//         ? (reel.mediaUrls[0].poster?.isNotEmpty ?? false ? reel.mediaUrls[0].poster : reel.mediaUrls[0].url)
//         : null;
    
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: InkWell(
//         onTap: () => controller.playReel(reel),
//         borderRadius: BorderRadius.circular(12),
//         child: Row(
//           children: [
//             // صورة الريل
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//               child: Stack(
//                 children: [
//                   Container(
//                     width: 120,
//                     height: 120,
//                     child: thumbnailUrl != null ? CachedNetworkImage(
//                       imageUrl: thumbnailUrl,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Container(
//                         color: Colors.grey[900],
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             color: AppColors.primary,
//                             strokeWidth: 2,
//                           ),
//                         ),
//                       ),
//                       errorWidget: (context, url, error) => Container(
//                         color: Colors.grey[900],
//                         child: Icon(
//                           Icons.broken_image,
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                       ),
//                     ) : Container(
//                       color: Colors.grey[900],
//                       child: Center(
//                         child: Icon(
//                           Icons.image_not_supported,
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   // أيقونة تشغيل الفيديو - استخدام طريقة isVideoMedia
//                   if (reel.mediaUrls.isNotEmpty && reel.isVideoMedia(0))
//                     Positioned.fill(
//                       child: Center(
//                         child: Container(
//                           padding: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.play_arrow,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
            
//             // معلومات الريل
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // عنوان الريل
//                     Text(
//                       reel.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: AppFonts.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // معلومات المنشئ والتاريخ
//                     Row(
//                       children: [
//                         Text(
//                           reel.ownerName,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: AppFonts.medium,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             _formatDate(reel.createdAt),
//                             style: TextStyle(
//                               color: AppColors.primary,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     // وصف الريل
//                     Text(
//                       reel.description,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 12,
//                         height: 1.4,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     // الاهتمامات
//                     if (reel.interests.isNotEmpty)
//                       Container(
//                         height: 22,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: reel.interests.length.clamp(0, 3),
//                           itemBuilder: (context, index) {
//                             return Container(
//                               margin: EdgeInsets.only(right: 6),
//                               padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 reel.interests[index].name,
//                                 style: TextStyle(
//                                   color: AppColors.primary,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     const SizedBox(height: 8),
//                     // إحصائيات
//                     Row(
//                       children: [
//                         _buildStatItem(Icons.favorite, '${reel.counts.likedBy}'),
//                         const SizedBox(width: 12),
//                         _buildStatItem(Icons.remove_red_eye, '${reel.counts.viewedBy}'),
//                         const SizedBox(width: 12),
//                         _buildStatItem(Icons.share, '${reel.counts.whatsappedBy}'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // زر إزالة من المفضلة
//             IconButton(
//               onPressed: () => controller.removeFromFavorites(reel.id),
//               icon: Icon(
//                 Icons.delete_outline,
//                 color: Colors.red.withOpacity(0.8),
//               ),
//               tooltip: 'إزالة من المفضلة',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildStatItem(IconData icon, String count) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: Colors.white.withOpacity(0.6),
//           size: 14,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           count,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.6),
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _formatDate(DateTime date) {
//     DateTime now = DateTime.now();
//     Duration difference = now.difference(date);

//     if (difference.inDays > 30) {
//       return '${(difference.inDays / 30).floor()} شهر';
//     } else if (difference.inDays > 0) {
//       return '${difference.inDays} يوم';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} ساعة';
//     } else {
//       return '${difference.inMinutes} دقيقة';
//     }
//   }
// }