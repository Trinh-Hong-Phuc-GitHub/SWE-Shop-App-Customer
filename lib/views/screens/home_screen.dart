import 'package:flutter/material.dart';
import 'package:uber_shop_app/views/widget/banner_widget.dart';
import 'package:uber_shop_app/views/widget/category_item_widget.dart';
import 'package:uber_shop_app/views/widget/category_text_widget.dart';
import 'package:uber_shop_app/views/widget/home_products_widget.dart';
import 'package:uber_shop_app/views/widget/location_widget.dart';
import 'package:uber_shop_app/views/widget/men_product_widget.dart';
import 'package:uber_shop_app/views/widget/reuse_text_widget.dart';
import 'package:uber_shop_app/views/widget/women_product_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocationWidget(),
          SizedBox(
            height: 10,
          ),
          BannerWidget(),
          SizedBox(
            height: 10,
          ),
          CategoryTextWidget(),
          SizedBox(
            height: 10,
          ),
          HomeProductsWidget(),
          SizedBox(
            height: 10,
          ),
          ReuseTextWidget(
            title: "Men's Product",
          ),
          SizedBox(
            height: 10,
          ),
          MenProductWidget(),
          SizedBox(height: 10,),
          ReuseTextWidget(
            title: "Women's Product",
          ),
          WomenProductWidget(),
        ],
      ),
    );
  }
}

