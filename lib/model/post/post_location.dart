enum PostLocationPrecision { place, neighborhood, city, region }

class GeoCoordinates {
  GeoCoordinates({required this.latitude, required this.longitude}) {
    if (!latitude.isFinite ||
        latitude < minimumLatitude ||
        latitude > maximumLatitude) {
      throw ArgumentError.value(latitude, 'latitude');
    }
    if (!longitude.isFinite ||
        longitude < minimumLongitude ||
        longitude > maximumLongitude) {
      throw ArgumentError.value(longitude, 'longitude');
    }
  }

  static const double minimumLatitude = -90;
  static const double maximumLatitude = 90;
  static const double minimumLongitude = -180;
  static const double maximumLongitude = 180;

  final double latitude;
  final double longitude;
}

class PostLocation {
  const PostLocation({
    required this.name,
    this.placeId,
    this.locality,
    this.region,
    this.countryCode,
    this.precision = PostLocationPrecision.place,
    this.coordinates,
  });

  final String? placeId;
  final String name;
  final String? locality;
  final String? region;
  final String? countryCode;
  final PostLocationPrecision precision;
  final GeoCoordinates? coordinates;

  bool get hasCoordinates => coordinates != null;
}
