import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class MapLauncherService extends GetxService {
  // Initialize the service
  Future<MapLauncherService> init() async {
    return this;
  }
  
  // Open Google Maps with the store location
  Future<bool> openGoogleMaps({
    required double latitude,
    required double longitude,
    required String title,
  }) async {
    // Construct the Google Maps URL
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$title'
    );
    
    try {
      // Attempt to launch Google Maps
      final bool canLaunch = await canLaunchUrl(googleMapsUrl);
      if (canLaunch) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to browser if Google Maps app is not installed
        final Uri fallbackUrl = Uri.parse(
          'https://maps.google.com/?q=$latitude,$longitude'
        );
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('Error launching maps: $e');
      Get.snackbar(
        'خطأ',
        'فشل في فتح الخرائط، يرجى التأكد من وجود تطبيق الخرائط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  // Open Google Maps with directions to the store location
  Future<bool> openGoogleMapsDirections({
    required double destinationLatitude,
    required double destinationLongitude,
    double? startLatitude,
    double? startLongitude,
  }) async {
    String url;
    
    if (startLatitude != null && startLongitude != null) {
      // If starting coordinates are provided, use them
      url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=$startLatitude,$startLongitude'
          '&destination=$destinationLatitude,$destinationLongitude'
          '&travelmode=driving';
    } else {
      // Otherwise let Google Maps determine the starting point (user's current location)
      url = 'https://www.google.com/maps/dir/?api=1'
          '&destination=$destinationLatitude,$destinationLongitude'
          '&travelmode=driving';
    }
    
    try {
      final Uri mapsUri = Uri.parse(url);
      final bool canLaunch = await canLaunchUrl(mapsUri);
      if (canLaunch) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback if Google Maps app is not installed
        final Uri fallbackUri = Uri.parse(
          'https://maps.google.com/?q=$destinationLatitude,$destinationLongitude'
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('Error launching maps directions: $e');
      Get.snackbar(
        'خطأ',
        'فشل في فتح الاتجاهات، يرجى التأكد من وجود تطبيق الخرائط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}