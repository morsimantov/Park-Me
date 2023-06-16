class ParkingLot {
  final int lot_id;
  final String lot_name;
  final String address;
  final String opening_hours;
  final String? fare;
  final bool? is_accessible;
  final num? availability;
  final int? num_parking_spots;
  final String paying_method;
  final String? updated_time;
  final int? fixed_price;
  final String? fixed_price_hours;
  final String image;
  double distance = 0;
  final bool? hourly_fare;
  final String? resident_discount;
  final bool? is_underground;

  ParkingLot(
      {required this.lot_id,
      required this.lot_name,
      required this.address,
      required this.opening_hours,
      this.fare,
      this.is_accessible,
      this.availability,
      this.num_parking_spots,
      required this.paying_method,
      this.updated_time,
      this.fixed_price,
      this.fixed_price_hours,
      required this.image,
      required this.distance,
      this.hourly_fare,
      this.is_underground,
      this.resident_discount});

  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot(
        lot_id: json['lot_id'],
        lot_name: json['lot_name'],
        address: json['address'],
        opening_hours: json['opening_hours'],
        fare: json['fare'],
        is_accessible: json['is_accessible'],
        availability: json['availability'],
        num_parking_spots: json['num_parking_spots'],
        paying_method: json['paying_method'],
        updated_time: json['updated_time'],
        fixed_price: json['fixed_price'],
        fixed_price_hours: json['fixed_price_hours'],
        image: json['image'],
        distance: 0,
        hourly_fare: json['hourly_fare'],
        is_underground: json['is_underground'],
        resident_discount: json['resident_discount']);
  }

  Map<String, dynamic> toJson() => {
        'lot_id': lot_id,
        'lot_name': lot_name,
        'address': address,
        'opening_hours': opening_hours,
        'fare': fare,
        'is_accessible': is_accessible,
        'availability': availability,
        'num_parking_spots': num_parking_spots,
        'paying_method': paying_method,
        'updated_time': updated_time,
        'fixed_price': fixed_price,
        'fixed_price_hours': fixed_price_hours,
        'image': image,
        'distance': distance,
        'hourly_fare': hourly_fare,
        'is_underground': is_underground,
        'resident_discount': resident_discount,
      };
}
