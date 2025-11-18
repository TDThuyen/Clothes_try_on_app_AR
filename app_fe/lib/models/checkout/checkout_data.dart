class CheckoutData {
  final String firstName;
  final String lastName;
  final String country;
  final String streetName;
  final String city;
  final String? stateProvince;
  final String zipCode;
  final String phoneNumber;
  final String shippingMethod;
  final String? coupon;

  CheckoutData({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.streetName,
    required this.city,
    this.stateProvince,
    required this.zipCode,
    required this.phoneNumber,
    required this.shippingMethod,
    this.coupon,
  });

  Map<String, dynamic> toJson() => {
        "shippingAddress": {
          "firstName": firstName,
          "lastName": lastName,
          "country": country,
          "streetName": streetName,
          "city": city,
          "stateProvince": stateProvince,
          "zipCode": zipCode,
          "phoneNumber": phoneNumber,
        },
        "shippingMethod": shippingMethod,
        "couponCode": coupon,
      };
}
