// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:radar/controller/home/reel_controller.dart';
// import 'package:radar/core/theme/app_colors.dart';
// import 'package:radar/core/theme/app_fonts.dart';
// import 'package:radar/data/model/reel_model_api.dart';

// class ShareOptionsBottomSheet extends StatelessWidget {
//   final Reel reel;

//   const ShareOptionsBottomSheet({
//     Key? key,
//     required this.reel,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<ReelsController>();

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.1),
//             width: 0.5,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // عنوان النافذة
//             Row(
//               children: [
//                 Text(
//                   "مشاركة الريل",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: AppFonts.semiBold,
//                   ),
//                 ),
//                 Spacer(),
//                 IconButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   icon: Icon(Icons.close, color: Colors.white),
//                 ),
//               ],
//             ),

//             SizedBox(height: 20),

//             // قسم معاينة الريل (اختياري)
//             _buildReelPreview(),

//             SizedBox(height: 24),

//             // خيارات المشاركة
//             Text(
//               "مشاركة عبر",
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.8),
//                 fontSize: 16,
//                 fontWeight: AppFonts.medium,
//               ),
//             ),

//             SizedBox(height: 16),

//             // أزرار المشاركة
//             GridView.count(
//               crossAxisCount: 4,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               mainAxisSpacing: 16,
//               crossAxisSpacing: 16,
//               childAspectRatio: 0.9,
//               children: [
//                 _buildShareOption(
//                   icon: FontAwesomeIcons.whatsapp,
//                   label: "واتساب",
//                   color: Color(0xFF25D366),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     controller.shareToWhatsApp(reel);
//                   },
//                 ),
//                 _buildShareOption(
//                   icon: Icons.link,
//                   label: "نسخ الرابط",
//                   color: Colors.blue,
//                   onTap: () {
//                     controller.copyReelLink(reel);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 _buildShareOption(
//                   icon: Icons.share,
//                   label: "مشاركة",
//                   color: AppColors.primary,
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     controller.shareReelLink(reel);
//                   },
//                 ),
//                 _buildShareOption(
//                   icon: Icons.image,
//                   label: "مشاركة الصورة",
//                   color: Colors.purple,
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     controller.shareReelImage(reel);
//                   },
//                 ),
//               ],
//             ),

//             SizedBox(height: 16),

//             // دالة إرسال التفاعل مع الريل (اختياري)
//             _buildSendReaction(),

//             SizedBox(
//                 height: MediaQuery.of(context).padding.bottom > 0
//                     ? MediaQuery.of(context).padding.bottom
//                     : 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // معاينة مصغرة للريل (اختياري)
//   Widget _buildReelPreview() {
//     // إذا لم تكن هناك وسائط، عرض مساحة فارغة
//     if (reel.mediaUrls.isEmpty) {
//       return SizedBox.shrink();
//     }

//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           // صورة مصغرة
//           ClipRRect(
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(8),
//               bottomRight: Radius.circular(8),
//             ),
//             child: Container(
//               width: 80,
//               height: 80,
//               color: Colors.grey[900],
//               child: _buildThumbnail(),
//             ),
//           ),

//           // معلومات الريل
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     reel.ownerName,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: AppFonts.medium,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     reel.description,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.7),
//                       fontSize: 12,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // عرض صورة مصغرة للريل
//   Widget _buildThumbnail() {
//     if (reel.mediaUrls.isEmpty) {
//       return Center(child: Icon(Icons.image, color: Colors.white));
//     }

//     final media = reel.mediaUrls[0];
//     final imageUrl = media.type == 'VIDEO' ? (media.poster ?? '') : media.url;

//     if (imageUrl.isEmpty) {
//       return Center(child: Icon(Icons.video_collection, color: Colors.white));
//     }

//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       fit: BoxFit.cover,
//       placeholder: (context, url) => Center(
//         child: CircularProgressIndicator(
//           color: AppColors.primary,
//           strokeWidth: 2,
//         ),
//       ),
//       errorWidget: (context, url, error) => Center(
//         child: Icon(
//           media.type == 'VIDEO' ? Icons.video_collection : Icons.image,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   // زر خيار المشاركة
//   Widget _buildShareOption({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // أيقونة مع خلفية دائرية
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: FaIcon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//             ),
//           ),

//           // نص الخيار
//           SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: AppFonts.medium,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   // وظيفة اختيارية: إرسال تفاعل مع الريل
//   Widget _buildSendReaction() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.emoji_emotions_outlined,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           SizedBox(width: 8),
//           Text(
//             "أرسل تفاعلًا مع الريل",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: AppFonts.regular,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
