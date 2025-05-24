import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/stores/StoreDetailsController.dart';
import 'package:radar/core/class/statusrequest.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:radar/data/model/OfferModel.dart';
import 'package:radar/view/pages/home/NetworkErrorSkeleton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StoreDetailsScreen extends StatelessWidget {
  final StoreDetailsController controller = Get.put(StoreDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header مع صورة المتجر والمعلومات الأساسية
            _buildStoreHeader(context),

            // شريط البحث والفلترة
            _buildSearchAndFilter(context),

            // قائمة العروض
            Expanded(
              child: Obx(() {
                if (controller.statusRequest.value == StatusRequest.loading) {
                  return _buildLoadingState(context);
                } else if (controller.statusRequest.value ==
                    StatusRequest.offlinefailure) {
                  return NetworkErrorSkeleton(
                    message: 'لا يوجد اتصال بالإنترنت',
                    onRetry: () => controller.refreshOffers(),
                  );
                } else if (controller.statusRequest.value ==
                    StatusRequest.serverfailure) {
                  return NetworkErrorSkeleton(
                    message: 'حدث خطأ في الاتصال بالخادم',
                    onRetry: () => controller.refreshOffers(),
                  );
                } else if (controller.statusRequest.value ==
                        StatusRequest.failure ||
                    controller.offers.isEmpty) {
                  return _buildEmptyState(context);
                } else {
                  return _buildOffersGrid(context);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final headerHeight = isTablet ? 200.0 : 160.0;

    return Container(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // صورة خلفية المتجر
          _buildStoreBackgroundImage(context),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // محتوى Header
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر الرجوع
                Row(
                  children: [
                    GestureDetector(
                      onTap: controller.goBack,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          PhosphorIcons.arrowRight,
                          color: Colors.white,
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // معلومات المتجر
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // صورة المتجر الصغيرة
                    Container(
                      width: isTablet ? 60 : 50,
                      height: isTablet ? 60 : 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: controller.store.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: controller.store.image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Color(0xFF1C1C1C),
                                  child: Center(
                                    child: Icon(
                                      PhosphorIcons.storefrontBold,
                                      color: Colors.white.withOpacity(0.3),
                                      size: isTablet ? 24 : 20,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Color(0xFF1C1C1C),
                                  child: Center(
                                    child: Icon(
                                      PhosphorIcons.storefrontBold,
                                      color: Colors.white.withOpacity(0.3),
                                      size: isTablet ? 24 : 20,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  PhosphorIcons.storefrontBold,
                                  color: Colors.white.withOpacity(0.3),
                                  size: isTablet ? 24 : 20,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // تفاصيل المتجر
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.store.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: AppFonts.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.mapPin,
                                color: AppColors.primary,
                                size: isTablet ? 16 : 14,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  controller.store.city,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isTablet ? 15 : 13,
                                    fontWeight: AppFonts.medium,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreBackgroundImage(BuildContext context) {
    return controller.store.image.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: controller.store.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: Color(0xFF1C1C1C),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Color(0xFF1C1C1C),
              child: Center(
                child: Icon(
                  PhosphorIcons.storefrontBold,
                  color: Colors.white.withOpacity(0.3),
                  size: 60,
                ),
              ),
            ),
          )
        : Container(
            color: Color(0xFF1C1C1C),
            child: Center(
              child: Icon(
                PhosphorIcons.storefrontBold,
                color: Colors.white.withOpacity(0.3),
                size: 60,
              ),
            ),
          );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = mediaQuery.size.height < 650;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Column(
        children: [
          // شريط البحث
          Container(
            height: isTablet ? 45 : (isSmallScreen ? 38 : 42),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: TextField(
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 15 : 13,
                fontWeight: AppFonts.medium,
              ),
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'ابحث في العروض...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isTablet ? 15 : 13,
                ),
                prefixIcon: Icon(
                  PhosphorIcons.magnifyingGlass,
                  color: AppColors.primary.withOpacity(0.8),
                  size: isTablet ? 18 : 16,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),

          SizedBox(height: 8),

          // فلترة الفئات - الحل هنا
          Container(
            height: isTablet ? 38 : (isSmallScreen ? 32 : 35),
            child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];

                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => controller.changeCategory(category),
                        child: Obx(() => AnimatedContainer(
                              // إضافة Obx هنا للتحديث
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16 : 12,
                                vertical: isTablet ? 8 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: controller.selectedCategory.value ==
                                        category
                                    ? AppColors.primary
                                    : Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: controller.selectedCategory.value ==
                                          category
                                      ? AppColors.primary
                                      : Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: controller.selectedCategory.value ==
                                          category
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.8),
                                  fontSize:
                                      isTablet ? 13 : (isSmallScreen ? 10 : 11),
                                  fontWeight:
                                      controller.selectedCategory.value ==
                                              category
                                          ? AppFonts.bold
                                          : AppFonts.medium,
                                ),
                              ),
                            )),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersGrid(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchStoreOffers(),
      color: AppColors.primary,
      backgroundColor: Color(0xFF0A0A0A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isTablet = screenWidth > 600;
          final isLargeTablet = screenWidth > 900;
          final horizontalPadding = isTablet ? 32.0 : 16.0;

          int crossAxisCount = 2;
          if (isLargeTablet) {
            crossAxisCount = 3;
          }

          double childAspectRatio = 0.75;
          if (isLargeTablet) {
            childAspectRatio = 0.7;
          } else if (isTablet) {
            childAspectRatio = 0.75;
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Obx(() {
              final offers = controller.filteredOffers;

              if (offers.isEmpty) {
                return _buildNoResultsState(context);
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: isTablet ? 16 : 12,
                  mainAxisSpacing: isTablet ? 20 : 16,
                ),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                itemCount: offers.length,
                itemBuilder: (context, index) =>
                    _buildOfferCard(context, offers[index]),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferModel offer) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isLargeTablet = mediaQuery.size.width > 900;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة العرض
          _buildOfferImage(context, offer),
    
          // محتوى العرض
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 14 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان العرض
                  Expanded(
                    flex: 2,
                    child: Text(
                      offer.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeTablet ? 16 : (isTablet ? 15 : 14),
                        fontWeight: AppFonts.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
    
                  SizedBox(height: 8),
    
                  // السعر والخصم
                  Row(
                    children: [
                      // السعر بعد الخصم
                      Text(
                        '${offer.priceAfterDiscount.toStringAsFixed(0)} ${controller.getCurrencySymbol(offer.priceType) ?? 'ل.س'}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: isLargeTablet ? 16 : (isTablet ? 15 : 14),
                          fontWeight: AppFonts.bold,
                        ),
                      ),
    
                      SizedBox(width: 8),
    
                      // السعر الأصلي مشطوب
                      if (offer.discount > 0)
                        Text(
                          '${offer.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: isTablet ? 12 : 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
    
                  SizedBox(height: 4),
    
                  // نسبة الخصم
                  if (offer.discount > 0)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Text(
                        '%${offer.discount} خصم',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: AppFonts.bold,
                        ),
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

  Widget _buildOfferImage(BuildContext context, OfferModel offer) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isLargeTablet = mediaQuery.size.width > 900;
    final imageHeight = isLargeTablet ? 160.0 : (isTablet ? 140.0 : 120.0);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // خلفية افتراضية
            Container(
              color: Color(0xFF1C1C1C),
              child: Center(
                child: Icon(
                  PhosphorIcons.tag,
                  color: Colors.white.withOpacity(0.3),
                  size: isTablet ? 40 : 30,
                ),
              ),
            ),

            // الصورة الحقيقية
            if (offer.mainImage.isNotEmpty)
              CachedNetworkImage(
                imageUrl: offer.mainImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Color(0xFF1C1C1C),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Color(0xFF1C1C1C),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.tag,
                      color: Colors.white.withOpacity(0.3),
                      size: isTablet ? 40 : 30,
                    ),
                  ),
                ),
              ),

            // شارة الفئة
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offer.category.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 11 : 10,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return ListView(
      children: [
        SizedBox(height: mediaQuery.size.height / 6),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isTablet ? 80 : 70,
                height: isTablet ? 80 : 70,
                decoration: BoxDecoration(
                  color: Color(0xFF1C1C1C),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    PhosphorIcons.tagBold,
                    color: Colors.white.withOpacity(0.4),
                    size: isTablet ? 40 : 35,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد عروض مطابقة للبحث',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 16 : 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 100 : 80,
            height: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: Color(0xFF151515),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                PhosphorIcons.tagBold,
                color: AppColors.primary.withOpacity(0.6),
                size: isTablet ? 45 : 40,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Text(
            'لا توجد عروض متاحة حالياً',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 20 : 18,
              fontWeight: AppFonts.medium,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'تحقق مرة أخرى لاحقاً للعروض الجديدة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isTablet ? 15 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshOffers(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20, vertical: isTablet ? 14 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary, width: 1),
              ),
              elevation: 0,
            ),
            icon: Icon(
              PhosphorIcons.arrowClockwise,
              size: isTablet ? 18 : 16,
            ),
            label: Text(
              'تحديث',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: AppFonts.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;
        final isLargeTablet = screenWidth > 900;
        final horizontalPadding = isTablet ? 32.0 : 16.0;

        int crossAxisCount = isLargeTablet ? 3 : 2;
        double childAspectRatio = 0.75;
        if (isLargeTablet) {
          childAspectRatio = 0.7;
        } else if (isTablet) {
          childAspectRatio = 0.75;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: isTablet ? 16 : 12,
              mainAxisSpacing: isTablet ? 20 : 16,
            ),
            padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
            itemCount: 6,
            itemBuilder: (_, __) => _buildOfferCardSkeleton(context),
          ),
        );
      },
    );
  }

  Widget _buildOfferCardSkeleton(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isLargeTablet = mediaQuery.size.width > 900;
    final imageHeight = isLargeTablet ? 160.0 : (isTablet ? 140.0 : 120.0);

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شكل الصورة
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

          // شكل المحتوى
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 14 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // شكل العنوان
                  Container(
                    height: isLargeTablet ? 16 : (isTablet ? 15 : 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF252525),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  SizedBox(height: 8),

                  // شكل السعر
                  Container(
                    height: isLargeTablet ? 16 : (isTablet ? 15 : 14),
                    width: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF202020),
                      borderRadius: BorderRadius.circular(3),
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
}
