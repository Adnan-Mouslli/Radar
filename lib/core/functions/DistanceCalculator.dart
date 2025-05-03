import 'dart:math' as math;

class DistanceCalculator {
  // Calculate the distance between two coordinates using the Haversine formula
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in kilometers
    
    // Convert to radians
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    // Haversine formula
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
              math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = R * c;
    
    return distance;
  }
  
  // Convert degrees to radians
  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
}