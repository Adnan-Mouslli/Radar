class ProvidenceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  ProvidenceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  static List<ProvidenceModel> getProvidences() {
    return [
      ProvidenceModel(
        id: 'CURRENT_LOCATION',
        name: 'موقعي الحالي',
        latitude: 0.0,
        longitude: 0.0,
      ),
      ProvidenceModel(
        id: 'DAMASCUS',
        name: 'دمشق',
        latitude: 33.5138,
        longitude: 36.2765,
      ),
      ProvidenceModel(
        id: 'ALEPPO',
        name: 'حلب',
        latitude: 36.2021,
        longitude: 37.1343,
      ),
      ProvidenceModel(
        id: 'HOMS',
        name: 'حمص',
        latitude: 34.7324,
        longitude: 36.7137,
      ),
      ProvidenceModel(
        id: 'HAMA',
        name: 'حماة',
        latitude: 35.1442,
        longitude: 36.7552,
      ),
      ProvidenceModel(
        id: 'LATAKIA',
        name: 'اللاذقية',
        latitude: 35.5306,
        longitude: 35.7911,
      ),
      ProvidenceModel(
        id: 'DEIR_EZ_ZOR',
        name: 'دير الزور',
        latitude: 35.3359,
        longitude: 40.1408,
      ),
      ProvidenceModel(
        id: 'RAQQA',
        name: 'الرقة',
        latitude: 35.9528,
        longitude: 39.0079,
      ),
      ProvidenceModel(
        id: 'HASAKAH',
        name: 'الحسكة',
        latitude: 36.5024,
        longitude: 40.7477,
      ),
      ProvidenceModel(
        id: 'TARTUS',
        name: 'طرطوس',
        latitude: 34.8889,
        longitude: 35.8866,
      ),
      ProvidenceModel(
        id: 'IDLIB',
        name: 'إدلب',
        latitude: 35.9306,
        longitude: 36.6348,
      ),
      ProvidenceModel(
        id: 'DARAA',
        name: 'درعا',
        latitude: 32.6189,
        longitude: 36.1121,
      ),
      ProvidenceModel(
        id: 'SUWEIDA',
        name: 'السويداء',
        latitude: 32.7062,
        longitude: 36.5735,
      ),
      ProvidenceModel(
        id: 'QUNEITRA',
        name: 'القنيطرة',
        latitude: 33.1214,
        longitude: 35.8225,
      ),
    ];
  }
}
