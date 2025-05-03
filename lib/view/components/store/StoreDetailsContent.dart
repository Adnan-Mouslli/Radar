import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/view/components/store/offer_card.dart';
import 'package:radar/view/components/store/store_header.dart';

class StoreDetailsContent extends StatelessWidget {
  final Map<String, dynamic> storeData;
  final Function(String) launchWhatsApp;

  const StoreDetailsContent({
    Key? key,
    required this.storeData,
    required this.launchWhatsApp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeName = storeData['name'] ?? 'المتجر';
    final storeAddress = storeData['address'] ?? '';
    final storeCity = storeData['city'] ?? '';
    final storeImage = storeData['image'];
    final offers = storeData['offers'] ?? [];

    return Container(
      color: Color(0xFF1E1E1E),
      child: Column(
        children: [
          // عنوان المتجر
          StoreHeader(
            storeName: storeName,
            storeCity: storeCity,
            storeAddress: storeAddress,
            storeImage: storeImage,
            phone: storeData['phone'],
            launchWhatsApp: launchWhatsApp,
          ),

          // فاصل
          Divider(color: Colors.white.withOpacity(0.15)), // تحسين لون الفاصل

          // عنوان القسم
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_offer_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'عروض المتجر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
          ),

          // قائمة العروض
          Expanded(
            child: offers.isEmpty
                ? _buildEmptyOffersView()
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(10),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return OfferCard(offer: offer);
                    },
                  ),
          ),

          // زر إغلاق
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'إغلاق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOffersView() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[500],
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد عروض متاحة حالياً',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: AppFonts.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
