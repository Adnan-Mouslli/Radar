import '../../../core/constant/imagasset.dart';
import '../../model/onboaringmodel.dart';


List<OnBoardingModel> onBoardingList = [
  OnBoardingModel(
      title: "شاهد واستمتع",
      body: "استمتع بمشاهدة مقاطع الريلز المتنوعة والمميزة\nاسحب يميناً ويساراً للتنقل بين المقاطع",
      image: AppImageAsset.onBoardingStreaming,
      darkImage: AppImageAsset.onBoardingStreamingDark
  ),
  OnBoardingModel(
      title: "اختر اهتماماتك",
      body: "حدد اهتماماتك من عقارات، سيارات، إلكترونيات وغيرها\nلتحصل على محتوى يناسب ذوقك",
      image: AppImageAsset.onBoardingPreferences,
       darkImage: AppImageAsset.onBoardingPreferencesDark

  ),
  OnBoardingModel(
      title: "اجمع النقاط",
      body: "احصل على نقاط وجواهر أثناء المشاهدة\nكلما شاهدت أكثر، ربحت أكثر",
      image: AppImageAsset.onBoardingWinners,
             darkImage: AppImageAsset.onBoardingWinnersDark

  ),
  OnBoardingModel(
      title: "استبدل جوائزك",
      body: "حول نقاطك إلى جوائز وهدايا قيمة\nاختر من بين مجموعة متنوعة من المكافآت",
      image: AppImageAsset.onBoardingGifts ,
      darkImage: AppImageAsset.onBoardingGiftsDark

  ),
];