import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function To Select Image From Gallary Or Camera
  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();

    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print('No Image Selected Or Captured');
    }
  }

  // Function To Upload Image To Firebase Storage
  _uploadImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('profileImages').child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(image!);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> createNewUser(
    String email,
    String fullName,
    String password,
    Uint8List? image,
  ) async {
    String res = 'some error occured';
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String downloadUrl = await _uploadImageToStorage(image);

      await _firestore.collection('buyers').doc(userCredential.user!.uid).set({
        'longitude': '',
        'latitude': '',
        'placeName': '',
        'fullName': fullName,
        'profileImage': downloadUrl,
        'email': email,
        'address': '',
        'phoneNumber': '',
        'buyerId': userCredential.user!.uid,
      });
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Function To Login The Created User
  Future<String> loginUser(String email, String password) async {
    String res = 'some error occured';

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
}
