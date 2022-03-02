import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_kisan/Component/category_roundcard.dart';
import 'package:my_kisan/accessories/Position.dart';
import 'package:my_kisan/accessories/local_notification_service.dart';
import 'package:my_kisan/accessories/sharedpref_helper.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/Cart_Screen.dart';
import 'package:my_kisan/screens/CustomCard.dart';
import 'package:my_kisan/screens/Maindrawer.dart';
import 'package:my_kisan/screens/categorylistscreen.dart';
import 'package:my_kisan/screens/notification_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  static String routName = "/home_screen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var categorystream,
      couponsstream,
      notificationstream,
      position,
      //  location,
      address,
      carttotal,
      cartitem,
      resturantstream;
  List slideslist = [];
  List<Map> categorlist = [];

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCcategories() async {
    return FirebaseFirestore.instance.collection("Category").snapshots();
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCcoupons() async {
    return FirebaseFirestore.instance.collection("Coupons").snapshots();
  }

  getcoupons() async {
    couponsstream = await getCcoupons();
    setState(() {});
  }

  getcategories() async {
    categorystream = await getCcategories();
    setState(() {});
  }

  getNotifications() async {
    notificationstream = await getuserNotifications();
    setState(() {});
  }

  getuserresturant() async {
    resturantstream = await getresturants();
    //setState(() {});
  }

  getCcarttotal() async {
    carttotal = await getcarttotal();
    setState(() {});
  }

  _requestPermisiion() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Done');
    } else if (status.isDenied) {
      _requestPermisiion();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  doThisOnLaunch() async {
    _requestPermisiion();
    categorlist = await categoryllist();
    slideslist = await sliderllist();
    //await getlocation();
    await getcategories();
    await getNotifications();
    await getCcarttotal();
    await getcoupons();
    // await getuser();
    SharedPreferncehelper.saveUserLoggedInSharedPreference(true);
    getuserresturant();
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   WidgetsFlutterBinding.ensureInitialized();
  //   doThisOnLaunch();
  //   super.didChangeDependencies();
  // }
  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .set({'token': token}, SetOptions(merge: true));
  }

  @override
  void initState() {
    storeNotificationToken();
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNOtificationService.createanddisplaynotification(message);
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );

    setState(() {
      //  this.cartitem = getuser();
    });
    super.initState();
    MainDrawer();

    doThisOnLaunch();
  }

  Future<Stream<QuerySnapshot>> getuserNotifications() async {
    return FirebaseFirestore.instance.collection("Notifications").snapshots();
  }

  Future<Stream<QuerySnapshot>> getcarttotal() async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.phoneNumber)
        .collection("cart")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getresturants() async {
    return FirebaseFirestore.instance.collection("Products").snapshots();
  }

  Future<List<Map>> categoryllist() async {
    List<Map> categorylist = [];
    await FirebaseFirestore.instance.collection("Category").get().then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        String image = element['Imgurl'];
        String name = element['Name'];
        Map a = {name: image};
        // sliderlist[name] = percentage;
        categorylist.add(a);
      });
    });
    print(categorylist);
    return categorylist;
  }

  Future<List> sliderllist() async {
    List sliderlist = [];
    await FirebaseFirestore.instance.collection('Slider').get().then((value) {
      List<DocumentSnapshot> ls = value.docs;
      ls.forEach((element) {
        String name = element['imgurl'];
        var a = name;
        // sliderlist[name] = percentage;
        sliderlist.add(a);
      });
    });
    // print(sliderlist);
    return sliderlist;
  }

  Widget Offersbody({
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 100,
                width: 130,
                child: SvgPicture.asset(image),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int activeIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final Height = MediaQuery.of(context).size.height;
    final Width = MediaQuery.of(context).size.width;
    return Scaffold(
        drawer: Drawer(
          child: MainDrawer(),
          backgroundColor: greencolor,
        ),
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: greencolor,
          centerTitle: true,
          title: Text("My Kisan"),
          leading: IconButton(
            onPressed: () {
              _scaffoldkey.currentState!.openDrawer();
            },
            icon: Image.asset(
              "assets/images/paragraph.png",
              color: Colors.white,
              width: 30,
            ),
          ),
          actions: [
            StreamBuilder(
                stream: notificationstream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  {
                    if (!snapshot.hasData) {
                      return Container();
                    } else
                      return IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, NotificationScreen.routName);
                          },
                          icon: Badge(
                              badgeContent: Text(
                                snapshot.hasData
                                    ? '${snapshot.data!.docs.length}'
                                    : "0",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              animationDuration: Duration(milliseconds: 300),
                              child: Icon(
                                Icons.notifications,
                                size: 25,
                              )));
                  }
                }),
            StreamBuilder(
                stream: carttotal,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CartScreen()));
                        //   Navigator.pushNamed(context, CartScreen.routName);
                      },
                      icon: Badge(
                          badgeContent: Text(
                            snapshot.hasData
                                ? '${snapshot.data!.docs.length}'
                                : "0",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          animationDuration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.shopping_cart,
                            size: 25,
                          )));
                }),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Row(
              children: [
                Container(
                  height: Height / 20,
                ),
                //location
                // InkWell(
                //   child: Container(
                //     margin: EdgeInsets.only(top: 15, left: 10),
                //     height: Height / 20,
                //     // width: Width * 0.4 - 10,
                //     decoration: BoxDecoration(
                //       color: whitecolors,
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                //       children: [
                //         Image.asset(
                //           "assets/images/location.png",
                //           width: 25,
                //         ),
                //         Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Padding(
                //               padding: const EdgeInsets.only(right: 10),
                //               child: Text(
                //                 '${address}',
                //                 style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     fontSize:
                //                         MediaQuery.of(context).size.height /
                //                             55),
                //               ),
                //             )
                //           ],
                //         )
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 55),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  children: [
                    Text("Popular Categories",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 40)),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            //cateogry list
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 100,
                child: StreamBuilder(
                  stream: categorystream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (!snapshot.hasData) {
                        return Container();
                      } else
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> map =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryListScreen(map: map)));
                                },
                                child: CategoryRoundCard(
                                    image: map["Imgurl"], name: map["Name"]),
                              );
                            });
                    } else {
                      return Container(height: 40, child: Container());
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //slider
            slideslist.length != 0
                ? Column(
                    children: [
                      CarouselSlider.builder(
                        itemCount: slideslist.length,
                        itemBuilder: (context, itemIndex, realIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(slideslist[itemIndex]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          aspectRatio: 16 / 9,
                          initialPage: 1,
                          enableInfiniteScroll: true,
                          autoPlayInterval: Duration(seconds: 2),
                          onPageChanged: (index, reason) =>
                              setState(() => activeIndex = index),
                          autoPlay: true,
                          height: MediaQuery.of(context).size.height * 0.2 + 5,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      buildIndicator(slideslist.length),
                    ],
                  )
                : Container(),

            Column(children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15, left: 10),
                    height: MediaQuery.of(context).size.height / 20,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          "assets/images/offer.png",
                          width: 25,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: Text(
                                "Offers for you",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            55),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 80,
                  child: StreamBuilder(
                    stream: couponsstream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> map =
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
                                return Card(
                                  elevation: 10,
                                  child: Center(
                                    child: Container(
                                      height: 80,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            map["code"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                // return Container(
                                //     margin: EdgeInsets.all(10),
                                //     decoration:
                                //         BoxDecoration(color: Colors.blue),
                                //     height: 100,
                                //     width:
                                //         MediaQuery.of(context).size.width / 4,
                                //     // map["code"],

                                //     child: Card(child: Text(map["code"])));
                              });
                        } else {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Offersbody(
                                      image: "assets/images/discount_50.svg"),
                                  Offersbody(
                                      image: "assets/images/discount_25.svg"),
                                  Offersbody(
                                      image: "assets/images/discount_15.svg"),
                                  Offersbody(
                                      image: "assets/images/discount_10.svg"),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return Container(height: 20, child: Container());
                      }
                    },
                  ),
                ),
              ),
              //offers body

              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: MediaQuery.of(context).size.height / 20,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              "assets/images/offer.png",
                              width: 25,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: Text(
                                    "Best Selling",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textcolorblack,
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                55),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
            //   Container(
            //   height: 300,
            //    child:
            Container(
              padding: EdgeInsets.all(10),
              child: StreamBuilder(
                  stream: resturantstream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    print(resturantstream);
                    if (snapshot.connectionState == ConnectionState.active) {
                      return Container(
                        // alignment: Alignment.center,
                        height: snapshot.data!.docs.length * 150.00,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return CustomeProductCard(
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
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
            //  ),
          ]),
        ));
  }

  Widget buildIndicator(int length) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: length,
        effect: ExpandingDotsEffect(
          dotHeight: 8,
          dotWidth: 10,
          activeDotColor: orangecolor,
          dotColor: yellowcolor,
        ),
      );
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    Key? key,
    required this.image,
    required this.resturantname,
    required this.submenus,
    required this.ontap,
  }) : super(key: key);
  final String image;
  final String resturantname;
  final String submenus;
  final VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // SizedBox(
              //     height: screenHeight(context) * 0.15,
              //     child: Image.network(image)),
              Container(
                // margin: EdgeInsets.only(left: 15, top: 10),
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height / 12,
                width: MediaQuery.of(context).size.height * 0.1 - 10,
                // color: Colors.red,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(image),
                ),
              ),
              SizedBox(
                width: 7,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resturantname,
                    style: headingstyle(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    submenucard(name: submenus),
                  ]),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Container submenucard({required String name}) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
      decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        submenus,
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
