import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_kisan/accessories/Position.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/payment_screen.dart';
//import ;'package:my_kisan/screens/rajorpayscreen.dart'
//import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  static String routName = "/cart_screen";
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final couponcontroller = TextEditingController();
  final addresscontroller = TextEditingController();
  final subaddresscontroller = TextEditingController();
  int total = 0;
  var items, coupons;
  var cartstream;
  int off = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    getcart();
    getcoupons();
    getlocation();
    super.initState();
  }

  //

  FirebaseAuth _auth = FirebaseAuth.instance;

  getcart() async {
    this.cartstream = await getusercart();
    int temp = await getTotal();
    var tem = await getcoupons();
    // int temp = await getTotal();
    // int temp = await getTotal();
    List tempitems = await getallitems();
    setState(() {
      coupons = tem;
      total = temp;
      items = tempitems;
    });

    // print(coupons);
    // print(coupons["SWIGGYIT"]);
    // print(coupons["S"]);
  }

  addquantity(String productid, int quantity) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.phoneNumber)
        .collection("cart")
        .doc(productid)
        .update({"quantity": quantity + 1});

    int temp = await getTotal();
    List tempitems = await getallitems();
    setState(() {
      total = temp;
      items = tempitems;
    });
  }

  minusquantity(String productid, int quantity) async {
    if (quantity > 1) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.phoneNumber)
          .collection("cart")
          .doc(productid)
          .update({"quantity": quantity - 1});
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.phoneNumber)
          .collection("cart")
          .doc(productid)
          .delete();
    }

    int temp = await getTotal();
    List tempitems = await getallitems();
    setState(() {
      total = temp;
      items = tempitems;
    });
  }

  Future<Stream<QuerySnapshot>> getusercart() async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.phoneNumber)
        .collection("cart")
        .snapshots();
  }

  Future<int> getTotal() async {
    int total = 0;
    int totalitems = 0;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.phoneNumber)
        .collection('cart')
        .get()
        .then((value) {
      List<DocumentSnapshot> ls = value.docs;
      // print(ls[0].toString());
      ls.forEach((element) {
        print(element['price'] + element['quantity']);
        int price = element['price'] as int;
        int quantity = element['quantity'] as int;

        totalitems += quantity;
        total += (price * quantity);
        // print(total);
      });
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.phoneNumber)
        .update({"carttotal": total, "totalitems": totalitems});
    //setState(() {});
    //print("total:$total");
    return total;
  }

  Future<List> getallitems() async {
    List items = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.phoneNumber)
        .collection('cart')
        .get()
        .then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        String name = element['name'];
        int quantity = element['quantity'];
        var a = name + " x " + '${quantity}';
        items.add(a);
        // items.add(a);
      });
    });

    //  print(items);

    return items;
  }

  Future<List> getallitem() async {
    List items = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.phoneNumber)
        .collection('cart')
        .get()
        .then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        String name = element['name'];
        int quantity = element['quantity'];
        var a = name + " x " + '${quantity}';
        items.add(a);
        // items.add(a);
      });
    });

    // print(items);

    if (items != null) {
      return items;
    } else {
      return [];
    }
  }

  Future<Map<String, int>> getcoupons() async {
    Map<String, int> coupons = {};
    await FirebaseFirestore.instance.collection('Coupons').get().then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        String name = element['code'].toUpperCase();
        int percentage = element['percentage'];
        // var a = {name: percentage};
        coupons[name] = percentage;
        // items.add(a);
      });
    });

    // print(coupons);
    return coupons;
  }

  var position, location, address, subaddress;

  getlocation() async {
    position = await Locationa().determinePosition();
    location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    GetAddressFromLatLong(position);
    //setState(() {});
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemark[0];
    // print(place);
    address = '${place.subAdministrativeArea},${place.administrativeArea}';
    subaddress = '${place.postalCode},${place.street},';
    setState(() {});
  }

  //  FutureBuilder(
  //             future: getallitem(),
  //             builder: (BuildContext context, AsyncSnapshot snapshot) {
  //               if ((snapshot.hasData) && (snapshot.data.length) > 0) {

  @override
  Widget build(BuildContext context) {
    final Height = MediaQuery.of(context).size.height;
    final Width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: greencolor,
          title: Text("Cart"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
              future: getallitem(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if ((snapshot.hasData) && (snapshot.data.length) > 0) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: cartstream,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                return Container(
                                  alignment: Alignment.center,
                                  height: snapshot.data!.docs.length * 80.00,
                                  width: double.infinity,
                                  child: ListView.builder(
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Map<String, dynamic> map =
                                          snapshot.data!.docs[index].data()
                                              as Map<String, dynamic>;

                                      // total = total + map['quantity'] * map['price'];
                                      return Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        alignment: Alignment.center,
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(color: Colors.black),
                                        // ),
                                        height: 80,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 30, left: 5),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(map['name'],
                                                      style: TextStyle(
                                                          fontSize: 18)),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text("in " + map['category'],
                                                      style: subheadingstyle()),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            Container(
                                              margin: EdgeInsets.only(top: 20),
                                              // padding: EdgeInsets.only(
                                              //     left: 5, right: 5, top: 5, bottom: 5),
                                              decoration: BoxDecoration(
                                                  color: orangecolor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      addquantity(
                                                          map['productid'],
                                                          map['quantity']);
                                                    },
                                                    child: Icon(
                                                      Icons.add_circle,
                                                      color: orangecolor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    '${map['quantity']}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      minusquantity(
                                                          map['productid'],
                                                          map['quantity']);
                                                    },
                                                    child: Icon(
                                                        Icons.remove_circle,
                                                        color: orangecolor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(top: 20),
                                                child: Text(
                                                  "₹" +
                                                      '${map['quantity'] * map['price']}',
                                                  style: headingstyle(),
                                                )),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else
                                return Container();
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        PaymentDetail(
                          off: off.toInt(),
                          total: total,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Any request for the resturant",
                                    style: TextStyle(color: Colors.grey[600]),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.center,
                                    height: 35,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: orangecolor),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: TextField(
                                      controller: couponcontroller,
                                      style: TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Enter Coupon code",
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: MaterialButton(
                                      height: Height / 25,
                                      minWidth: Width * 0.4 - 20,
                                      onPressed: () {
                                        if (couponcontroller.text != "") {
                                          if (coupons[couponcontroller.text
                                                  .toUpperCase()] !=
                                              null) {
                                            off = (coupons[couponcontroller.text
                                                        .toUpperCase()] *
                                                    total /
                                                    100)
                                                .toInt();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "You have Availed " +
                                                            '${coupons[couponcontroller.text.toUpperCase()]}' +
                                                            "% discount")));
                                            print(off);
                                          } else {
                                            off = 0;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Wrong Coupon Code")));
                                          }
                                        }
                                        FocusScope.of(context).unfocus();
                                      },
                                      color: Color(0xfffeda704),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        "Apply",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              FutureBuilder(
                                  future: getlocation(),
                                  builder: (context, snapshot) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  addresscontroller.text == ""
                                                      ? '${address}'
                                                      : addresscontroller.text,
                                                  style: TextStyle(
                                                      color: textcolorblack,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                )
                                              ],
                                            ),
                                            // GestureDetector(
                                            //   onTap: () {
                                            //     showDialog(
                                            //         context: context,
                                            //         builder: (context) {
                                            //           return Dialog(
                                            //             shape: RoundedRectangleBorder(
                                            //                 borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                             20)),
                                            //             elevation: 16,
                                            //             child: SizedBox(
                                            //               height: 200,
                                            //               // decoration: BoxDecoration(
                                            //               //   border: Border.all(),
                                            //               // ),
                                            //               child: Column(
                                            //                 // mainAxisAlignment: MainAxisAlignment.start,
                                            //                 crossAxisAlignment:
                                            //                     CrossAxisAlignment
                                            //                         .center,
                                            //                 children: [
                                            //                   const SizedBox(
                                            //                     height: 20,
                                            //                   ),
                                            //                   const Text(
                                            //                     "Address",
                                            //                     style: TextStyle(
                                            //                         fontSize:
                                            //                             20),
                                            //                   ),
                                            //                   const SizedBox(
                                            //                     height: 20,
                                            //                   ),
                                            //                   Container(
                                            //                     margin: const EdgeInsets
                                            //                             .fromLTRB(
                                            //                         10,
                                            //                         0,
                                            //                         10,
                                            //                         0),
                                            //                     padding:
                                            //                         const EdgeInsets
                                            //                                 .fromLTRB(
                                            //                             10,
                                            //                             0,
                                            //                             10,
                                            //                             0),
                                            //                     child: Column(
                                            //                       children: [
                                            //                         Row(
                                            //                           crossAxisAlignment:
                                            //                               CrossAxisAlignment
                                            //                                   .center,
                                            //                           children: [
                                            //                             //here
                                            //                             Center(
                                            //                               child:
                                            //                                   Container(
                                            //                                 padding:
                                            //                                     EdgeInsets.symmetric(horizontal: 10),
                                            //                                 alignment:
                                            //                                     Alignment.center,
                                            //                                 height:
                                            //                                     35,
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width / 1.5,
                                            //                                 decoration:
                                            //                                     BoxDecoration(border: Border.all(color: orangecolor), borderRadius: BorderRadius.circular(10)),
                                            //                                 child:
                                            //                                     TextField(
                                            //                                   controller: addresscontroller,
                                            //                                   style: TextStyle(fontSize: 14),
                                            //                                   decoration: InputDecoration(
                                            //                                     border: InputBorder.none,
                                            //                                     hintText: "Address",
                                            //                                   ),
                                            //                                 ),
                                            //                               ),
                                            //                             ),
                                            //                           ],
                                            //                         ),
                                            //                         const SizedBox(
                                            //                           height:
                                            //                               11,
                                            //                         ),
                                            //                         Row(
                                            //                           crossAxisAlignment:
                                            //                               CrossAxisAlignment
                                            //                                   .center,
                                            //                           children: [
                                            //                             //here
                                            //                             Center(
                                            //                               child:
                                            //                                   Container(
                                            //                                 padding:
                                            //                                     EdgeInsets.symmetric(horizontal: 10),
                                            //                                 alignment:
                                            //                                     Alignment.center,
                                            //                                 height:
                                            //                                     35,
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width / 1.5,
                                            //                                 decoration:
                                            //                                     BoxDecoration(border: Border.all(color: orangecolor), borderRadius: BorderRadius.circular(10)),
                                            //                                 child:
                                            //                                     TextField(
                                            //                                   controller: subaddresscontroller,
                                            //                                   style: TextStyle(fontSize: 14),
                                            //                                   decoration: InputDecoration(
                                            //                                     border: InputBorder.none,
                                            //                                     hintText: "Sub-Address",
                                            //                                   ),
                                            //                                 ),
                                            //                               ),
                                            //                             ),
                                            //                           ],
                                            //                         ),
                                            //                       ],
                                            //                     ),
                                            //                   ),
                                            //                   // const SizedBox(
                                            //                   //   height: 22,
                                            //                   // ),
                                            //                   // Row(
                                            //                   //   crossAxisAlignment:
                                            //                   //       CrossAxisAlignment
                                            //                   //           .center,
                                            //                   //   children: [
                                            //                   //     //here
                                            //                   //     Center(
                                            //                   //       child:
                                            //                   //           Container(
                                            //                   //         padding: EdgeInsets.symmetric(
                                            //                   //             horizontal:
                                            //                   //                 10),
                                            //                   //         alignment:
                                            //                   //             Alignment
                                            //                   //                 .center,
                                            //                   //         height:
                                            //                   //             35,
                                            //                   //         width: MediaQuery.of(context)
                                            //                   //                 .size
                                            //                   //                 .width /
                                            //                   //             1.5,
                                            //                   //         decoration: BoxDecoration(
                                            //                   //             border: Border.all(
                                            //                   //                 color:
                                            //                   //                     orangecolor),
                                            //                   //             borderRadius:
                                            //                   //                 BorderRadius.circular(10)),
                                            //                   //         child:
                                            //                   //             TextField(
                                            //                   //           // controller: couponcontroller,
                                            //                   //           style: TextStyle(
                                            //                   //               fontSize:
                                            //                   //                   14),
                                            //                   //           decoration:
                                            //                   //               InputDecoration(
                                            //                   //             border:
                                            //                   //                 InputBorder.none,
                                            //                   //             hintText:
                                            //                   //                 "Address",
                                            //                   //           ),
                                            //                   //         ),
                                            //                   //       ),
                                            //                   //     ),
                                            //                   //   ],
                                            //                   // ),
                                            //                   TextButton(
                                            //                       onPressed:
                                            //                           () {
                                            //                         setState(
                                            //                             () {
                                            //                           address =
                                            //                               addresscontroller
                                            //                                   .text;
                                            //                           subaddress =
                                            //                               subaddresscontroller
                                            //                                   .text;
                                            //                         });
                                            //                         Navigator.pop(
                                            //                             context);
                                            //                       },
                                            //                       child:
                                            //                           const Text(
                                            //                         "Submit",
                                            //                         style: TextStyle(
                                            //                             color: Colors
                                            //                                 .black,
                                            //                             fontSize:
                                            //                                 15),
                                            //                       )),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           );
                                            //         });
                                            //   },
                                            //   child: Padding(
                                            //     padding: const EdgeInsets.only(
                                            //         right: 30),
                                            //     child: Column(
                                            //       children: [
                                            //         Text(
                                            //           "CHANGE",
                                            //           style: TextStyle(
                                            //             color: Colors.grey[600],
                                            //           ),
                                            //         )
                                            //       ],
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 2,
                                          indent: 300,
                                          endIndent: 30,
                                        ),
                                        Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(subaddresscontroller
                                                          .text ==
                                                      ""
                                                  ? '${subaddress}'
                                                  : subaddresscontroller.text),
                                            )
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                              SizedBox(
                                height: 50,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: address != null
                                    ? MaterialButton(
                                        height: Height / 22,
                                        minWidth: Width * 0.8,
                                        onPressed: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => PaymentScreen(
                                                  longitude: position.longitude,
                                                  latitude: position.latitude,
                                                  address: addresscontroller
                                                              .text ==
                                                          ""
                                                      ? address
                                                      : addresscontroller.text,
                                                  subaddress:
                                                      subaddresscontroller
                                                                  .text ==
                                                              ""
                                                          ? subaddress
                                                          : subaddresscontroller
                                                              .text,
                                                  off: off,
                                                  total: total,
                                                  items: items)));
                                        },
                                        color: Color(0xfffeda704),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          "Make Payment",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      )
                                    : Container(
                                        height: 100,
                                        child:
                                            Center(child: const CircularProgressIndicator()),
                                      ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      child: Image.asset("assets/images/12.png"),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}

class PaymentDetail extends StatelessWidget {
  const PaymentDetail({
    Key? key,
    required this.off,
    required this.total,
  }) : super(key: key);

  final int off;

  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Detail",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "Total M.R.P",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '₹' + '${total}',
                    style: TextStyle(
                        color: textcolorblack,
                        // fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )
                ],
              ),
            ],
          ),
          Divider(
            thickness: 1,
            endIndent: 0,
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "Product Discount",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '₹' + '${off}',
                    style: TextStyle(
                        color: textcolorblack,
                        // fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )
                ],
              ),
            ],
          ),
          Divider(
            thickness: 1,
            endIndent: 25,
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                        color: textcolorblack, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '₹' + '${total - off}',
                    style: TextStyle(
                        color: textcolorblack,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "You Save ₹" + ' ${off}',
                    style: TextStyle(
                      color: greencolor,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
