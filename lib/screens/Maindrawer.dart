import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_kisan/Component/bottom_bar.dart';
import 'package:my_kisan/accessories/sharedpref_helper.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/Login_Screen.dart';
import 'package:my_kisan/screens/credit.dart';
import 'package:my_kisan/screens/orders.dart';
import 'package:my_kisan/screens/subscription.dart';
import 'package:my_kisan/screens/subscription_details.dart';
import 'package:my_kisan/screens/wallet.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  var myName;
  String? myname, mynumber;
  var nmae;
 bool isSubscribed = false ;
  @override
  void initState() {
    nmae = FirebaseAuth.instance.currentUser!.displayName;
    _fetch();
    onScreenloaded();
    super.initState();
  }

  onScreenloaded() async {
    await getMyInfoFromSHaredPrefrences();
    //getChatRooms();
  }

  getMyInfoFromSHaredPrefrences() async {
    myName = await SharedPreferncehelper().getDisplayName();
    mynumber = await SharedPreferncehelper().getUSerId();
  }

  _fetch() async {
    final firebaseUser = await FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.phoneNumber)
          .get()
          .then((ds) {
        //     ls = ds.docs;
        myname = ds.data()!['Firstname'];
        isSubscribed = ds.data()!["isSubscribed"];
        print(myname);
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                  // color: Color(0xFF40D876)
                  ),
              accountName: Row(
                children: [
                  Text(
                    myname != null
                        ? myname
                        : (myName != null
                            ? myName
                            : (nmae != null ? nmae : "User")),
                    // _auth.currentUser!.displayName != ""
                    //     ? _auth.currentUser!.displayName
                    //     : "User",
                    style: new TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              accountEmail: new Text(
                mynumber != null
                    ? myName as String
                    : _auth.currentUser!.phoneNumber as String,
                style: new TextStyle(fontSize: 16.0),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(
                  "assets/images/user.png",
                ),
                //       NetworkImage(_auth.currentUser!.photoURL as String),
              ),
              otherAccountsPictures: <Widget>[],
            ),
          ],
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => BottomBar(0)));

        },
        leading: Icon(
          Icons.home,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Home",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => BottomBar(1)));
        },
        leading: Icon(
          Icons.dashboard,
          color: Colors.white,
        ),
        title: Text(
          "Categories",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => BottomBar(3)));
        },
        leading: Icon(
          Icons.favorite_border,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Wishlist",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Orders()));
        },
        leading: Icon(
          Icons.card_travel,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Order",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => MyWallet()));
          //  Navigator.pushNamed(context, MyWallet.routName);
        },
        leading: Icon(
          Icons.account_balance_wallet_rounded,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Wallet",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => isSubscribed ? SubscriptionDetails() : Subscription()));
        },
        leading: Icon(
          Icons.account_balance_wallet_rounded,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Subscription",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Credit()));
          //  Navigator.pushNamed(context, MyWallet.routName);
        },
        leading: Icon(
          Icons.account_balance_wallet_rounded,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Credits",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
      ListTile(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()));
        },
        leading: Icon(
          Icons.power_settings_new,
          size: 24,
          color: Colors.white,
        ),
        title: Text(
          "Logout",
          style: new TextStyle(fontSize: 16.0, color: whitecolors),
        ),
      ),
    ]);
  }
}
