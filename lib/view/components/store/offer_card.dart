import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/view/components/offers/OfferPhotoViewer.dart'; // تأكد من استيراد ملف عارض الصور

class OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;

  const OfferCard({
    Key? key,
    required this.offer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = offer['title'] ?? '';
    final description = offer['description'] ?? '';
    final price = offer['price'] ?? 0;
    final discount = offer['discount'] ?? 0;
    final images = offer['images'] ?? [];
    final List<String> imageUrls = images is List
        ? List<String>.from(images.map((img) => img.toString()))
        : [];
    final String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
    final String categoryName =
        (offer['category'] != null) ? offer['category']['name'] ?? '' : '';

    // حساب السعر بعد الخصم
    final discountedPrice = price - (price * discount / 100);

    // حساب قيمة التوفير
    final savingsAmount = price - discountedPrice;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة العرض
          _buildOfferImage(imageUrls),

          // تفاصيل العرض
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان العرض والفئة
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (categoryName.isNotEmpty)
                      _buildCategoryTag(categoryName),
                  ],
                ),

                // وصف العرض
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                SizedBox(height: 12),

                // إضافة شريط التوفير الجديد
                if (discount > 0)
                  _buildSavingsBar(
                      price, discountedPrice, savingsAmount, discount),

                SizedBox(height: 12),

                // الأسعار والخصم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOriginalPrice(price),
                    SizedBox(width: 8),
                    Expanded(child: _buildDiscountedPrice(discountedPrice)),
                    _buildDiscountBadge(discount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// دالة جديدة لإضافة شريط معلومات التوفير
  Widget _buildSavingsBar(num originalPrice, num discountedPrice,
      num savingsAmount, num discountPercentage) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.green[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.green[700]!.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.savings_outlined,
            color: Colors.green[400],
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: 'وفّر ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  TextSpan(
                    text: '${savingsAmount.toStringAsFixed(0)} ل.س ',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: 'عند الشراء الآن!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferImage(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return SizedBox.shrink();
    }

    return Stack(
      children: [
        // الصورة الرئيسية
        GestureDetector(
          onTap: () {
            // فتح عارض الصور عند النقر على الصورة
            Get.to(
              () => OfferPhotoViewer(
                imageUrls: imageUrls,
                initialIndex: 0,
              ),
              transition: Transition.fadeIn,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Hero(
              tag: "offer_image_${offer['id']}_0",
              child: CachedNetworkImage(
                imageUrl: imageUrls[0],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),

        // شارة لعدد الصور إذا كان هناك أكثر من صورة
        if (imageUrls.length > 1)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${imageUrls.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // زر التكبير
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTag(String categoryName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        categoryName,
        style: TextStyle(
          color: Colors.blue[300],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOriginalPrice(num price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السعر الأصلي',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
        Row(
          children: [
            Text(
              price.toString(),
              style: TextStyle(
                color: Colors.red[200], // لون أغمق للسعر الأصلي
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.red[400], // خط أكثر غمقاً للتشطيب
                decorationThickness: 2.0, // زيادة سماكة خط التشطيب
                fontWeight: FontWeight.w500, // زيادة وزن الخط للوضوح
              ),
            ),
            Text(
              ' ل.س',
              style: TextStyle(
                color: Colors.red[200], // لون متناسق مع السعر
                fontSize: 10,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.red[400],
                decorationThickness: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

// تحديث دالة _buildDiscountedPrice للتركيز أكثر على السعر الجديد
  Widget _buildDiscountedPrice(num discountedPrice) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // تغيير المحاذاة لتكون من اليمين إلى اليسار
      children: [
        Text(
          'السعر بعد الخصم',
          style: TextStyle(
            color: Colors.green[300],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              discountedPrice.toStringAsFixed(0),
              style: TextStyle(
                color: Colors.green[300],
                fontSize: 18, // زيادة حجم الخط
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' ل.س',
              style: TextStyle(
                color: Colors.green[300],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

// تحسين دالة _buildDiscountBadge لجعل شارة الخصم أكثر بروزاً
  Widget _buildDiscountBadge(num discount) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10, vertical: 6), // زيادة الحشوة
      decoration: BoxDecoration(
        color: Colors.red[700], // لون أحمر أغمق
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_downward,
            color: Colors.white,
            size: 12,
          ),
          SizedBox(width: 2),
          Text(
            '$discount%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
