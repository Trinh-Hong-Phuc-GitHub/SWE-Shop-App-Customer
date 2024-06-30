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
          title: Text('Edit $title'),
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
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
        title: Text('Checkout'),
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
                        'Buyer Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListTile(
                        title: Text('Full Name: $_fullName'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Full Name', _fullNameController, () {
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
                        title: Text('Address: $_address'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Address', _addressController, () {
                              setState(() {
                                _address = _addressController.text;
                              });
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Phone Number: $_phoneNumber'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editDialog(context, 'Phone Number', _phoneNumberController, () {
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
                        'Order Information',
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
                                    Padding(
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
                                          ),
                                          Text(
                                            'Size ' + cartItem.productSize,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            cartItem.price.toStringAsFixed(2),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.pink),
                                          ),
                                        ],
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
            DocumentSnapshot userDoc = await _firestore
                .collection('buyers')
                .doc(_auth.currentUser!.uid)
                .get();
            _cartProvider.getCartItems.forEach(
                  (key, item) async {
                final orderId = Uuid().v4();
                await _firestore.collection('orders').doc(orderId).set({
                  'orderId': orderId,
                  'productId': item.productId,
                  'productName': item.productName,
                  'quantity': item.quantity,
                  'price': item.quantity * item.price,
                  'fullName': _fullName,
                  'email': _email,
                  'profileImage': userDoc['profileImage'],
                  'address': _address,
                  'phoneNumber': _phoneNumber,
                  'buyerId': _auth.currentUser!.uid,
                  'vendorId': item.vendorId,
                  'productSize': item.productSize,
                  'productImage': item.imageUrl,
                  'vendorQuantity': item.productQuantity,
                  'accepted': false,
                  'orderDate': DateTime.now(),
                }).whenComplete(() {
                  // Order completed successfully, show dialog and clear cart
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Order Placed'),
                        content: Text('Your order has been placed successfully.'),
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

                  // Clear cart
                  _cartProvider.removeAllItem();

                  setState(() {
                    _isLoading = false;
                  });
                });
              },
            );
          },
          child: Container(
            height: 50,
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
                'Place Order' +
                    " " +
                    "\$" +
                    totalAmount.toStringAsFixed(2),
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
