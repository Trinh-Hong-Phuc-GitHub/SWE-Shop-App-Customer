import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomerOrderScreen extends StatefulWidget {
  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double rating = 0;

  final TextEditingController _reviewController = TextEditingController();

  String formatedDate(date) {
    final outPutDateFormate = DateFormat("dd/MM/yyyy");
    final outPutDate = outPutDateFormate.format(date);
    return outPutDate;
  }

  Future<bool> hasUserReviewedProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('productReviews')
        .where('buyerId', isEqualTo: user!.uid)
        .where('productId', isEqualTo: productId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateProductRating(String productId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('productReviews')
        .where('productId', isEqualTo: productId)
        .get();
    double totalRating = 0;
    int totalReviews = querySnapshot.docs.length;
    for (final doc in querySnapshot.docs) {
      totalRating += doc['rating'];
    }
    final double averageRating =
        totalReviews > 0 ? totalRating / totalReviews : 0;
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({
      'rating': averageRating,
      'totalReviews': totalReviews,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              CupertinoIcons.bag,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Đơn Hàng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Slidable(
                key: ValueKey(data['orderId']),
                endActionPane: data['accepted'] == false
                    ? ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(document.id)
                                  .delete();
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Hủy Đơn Hàng',
                          ),
                        ],
                      )
                    : null,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 14,
                        child: data['accepted'] == true
                            ? Icon(Icons.delivery_dining)
                            : Icon(Icons.access_time),
                      ),
                      title: data['accepted'] == true
                          ? Text(
                              'Xác Nhận',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            )
                          : Text(
                              'Chưa Xác Nhận',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                      trailing: Text(
                        data['totalPrice'].toStringAsFixed(0) + ' đ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ExpansionTile(
                      title: Text(
                        'Mô Tả Đơn Hàng',
                        style: TextStyle(
                          color: Colors.pink.shade900,
                        ),
                      ),
                      subtitle: Text(
                        'Xem Chi Tiết',
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data['products'].length,
                          itemBuilder: (context, index) {
                            final product = data['products'][index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Image.network(
                                  product['productImage'][0],
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['productName'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Số Lượng',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product['quantity'].toString(),
                                        style: TextStyle(
                                          color: Colors.pink.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Size',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product['productSize'],
                                        style: TextStyle(
                                          color: Colors.pink.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Giá',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product['price'].toStringAsFixed(0) + ' đ',
                                        style: TextStyle(
                                          color: Colors.pink.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  data['accepted'] == true &&
                                          data['orderStatus'] ==
                                              'Giao Thành Công'
                                      ? Center(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final productId =
                                                  product['productId'];
                                              final hasReviewed =
                                                  await hasUserReviewedProduct(
                                                      productId);
                                              if (hasReviewed) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Cập Nhật Đánh Giá'),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextFormField(
                                                            controller:
                                                                _reviewController,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Đánh giá của bạn',
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: RatingBar
                                                                .builder(
                                                              initialRating:
                                                                  rating,
                                                              itemCount: 5,
                                                              minRating: 1,
                                                              maxRating: 5,
                                                              allowHalfRating:
                                                                  true,
                                                              itemSize: 15,
                                                              unratedColor:
                                                                  Colors.grey,
                                                              itemPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 4,
                                                              ),
                                                              itemBuilder:
                                                                  (context, _) {
                                                                return Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                );
                                                              },
                                                              onRatingUpdate:
                                                                  (value) {
                                                                rating = value;
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            final review =
                                                                _reviewController
                                                                    .text;
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'productReviews')
                                                                .doc(data[
                                                                    'orderId'])
                                                                .update({
                                                              'productId': product[
                                                                  'productId'],
                                                              'fullName': data[
                                                                  'fullName'],
                                                              'buyerId': data[
                                                                  'buyerId'],
                                                              'rating': rating,
                                                              'review': review,
                                                              'email':
                                                                  data['email'],
                                                            }).whenComplete(() {
                                                              updateProductRating(
                                                                  productId);
                                                              Navigator.pop(
                                                                  context);
                                                              _reviewController
                                                                  .clear();
                                                            });
                                                          },
                                                          child: Text('Lưu'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title:
                                                          Text('Thêm Đánh Giá'),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextFormField(
                                                            controller:
                                                                _reviewController,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Đánh giá của bạn',
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: RatingBar
                                                                .builder(
                                                              initialRating:
                                                                  rating,
                                                              itemCount: 5,
                                                              minRating: 1,
                                                              maxRating: 5,
                                                              allowHalfRating:
                                                                  true,
                                                              itemSize: 15,
                                                              unratedColor:
                                                                  Colors.grey,
                                                              itemPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 4,
                                                              ),
                                                              itemBuilder:
                                                                  (context, _) {
                                                                return Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                );
                                                              },
                                                              onRatingUpdate:
                                                                  (value) {
                                                                rating = value;
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            final review =
                                                                _reviewController
                                                                    .text;
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'productReviews')
                                                                .doc(data[
                                                                    'orderId'])
                                                                .set({
                                                              'productId': product[
                                                                  'productId'],
                                                              'fullName': data[
                                                                  'fullName'],
                                                              'buyerId': data[
                                                                  'buyerId'],
                                                              'rating': rating,
                                                              'review': review,
                                                              'email':
                                                                  data['email'],
                                                              'buyerPhoto': data[
                                                                  'profileImage'],
                                                            }).whenComplete(() {
                                                              updateProductRating(
                                                                  productId);
                                                              Navigator.pop(
                                                                  context);
                                                              _reviewController
                                                                  .clear();
                                                            });
                                                          },
                                                          child: Text('Submit'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            child: Text('Đánh Giá'),
                                          ),
                                        )
                                      : Text(''),
                                ],
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Thông Tin Người Mua',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                data['email'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                data['address'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                data['phoneNumber'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Thời Gian Đặt:' +
                                      " " +
                                      formatedDate(
                                        data['orderDate'].toDate(),
                                      ),
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              if (data['accepted'] == true)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Trạng Thái:' + ' ' + data['orderStatus'],
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              if (data['accepted'] == false)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Trạng Thái: Chưa Xác Nhận',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
