class CartModel {
  final String productName;
  final String productId;
  final List imageUrl;

  int quantity;
  int productQuantity;
  final double price;
  final String vendorId;
  final String productSize;

  CartModel(
      {required this.productName,
      required this.productId,
      required this.imageUrl,
      required this.quantity,
      required this.productQuantity,
      required this.price,
      required this.vendorId,
      required this.productSize});
}
