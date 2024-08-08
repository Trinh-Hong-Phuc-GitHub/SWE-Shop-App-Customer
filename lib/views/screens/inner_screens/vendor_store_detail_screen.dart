import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uber_shop_app/views/screens/inner_screens/widgets/product_detail_model.dart';

class VendorStoreDetailScreen extends StatelessWidget {
  final dynamic vendorData;

  const VendorStoreDetailScreen({super.key, required this.vendorData});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 428;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: vendorData['vendorId'])
        .snapshots();
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('approved', isEqualTo: true)
        .where('vendorId', isEqualTo: vendorData['vendorId'])
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông tin người bán',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LinearProgressIndicator(
                color: Colors.pink,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                Center(
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(vendorData['storeImage']),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    vendorData['businessName'],
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  vendorData['vendorAddress'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _ordersStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading");
                        }

                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Tổng số đơn hàng',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      Text(
                                        snapshot.data!.docs.length.toString(),
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // SizedBox(height: 20),
                              // snapshot.data!.size >= 4
                              //     ? Row(
                              //   children: [
                              //     Text(
                              //       'verified',
                              //       style: TextStyle(
                              //         fontSize: 20,
                              //       ),
                              //     ),
                              //     Icon(
                              //       Icons.verified,
                              //       color: Colors.pink,
                              //     ),
                              //   ],
                              // )
                              //     : Text(
                              //   'Not verified',
                              //   style: TextStyle(
                              //     fontSize: 20,
                              //     decoration: TextDecoration.underline,
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Số sản phẩm: ${snapshot.data!.docs.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 500,
                  child: ListView.builder(
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) {
                      final productData = snapshot.data!.docs[index];
                      return SingleChildScrollView(
                          child: ProductDetailModel(
                              productData: productData, fem: fem));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
