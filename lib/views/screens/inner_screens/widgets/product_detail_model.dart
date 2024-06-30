import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/favorite_provider.dart';
import '../product_detail_screen.dart';

class ProductDetailModel extends ConsumerWidget {
  const ProductDetailModel({
    Key? key,
    required this.productData,
    required this.fem,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> productData;
  final double fem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _favoriteProvider = ref.read(favoriteProvider.notifier);
    final favoriteItems = ref.watch(favoriteProvider);
    final isFavorite = favoriteItems.containsKey(productData['productId']);

    return GestureDetector(
      onTap: () {
        Get.to(ProductDetailScreen(productData: productData));
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 72 * fem,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffdddddd)),
                color: Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0f000000),
                    offset: Offset(0 * fem, 4 * fem),
                    blurRadius: 6 * fem,
                  ),
                ],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 48 * fem,
                      height: 50 * fem,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          productData['productImage'][0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          productData['productName'],
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.525 * fem,
                            color: Color(0xff000000),
                          ),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${productData['productPrice'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  if (isFavorite) {
                    _favoriteProvider.removeItem(productData['productId']);
                  } else {
                    _favoriteProvider.addProductToFavorite(
                      productData['productName'],
                      productData['productId'],
                      productData['productImage'],
                      1,
                      productData['productQuantity'],
                      productData['productPrice'],
                      productData['vendorId'],
                    );
                  }
                },
                icon: isFavorite
                    ? Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
                    : Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
