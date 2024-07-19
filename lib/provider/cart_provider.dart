import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uber_shop_app/models/cart_models.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartModel>>(
        (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, CartModel>> {
  CartNotifier() : super({});

  void addProductToCart(
      String productName,
      String productId,
      List imageUrl,
      int quantity,
      int productQuantity,
      double price,
      String vendorId,
      String productSize,
      ) {
    final cartItemId = '$productId-$productSize'; // Unique identifier for cart items

    if (state.containsKey(cartItemId)) {
      // If the item with the same productId and productSize is already in cart
      state = {
        ...state,
        cartItemId: CartModel(
          productName: state[cartItemId]!.productName,
          productId: state[cartItemId]!.productId,
          imageUrl: state[cartItemId]!.imageUrl,
          quantity: state[cartItemId]!.quantity + 1,
          productQuantity: state[cartItemId]!.productQuantity,
          price: state[cartItemId]!.price,
          vendorId: state[cartItemId]!.vendorId,
          productSize: state[cartItemId]!.productSize,
        ),
      };
    } else {
      // If the item with productId and productSize is not in cart, add it
      state = {
        ...state,
        cartItemId: CartModel(
          productName: productName,
          productId: productId,
          imageUrl: imageUrl,
          quantity: quantity,
          productQuantity: productQuantity,
          price: price,
          vendorId: vendorId,
          productSize: productSize,
        ),
      };
    }
  }

  void incrementItem(String cartItemId) {
    if (state.containsKey(cartItemId)) {
      state = {
        ...state,
        cartItemId: CartModel(
          productName: state[cartItemId]!.productName,
          productId: state[cartItemId]!.productId,
          imageUrl: state[cartItemId]!.imageUrl,
          quantity: state[cartItemId]!.quantity + 1,
          productQuantity: state[cartItemId]!.productQuantity,
          price: state[cartItemId]!.price,
          vendorId: state[cartItemId]!.vendorId,
          productSize: state[cartItemId]!.productSize,
        ),
      };
    }
  }

  void decrementItem(String cartItemId) {
    if (state.containsKey(cartItemId) && state[cartItemId]!.quantity > 1) {
      state = {
        ...state,
        cartItemId: CartModel(
          productName: state[cartItemId]!.productName,
          productId: state[cartItemId]!.productId,
          imageUrl: state[cartItemId]!.imageUrl,
          quantity: state[cartItemId]!.quantity - 1,
          productQuantity: state[cartItemId]!.productQuantity,
          price: state[cartItemId]!.price,
          vendorId: state[cartItemId]!.vendorId,
          productSize: state[cartItemId]!.productSize,
        ),
      };
    }
  }

  void removeAllItem() {
    state = {};
  }

  void removeItem(String cartItemId) {
    state.remove(cartItemId);
    state = {...state};
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.price;
    });

    return totalAmount;
  }

  Map<String, CartModel> get getCartItems => state;
}
