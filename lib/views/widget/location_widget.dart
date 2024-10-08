import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/logo.png',
            width: 30,
          ),
          SizedBox(
            width: 15,
          ),
          Image.asset(
            'assets/icons/pickicon.png',
            width: 30,
          ),
          SizedBox(
            width: 8,
          ),
          Flexible(
            child: SizedBox(
              width: 300,
              child: TextFormField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Current Location',
                  labelText: 'Current Location',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}