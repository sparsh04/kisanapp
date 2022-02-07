// ignore_for_file: unused_import

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/Cart_Screen.dart';
import 'package:my_kisan/screens/CustomCard.dart';
import 'package:my_kisan/screens/Maindrawer.dart';
import 'package:my_kisan/screens/notification_screen.dart';

class CategoryListScreen extends StatefulWidget {
  // const CategoryListScreen({Key? key}) : super(key: key);
  var map;
  CategoryListScreen({required this.map});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  // FirebaseFirestore _firestore = FirebaseFirestore.instance
  var categorylistsream;

  @override
  void initState() {
    super.initState();
    getcategorylist();
  }

  getcategorylist() async {
    categorylistsream = await getusercategorylist();
    setState(() {});
  }

  Future<Stream<QuerySnapshot>> getusercategorylist() async {
    return FirebaseFirestore.instance
        .collection("Category")
        .doc(widget.map['Name'])
        .collection("Products")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
    final Height = MediaQuery.of(context).size.height;
    final Width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: greencolor,
        centerTitle: true,
        title: Text(widget.map['Name'].toUpperCase()),
      ),
      body: StreamBuilder(
        stream: categorylistsream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> map =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  //print(map['price']);
                  return
                      //CustomBody(image: image, name: name, price: price, title: title, index: index, productid: productid)
                      CustomeProductCard(
                    wis: false,
                    isfavoutite: false,
                    image: map['imgurl'],
                    name: map['name'],
                    price: map['price'] ?? '',
                    title: map['category'],
                    index: index,
                    productid: map['productid'],
                    map: map,
                  );
                });
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
