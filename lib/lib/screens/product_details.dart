import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:my_kisan/screens/CustomCard.dart';

class ProductDetail extends StatefulWidget {
  static String routName = "/product_detail";
  var map;
  ProductDetail({required this.map});
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  var resturantcategories;

  @override
  void initState() {
    super.initState();
    getresturantscategories();
  }

  getresturantscategories() async {
    this.resturantcategories = await gethotelcategories();
    setState(() {});
  }

  Future<Stream<QuerySnapshot>> gethotelcategories() async {
    return FirebaseFirestore.instance
        .collection("Resturants")
        .doc(widget.map['name'])
        .collection("categories")
        .snapshots();
  }

  Widget MoreInfo() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
                alignment: Alignment.centerLeft,
                height: 200,
                child: Image.network(
                  widget.map['imgurl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                "Phone : " + widget.map['Phone'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                "Address : " + widget.map['Address'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget Menu() {
    return Container(
      child: StreamBuilder(
        stream: resturantcategories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> map1 =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                print(map1);
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Card(
                      child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Center(
                            child: Text(
                          map1['name'].toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                      CategoryList(map1: map1, map0: widget.map),
                    ],
                  )),
                );
              },
            );
          } else {
            return Container(
              child: Text("load"),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  child: Text("Dishes"),
                ),
                Tab(
                  child: Text("More Info"),
                ),
              ],
            ),
            backgroundColor: Color(0xfff35751f),
            title: Text("Rolex Hotel"),
            centerTitle: true,
            // leading: IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back)),
          ),
          body: TabBarView(children: [
            //   Dishes(),
            Menu(),
            MoreInfo(),
          ]),
        ),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  // CategoryList({Key? key}) : super(key: key);
  var map1, map0;
  CategoryList({required this.map1, required this.map0});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  var resturantproducts;

  @override
  void initState() {
    super.initState();
    getresturantscategories();
  }

  getresturantscategories() async {
    this.resturantproducts = await gethotelcategories();

    setState(() {});
  }

  Future<Stream<QuerySnapshot>> gethotelcategories() async {
    return FirebaseFirestore.instance
        .collection("Resturants")
        .doc(widget.map0['name'])
        .collection("categories")
        .doc(widget.map1['name'])
        .collection("Products")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: resturantproducts,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return Container(
            height: snapshot.data!.docs.length * 160.00,
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> map2 =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                //   print(map2);
                return CustomeProductCard(
                  wis: false,
                  isfavoutite: false,
                  image: map2['imgurl'],
                  name: map2['name'],
                  price: map2['price'] ?? '',
                  title: map2['category'],
                  index: index,
                  productid: map2['productid'],
                  map: map2,
                );
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
