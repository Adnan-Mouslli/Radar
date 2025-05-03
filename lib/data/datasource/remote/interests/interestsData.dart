import 'package:dartz/dartz.dart';
import 'package:radar/data/model/reel_model_api.dart';
import '../../../../core/class/crud.dart';
import '../../../../core/class/statusrequest.dart';
import '../../../../core/constant/Link.dart';

class InterestData {
  final Crud crud;

  InterestData(this.crud);

  // في فئة InterestData
  Future<Either<StatusRequest, List<Interest>>> getInterestsList() async {
    try {
      var response = await crud.getData(AppLink.interestsList);
      print("Interests Response: $response");

      if (response.isRight()) {
        final data = response.fold((l) => null, (r) => r);

        if (data != null && data is List) {
          // هنا التحويل الصحيح من List<dynamic> إلى List<Interest>
          List<Interest> interestsList = data.map((item) {
            if (item is Map<String, dynamic>) {
              return Interest.fromJson(item);
            } else {
              // حالة احتياطية إذا كان شكل البيانات غير متوقع
              print("Unexpected data format: $item");
              return Interest(id: '', name: '');
            }
          }).toList();

          return Right(interestsList);
        }
      }

      return const Left(StatusRequest.error);
    } catch (e) {
      print("Error in getInterests: $e");
      return const Left(StatusRequest.error);
    }
  }
}
