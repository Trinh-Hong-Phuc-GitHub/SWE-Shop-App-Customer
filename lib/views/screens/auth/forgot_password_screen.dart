import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uber_shop_app/controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  bool _isLoading = false;

  sendPasswordResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String res = await _authController.sendPasswordResetLink(email);

      setState(() {
        _isLoading = false;
      });

      if (res == 'success') {
        Get.snackbar(
          'Password Reset',
          'A password reset link has been sent to $email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context);
      } else {
        Get.snackbar(
          'Error Occurred',
          res,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email to reset password',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email address';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(
                    Icons.email,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendPasswordResetLink();
                },
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
