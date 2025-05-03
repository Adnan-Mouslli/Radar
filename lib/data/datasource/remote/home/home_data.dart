// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:radar/data/model/reel_model_api.dart';

// class ReelsApiService {
//   // تغيير هذا الرابط إلى رابط الـ API الخاص بك
//   final String baseUrl = 'https://your-api-domain.com/api';
  
//   // دالة للحصول على قائمة الريلز
//   Future<List<Reel>> getReels({int page = 1, int limit = 10}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/reels?page=$page&limit=$limit'),
//         headers: {
//           'Content-Type': 'application/json',
//           // يمكنك إضافة headers إضافية هنا مثل التوكن
//           // 'Authorization': 'Bearer $token',
//         },
//       );
  
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
        
//         // تحويل البيانات إلى قائمة من نوع Reel
//         if (jsonData['data'] != null && jsonData['data'] is List) {
//           return (jsonData['data'] as List)
//               .map((item) => Reel.fromJson(item))
//               .toList();
//         } else {
//           // إذا كان التنسيق مختلفًا
//           return jsonData.map<Reel>((item) => Reel.fromJson(item)).toList();
//         }
//       } else {
//         throw Exception('فشل في الحصول على الريلز: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء جلب الريلز: $e');
//     }
//   }

//   // دالة للحصول على ريلز مستخدم معين
//   Future<List<Reel>> getUserReels(String userId, {int page = 1, int limit = 10}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/users/$userId/reels?page=$page&limit=$limit'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
        
//         if (jsonData['data'] != null && jsonData['data'] is List) {
//           return (jsonData['data'] as List)
//               .map((item) => Reel.fromJson(item))
//               .toList();
//         } else {
//           return jsonData.map<Reel>((item) => Reel.fromJson(item)).toList();
//         }
//       } else {
//         throw Exception('فشل في الحصول على ريلز المستخدم: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء جلب ريلز المستخدم: $e');
//     }
//   }

//   // دالة لتحميل المزيد من الريلز (للتحميل المستمر)
//   Future<List<Reel>> loadMoreReels(int lastReelId, {int limit = 10}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/reels/more?lastId=$lastReelId&limit=$limit'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
        
//         if (jsonData['data'] != null && jsonData['data'] is List) {
//           return (jsonData['data'] as List)
//               .map((item) => Reel.fromJson(item))
//               .toList();
//         } else {
//           return jsonData.map<Reel>((item) => Reel.fromJson(item)).toList();
//         }
//       } else {
//         throw Exception('فشل في تحميل المزيد من الريلز: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء تحميل المزيد من الريلز: $e');
//     }
//   }

//   // دالة للإعجاب بريل معين
//   Future<bool> likeReel(int reelId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/reels/$reelId/like'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء الإعجاب بالريل: $e');
//     }
//   }

//   // دالة لإلغاء الإعجاب بريل معين
//   Future<bool> unlikeReel(int reelId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/reels/$reelId/like'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء إلغاء الإعجاب بالريل: $e');
//     }
//   }

//   // دالة لإرسال تعليق على ريل
//   Future<bool> commentOnReel(int reelId, String comment) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/reels/$reelId/comments'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token',
//         },
//         body: json.encode({
//           'comment': comment,
//         }),
//       );

//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء إرسال التعليق: $e');
//     }
//   }

//   // دالة للحصول على تعليقات ريل معين
//   Future<List<dynamic>> getReelComments(int reelId, {int page = 1, int limit = 20}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/reels/$reelId/comments?page=$page&limit=$limit'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
        
//         if (jsonData['data'] != null && jsonData['data'] is List) {
//           return jsonData['data'];
//         } else {
//           return jsonData;
//         }
//       } else {
//         throw Exception('فشل في الحصول على التعليقات: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء جلب التعليقات: $e');
//     }
//   }
// }