import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_fork/cached_video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:radar/controller/home/reel_controller.dart';
import 'package:radar/core/theme/app_colors.dart';
import 'package:radar/core/theme/app_fonts.dart';
import 'package:radar/data/model/reel_model_api.dart';
import 'package:radar/view/pages/home/NetworkErrorSkeleton.dart';
import 'package:radar/view/pages/skeletons_/reel_skeleton.dart';

class ReelsScreen extends GetView<ReelsController> {
  final controllerApi = Get.put(ReelsController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            PageStorage(
              bucket: PageStorageBucket(),
              child: Obx(() {
                // إضافة شرط للتحقق من وجود بيانات الريلز المحملة مسبقًا
                if (controller.reels.isNotEmpty &&
                    !controller.isRefreshing.value &&
                    !controller.isLoading.value) {
                  // إذا كانت البيانات موجودة مسبقًا، عرض الريلز مباشرة بدون إنتظار التحميل
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (controller.pageController.page == 0) {
                        print("Refresh");
                        await controller.refreshReels();
                      }
                    },
                    color: AppColors.primary,
                    backgroundColor: Colors.black,
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: controller.pageController,
                      onPageChanged: controller.onReelPageChanged,
                      itemCount: controller.reels.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final reel = controller.reels[index];
                        return ReelItem(
                          reel: reel,
                          index: index,
                        );
                      },
                    ),
                  );
                } else if (controller.isRefreshing.value) {
                  // عرض مؤشر التحميل أثناء إعادة التحميل
                  return const ReelSkeleton();
                } else if (controller.isLoading.value) {
                  return const ReelSkeleton();
                } else if (controller.hasError.value) {
                  return NetworkErrorSkeleton(
                    message: controller.errorMessage.value,
                    onRetry: () => controller.refreshReels(),
                  );
                } else if (controller.reels.isEmpty) {
                  return const ReelSkeleton();
                } else {
                  // حالة وجود محتوى (لن نصل إلى هنا في العادة بسبب الشرط الأول)
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (controller.pageController.page == 0) {
                        print("Refresh");
                        await controller.refreshReels();
                      }
                    },
                    color: AppColors.primary,
                    backgroundColor: Colors.black,
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: controller.pageController,
                      onPageChanged: controller.onReelPageChanged,
                      itemCount: controller.reels.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final reel = controller.reels[index];
                        return ReelItem(
                          reel: reel,
                          index: index,
                        );
                      },
                    ),
                  );
                }
              }),
            ),

            // مؤشر تحميل المزيد في أسفل الشاشة
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Obx(() => controller.isLoadingMore.value
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // رسم متحرك أو رمز للخطأ
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => controller.refreshReels(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                "إعادة المحاولة",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReelItem extends GetView<ReelsController> {
  final Reel reel;
  final int index;

  const ReelItem({
    Key? key,
    required this.reel,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getMediaController(index);

    // تهيئة الفيديو فقط مرة واحدة عند عرض الريل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentReelIndex.value == index) {
        if (reel.mediaUrls.isNotEmpty) {
          if (reel.isVideoMedia(0)) {
            // استخدام صورة الغلاف عند تهيئة الفيديو
            final firstMedia = reel.mediaUrls[0];
            controller.initializeVideo(
                reel.id, firstMedia.url, firstMedia.poster);
          } else {
            // إذا كان صورة، ابدأ تتبع المشاهدة
            controller.startImageWatchTimer(index);
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // منطقة عرض الوسائط
              _buildMediaSection(),

              // تحسين الظل والتدرج
              _buildGradientOverlay(),

              // منطقة الاستجابة للنقر والسحب
              GestureDetector(
                onHorizontalDragEnd: (details) =>
                    controller.handleHorizontalDrag(
                        details, index, reel.mediaUrls.length),
                onDoubleTap: () => controller.handleDoubleTap(index),
                onTap: () {
                  if (reel.mediaUrls.isNotEmpty &&
                      reel.isVideoMedia(controller.currentMediaIndex.value)) {
                    controller.toggleVideoPlayback(reel.id);
                  }
                },
                child: Container(
                  color: Colors.transparent, // شفاف لالتقاط النقر
                ),
              ),

              // أزرار ومعلومات المحتوى
              _buildContentSection(),

              // إضافة زر كتم الصوت
              Obx(() {
                final currentMediaIndex = controller.currentMediaIndex.value;
                final isCurrentMediaVideo =
                    currentMediaIndex < reel.mediaUrls.length &&
                        reel.isVideoMedia(currentMediaIndex);

                // عرض زر كتم الصوت فقط إذا كان الوسائط الحالية فيديو
                return isCurrentMediaVideo
                    ? _buildMuteButton(context)
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuteButton(BuildContext context) {
    // الحصول على أبعاد الشاشة الحالية
    final screenSize = MediaQuery.of(context).size;

    // حساب المواقع النسبية (النسب المئوية من حجم الشاشة)
    final topPosition =
        screenSize.height * 0.05; // 5% من ارتفاع الشاشة من الأعلى
    final leftPosition = screenSize.width * 0.05; // 5% من عرض الشاشة من اليسار

    return Obx(() {
      final isMuted = controller.isMuted.value;

      return Positioned(
        top: topPosition,
        left: leftPosition,
        child: GestureDetector(
          onTap: () => controller.toggleMute(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    });
  }

  // منطقة عرض الوسائط
  Widget _buildMediaSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // عرض الوسائط كما هو الحال حاليًا
        SizedBox.expand(
          child: PageView.builder(
            controller: controller.getMediaController(index),
            physics: const BouncingScrollPhysics(),
            onPageChanged: controller.onMediaPageChanged,
            itemCount: reel.mediaUrls.length,
            itemBuilder: (context, mediaIndex) {
              if (mediaIndex < reel.mediaUrls.length) {
                final media = reel.mediaUrls[mediaIndex];

                return media.type == 'VIDEO'
                    ? _buildVideoPlayer(media.url, media.poster)
                    : _buildOptimizedImage(media.url);
              } else {
                return Container(color: Colors.black);
              }
            },
          ),
        ),
      ],
    );
  }

  // التدرج لتحسين وضوح النص
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.2, 0.7, 1.0],
        ),
      ),
    );
  }

  // معلومات المحتوى والأزرار
  Widget _buildContentSection() {
    return SafeArea(
        child: Column(
      children: [
        // Media indicator at top (unchanged)
        if (reel.mediaUrls.length > 1) _buildMediaIndicator(),

        // محتوى الريل في الأسفل
        Expanded(
          child: Stack(
            children: [
              // Progress bar stays the same
              _buildProgressBar(),

              // محتوى الريل الأساسي - with improved layout
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // معلومات المستخدم والوصف
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16.0), // Reduced padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfo(), // This now includes address when available
                              const SizedBox(height: 8), // Reduced spacing
                              _buildCaption(),

                              // If there are interests, show them
                              // if (reel.interests.isNotEmpty && reel.interests.length > 0) ...[
                              //   const SizedBox(height: 8),
                              //   _buildInterests(),
                              // ],
                            ],
                          ),
                        ),
                      ),

                      // أزرار التفاعل
                      _buildActionButtons(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildInterests() {
    // Only show up to 3 interests to avoid cluttering the UI
    final displayInterests = reel.interests.take(3).toList();

    return Container(
      height: 24, // Reduced height
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayInterests.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: 8, vertical: 3), // Smaller padding
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${displayInterests[i].name}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10, // Smaller font
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  // مؤشر تقدم الوسائط المتعددة
  Widget _buildMediaIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              reel.mediaUrls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: controller.currentMediaIndex.value == i
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )),
    );
  }

  // أزرار التفاعل
  Widget _buildActionButtons() {
    return GetBuilder<ReelsController>(builder: (controller) {
      final hasStore = reel.store != null || reel.ownerType == 'STORE';

      return Container(
        width: 70,
        padding: const EdgeInsets.only(right: 8, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() {
              final isLiked = controller.likedReels[reel.id] ?? false;
              return _buildVerticalActionButton(
                icon: isLiked
                    ? Icons.favorite
                    : Icons
                        .favorite_outline, // تغيير من favorite_border إلى favorite_outline
                label: formatCount(reel.counts.likedBy),
                isLiked: isLiked,
                onTap: () => controller.toggleLike(index),
              );
            }),
            const SizedBox(height: 16),
            _buildVerticalActionButton(
              icon: Icons.remove_red_eye_outlined, // هذا بالفعل outlined
              label: formatCount(reel.counts.viewedBy),
              isViewIcon: true,
            ),
            const SizedBox(height: 16),
            _buildVerticalActionButton(
              icon: Icons.share_outlined, // تغيير من share إلى share_outlined
              label: "مشاركة",
              onTap: () => controller.shareReel(index),
            ),
            const SizedBox(height: 16),
            _buildVerticalActionButton(
              customIcon: FaIcon(
                hasStore
                    ? FontAwesomeIcons
                        .storeAlt // استخدام أيقونة متجر مفرغة من Font Awesome
                    : FontAwesomeIcons
                        .whatsapp, // واتساب ليس له نسخة مفرغة في Font Awesome، أو يمكنك استخدام FontAwesomeIcons.whatsappSquare
                color: AppColors.white,
                size: hasStore ? 22 : 25,
              ),
              label: hasStore ? "المتجر" : "إرسال",
              onTap: () => hasStore
                  ? controller.showStoreDetails(reel.store!.id)
                  : controller.markAsWhatsappClicked(index),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      // أكثر من مليون: عرض بصيغة "1.2M"
      double millions = count / 1000000;
      return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M';
    } else if (count >= 10000) {
      // أكثر من 10 آلاف: عرض بصيغة "10K" بدون فاصلة عشرية
      return '${(count / 1000).floor()}K';
    } else if (count >= 1000) {
      // بين 1000 و 9999: عرض بصيغة "1.2K"
      double thousands = count / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}K';
    } else {
      // أقل من 1000: عرض كما هو
      return count.toString();
    }
  }

  Widget _buildVerticalActionButton({
    IconData? icon,
    Widget? customIcon,
    required String label,
    bool isLiked = false,
    bool isViewIcon = false, // New parameter to identify view icon
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // For view icon, we need to handle the shine effect
          isViewIcon
              ? _buildViewIconWithShine(icon!, label, isLiked)
              : (customIcon ??
                  Icon(
                    icon,
                    color: isLiked ? AppColors.primary : Colors.white,
                    size: 28,
                  )),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isLiked ? AppColors.primary : Colors.white,
                fontSize: 13,
                fontWeight: AppFonts.medium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewIconWithShine(IconData icon, String label, bool isLiked) {
    return GetBuilder<ReelsController>(
      builder: (controller) {
        // التحقق مما إذا كان يجب أن تكون الرسوم المتحركة نشطة
        final isAnimationActive =
            controller.shineAnimationActive[reel.id] ?? false;

        return Container(
          width: 28, // تثبيت عرض الحاوية
          height: 28, // تثبيت ارتفاع الحاوية
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الأيقونة الأساسية - ثابتة الحجم
              Icon(
                icon,
                color: isLiked ? AppColors.primary : Colors.white,
                size: 28,
              ),

              // تأثير اللمعة المتحركة
              if (isAnimationActive)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  // تسريع ظهور اللمعة (1000ms بدلاً من 2000ms)
                  duration: Duration(milliseconds: 2000),
                  // استخدام منحنى يسرع الظهور ويبطئ التلاشي
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    // حساب الشفافية - تظهر بسرعة وتبقى لفترة أطول
                    double opacity;
                    if (value < 0.3) {
                      // الظهور السريع في الـ 30% الأولى
                      opacity = value / 0.3;
                    } else if (value < 0.7) {
                      // البقاء مشرقة لـ 40% من المدة
                      opacity = 1.0;
                    } else {
                      // التلاشي التدريجي في الـ 30% الأخيرة
                      opacity = (1.0 - value) / 0.3;
                      opacity = opacity.clamp(0.0, 1.0);
                    }

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // توهج خارجي - ثابت الحجم ولكن متغير الشفافية
                        Container(
                          width: 28, // نفس حجم الأيقونة تماماً
                          height: 28, // نفس حجم الأيقونة تماماً
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.7 * opacity),
                                blurRadius: 12,
                                spreadRadius: 6 * opacity,
                              ),
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4 * opacity),
                                blurRadius: 20,
                                spreadRadius: 2 * opacity,
                              ),
                            ],
                          ),
                        ),

                        // الأيقونة المضيئة بلون ذهبي - نفس الحجم تماماً
                        Opacity(
                          opacity:
                              opacity * 0.9, // تعديل الشفافية للتناسب مع التوهج
                          child: Icon(
                            icon,
                            color: Colors.amber,
                            size: 28, // نفس حجم الأيقونة الأصلية تماماً
                          ),
                        ),
                      ],
                    );
                  },
                  onEnd: () {
                    // بعد انتهاء الرسوم المتحركة الأولى، ندخل في مرحلة النبضات الخفيفة
                    // التي تبقى لفترة أطول
                    if (controller.shineAnimationActive[reel.id] == true) {
                      // إعادة ضبط حالة اللمعة
                      controller.shineAnimationShown[reel.id] = false;

                      // تنشيط اللمعة
                      controller.shineAnimationActive[reel.id] = true;
                      controller.update();
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptimizedImage(String mediaUrl) {
    return GetBuilder<ReelsController>(builder: (controller) {
      final imageAspectRatio = controller.imageAspectRatios[mediaUrl];

      return Stack(
        fit: StackFit.expand,
        children: [
          // عرض خلفية سوداء ثابتة للبداية
          Container(color: Colors.black),

          // عرض الصورة بنسبتها الأصلية في الوسط
          Center(
            child: AspectRatio(
              aspectRatio: imageAspectRatio ??
                  9 / 16, // استخدام النسبة المحسوبة، أو النسبة الافتراضية
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                fit: BoxFit
                    .contain, // تغيير من cover إلى contain للحفاظ على النسبة الصحيحة
                fadeInDuration: Duration(milliseconds: 150),
                fadeOutDuration: Duration.zero,
                memCacheWidth: 1080,
                placeholderFadeInDuration: Duration.zero,
                imageBuilder: (context, imageProvider) {
                  // تحديث نسبة الأبعاد عند تحميل الصورة
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateImageAspectRatio(mediaUrl, imageProvider);
                  });

                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain, // تغيير من cover إلى contain
                      ),
                    ),
                  );
                },
                placeholder: (context, url) => Container(color: Colors.black),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: Center(
                      child: Icon(Icons.broken_image, color: Colors.white60)),
                ),
              ),
            ),
          ),

          // طبقة التدرج
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.2, 0.7, 1.0],
              ),
            ),
          ),
        ],
      );
    });
  }

  // دالة مساعدة لحساب وتخزين نسبة أبعاد الصورة
  void _updateImageAspectRatio(
      String imageUrl, ImageProvider imageProvider) async {
    try {
      final controller = Get.find<ReelsController>();

      // تجنب إعادة الحساب إذا كانت النسبة محفوظة بالفعل
      if (controller.imageAspectRatios.containsKey(imageUrl)) {
        return;
      }

      // الحصول على معلومات الصورة
      final completer = Completer<ImageInfo>();
      final imageStream = imageProvider.resolve(ImageConfiguration());

      final imageStreamListener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info);
        },
        onError: (exception, stackTrace) {
          completer.completeError(exception);
        },
      );

      imageStream.addListener(imageStreamListener);

      try {
        final imageInfo = await completer.future;

        // حساب نسبة العرض إلى الارتفاع
        final double width = imageInfo.image.width.toDouble();
        final double height = imageInfo.image.height.toDouble();

        if (width > 0 && height > 0) {
          final aspectRatio = width / height;

          // تخزين نسبة الأبعاد
          controller.imageAspectRatios[imageUrl] = aspectRatio;

          print("Image dimensions: ${width.toInt()}x${height.toInt()}");
          print(
              "Using original image aspect ratio: $aspectRatio for $imageUrl");

          // تحديث الواجهة لتعكس نسبة الأبعاد الجديدة
          controller.update();
        }
      } finally {
        // إزالة المستمع
        imageStream.removeListener(imageStreamListener);
      }
    } catch (e) {
      print("Error calculating image aspect ratio: $e");
    }
  }

  Widget _buildVideoPlayer(String mediaUrl, String? posterUrl) {
    return GetBuilder<ReelsController>(
      builder: (controller) {
        // استخدام دوال الكنترولر الجديدة للحصول على المعلومات
        final videoAspectRatio = controller.getVideoAspectRatio(reel.id);
        final isLoading = controller.videoLoadingStates[reel.id] == true;
        final hasError = controller.videoErrorStates[reel.id] == true;
        final isInitialized = controller.isVideoInitialized(reel.id);
        final isPlaying = controller.isVideoPlaying(reel.id);

        // الحصول على المتحكم من VideoManager
        final videoController = controller.videoManager.getController(reel.id);

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // عرض صورة البوستر كخلفية ضبابية دائمة (حتى عند تشغيل الفيديو)
              if (posterUrl != null && posterUrl.isNotEmpty)
                Positioned.fill(
                  child: Stack(
                    children: [
                      // البوستر كخلفية
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 100),
                          child: CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            fadeInDuration: Duration.zero,
                            placeholderFadeInDuration: Duration.zero,
                          ),
                        ),
                      ),
                      // تأثير الضباب
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Container(
                            color: Colors.grey[800]!.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // عرض الفيديو أو البوستر في المركز
              Center(
                child: AspectRatio(
                  aspectRatio: videoAspectRatio ?? 9 / 16,
                  child: isInitialized && videoController != null
                      ? AnimatedOpacity(
                          opacity: isPlaying ? 1.0 : 0.9,
                          duration: Duration(milliseconds: 150),
                          child: CachedVideoPlayer(videoController),
                        )
                      : (posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                            )
                          : Container(color: Colors.black)),
                ),
              ),

              // مؤشر التحميل
              if (false && isLoading && !isInitialized)
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),

              // أيقونة التشغيل
              if (isInitialized && !isPlaying)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

              // رسالة الخطأ
              if (hasError)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "حدث خطأ أثناء تحميل الفيديو",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // إعادة تهيئة الفيديو
                          controller.initializeVideo(
                              reel.id, mediaUrl, posterUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text("إعادة المحاولة"),
                      ),
                    ],
                  ),
                ),

              // طبقة التدرج
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return GetBuilder<ReelsController>(
      builder: (controller) {
        // عرض شريط التقدم فقط في حالة الفيديو
        if (reel.mediaUrls.isEmpty ||
            !reel.isVideoMedia(controller.currentMediaIndex.value)) {
          return SizedBox.shrink();
        }

        return Positioned(
          bottom: 10, // موضع أعلى من باقي محتوى الريل
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Obx(() {
              // استخدام Obx لاستجابة مباشرة للتغييرات
              final currentProgress =
                  controller.videoProgressValues[reel.id] ?? 0.0;
              return LinearProgressIndicator(
                value: currentProgress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              );
            }),
          ),
        );
      },
    );
  }

  // معلومات المستخدم
  Widget _buildUserInfo() {
    // Check if the reel has an associated store
    final hasStore = reel.store != null || reel.ownerType == 'STORE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main user info row with avatar and name
        Row(
          children: [
            // Display profile image - either store image or avatar
            if (hasStore && reel.store?.image != null)
              // Store image
              _buildAvatarWithFallback(
                imageUrl: reel.store!.image!,
                name: reel.store!.name,
              )
            else
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary, // لون الإطار
                    width: 1.2, // سماكة الإطار
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/ReelWin.png'),
                ),
              ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row - name with optional store badge
                  Row(
                    children: [
                      // Only show the badge if it's a store (not for individuals)
                      if (hasStore) _buildOwnerTypeBadge(),

                      // Display name
                      Expanded(
                        child: Text(
                          hasStore && reel.store != null
                              ? reel.store!.name
                              : reel.ownerName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: AppFonts.semiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Second row - either store city or creation date
                  if (hasStore &&
                      reel.store?.city != null &&
                      reel.store!.city!.isNotEmpty)
                    Text(
                      reel.store!.city!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      _formatDate(reel.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Address row - only show for stores with address
        if (hasStore &&
            reel.store?.address != null &&
            reel.store!.address!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reel.store!.address!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarWithFallback({
    required String imageUrl,
    required String name,
    double radius = 20,
  }) {
    return Stack(
      children: [
        // Avatar por defecto con inicial que se muestra inmediatamente
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[800],
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.8,
            ),
          ),
        ),

        // Imagen real con transición suave
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 200),
            fadeOutDuration: Duration.zero,
            progressIndicatorBuilder: (context, url, progress) =>
                SizedBox.shrink(),
            errorWidget: (context, url, error) => SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerTypeBadge() {
    return Container(
      margin: EdgeInsets.only(left: 6),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "متجر",
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    final hasStore = reel.store != null;
    final contactNumber = hasStore ? reel.store!.phone : reel.ownerNumber;

    // Only show button if there's a number to contact
    if (contactNumber.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 12),
      child: ElevatedButton.icon(
        onPressed: () => controller.markAsWhatsappClicked(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF25D366), // WhatsApp green color
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          hasStore ? "تواصل مع المتجر" : "تواصل مع المعلن",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: AppFonts.medium,
          ),
        ),
      ),
    );
  }

  // عرض النص الوصفي
  Widget _buildCaption() {
    // تحديد الحد الأقصى للأحرف في النمط المطوي
    const int maxCharacters = 100;

    // التحقق من طول النص
    bool isLongText = reel.description.length > maxCharacters;

    return GetBuilder<ReelsController>(
      id: 'caption_${reel.id}', // معرف خاص لتحديث هذا الجزء فقط
      builder: (controller) {
        // الحصول على حالة توسيع النص لهذا الريل
        bool isExpanded = controller.expandedCaptions[reel.id] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض النص كاملاً أو جزء منه حسب حالة التوسيع
            Text(
              isLongText && !isExpanded
                  ? '${reel.description.substring(0, maxCharacters)}...'
                  : reel.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: isExpanded ? null : 3, // بدون حد للأسطر في حالة التوسيع
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),

            // إظهار زر "المزيد" فقط إذا كان النص طويلاً
            if (isLongText) ...[
              GestureDetector(
                onTap: () => controller.toggleCaptionExpansion(reel.id),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    isExpanded ? 'عرض أقل' : 'عرض المزيد',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // معلومات إضافية
  Widget _buildActionInfo() {
    List<Widget> actions = [];

    // إضافة الاهتمامات إذا كانت موجودة

    if (reel.interests.isNotEmpty) {
      actions.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قائمة الاهتمامات بتصميم مبسط
            Container(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reel.interests.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      // استخدام خلفية شفافة مع حدود بيضاء
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${reel.interests[i].name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions,
    );
  }

  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
