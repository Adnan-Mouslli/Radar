import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/controller/stores/StoresController.dart';
import 'package:radar/core/class/statusrequest.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:radar/data/model/Store.dart';
import 'package:radar/view/pages/home/NetworkErrorSkeleton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StoresScreen extends StatelessWidget {
  final StoresController controller = Get.put(StoresController());
  
  // إضافة متغير محلي للـ selected city
  final RxString localSelectedCity = ''.obs;

  @override
  Widget build(BuildContext context) {
    // تهيئة المتغير المحلي
    if (localSelectedCity.value.isEmpty && controller.cities.isNotEmpty) {
      localSelectedCity.value = controller.selectedCity.value;
    }
    
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.statusRequest.value == StatusRequest.loading) {
            return _buildLoadingState(context);
          } else if (controller.statusRequest.value == StatusRequest.offlinefailure) {
            return NetworkErrorSkeleton(
              message: 'لا يوجد اتصال بالإنترنت',
              onRetry: () => controller.refreshStores(),
            );
          } else if (controller.statusRequest.value == StatusRequest.serverfailure) {
            return NetworkErrorSkeleton(
              message: 'حدث خطأ في الاتصال بالخادم',
              onRetry: () => controller.refreshStores(),
            );
          } else if (controller.statusRequest.value == StatusRequest.failure || 
                   controller.stores.isEmpty) {
            return _buildEmptyState(context);
          } else {
            return _buildStoresGrid(context);
          }
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 650;
    
    // حل نهائي للـ overflow - ارتفاعات محسوبة بدقة
    final toolbarHeight = isSmallScreen ? 40.0 : 50.0;
    final searchBarHeight = isSmallScreen ? 34.0 : 40.0;
    final citiesHeight = isSmallScreen ? 28.0 : 34.0;
    final bottomHeight = isSmallScreen ? 68.0 : 80.0; // تقليل كبير
    
    return AppBar(
      backgroundColor: Color(0xFF0A0A0A),
      elevation: 0,
      toolbarHeight: toolbarHeight,
      title: Text(
        'المتاجر',
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 24 : (isSmallScreen ? 17 : 20),
          fontWeight: AppFonts.bold,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(bottomHeight),
        child: SizedBox(
          width: double.infinity,
          height: bottomHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط البحث محسن
              _buildSearchBar(context, searchBarHeight),
              SizedBox(height: 4), // تقليل المسافة
              // شريط تصفية المدن محسن
              _buildCitiesFilter(context, citiesHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double height) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = mediaQuery.size.height < 650;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 1, horizontalPadding, 1),
      child: Container(
        height: height,
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 15 : (isSmallScreen ? 12 : 13),
            fontWeight: AppFonts.medium,
          ),
          onChanged: controller.updateSearchQuery,
          decoration: InputDecoration(
            hintText: 'ابحث عن متجر...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: isTablet ? 15 : (isSmallScreen ? 12 : 13),
              fontWeight: AppFonts.regular,
            ),
            prefixIcon: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                PhosphorIcons.magnifyingGlass,
                color: AppColors.primary.withOpacity(0.8),
                size: isTablet ? 18 : (isSmallScreen ? 14 : 16),
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12, 
              vertical: 8
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCitiesFilter(BuildContext context, double height) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = mediaQuery.size.height < 650;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 1),
      child: Obx(() {
        // تحديث المتغير المحلي إذا تغير controller
        if (localSelectedCity.value != controller.selectedCity.value) {
          localSelectedCity.value = controller.selectedCity.value;
        }
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.cities.length,
          itemBuilder: (context, index) {
            final city = controller.cities[index];
            final isSelected = localSelectedCity.value == city;
            
            return Padding(
              padding: EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () {
                  // تحديث فوري للمتغير المحلي
                  localSelectedCity.value = city;
                  // تحديث الـ controller
                  controller.selectedCity.value = city;
                  // استدعاء دالة التغيير
                  controller.changeCity(city);
                },
                child: Obx(() => AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 10,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: localSelectedCity.value == city
                        ? AppColors.primary 
                        : Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: localSelectedCity.value == city
                          ? AppColors.primary 
                          : Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: localSelectedCity.value == city ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    city,
                    style: TextStyle(
                      color: localSelectedCity.value == city
                          ? Colors.white 
                          : Colors.white.withOpacity(0.8),
                      fontSize: isTablet ? 13 : (isSmallScreen ? 10 : 11),
                      fontWeight: localSelectedCity.value == city ? AppFonts.bold : AppFonts.medium,
                    ),
                  ),
                )),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStoresGrid(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchStores(),
      color: AppColors.primary,
      backgroundColor: Color(0xFF0A0A0A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isTablet = screenWidth > 600;
          final isLargeTablet = screenWidth > 900;
          final horizontalPadding = isTablet ? 32.0 : 16.0;
          
          // تحديد عدد الأعمدة
          int crossAxisCount = 2;
          if (isLargeTablet) {
            crossAxisCount = 3;
          }
          
          // تحسين نسبة الأبعاد للايباد - حل قوي للمسافات
          double childAspectRatio = 0.95;
          if (isLargeTablet) {
            childAspectRatio = 0.65; // تقليل كبير للشاشات الكبيرة
          } else if (isTablet) {
            childAspectRatio = 0.60; // تقليل كبير للايباد العادي
          }
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Obx(() {
              final stores = controller.filteredStores;
              
              if (stores.isEmpty) {
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
                itemCount: stores.length,
                itemBuilder: (context, index) => _buildStoreCard(context, stores[index]),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    
    return ListView(
      children: [
        SizedBox(height: mediaQuery.size.height / 4),
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
                    PhosphorIcons.storefrontBold,
                    color: Colors.white.withOpacity(0.4),
                    size: isTablet ? 40 : 35,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد متاجر مطابقة للبحث',
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

  Widget _buildStoreCard(BuildContext context, Store store) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isLargeTablet = mediaQuery.size.width > 900;
    final isSmallScreen = mediaQuery.size.height < 650;
    
    return GestureDetector(
      onTap: () => controller.openStoreDetails(store),
      child: Container(
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
            // صورة المتجر
            _buildStoreImage(context, store),
            
            // محتوى المتجر - حل جذري لمشكلة المسافات
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 16 : 12, 
                  isTablet ? 16 : 12,
                  isTablet ? 16 : 12, 
                  isTablet ? 12 : 10, // تقليل bottom padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المتجر - مساحة محددة
                    Expanded(
                      flex: isTablet ? 3 : 2, // مساحة أكبر للايباد
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          store.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLargeTablet ? 18 : (isTablet ? 17 : (isSmallScreen ? 14 : 15)),
                            fontWeight: AppFonts.bold,
                            letterSpacing: 0.1,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    
                    // المدينة - مساحة ثابتة في الأسفل
                    Container(
                      height: isTablet ? 24 : 20, // ارتفاع ثابت
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.mapPin,
                            color: AppColors.primary.withOpacity(0.7),
                            size: isLargeTablet ? 16 : (isTablet ? 15 : 12),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              store.city,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isLargeTablet ? 15 : (isTablet ? 14 : (isSmallScreen ? 11 : 12)),
                                fontWeight: AppFonts.medium,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreImage(BuildContext context, Store store) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isLargeTablet = mediaQuery.size.width > 900;
    // زيادة ارتفاع الصورة بشكل كبير للايباد لملء المساحة
    final imageHeight = isLargeTablet ? 200.0 : (isTablet ? 190.0 : 120.0);
    
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
                  PhosphorIcons.storefrontBold,
                  color: Colors.white.withOpacity(0.3),
                  size: isLargeTablet ? 50 : (isTablet ? 45 : 35),
                ),
              ),
            ),
            
            // الصورة الحقيقية
            if (store.image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: store.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Color(0xFF1C1C1C),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Color(0xFF1C1C1C),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.storefrontBold,
                      color: Colors.white.withOpacity(0.3),
                      size: isLargeTablet ? 50 : (isTablet ? 45 : 35),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
        // تطبيق نفس نسب الأبعاد
        double childAspectRatio = 0.95;
        if (isLargeTablet) {
          childAspectRatio = 0.65;
        } else if (isTablet) {
          childAspectRatio = 0.60;
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
            itemBuilder: (_, __) => _buildStoreCardSkeleton(context),
          ),
        );
      },
    );
  }
  
  Widget _buildStoreCardSkeleton(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isLargeTablet = mediaQuery.size.width > 900;
    // تطبيق نفس ارتفاع الصورة
    final imageHeight = isLargeTablet ? 200.0 : (isTablet ? 190.0 : 120.0);
    
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
                  // شكل اسم المتجر
                  Container(
                    height: isLargeTablet ? 18 : (isTablet ? 17 : 14),
                    width: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFF252525),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  
                  // شكل المدينة
                  Container(
                    height: isLargeTablet ? 15 : (isTablet ? 14 : 12),
                    width: 80,
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
                PhosphorIcons.storefrontBold,
                color: AppColors.primary.withOpacity(0.6),
                size: isTablet ? 45 : 40,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Text(
            'لا توجد متاجر متاحة حالياً',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 20 : 18,
              fontWeight: AppFonts.medium,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'يرجى المحاولة مرة أخرى لاحقاً',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isTablet ? 15 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshStores(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 20, 
                vertical: isTablet ? 14 : 12
              ),
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
}