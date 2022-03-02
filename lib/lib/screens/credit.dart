import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_kisan/all_list.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/size_config.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

class Credit extends StatefulWidget {
  static String routName = "/my_credit";
  const Credit({Key? key}) : super(key: key);

  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  final creditcontroller = TextEditingController();
  double total = 0.000;
  //double spent = 0.000;
  var _razorpay, credittransactionstream;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    getcart();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  getcart() async {
    double temp = await getTotal();
    this.credittransactionstream = await getusercredit();
    setState(() {
      total = temp;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<Stream<QuerySnapshot>> getusercredit() async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection("credit")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_Mqukymbnx3hIYA",
      "amount":
          ((num.parse(creditcontroller.text) * 100) * 100).round() / 100.00,
      "name": "CFJ-Ulrapi App",
      "description": "Credit Payment",
      "prefill": {"contact": FirebaseAuth.instance.currentUser!.phoneNumber},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  onsuccess() async {
    setState(() {});
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final String formattedTime = DateFormat.Hms().format(now);
    Map<String, dynamic> userInfoMap = {
      "amount": (double.parse(creditcontroller.text) * 100).round() / 100.00,
      "time": formattedTime,
      "date": formatted,
      "type": "Credit Payment",
      "ts": DateTime.now(),
    };

    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection("credit")
        .doc(randomNumeric(10))
        .set(userInfoMap);

    await getTotal();
    setState(() {});
  }

  onFailure() async {
    setState(() {});
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final String formattedTime = DateFormat.Hms().format(now);
    Map<String, dynamic> userInfoMap = {
      "amount": (double.parse(creditcontroller.text) * 100).round() / 100.00,
      "time": formattedTime,
      "date": formatted,
      "type": "Failure",
      "ts": DateTime.now(),
    };

    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection("credit")
        .doc(randomNumeric(10))
        .set(userInfoMap);

    await getTotal();
    setState(() {});
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Payment successfull")));

    onsuccess();
    getTotal();
    setState(() {});
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Payment Failed")));

    onFailure();
    getTotal();
    setState(() {});
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("External Wallet selected")));

    onsuccess();
    getTotal();
    setState(() {});
  }

  Future<double> getTotal() async {
    double to = 0.00;
    double recharge = 0.00, spent = 0.00;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection('credit')
        .where("type", isEqualTo: "Credit Payment")
        .get()
        .then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        num credits = element['amount'];
        recharge += (credits);
      });
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection('credit')
        .where("type", isEqualTo: "credit")
        .get()
        .then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        num credits = element['amount'];
        spent += (credits);
      });
    });

    to = spent - recharge;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .update({"spent": to});

    return to;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Pay Later"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("Phonenumber",
                          isEqualTo:
                              FirebaseAuth.instance.currentUser!.phoneNumber)
                      // .doc(widget.map['orderid'])
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active &&
                        snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                " To Pay   ",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                  snapshot.data!.docs[0]['spent'] != ""
                                      //  snapshot.data!.docs[0]['credits'] != Null
                                      ? '${snapshot.data!.docs[0]['spent']}'
                                      : '${total}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: greencolor)),
                              Spacer(),
                            ],
                          ),

                          SizedBox(
                            height: 20,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Container(
                                  height: screenHeight(context) * 0.05,
                                  width: screenWidth(context) / 6,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: creditcontroller,
                                    decoration: InputDecoration(
                                      prefix: Text("₹"),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      prefixStyle: TextStyle(
                                          color: greencolor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                              ),
                              GestureDetector(
                                onTap: () => {
                                  if (num.parse(creditcontroller.text) <= total)
                                    {
                                      openCheckout(),
                                      setState(() {}),
                                      FocusScope.of(context).unfocus(),
                                    }
                                  else
                                    {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "You cant Pay more than you owe"),
                                        ),
                                      ),
                                      FocusScope.of(context).unfocus(),
                                    }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: orangecolor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text("Repay Money",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          //transaction tab bar
                          Container(
                            padding: new EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2.2,
                                  width: double.infinity,
                                  child: StreamBuilder(
                                      stream: credittransactionstream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.active) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 5),
                                            child: ListView.builder(
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  Map<String, dynamic> map =
                                                      snapshot.data!.docs[index]
                                                              .data()
                                                          as Map<String,
                                                              dynamic>;
                                                  return transactionCard(
                                                      map: map);
                                                }),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ),
                          //transaction card
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Widget transactionCard({
    required Map<String, dynamic> map,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5, bottom: 5, top: 5),
      child: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(0, 0),
                  blurRadius: 5)
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  map['date'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(map['type'],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.5))),
                SizedBox(
                  height: 5,
                ),
                Text(map['time'],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.5))),
              ],
            ),
            Text(
              '${map['amount']}',
              style: TextStyle(color: greencolor),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:my_kisan/all_list.dart';
// import 'package:my_kisan/constant.dart';
// import 'package:my_kisan/size_config.dart';
// import 'package:buttons_tabbar/buttons_tabbar.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:random_string/random_string.dart';
// import 'package:intl/intl.dart';

// class Credit extends StatefulWidget {
//   static String routName = "/my_wallet";
//   const Credit({Key? key}) : super(key: key);

//   @override
//   State<Credit> createState() => _CreditState();
// }

// class _CreditState extends State<Credit> {
//   final creditcontroller = TextEditingController();
//   num total = 0.000;
//   var _razorpay, wallettransactionstream, walletcreditstream;

//   @override
//   void initState() {
//     WidgetsFlutterBinding.ensureInitialized();
//     getcart();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     super.initState();
//   }

//   getcart() async {
//     num temp = await getTotal();
//     this.wallettransactionstream = await getuserwallet();
//     this.walletcreditstream = await getusercredit();
//     setState(() {
//       total = temp;
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _razorpay.clear();
//   }

//   Future<Stream<QuerySnapshot>> getuserwallet() async {
//     return FirebaseFirestore.instance
//         .collection("users")
//         .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
//         .collection("wallet")
//         .where("type", isNotEqualTo: "credit")
//         //.orderBy("ts", descending: true)
//         .snapshots();
//   }

//   Future<Stream<QuerySnapshot>> getusercredit() async {
//     return FirebaseFirestore.instance
//         .collection("users")
//         .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
//         .collection("wallet")
//         //.orderBy("ts", descending: true)
//         .where("type", isEqualTo: "credit")
//         .snapshots();
//   }

//   void openCheckout() {
//     var options = {
//       "key": "rzp_test_Mqukymbnx3hIYA",
//       "amount":
//           ((num.parse(creditcontroller.text) * 100) * 100).round() / 100.00,
//       "name": "CFJ-Ulrapi App",
//       "description": "Payment for items ordered",
//       "prefill": {"contact": FirebaseAuth.instance.currentUser!.phoneNumber},
//       "external": {
//         "wallets": ["paytm"]
//       }
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   onsuccess() async {
//     setState(() {});
//     final DateTime now = DateTime.now();
//     final DateFormat formatter = DateFormat('yyyy-MM-dd');
//     final String formatted = formatter.format(now);
//     final String formattedTime = DateFormat.Hms().format(now);
//     Map<String, dynamic> userInfoMap = {
//       "amount": (num.parse(creditcontroller.text) * 100).round() / 100.00,
//       "time": formattedTime,
//       "date": formatted,
//       "type": "Recharge",
//       "ts": DateTime.now(),
//     };

//     FirebaseFirestore.instance
//         .collection("users")
//         .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
//         .collection("wallet")
//         .doc(randomNumeric(10))
//         .set(userInfoMap);

//     await getTotal();
//     setState(() {});
//   }

//   onFailure() async {
//     setState(() {});
//     final DateTime now = DateTime.now();
//     final DateFormat formatter = DateFormat('yyyy-MM-dd');
//     final String formatted = formatter.format(now);
//     final String formattedTime = DateFormat.Hms().format(now);
//     Map<String, dynamic> userInfoMap = {
//       "amount": (num.parse(creditcontroller.text) * 100).round() / 100.00,
//       "time": formattedTime,
//       "date": formatted,
//       "type": "Failure",
//       "ts": DateTime.now(),
//     };

//     FirebaseFirestore.instance
//         .collection("users")
//         .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
//         .collection("wallet")
//         .doc(randomNumeric(10))
//         .set(userInfoMap);

//     await getTotal();
//     setState(() {});
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("Payment successfull")));

//     onsuccess();
//     getTotal();
//     setState(() {});
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     // Do something when payment fails
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("Payment Failed")));

//     onFailure();
//     getTotal();
//     setState(() {});
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     // Do something when an external wallet was selected
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("External Wallet selected")));

//     onsuccess();
//     getTotal();
//     setState(() {});
//   }

//   Future<num> getTotal() async {
//     num total = 0.00;
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
//         .collection('wallet')
//         .where("type", isNotEqualTo: "Failure")
//         .get()
//         .then((value) {
//       List<DocumentSnapshot> ls = value.docs;
//       ls.forEach((element) {
//         num price = element['amount'];
//         total += (price);
//       });
//     });

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
//         .update({"wallettotal": total});

//     return total;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: SafeArea(
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text("Wallet"),
//           ),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "My kisan Wallet",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.w700),
//                       ),
//                       CircleAvatar(
//                         radius: 36,
//                         backgroundColor: orangecolor.withOpacity(0.4),
//                         child: Icon(
//                           Icons.account_balance_wallet_rounded,
//                           color: Colors.white,
//                           size: 36,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text("₹" + '${total}',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: greencolor)),
//                   SizedBox(
//                     height: 10,
//                   ),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: screenHeight(context) * 0.05,
//                           width: screenWidth(context) / 6,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             controller: creditcontroller,
//                             decoration: InputDecoration(
//                               prefix: Text("₹"),
//                               contentPadding:
//                                   EdgeInsets.symmetric(horizontal: 20),
//                               prefixStyle: TextStyle(
//                                   color: greencolor,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 100,
//                       ),
//                       GestureDetector(
//                         onTap: () => {
//                           openCheckout(),
//                           setState(() {}),
//                         },
//                         child: Container(
//                           alignment: Alignment.center,
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                               color: orangecolor,
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Text("Add money",
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Divider(
//                     thickness: 1,
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   //transaction tab bar
//                   Container(
//                     padding: new EdgeInsets.all(10.0),
//                     child: DefaultTabController(
//                         length: 2,
//                         child: Column(
//                           children: [
//                             ButtonsTabBar(
//                                 height: screenHeight(context) * 0.05,
//                                 buttonMargin:
//                                     EdgeInsets.symmetric(horizontal: 15),
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 10, vertical: 0),
//                                 labelStyle: TextStyle(color: Colors.black),
//                                 backgroundColor: orangecolor,
//                                 unselectedBackgroundColor:
//                                     orangecolor.withOpacity(0.5),
//                                 unselectedLabelStyle: TextStyle(
//                                   color: Colors.black,
//                                 ),
//                                 tabs: [
//                                   Tab(
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       width: screenWidth(context) / 4,
//                                       child: Text(
//                                         "Recharge",
//                                         style: TextStyle(color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                                   Tab(
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       width: screenWidth(context) / 4,
//                                       child: Text("Credit",
//                                           style:
//                                               TextStyle(color: Colors.white)),
//                                     ),
//                                   ),
//                                 ]),
//                             SizedBox(
//                               height: 20,
//                             ),
//                             SizedBox(
//                               height: MediaQuery.of(context).size.height / 2.2,
//                               width: double.infinity,
//                               child: TabBarView(children: [
//                                 StreamBuilder(
//                                     stream: wallettransactionstream,
//                                     builder: (BuildContext context,
//                                         AsyncSnapshot snapshot) {
//                                       if (snapshot.connectionState ==
//                                           ConnectionState.active) {
//                                         if (snapshot.hasData) {
//                                           return Padding(
//                                             padding: const EdgeInsets.only(
//                                                 left: 5.0, right: 5),
//                                             child: ListView.builder(
//                                                 itemCount:
//                                                     snapshot.data!.docs.length,
//                                                 itemBuilder:
//                                                     (BuildContext context,
//                                                         int index) {
//                                                   Map<String, dynamic> map =
//                                                       snapshot.data!.docs[index]
//                                                               .data()
//                                                           as Map<String,
//                                                               dynamic>;
//                                                   return transactionCard(
//                                                       map: map);
//                                                 }),
//                                           );
//                                         } else {
//                                           return Container();
//                                         }
//                                       } else {
//                                         return Container();
//                                       }
//                                     }),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 5.0, right: 5),
//                                   child: StreamBuilder(
//                                       stream: walletcreditstream,
//                                       builder: (BuildContext context,
//                                           AsyncSnapshot snapshot) {
//                                         if (snapshot.connectionState ==
//                                             ConnectionState.active) {
//                                           if (snapshot.hasData) {
//                                             return Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 5.0, right: 5),
//                                               child: ListView.builder(
//                                                   itemCount: snapshot
//                                                       .data!.docs.length,
//                                                   itemBuilder:
//                                                       (BuildContext context,
//                                                           int index) {
//                                                     Map<String, dynamic> map2 =
//                                                         snapshot.data!
//                                                                 .docs[index]
//                                                                 .data()
//                                                             as Map<String,
//                                                                 dynamic>;
//                                                     return transactionCard(
//                                                         map: map2);
//                                                   }),
//                                             );
//                                           } else {
//                                             return Container();
//                                           }
//                                         } else {
//                                           return Container();
//                                         }
//                                       }),
//                                 )
//                               ]),
//                             ),
//                           ],
//                         )),
//                   ),
//                   //transaction card
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget transactionCard({
//     required Map<String, dynamic> map,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 5.0, right: 5, bottom: 5, top: 5),
//       child: Container(
//         margin: EdgeInsets.only(top: 10),
//         padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   offset: Offset(0, 0),
//                   blurRadius: 5)
//             ]),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   map['date'],
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Text(map['type'],
//                     style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black.withOpacity(0.5))),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Text(map['time'],
//                     style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black.withOpacity(0.5))),
//               ],
//             ),
//             Text(
//               '${map['amount']}',
//               style: TextStyle(color: greencolor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
