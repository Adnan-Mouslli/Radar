import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/data/model/OfferModel.dart';
import 'package:radar/data/model/ProvidenceModel.dart';
import 'package:radar/controller/OffersRadar/OffersRadarController.dart';

class OffersRadarScreen extends StatelessWidget {
  final OffersRadarController controller = Get.put(OffersRadarController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                  Icons.radar,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Obx(() {
                  String locationInfo = "";
                  if (controller.selectedProvidence.value?.id !=
                      'CURRENT_LOCATION') {
                    locationInfo =
                        " (${controller.selectedProvidence.value!.name})";
                  }

                  return Text(
                    'رادار العروض$locationInfo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: AppFonts.bold,
                    ),
                  );
                }),
              ),
              Spacer(),
              IconButton(
                onPressed: _showFilterDialog,
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
                tooltip: 'الفلترة والفرز',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
              ),
            ],
          ),
          Obx(() {
            if (controller.selectedProvidence.value?.id == 'CURRENT_LOCATION') {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.explore,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'نطاق البحث:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildCompactRadiusSelector(),
                  ],
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCompactRadiusSelector() {
    final List<double> allowedValues = [
      0.5,
      1.0,
      1.5,
      2.0,
      2.5,
      3.0,
      3.5,
      4.0,
      4.5,
      5.0
    ];

    return Obx(() {
      double currentValue = controller.currentRadius.value;

      if (!allowedValues.contains(currentValue)) {
        double closestValue = allowedValues.reduce((a, b) =>
            (a - currentValue).abs() < (b - currentValue).abs() ? a : b);
        Future.microtask(() => controller.currentRadius.value = closestValue);
        currentValue = closestValue;
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: DropdownButton<double>(
          value: currentValue,
          underline: SizedBox(),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.primary,
            size: 18,
          ),
          dropdownColor: Colors.grey[900],
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: AppFonts.medium,
          ),
          isDense: true,
          items: allowedValues.map((double value) {
            return DropdownMenuItem<double>(
              value: value,
              child: Text('${value.toStringAsFixed(1)} كم'),
            );
          }).toList(),
          onChanged: (double? newValue) {
            if (newValue != null) {
              controller.changeRadius(newValue, isTemp: false);
            }
          },
        ),
      );
    });
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // الخلفية الأساسية
        _buildMainBackground(),

        // محتوى الصفحة
        Obx(() {
          // إضافة شرط جديد: إذا كان في حالة عرض الرادار، نظهر الرادار
          if (controller.isShowingRadarAnimation.value) {
            return _buildWelcomeScreen();
          } else if (controller.discoveredOffers.isEmpty) {
            return _buildWelcomeScreen();
          } else {
            return _buildOffersListView();
          }
        }),

        // رسالة الموقع عندما لا يوجد موقع
        Obx(() {
          if (controller.userLocation.value == null &&
              !controller.isLoading.value) {
            return _buildLocationMessage();
          }
          return SizedBox();
        }),

        // تم إزالة طبقة التعتيم عند البحث
      ],
    );
  }

  Widget _buildMainBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xFF101010),
            Colors.black,
          ],
          radius: 1.0,
          center: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // رادار متحرك عند البحث أو ثابت في الوضع العادي
            Obx(() {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: controller.isScanning.value ||
                        controller.isShowingRadarAnimation.value
                    ? _buildActiveRadar()
                    : _buildStaticRadar(),
              );
            }),

            SizedBox(height: 40),

            // معلومات التطبيق - تظهر فقط عندما لا يكون في وضع المسح
            // وتختفي عندما يكون هناك عروض ولم يكن في وضع البحث
            Obx(() {
              bool showWelcomeBox = !(controller.isScanning.value ||
                      controller.isShowingRadarAnimation.value) &&
                  controller.discoveredOffers.isEmpty;

              return AnimatedOpacity(
                opacity: showWelcomeBox ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "اكتشف العروض القريبة منك",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeatureItem(Icons.location_on, "حدد موقعك"),
                          SizedBox(width: 20),
                          _buildFeatureItem(Icons.search, "ابحث عن العروض"),
                          SizedBox(width: 20),
                          _buildFeatureItem(Icons.local_offer, "وفر أموالك"),
                        ],
                      ),
                      SizedBox(height: 24),
                      // زر البدء - إخفاءه عندما تكون هناك عروض بالفعل
                      if (controller.discoveredOffers.isEmpty)
                        ElevatedButton(
                          onPressed: () => controller.scanForOffers(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.radar, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'ابدأ البحث',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticRadar() {
    return Container(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الدوائر الخارجية
          ...List.generate(4, (index) {
            final radius = 135.0 - index * 30.0;
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1 + index * 0.05),
                  width: 1.5,
                ),
              ),
            );
          }),

          // خطوط الاتجاهات
          CustomPaint(
            size: Size(260, 260),
            painter: RadarDirectionsPainter(),
          ),

          // نقطة المركز النابضة
          PulsingDot(
            color: AppColors.primary,
            size: 10,
          ),

          // إضافة بعض النقاط العشوائية الثابتة لتمثيل العروض
          ...List.generate(5, (index) {
            final random = math.Random(index * 100);
            final angle = random.nextDouble() * math.pi * 2;
            final distance = 30.0 + random.nextDouble() * 90.0;
            final x = distance * math.cos(angle);
            final y = distance * math.sin(angle);
            final size = 4.0 + random.nextDouble() * 4.0;

            return Positioned(
              left: 135 + x - size / 2,
              top: 135 + y - size / 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveRadar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // تحسين تصميم الرادار ليكون متناسقًا مع الرادار الثابت
        Container(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // دوائر الرادار الخلفية
              ...List.generate(4, (index) {
                final radius = 135.0 - index * 30.0;
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1 + index * 0.05),
                      width: 1.5,
                    ),
                  ),
                );
              }),

              // خطوط الاتجاهات
              CustomPaint(
                size: Size(260, 260),
                painter: RadarDirectionsPainter(),
              ),

              // خط المسح الدوار
              RadarSweepAnimation(
                size: 260,
                duration: Duration(seconds: 3),
              ),

              // نقطة المركز النابضة
              PulsingDot(
                color: AppColors.primary,
                size: 14,
                pulseSpeed: 1.2,
              ),

              // نقاط العثور على العروض المحاكاة
              Obx(() {
                if (controller.isScanning.value &&
                    controller.hasFoundOffers.value) {
                  return SimulatedDiscoveryDots(
                    radarSize: 240,
                  );
                } else {
                  return SizedBox();
                }
              }),
            ],
          ),
        ),

        SizedBox(height: 20),

        // تحسين تصميم مربع الرسالة
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                AppColors.primary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Obx(() {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: controller.showSuccessMessage.value
                      ? Text(
                          controller.hasFoundOffers.value
                              ? 'تم اكتشاف العروض بنجاح!'
                              : 'لم يتم العثور على عروض',
                          key: ValueKey(controller.showSuccessMessage.value),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : // تعديل طريقة عرض النص لمنع التكسير
                      // استخدام Wrap بدلاً من Row لمنع تكسير النص
                      Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'جاري البحث عن العروض',
                              key: ValueKey('searching'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            ScanningDots(), // إضافة نقاط متحركة عند البحث
                          ],
                        ),
                );
              }),
              SizedBox(height: 8),
              Obx(() {
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    controller.showSuccessMessage.value
                        ? controller.hasFoundOffers.value
                            ? 'يمكنك استعراض العروض الآن'
                            : 'حاول زيادة نطاق البحث أو تغيير الفئة'
                        : 'قد يستغرق البحث بضع ثوانٍ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMessage() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(32),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 20),
                Text(
                  'تحديد الموقع غير متاح',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: AppFonts.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'نحتاج إلى إذن الوصول إلى موقعك للبحث عن العروض القريبة منك.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.showLocationPermissionDialog();
                  },
                  icon: Icon(Icons.location_on),
                  label: Text('السماح بالوصول للموقع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOffersListView() {
    return Column(
      children: [
        // _buildFilterBar(),
        Expanded(
          child: Obx(() {
            final nearbyOffers = controller.getFilteredOffers();

            if (nearbyOffers.isEmpty) {
              return _buildEmptyOffersView();
            }

            // Grid mejorado con dos columnas para mostrar ofertas
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8, // تحسين النسبة لتجنب المساحات الفارغة
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: nearbyOffers.length,
                itemBuilder: (context, index) {
                  return _buildOfferGridItem(nearbyOffers[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOfferGridItem(OfferModel offer) {
    return InkWell(
      onTap: () => controller.showOfferDetails(offer),
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المنتج
              Expanded(
                flex: 6, // تخصيص 60% من المساحة للصورة
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // الصورة الرئيسية
                      Positioned.fill(
                        child: offer.mainImage.isNotEmpty
                            ? Image.network(
                                offer.mainImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[850],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white.withOpacity(0.3),
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[850],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 30,
                                ),
                              ),
                      ),

                      // تدرج لتحسين وضوح العناصر
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                              stops: [0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // بطاقة الخصم
                      if (offer.discount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade600,
                                  Colors.red.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade700.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${offer.discount}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                      // شعار المتجر
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              offer.store.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: Icon(
                                    Icons.store,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 14,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // معلومات العرض - تصميم جديد ومحسن
              Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عنوان العرض
                    Text(
                      offer.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: cardWidth < 150 ? 12 : 14,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    // اسم المتجر
                    Text(
                      offer.store.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: cardWidth < 150 ? 10 : 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    // الأسعار - تصميم نظيف ومباشر
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // السعر الحالي
                        Text(
                          '${offer.formattedPriceAfterDiscount} ${controller.getCurrencySymbol(offer.priceType)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: cardWidth < 150 ? 13 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        // السعر الأصلي والتوفير (إذا وجد خصم)
                        if (offer.discount > 0) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              // السعر الأصلي
                              Text(
                                '${offer.formattedPrice} ${controller.getCurrencySymbol(offer.priceType)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: cardWidth < 150 ? 10 : 11,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor:
                                      Colors.redAccent.withOpacity(0.8),
                                  decorationThickness: 1.5,
                                ),
                              ),

                              SizedBox(width: 8),

                              // نص التوفير
                              Expanded(
                                child: Text(
                                  'وفر ${((offer.price - offer.priceAfterDiscount)).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: cardWidth < 150 ? 8 : 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 6),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Obx(() {
            final nearbyOffers = controller.getFilteredOffers();
            return Text(
              'العروض (${nearbyOffers.length})',
              style: TextStyle(
                fontWeight: AppFonts.bold,
                fontSize: 15,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            );
          }),
          Spacer(),
          // Botón de filtrado más compacto
          InkWell(
            onTap: () => _showFilterDialog(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'تصفية',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

  Widget _buildEmptyOffersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Obx(() {
                  return Text(
                    controller.getEmptyStateMessage(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: AppFonts.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
                SizedBox(height: 12),
                Obx(() {
                  String suggestionText = "حاول ";

                  if (controller.selectedProvidence.value?.id ==
                      'CURRENT_LOCATION') {
                    suggestionText += "زيادة نطاق البحث أو ";
                  }

                  suggestionText += "تغيير الفئة المحددة";

                  if (controller.selectedProvidence.value?.id !=
                      'CURRENT_LOCATION') {
                    suggestionText += " أو تغيير المدينة";
                  }

                  suggestionText += " للعثور على المزيد من العروض";

                  return Text(
                    suggestionText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.scanForOffers,
                    icon: Icon(Icons.refresh, size: 20),
                    label: Text(
                      'إعادة البحث',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'مطاعم':
      case 'طعام':
        return Icons.restaurant;
      case 'مشروبات':
        return Icons.local_drink;
      case 'كافيهات':
      case 'قهوة':
        return Icons.coffee;
      case 'تسوق':
      case 'أزياء':
        return Icons.shopping_bag;
      case 'إلكترونيات':
        return Icons.devices;
      case 'صحة وجمال':
        return Icons.face;
      case 'رياضة':
        return Icons.sports_basketball;
      case 'ترفيه':
        return Icons.movie;
      case 'خدمات':
        return Icons.build;
      case 'سيارات':
        return Icons.directions_car;
      case 'عقارات':
        return Icons.home;
      case 'تعليم':
        return Icons.school;
      case 'سفر':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      final hasOffers = controller.discoveredOffers.isNotEmpty;
      final isShowingRadar = controller.isShowingRadarAnimation.value;

      return Stack(
        children: [
          FloatingActionButton(
            onPressed: isShowingRadar
                ? null
                : () {
                    // إذا كانت هناك عروض، نقوم بإجراء تبديل للعرض
                    if (hasOffers) {
                      // إعادة ضبط واجهة الرادار - إضافة هذا الكود
                      controller.resetRadarView();
                      // ثم بدء البحث
                      controller.scanForOffers();
                    } else {
                      // مجرد بدء البحث إذا لم تكن هناك عروض
                      controller.scanForOffers();
                    }
                  },
            backgroundColor:
                isShowingRadar ? Colors.grey.shade800 : AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            tooltip: isShowingRadar
                ? 'جاري البحث...'
                : (hasOffers ? 'تحديث البحث' : 'بدء البحث'),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: isShowingRadar
                  ? Stack(
                      key: ValueKey('loading'),
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        Icon(
                          Icons.radar,
                          size: 26,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    )
                  : Icon(
                      hasOffers ? Icons.refresh : Icons.search,
                      size: 28,
                      key: ValueKey(hasOffers ? 'refresh' : 'search'),
                    ),
            ),
          ),
          if (_hasFilterChanges() && !isShowingRadar)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 5,
                  height: 5,
                ),
              ),
            ),
        ],
      );
    });
  }

  bool _hasFilterChanges() {
    // التحقق من التغييرات في المدينة المحددة
    final defaultProvidence = controller.providences.first;
    final hasProvidenceChanges =
        controller.selectedProvidence.value?.id != defaultProvidence.id;

    // التحقق من تحديد فئة محددة غير "الكل"
    final hasCategoryChanges = controller.selectedCategoryId.value.isNotEmpty;

    // التحقق مما إذا كان نطاق البحث ليس بقيمته الافتراضية (1.0)
    final hasRadiusChanges = controller.currentRadius.value != 1.0;

    // التحقق مما إذا كان الترتيب ليس في حالته الافتراضية (المسافة، تصاعدي)
    final hasSortingChanges = controller.sortBy.value != 'distance' ||
        controller.descendingOrder.value != false;

    return hasProvidenceChanges ||
        hasCategoryChanges ||
        hasRadiusChanges ||
        hasSortingChanges;
  }

  void _showFilterDialog() {
    // تهيئة القيم المؤقتة
    controller.initTempFilters();

    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: Get.width * 0.9,
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان نافذة الحوار
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tune,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خيارات البحث',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // زر الإغلاق
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // قسم اختيار المدينة
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'البحث في مدينة:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

// قائمة المدن بتصميم محسن
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 150,
                      maxHeight: 180, // زيادة ارتفاع القائمة قليلاً
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Get.width > 400 ? 3 : 2,
                        childAspectRatio: 2.6,
                        crossAxisSpacing: 10, // زيادة المسافة بين المدن
                        mainAxisSpacing: 10,
                      ),
                      itemCount: controller.providences.length,
                      itemBuilder: (context, index) {
                        final providence = controller.providences[index];
                        return _buildSimplifiedProvidenceOption(providence);
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // يظهر محدد نطاق البحث فقط إذا كان موقعي الحالي محدداً
                  Obx(() {
                    if (controller.tempSelectedProvidence.value?.id ==
                        'CURRENT_LOCATION') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // محدد نطاق البحث
                          _buildEnhancedRadiusSelector(),
                          SizedBox(height: 20),
                        ],
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),

                  // قسم التصفية حسب الفئة
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'تصفية حسب الفئة:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

                  // شبكة اختيار الفئات - تم زيادة الارتفاع
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 200, // زيادة الارتفاع لعرض المزيد من الفئات
                      maxHeight: 250, // حد أقصى للارتفاع
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Get.width > 400 ? 3 : 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 10, // زيادة المسافة بين الفئات
                        mainAxisSpacing: 10,
                      ),
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        return _buildEnhancedCategoryOption(
                            category); // استخدام الدالة المحسنة
                      },
                    ),
                  ),

                  SizedBox(height: 24),

                  // قسم الترتيب
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ترتيب العروض حسب:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // خيارات الترتيب
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildSimplifiedSortOption('distance',
                            'المسافة (الأقرب أولاً)', Icons.near_me_rounded),
                        Divider(
                            height: 1, color: Colors.white.withOpacity(0.1)),
                        _buildSimplifiedSortOption(
                            'discount',
                            'نسبة الخصم (الأعلى أولاً)',
                            Icons.local_offer_outlined),
                        Divider(
                            height: 1, color: Colors.white.withOpacity(0.1)),
                        _buildSimplifiedSortOption(
                            'price',
                            'السعر (الأقل أولاً)',
                            Icons.monetization_on_outlined),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // أزرار الإلغاء والتطبيق
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الإلغاء
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ),

                      // زر التطبيق
                      ElevatedButton(
                        onPressed: () {
                          // تطبيق الفلاتر المؤقتة على الفلاتر الحقيقية
                          controller.applyTempFilters();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'تطبيق وبجث',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  // دالة بناء خيارات الترتيب في الفلتر
  Widget _buildSimplifiedSortOption(
      String sortValue, String label, IconData icon) {
    return Obx(() {
      // استخدام القيم المؤقتة للترتيب
      final isSelected = controller.tempSortBy.value == sortValue;
      final isDescending = controller.tempDescendingOrder.value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // تبديل الترتيب بشكل مباشر
            if (controller.tempSortBy.value == sortValue) {
              controller.tempDescendingOrder.toggle();
            } else {
              controller.tempSortBy.value = sortValue;
              controller.tempDescendingOrder.value = false;
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight:
                          isSelected ? AppFonts.medium : AppFonts.regular,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 3. نسخة محسنة من محدد نطاق البحث حيث تبدأ الدوائر من الداخل للخارج
  Widget _buildEnhancedRadiusSelector() {
    final List<double> allowedValues = [
      0.5,
      1.0,
      1.5,
      2.0,
      2.5,
      3.0,
      3.5,
      4.0,
      4.5,
      5.0
    ];

    return Obx(() {
      // استخدام القيمة المؤقتة لنطاق البحث
      double radius = controller.tempCurrentRadius.value;

      // إذا لم تكن القيمة موجودة في القائمة، استخدم أقرب قيمة
      if (!allowedValues.contains(radius)) {
        // البحث عن أقرب قيمة في القائمة
        radius = allowedValues
            .reduce((a, b) => (a - radius).abs() < (b - radius).abs() ? a : b);

        // تحديث القيمة المؤقتة في الكونترولر
        Future.microtask(() => controller.tempCurrentRadius.value = radius);
      }

      return Container(
        margin: EdgeInsets.only(top: 4, bottom: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            // معلومات المسافة - تغيير التصميم لتفادي مشكلة التكسير
            Row(
              children: [
                // أيقونة ونص المسافة
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.explore,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نطاق البحث',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${radius.toStringAsFixed(1)} كم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Spacer(), // إضافة Spacer لدفع وصف المسافة للطرف الآخر

                // وصف المسافة - الآن على يسار الشاشة
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getRadiusDescription(radius),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // عرض مرئي للمسافة - بدون أرقام في وسط الدوائر
            LayoutBuilder(builder: (context, constraints) {
              // الحصول على عرض النافذة الحالي
              final maxWidth = constraints.maxWidth;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // دوائر المسافة - بدون أرقام في وسط الدوائر
                  ...List.generate(5, (index) {
                    // عدد الدوائر 5 بما يتناسب مع القيم
                    final radiusValue = (index + 1) * 1.0;
                    final isActive = radius >= radiusValue;

                    // تعديل حجم كل دائرة لتكون متدرجة من الداخل للخارج
                    final size = 60 + index * 40;

                    return Container(
                      width: size.toDouble(),
                      height: size.toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.7 - index * 0.1)
                              : Colors.white.withOpacity(0.1),
                          width: isActive ? 1.5 : 0.8,
                        ),
                      ),
                    );
                  }),

                  // النقطة المركزية
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),

                  // خطوط استدلالية
                  CustomPaint(
                    size: Size(maxWidth, maxWidth * 0.5),
                    painter: SimpleRadarPainter(color: AppColors.primary),
                  ),
                ],
              );
            }),

            SizedBox(height: 8),

            // شريط تمرير المسافة مع تحسين في الشكل
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white.withOpacity(0.1),
                thumbColor: Colors.white,
                overlayColor: AppColors.primary.withOpacity(0.2),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
              ),
              child: Slider(
                value: radius,
                min: 0.5,
                max: 5.0,
                divisions: allowedValues.length - 1,
                onChanged: (value) {
                  // البحث عن أقرب قيمة في القائمة المسموح بها
                  double closestValue = allowedValues.reduce(
                      (a, b) => (a - value).abs() < (b - value).abs() ? a : b);

                  // تحديث القيمة المؤقتة مباشرة
                  controller.tempCurrentRadius.value = closestValue;
                },
              ),
            ),

            // مؤشرات شريط التمرير مع تحسين في الشكل
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '0.5 كم',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '5 كم',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

// 4. وصف محسن لنطاق البحث
  String _getRadiusDescription(double radius) {
    if (radius <= 1.0) {
      return 'قريب جداً';
    } else if (radius <= 2.0) {
      return 'قريب';
    } else if (radius <= 3.0) {
      return 'متوسط';
    } else if (radius <= 4.0) {
      return 'بعيد';
    } else {
      return 'بعيد جداً';
    }
  }

// 5. تحسين طريقة عرض خيارات المدن
  Widget _buildSimplifiedProvidenceOption(ProvidenceModel providence) {
    return Obx(() {
      // استخدام القيمة المؤقتة للمدينة للتحقق من الاختيار
      final isSelected =
          controller.tempSelectedProvidence.value?.id == providence.id;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.changeProvidence(providence, isTemp: true);
          },
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    Icon(
                      providence.id == 'CURRENT_LOCATION'
                          ? Icons.my_location
                          : Icons.check_circle,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  if (isSelected) SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      providence.name,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEnhancedCategoryOption(CategoryModel category) {
    return Obx(() {
      // استخدام القيمة المؤقتة للفئة
      final isSelected = controller.tempSelectedCategoryId.value == category.id;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // استخدام المتغيرات المؤقتة فقط داخل الفلتر
            controller.tempSelectedCategoryId.value = category.id;
            controller.tempSelectedCategoryName.value = category.name;
          },
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    if (isSelected) SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.8),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Widget مخصص لرسم اتجاهات الرادار
class RadarDirectionsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // رسم خطوط الاتجاهات
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // رسم خطوط الاتجاهات الرئيسية
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX + radius * math.cos(angle),
            centerY + radius * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// رسام الرادار البسيط
class SimpleRadarPainter extends CustomPainter {
  final Color color;

  SimpleRadarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // خطوط الاستدلال
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // خط أفقي
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // خط رأسي
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // خطوط قطرية
    canvas.drawLine(
      Offset(centerX - centerX * 0.7, centerY - centerY * 0.7),
      Offset(centerX + centerX * 0.7, centerY + centerY * 0.7),
      paint..color = color.withOpacity(0.2),
    );

    canvas.drawLine(
      Offset(centerX - centerX * 0.7, centerY + centerY * 0.7),
      Offset(centerX + centerX * 0.7, centerY - centerY * 0.7),
      paint..color = color.withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget للخط المتحرك في الرادار
class RadarSweepAnimation extends StatefulWidget {
  final double size;
  final Duration duration;

  const RadarSweepAnimation({
    Key? key,
    required this.size,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _RadarSweepAnimationState createState() => _RadarSweepAnimationState();
}

class _RadarSweepAnimationState extends State<RadarSweepAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: RadarSweepPainter(
            progress: _controller.value,
            color: AppColors.primary,
          ),
        );
      },
    );
  }
}

class RadarSweepPainter extends CustomPainter {
  final double progress;
  final Color color;

  RadarSweepPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // الزاوية المحسوبة من التقدم
    final angle = 2 * math.pi * progress;

    // رسم شعاع الرادار
    final radarLinePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // رسم خط الرادار
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      ),
      radarLinePaint,
    );

    // رسم الشعاع المتلاشي
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.4),
        ],
        stops: [0.0, 1.0],
        startAngle: 0,
        endAngle: math.pi / 2,
        transform: GradientRotation(angle - math.pi / 4),
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ));

    // رسم شعاع المسح
    final sweepPath = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(centerX + radius * math.cos(angle),
          centerY + radius * math.sin(angle))
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        angle,
        math.pi / 4,
        false,
      )
      ..lineTo(centerX, centerY);

    canvas.drawPath(sweepPath, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Widget للنقطة النابضة
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  final double pulseSpeed;

  const PulsingDot({
    Key? key,
    required this.color,
    this.size = 15,
    this.pulseSpeed = 1.0,
  }) : super(key: key);

  @override
  _PulsingDotState createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / widget.pulseSpeed).round()),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * _animation.value,
          height: widget.size * _animation.value,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.7),
                blurRadius: 10 * _animation.value,
                spreadRadius: 3 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget for the spinning radar line
class RadarScanLine extends StatefulWidget {
  final Color color;
  final Duration scanDuration;

  const RadarScanLine({
    Key? key,
    required this.color,
    this.scanDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _RadarScanLineState createState() => _RadarScanLineState();
}

class _RadarScanLineState extends State<RadarScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.scanDuration,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(200, 200),
          painter: RadarScanPainter(
            angle: _controller.value * 2 * math.pi,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class RadarScanPainter extends CustomPainter {
  final double angle;
  final Color color;

  RadarScanPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Radar scan line
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      ),
      paint,
    );

    // Scan arc with fade effect
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.3),
        ],
        stops: [0.0, 1.0],
        startAngle: 0,
        endAngle: math.pi / 2,
        transform: GradientRotation(angle - math.pi / 2),
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ))
      ..style = PaintingStyle.fill;

    final arcRect = Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    );

    canvas.drawArc(
      arcRect,
      angle - math.pi / 4,
      math.pi / 2,
      true,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(RadarScanPainter oldDelegate) =>
      angle != oldDelegate.angle;
}

// Simulated Discovery Dots
class SimulatedDiscoveryDots extends StatefulWidget {
  final double radarSize;

  const SimulatedDiscoveryDots({
    Key? key,
    required this.radarSize,
  }) : super(key: key);

  @override
  _SimulatedDiscoveryDotsState createState() => _SimulatedDiscoveryDotsState();
}

class _SimulatedDiscoveryDotsState extends State<SimulatedDiscoveryDots> {
  final List<Map<String, dynamic>> _dots = [];
  final Random _random = Random();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAddingDots();
  }

  void _startAddingDots() {
    // إضافة نقطة كل 0.5-0.8 ثانية
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_dots.length < 10) {
        // زيادة عدد النقاط لتجربة أكثر جاذبية
        _addRandomDot();
      } else if (timer.tick > 20) {
        // إيقاف المؤقت بعد فترة معقولة
        _timer?.cancel();
      }
    });
  }

  void _addRandomDot() {
    // حساب موقع عشوائي داخل دائرة الرادار
    final angle = _random.nextDouble() * 2 * math.pi;
    final distance = 20.0 + _random.nextDouble() * (widget.radarSize / 2 - 40);

    setState(() {
      _dots.add({
        'x': distance * math.cos(angle),
        'y': distance * math.sin(angle),
        'opacity': 0.0,
        'size': 4.0 + _random.nextDouble() * 6.0, // حجم عشوائي بين 4-10
        'pulseSpeed': 0.8 + _random.nextDouble() * 0.7, // سرعة النبض
      });
    });

    // تحريك النقطة لتظهر بشكل تدريجي
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _dots.last['opacity'] = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _dots.map((dot) {
        return Positioned(
          left: widget.radarSize / 2 + dot['x'] - (dot['size'] / 2),
          top: widget.radarSize / 2 + dot['y'] - (dot['size'] / 2),
          child: AnimatedOpacity(
            opacity: dot['opacity'],
            duration: Duration(milliseconds: 800),
            child: PulsingDot(
              color: AppColors.primary,
              size: dot['size'],
              pulseSpeed: dot['pulseSpeed'],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ScanningDots extends StatefulWidget {
  @override
  _ScanningDotsState createState() => _ScanningDotsState();
}

class _ScanningDotsState extends State<ScanningDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 20, // ارتفاع ثابت للحاوية لضمان التوسيط العمودي
          child: Directionality(
            // ضمان اتجاه النص من اليمين إلى اليسار للتوافق مع اللغة العربية
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(3, (index) {
                // إنشاء تأخير للنقاط المتتالية
                final delay = index * 0.3;
                final animationValue = (_controller.value + delay) % 1.0;

                // قيمة الشفافية لكل نقطة
                final opacity = sin(animationValue * pi);

                return Container(
                  width: 5,
                  height: 5,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(opacity * 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
