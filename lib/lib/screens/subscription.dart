import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/subscription_details.dart';

import '../size_config.dart';

class Subscription extends StatefulWidget {
  const Subscription({Key? key}) : super(key: key);

  @override
  _SubscriptionState createState() => _SubscriptionState();
}
User? user = FirebaseAuth.instance.currentUser;

int choose = 0;
List subsList = [];


 late Timer timer;

class _SubscriptionState extends State<Subscription> {
  getData() async {
    await FirebaseFirestore.instance.collection("subscription").get().then(
          (value) => subsList = value.docs.map((e) => e.data()).toList(),
    );
  }
  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {});
      timer.cancel();
    });
    getData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              const SizedBox(
                width: 219,
                child: Text("Choose your Subscription plan",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 31,
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                    reverse: true,
                    itemCount: subsList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              choose = index;
                            },
                            child: Container(
                              width: screenWidth(context) - 30,
                              height: 80,
                              decoration: BoxDecoration(
                                  color: choose == index
                                      ? greencolor
                                      : Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: Border.all(color: greencolor)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Checkbox(
                                      shape: const CircleBorder(),
                                      side: const BorderSide(color: greencolor),
                                      checkColor: greencolor,
                                      activeColor: Colors.white,
                                      value: choose == index,
                                      onChanged: (newValue) {
                                        setState(() {
                                          choose = index;
                                        });
                                      }),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        subsList[index]["title"],
                                        style: TextStyle(
                                            color: choose == index
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      Text(
                                        subsList[index]["description"],
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: choose == index
                                                ? Colors.white
                                                : Colors.black54),
                                      )
                                    ],
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text:
                                              'Rs. ${subsList[index]["billingAmount"]} ',
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: choose == index
                                                  ? Colors.white
                                                  : Colors.black)),
                                      WidgetSpan(
                                        child: Transform.translate(
                                          offset: const Offset(2, -10),
                                          child: Text(
                                            '/${subsList[index]["time"]}',
                                            //superscript is usually smaller in size
                                            textScaleFactor: 0.7,
                                            style: TextStyle(
                                                color:
                                                    choose == index
                                                        ? Colors.white
                                                        : Colors.black54),
                                          ),
                                        ),
                                      )
                                    ]),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () async {
                  print(user!.phoneNumber);
                  /// for updating the subscription in firebase
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(user!.phoneNumber)
                      .collection('activeSubscription')
                      .doc().set( {
                    "plan": subsList[choose]["title"],
                    "NextBillDate": DateTime.now().add(Duration(days: 28)).toString(),
                    "billingAmount": subsList[choose]["billingAmount"],
                    "description": subsList[choose]["description"],
                    "amountReceived": subsList[choose]["value"],
                  });
                  FirebaseFirestore.instance.collection("users").doc(user!.phoneNumber).update({
                    "isSubscribed" : true
                  });

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => SubscriptionDetails()));
                },
                child: Center(
                  child: Container(
                    width: 138,
                    height: 50,
                    decoration: const BoxDecoration(
                        color: greencolor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: const Center(
                        child: Text(
                      "Choose",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
