import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../provider/cart_provider.dart';
import '../auth/main_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;

  String _fullName = '';
  String _email = '';
  String _address = '';
  String _phoneNumber = '';

  Future<void> _editDialog(BuildContext context, String title, TextEditingController controller, Function onSave) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thay Đổi $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: title,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                onSave();
                Navigator.of(context).pop();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final _cartProvider = ref.read(cartProvider.notifier);
    final cartData = ref.watch(cartProvider);
    final totalAmount = ref.read(cartProvider.notifier).calculateTotalAmount();

    final TextEditingController _fullNameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _addressController = TextEditingController();
    final TextEditingController _phoneNumberController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt Hàng'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('buyers').doc(_auth.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final userDoc = snapshot.data!;
          _fullName = _fullName.isEmpty ? userDoc['fullName'] : _fullName;
          _email = _email.isEmpty ? userDoc['email'] : _email;
          _address = _address.isEmpty ? userDoc['address'] : _address;
          _phoneNumber = _phoneNumber.isEmpty ? userDoc['phoneNumber'] : _phoneNumber;

          _fullNameController.text = _fullName;
          _emailController.text = _email;
          _addressController.text = _address;
          _phoneNumberController.text = _phoneNumber;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông Tin Người Mua',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListTile(
                        title: Text('Họ Và Tên: $_fullName'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Họ Và Tên', _fullNameController, () {
                              setState(() {
                                _fullName = _fullNameController.text;
                              });
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Email: $_email'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Email', _emailController, () {
                              setState(() {
                                _email = _emailController.text;
                              });
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Địa Chỉ: $_address'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Địa Chỉ', _addressController, () {
                              setState(() {
                                _address = _addressController.text;
                              });
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Số Điện Thoại: $_phoneNumber'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Số Điện Thoại', _phoneNumberController, () {
                              setState(() {
                                _phoneNumber = _phoneNumberController.text;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông Tin Đơn Hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cartData.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartData.values.toList()[index];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: SizedBox(
                                height: 200,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Image.network(
                                        cartItem.imageUrl[0],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartItem.productName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              'Size ' + cartItem.productSize,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              cartItem.price.toStringAsFixed(0),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.pink),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            final userDoc = await _firestore
                .collection('buyers')
                .doc(_auth.currentUser!.uid)
                .get();
            final orders = <String, List<Map<String, dynamic>>>{};
            final totalPriceByVendor = <String, double>{};

            _cartProvider.getCartItems.forEach((key, item) {
              if (!orders.containsKey(item.vendorId)) {
                orders[item.vendorId] = [];
                totalPriceByVendor[item.vendorId] = 0.0;
              }
              final itemTotalPrice = item.quantity * item.price;
              totalPriceByVendor[item.vendorId] = (totalPriceByVendor[item.vendorId] ?? 0.0) + itemTotalPrice;

              orders[item.vendorId]!.add({
                'productId': item.productId,
                'productName': item.productName,
                'quantity': item.quantity,
                'price': itemTotalPrice,
                'productSize': item.productSize,
                'productImage': item.imageUrl,
              });
            });

            for (var vendorId in orders.keys) {
              final orderId = Uuid().v4();
              await _firestore.collection('orders').doc(orderId).set({
                'orderId': orderId,
                'totalPrice': totalPriceByVendor[vendorId] ?? 0.0,
                'products': orders[vendorId],
                'fullName': _fullName,
                'email': _email,
                'profileImage': userDoc['profileImage'],
                'address': _address,
                'phoneNumber': _phoneNumber,
                'buyerId': _auth.currentUser!.uid,
                'vendorId': vendorId,
                'accepted': false,
                'orderStatus': 'Đang Đóng Gói',
                'orderDate': DateTime.now(),
                // 'title': 'Chưa xác nhận',
              }).whenComplete(() {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Đã Đặt Hàng'),
                      content: Text('Đơn hàng của bạn đã được đặt thành công.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()),
                                  (route) => false,
                            );
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );

                _cartProvider.removeAllItem();

                setState(() {
                  _isLoading = false;
                });
              });
            }
          },
          child: Container(
            height
                : 50,
            width: MediaQuery.of(context).size.width - 50,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(9),
            ),
            child: _isLoading
                ? CircularProgressIndicator(
              color: Colors.white,
            )
                : Center(
              child: Text(
                'Đặt hàng' +
                    " " +
                    totalAmount.toStringAsFixed(0) + " đ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}