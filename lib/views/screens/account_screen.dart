import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_shop_app/views/screens/auth/login_screen.dart';
import 'package:uber_shop_app/views/screens/cart_screen.dart';
import 'package:uber_shop_app/views/screens/inner_screens/customer_order_screen.dart';
import 'package:uber_shop_app/views/screens/inner_screens/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference buyers = FirebaseFirestore.instance.collection('buyers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Hồ Sơ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: buyers.doc(_auth.currentUser!.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            String phoneNumber = data['phoneNumber'] ?? '';
            String address = data['address'] ?? '';

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(data['profileImage']),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data['fullName'].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data['email'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return EditProfileScreen();
                              },
                            ));
                          },
                          child: Text('Sửa thông tin'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.map),
                      title: Text(
                        "Địa chỉ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(address),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          String newAddress = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController controller = TextEditingController(text: address);
                              return AlertDialog(
                                title: Text("Thay đổi địa chỉ"),
                                content: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: "Nhập địa chỉ mới",
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Lưu"),
                                    onPressed: () {
                                      Navigator.of(context).pop(controller.text.trim());
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Trở về"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (newAddress != null) {
                            // Update Firestore with the new address
                            await buyers.doc(_auth.currentUser!.uid).update({'address': newAddress});
                            setState(() {
                              address = newAddress;
                            });
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        'Số điện thoại',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(phoneNumber),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          String newPhoneNumber = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController controller = TextEditingController(text: phoneNumber);
                              return AlertDialog(
                                title: Text("Thay đổi số điện thoại"),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "Nhập số điện thoại mới",
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Lưu"),
                                    onPressed: () {
                                      Navigator.of(context).pop(controller.text.trim());
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Trở về"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (newPhoneNumber != null) {
                            // Update Firestore with the new phone number
                            await buyers.doc(_auth.currentUser!.uid).update({'phoneNumber': newPhoneNumber});
                            setState(() {
                              phoneNumber = newPhoneNumber;
                            });
                          }
                        },
                      ),
                    ),
                    // ListTile(
                    //   leading: Icon(Icons.shopping_cart),
                    //   onTap: () {
                    //     Navigator.push(context, MaterialPageRoute(
                    //       builder: (context) {
                    //         return CartScreen();
                    //       },
                    //     ));
                    //   },
                    //   title: Text(
                    //     'Cart',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return CustomerOrderScreen();
                          },
                        ));
                      },
                      leading: Icon(CupertinoIcons.bag),
                      title: Text(
                        'Đơn hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        await _auth.signOut().whenComplete(() {
                          return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                            return LoginScreen();
                          }));
                        });
                      },
                      leading: Icon(Icons.logout),
                      title: Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
