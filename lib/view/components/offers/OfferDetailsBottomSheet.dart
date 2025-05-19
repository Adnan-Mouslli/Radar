import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:radar/controller/OffersRadar/OffersRadarController.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/data/model/OfferModel.dart';
import 'package:radar/view/components/offers/OfferPhotoViewer.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferDetailsBottomSheet extends StatelessWidget {
  final OfferModel offer;
  final OffersRadarController controller;

  OfferDetailsBottomSheet({
    required this.offer,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        // خلفية أفتح للواجهة بأكملها
        color:
            Color(0xFF1E1E1E), // درجة رمادي داكن بدلاً من الأسود لتحسين الوضوح
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 50,
            height: 5,
            margin: EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade500, // لون أفتح للمقبض
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Title and discount with improved styling
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    offer.title,
                    style: TextStyle(
                      fontWeight: AppFonts.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'خصم ${offer.discount}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Images carousel with improved styling
          _buildImagesCarousel(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store info
                  _buildStoreInfo(),

                  SizedBox(height: 20),

                  // Price information
                  _buildPriceInfo(),

                  SizedBox(height: 20),

                  // Description
                  _buildDescriptionSection(),

                  SizedBox(height: 30),

                  // Directions button
                  _buildDirectionsButton(),

                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesCarousel() {
    if (offer.images.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Color(0xFF2A2A2A),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Simple carousel without controller
        CarouselSlider(
          options: CarouselOptions(
            height: 240,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: offer.images.length > 1,
            enableInfiniteScroll: offer.images.length > 1,
            autoPlayInterval: Duration(seconds: 4),
            // onPageChanged: (index, reason) {
            //   // هنا يمكن إضافة تتبع للصفحة الحالية إذا كنت تريد
            // },
          ),
          items: offer.images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    // الانتقال إلى عارض الصور عند النقر على الصورة
                    final currentIndex = offer.images.indexOf(imageUrl);
                    Get.to(
                      () => OfferPhotoViewer(
                        imageUrls: offer.images,
                        initialIndex: currentIndex,
                      ),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade700,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Image
                            Positioned.fill(
                              child: Hero(
                                tag: "image_${offer.images.indexOf(imageUrl)}",
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Color(0xFF2A2A2A),
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Gradient overlay for better visibility
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // إضافة رمز التكبير للإشارة إلى إمكانية عرض الصورة
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),

        // إضافة مؤشرات للصور في حالة وجود أكثر من صورة
        if (offer.images.length > 1)
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: offer.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A), // لون أفتح للخلفية
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.15)), // لون أوضح للحدود
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                offer.store.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Color(0xFF3A3A3A), // لون أفتح للخلفية
                  child: Icon(
                    Icons.store,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.store.name,
                  style: TextStyle(
                    fontWeight: AppFonts.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${offer.store.address}, ${offer.store.city}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8), // لون أوضح للنص
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.near_me,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4),
                Text(
                  controller.formatDistance(offer.distance!),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppFonts.medium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF252525), // لون أفتح للخلفية
            Color(0xFF323232), // لون أفتح للخلفية
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.15)), // لون أوضح للحدود
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر الأصلي:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8), // لون أوضح للنص
                ),
              ),
              // استخدام خاصية decoration للشطب بدلاً من Stack
              Text(
                '${offer.formattedPrice} ليرة سورية',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.red[500], // لون الشطب أحمر واضح
                  decorationThickness: 2.5, // خط شطب سميك
                  decorationStyle: TextDecorationStyle.solid, // نمط خط الشطب
                ),
              ),
            ],
          ),
          Divider(
              color: Colors.white.withOpacity(0.15),
              thickness: 1,
              height: 24), // لون أوضح للخط الفاصل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.discount_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'قيمة الخصم:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                '${offer.discountAmount.toStringAsFixed(0)} ليرة سورية (${offer.discount}%)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: AppFonts.bold,
                ),
              ),
            ],
          ),
          Divider(
              color: Colors.white.withOpacity(0.15),
              thickness: 1,
              height: 24), // لون أوضح للخط الفاصل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر بعد الخصم:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: AppFonts.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  '${offer.formattedPriceAfterDiscount} ليرة سورية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: AppFonts.bold,
                    color: Colors.green.shade300, // لون أفتح للنص
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'تفاصيل العرض',
              style: TextStyle(
                fontWeight: AppFonts.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A), // لون أفتح للخلفية
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withOpacity(0.15)), // لون أوضح للحدود
          ),
          child: Text(
            offer.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), // لون أوضح للنص
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ),
        if (offer.content != null) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15), // لون أوضح للخلفية
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)), // لون أوضح للحدود
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    offer.content!.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF282828), // لون أفتح للخلفية
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withOpacity(0.1)), // لون أوضح للحدود
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.white.withOpacity(0.7), // لون أوضح للأيقونة
                  ),
                  SizedBox(width: 8),
                  Text(
                    'تاريخ بدء العرض: ${_formatDate(offer.startDate)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8), // لون أوضح للنص
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (offer.endDate != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 16,
                      color: Colors.white.withOpacity(0.7), // لون أوضح للأيقونة
                    ),
                    SizedBox(width: 8),
                    Text(
                      'تاريخ انتهاء العرض: ${_formatDate(offer.endDate!)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8), // لون أوضح للنص
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionsButton() {
    return Column(
      children: [
        // صف أول يحتوي على زر واتساب
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 14),
          child: ElevatedButton(
            onPressed: () {
              // تحقق من وجود رقم هاتف
              if (offer.store.phone != null && offer.store.phone.isNotEmpty) {
                // تنسيق رقم الهاتف لواتساب
                final formattedPhone =
                    offer.store.phone.toString().replaceAll('+', '');
                _launchWhatsApp('https://wa.me/$formattedPhone');
              } else {
                // إظهار رسالة إذا كان رقم الهاتف غير متوفر
                Get.snackbar(
                  'تنبيه',
                  'رقم الهاتف غير متوفر',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF25D366), // لون واتساب الأخضر
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'تواصل عبر واتساب',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppFonts.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // صف ثاني يحتوي على أزرار الموقع والاتجاهات
        Row(
          children: [
            // View store location button with enhanced design
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Close the details and open store location in Google Maps
                  Get.back();
                  controller.openStoreLocation(offer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A3A3A), // لون أفتح للخلفية
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color:
                            Colors.white.withOpacity(0.3)), // لون أوضح للحدود
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'عرض الموقع',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppFonts.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 14),

            // Get directions button with enhanced design
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Close the details and get directions in Google Maps
                  Get.back();
                  controller.getDirectionsToStore(offer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'الاتجاهات',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppFonts.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _launchWhatsApp(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Get.snackbar(
          'خطأ',
          'لا يمكن فتح واتساب. يرجى التأكد من تثبيت التطبيق.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("خطأ في فتح واتساب: $e");
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
