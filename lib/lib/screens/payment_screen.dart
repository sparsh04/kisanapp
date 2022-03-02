import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/Cart_Screen.dart';
import 'package:my_kisan/screens/order_placed.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  double longitude;
  double latitude;
  String address;
  String subaddress;
  int off;
  int total;
  var items;
  PaymentScreen(
      {required this.longitude,
      required this.latitude,
      required this.address,
      required this.subaddress,
      required this.off,
      required this.total,
      this.items});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var _razorpay;
  var myname, mynumber;
 bool isSubscribed = false;
 int SubscribedAmount = 0 ;
  @override
  void initState() {
    // TODO: implement initState
    _razorpay = Razorpay();
    // myname = FirebaseAuth.instance.
    doThisOnLaunch();
    getuser();
    subscriptionAmount();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  doThisOnLaunch() {
    myname = FirebaseAuth.instance.currentUser!.displayName;
    mynumber = FirebaseAuth.instance.currentUser!.phoneNumber;
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_Mqukymbnx3hIYA",
      "amount": widget.total * 100,
      "name": "CFJ-Ulrapi App",
      "description": "Payment for items ordered",
      "prefill": {"contact": mynumber},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      //  print(e.toString());
    }
  }

  void addorders() async {
    String v = randomNumeric(10);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection("orders")
        .doc(v)
        .set({
      "longitude": widget.longitude,
      "latitude": widget.latitude,
      "address": widget.address + " " + widget.subaddress,
      "orderid": v,
      "orderlist": widget.items,
      "ts": DateTime.now(),
      "mode": "Online",
      "amount": widget.total - widget.off,
      "discount": widget.off,
      "status": "preparing"
    });
    ;

    // print(widget.items);

    await FirebaseFirestore.instance.collection("Orders").doc(v).set({
      "longitude": widget.longitude,
      "latitude": widget.latitude,
      "address": widget.address + " " + widget.subaddress,
      "orderid": v,
      "Phone": mynumber,
      "orderby": FirebaseAuth.instance.currentUser!.displayName,
      "orderlist": widget.items,
      "ts": DateTime.now(),
      "mode": "Online",
      "amount": widget.total - widget.off,
      "discount": widget.off,
      "status": "preparing"
    });
    ;

    await FirebaseFirestore.instance.collection("Payments").doc(v).set({
      "orderid": v,
      "Phone": mynumber,
      "orderby": FirebaseAuth.instance.currentUser!.displayName,
      "orderlist": widget.items,
      "ts": DateTime.now(),
      "mode": "Online",
      "amount": widget.total - widget.off,
      "discount": widget.off,
      "status": "preparing"
    });
    ;

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => OrderPalced()));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Payment successful")));
    addorders();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Payment Failed")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("External Wallet selected")));
  }

  Future<dynamic> getuser() async {
    final userdoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .get();

    final userdata = userdoc.data();
    isSubscribed =  userdata!["isSubscribed"];
    setState(() {
    });
    return userdata;
  }

  subscriptionAmount()async{
   await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.phoneNumber).collection("activeSubscription").get().then((value) {
    SubscribedAmount = value.docs[0]["amountReceived"];

    }
    );
  }

  var _result;
  @override
  Widget build(BuildContext context) {
    final Height = MediaQuery.of(context).size.height;
    final Width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                    activeColor: orangecolor,
                    value: '0',
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value;
                        //   print(_result);
                      });
                    }),
                Text(
                  "Online",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Radio(
                    activeColor: orangecolor,
                    value: '1',
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value;
                        // print(_result);
                      });
                    }),
                Text(
                  "Cash on Delivery",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Radio(
                    activeColor: orangecolor,
                    value: '2',
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value;
                      });
                    }),
                Text(
                  "Wallet",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ],
            ),
          isSubscribed ?  Row(
              children: [
                Radio(
                    activeColor: orangecolor,
                    value: '3',
                    groupValue: _result,
                    onChanged: (value) {
                      setState(() {
                        _result = value;
                        //   print(_result);
                      });
                    }),
                Text(
                  "Pay later",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )
              ],
            ) : SizedBox(),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PaymentDetail(
                off: widget.off,
                total: widget.total,
              ),
            ),
            Spacer(),
            MaterialButton(
              height: Height / 22,
              minWidth: Width * 0.8,
              onPressed: () async {
                if (_result.toString() == "1") {
                  String v = randomNumeric(10);

                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                      .collection("orders")
                      .doc(v)
                      .set({
                    "longitude": widget.longitude,
                    "latitude": widget.latitude,
                    "address": widget.address + " " + widget.subaddress,
                    "orderid": v,
                    "orderlist": widget.items,
                    "ts": DateTime.now(),
                    "mode": "COD",
                    "amount": widget.total - widget.off,
                    "discount": widget.off,
                    "status": "preparing"
                  });
                  ;

                  // print(widget.items + "cod");

                  await FirebaseFirestore.instance
                      .collection("Orders")
                      .doc(v)
                      .set({
                    "longitude": widget.longitude,
                    "latitude": widget.latitude,
                    "address": widget.address + " " + widget.subaddress,
                    "orderid": v,
                    "Phone": mynumber,
                    "orderby": FirebaseAuth.instance.currentUser!.displayName,
                    "orderlist": widget.items,
                    "ts": DateTime.now(),
                    "mode": "COD",
                    "amount": widget.total - widget.off,
                    "discount": widget.off,
                    "status": "preparing"
                  });
                  ;

                  await FirebaseFirestore.instance
                      .collection("Payments")
                      .doc(v)
                      .set({
                    "orderid": v,
                    "Phone": mynumber,
                    "orderby": FirebaseAuth.instance.currentUser!.displayName,
                    "orderlist": widget.items,
                    "ts": DateTime.now(),
                    "mode": "COD",
                    "amount": widget.total - widget.off,
                    "discount": widget.off,
                    "status": "preparing"
                  });
                  ;

                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => OrderPalced()));
                }

                if (_result.toString() == "3") {
                  var data = await getuser();
                  var credittotal;
                  if (data['spent'] == null) {
                    credittotal = 0;
                  } else {
                    credittotal = data['spent'].toInt();
                  }
                  var total = widget.total.toInt() - widget.off.toInt();
                   // print((wallettotal));
                  if (data['credit'] == "Allowed"  &&  SubscribedAmount - credittotal >= total) {
                    final DateTime now = DateTime.now();
                    final DateFormat formatter = DateFormat('yyyy-MM-dd');
                    final String formatted = formatter.format(now);
                    final String formattedTime = DateFormat.Hms().format(now);
                    Map<String, dynamic> userInfoMap = {
                      "amount": widget.total - widget.off,
                      "time": formattedTime,
                      "date": formatted,
                      "type": "credit",
                      "ts": DateTime.now(),
                    };

                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                        .collection("credit")
                        .doc(randomNumeric(10))
                        .set(userInfoMap);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                        .update({"spent": credittotal + total.toInt()});

                    String v = randomNumeric(10);
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                        .collection("orders")
                        .doc(v)
                        .set({
                      "longitude": widget.longitude,
                      "latitude": widget.latitude,
                      "address": widget.address + " " + widget.subaddress,
                      "orderid": v,
                      "orderlist": widget.items,
                      "ts": DateTime.now(),
                      "mode": "credit",
                      "amount": widget.total - widget.off,
                      "discount": widget.off,
                      "status": "preparing"
                    });
                    ;

                    // print(widget.items + "wallet");

                    await FirebaseFirestore.instance
                        .collection("Orders")
                        .doc(v)
                        .set({
                      "longitude": widget.longitude,
                      "latitude": widget.latitude,
                      "address": widget.address + " " + widget.subaddress,
                      "orderid": v,
                      "Phone": mynumber,
                      "orderby": FirebaseAuth.instance.currentUser!.displayName,
                      "orderlist": widget.items,
                      "ts": DateTime.now(),
                      "mode": "credit",
                      "amount": widget.total - widget.off,
                      "discount": widget.off,
                      "status": "preparing"
                    });
                    ;

                    await FirebaseFirestore.instance
                        .collection("Payments")
                        .doc(v)
                        .set({
                      "orderid": v,
                      "Phone": mynumber,
                      "orderby": FirebaseAuth.instance.currentUser!.displayName,
                      "orderlist": widget.items,
                      "ts": DateTime.now(),
                      "mode": "credit",
                      "amount": widget.total - widget.off,
                      "discount": widget.off,
                      "status": "preparing"
                    });
                    ;

                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => OrderPalced()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(" Pay your previous  Balance First " )));
                  }
                }

                if (_result.toString() == "0") {
                  openCheckout();
                }

                if (_result.toString() == "2") {
                  var data = await getuser();
                  var wallettotal;
                  if (data['wallettotal'] == null) {
                    wallettotal = 0;
                  } else {
                    wallettotal = data['wallettotal'].toInt();
                  }

                  var total = widget.total.toInt() - widget.off.toInt();
                  //  print((wallettotal));
                  // print((total));
                  if ((wallettotal) >= (total)) {
                    final DateTime now = DateTime.now();
                    final DateFormat formatter = DateFormat('yyyy-MM-dd');
                    final String formatted = formatter.format(now);
                    final String formattedTime = DateFormat.Hms().format(now);
                    Map<String, dynamic> userInfoMap = {
                      "amount": widget.total - widget.off,
                      "time": formattedTime,
                      "date": formatted,
                      "type": "Purchase",
                      "ts": DateTime.now(),
                    };

                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                        .collection("wallet")
                        .doc(randomNumeric(10))
                        .set(userInfoMap);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                        .update({"wallettotal": wallettotal - total.toInt()});

                    String v = randomNumeric(10);
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                        .collection("orders")
                        .doc(v)
                        .set({
                      "longitude": widget.longitude,
                      "latitude": widget.latitude,
                      "address": widget.address + " " + widget.subaddress,
                      "orderid": v,
                      "orderlist": widget.items,
                      "ts": DateTime.now(),
                      "mode": "Wallet",
                      "amount": widget.total - widget.off,
                      "discount": widget.off,
                      "status": "preparing"
                    });
                    ;

                    // print(widget.items + "wallet");

                    await FirebaseFirestore.instance
                        .collection("Orders")
                        .doc(v)
                        .set({
                      "longitude": widget.longitude,
                      "latitude": widget.latitude,
                      "address": widget.address + " " + widget.subaddress,
                      "orderid": v,
                      "Phone": mynumber,
                      "orderby": FirebaseAuth.instance.currentUser!.displayName,
                      "orderlist": widget.items,
                      "ts": DateTime.now(),
                      "mode": "Wallet",
                      "amount": widget.total - widget.off,
                      "discount": widget.off,
                      "status": "preparing"
                    });
                    ;

                    await FirebaseFirestore.instance
                        .collection("Payments")
                        .doc(v)
                        .set({
                      "orderid": v,
                      "Phone": mynumber,
                      "orderby": FirebaseAuth.instance.currentUser!.displayName,
                      "orderlist": widget.items,
                      "ts": DateTime.now(),
                      "mode": "Wallet",
                      "amount": widget.total - widget.off,
                      "discount": widget.off,
                      "status": "preparing"
                    });
                    ;

                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => OrderPalced()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Wallet Balance Not Enough")));
                  }
                }
              },
              color: Color(0xfffeda704),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
