class ProductModel {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final bool isPO;
  final double? progress;
  final String? est;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.description = '',
    this.isPO = false,
    this.progress,
    this.est,
  });
}
