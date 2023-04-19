
class FilterParameters {
  bool isUnderground = false;
  bool availability = false;
  bool accessibility = false;
  double? walkingDistance;
  bool fixedPrice = false;
  double? price;
  bool credit = false;
  bool cash = false;
  bool pango = false;

  FilterParameters(this.availability, this.isUnderground, this.fixedPrice, this.credit, this.cash);
}