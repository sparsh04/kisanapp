import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/CustomCard.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool issearching = false;
  var userStream;

  TextEditingController searchUsernameeditingcontroller =
      TextEditingController();

  onSearchBtnCLick() async {
    issearching = true;
    userStream = await getProductByName(searchUsernameeditingcontroller.text);
    setState(() {});
  }

  Stream<QuerySnapshot> getProductByName(String productname) {
    Stream<QuerySnapshot> user = FirebaseFirestore.instance
        .collection("Products")
        .where("name", isGreaterThanOrEqualTo: productname)
        .snapshots();
    return user;
  }

  StreamBuilder searchUsersList() {
    //WidgetsFlutterBinding.ensureInitialized();
    return StreamBuilder<dynamic>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            return ListView.builder(
                physics: ScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data!.docs[index];
                  Map<String, dynamic> map =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
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
                });
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final Height = MediaQuery.of(context).size.height;
    final Width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: Height / 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: whitecolors,
              ),
              child: TextField(
                controller: searchUsernameeditingcontroller,
                onSubmitted: (name) {
                  onSearchBtnCLick();
                },
                decoration: InputDecoration(
                    icon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (searchUsernameeditingcontroller.text != "") {
                            onSearchBtnCLick();
                          }
                        },
                        child: Icon(
                          Icons.search,
                          color: orangecolor,
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: "Search Here"),
              ),
            ),
            issearching ? searchUsersList() : Container(),

            // Container(
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       ListView.builder(
            //           physics: ScrollPhysics(),
            //           itemCount: 5,
            //           shrinkWrap: true,
            //           itemBuilder: (context, index) {
            //             return Padding(
            //               padding: const EdgeInsets.symmetric(
            //                   horizontal: 15, vertical: 8),
            //               child: Container(
            //                 decoration: BoxDecoration(
            //                     color: Colors.white,
            //                     borderRadius: BorderRadius.circular(10),
            //                     boxShadow: [
            //                       BoxShadow(
            //                           offset: Offset(0, 10),
            //                           blurRadius: 33,
            //                           color:
            //                               Color(0xffd3d3d3).withOpacity(0.90))
            //                     ]),
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(8.0),
            //                   child: Row(
            //                     // crossAxisAlignment: CrossAxisAlignment.center,
            //                     mainAxisAlignment: MainAxisAlignment.start,
            //                     children: [
            //                       SizedBox(
            //                         width: 20,
            //                       ),
            //                       Stack(
            //                         children: [
            //                           Container(
            //                             child: CircleAvatar(
            //                               radius: 40,
            //                               backgroundImage: NetworkImage(
            //                                   'https://firebasestorage.googleapis.com/v0/b/bite-food-bbf6c.appspot.com/o/photo-1604382354936-07c5d9983bd3.jpg?alt=media&token=463ccb00-a652-496a-988e-03cd64e0b8f1'),
            //                             ),
            //                           ),
            //                           Positioned(
            //                             bottom: 40,
            //                             left: -10,
            //                             child: SizedBox(
            //                               height: 50,
            //                               width: 50,
            //                               child: Image.asset(
            //                                   "assets/images/nonveg.png"),
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                       Spacer(),
            //                       Column(
            //                         mainAxisSize: MainAxisSize.min,
            //                         crossAxisAlignment:
            //                             CrossAxisAlignment.start,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Text(
            //                             'Dosa' as String,
            //                             style: headingstyle(),
            //                           ),
            //                           SizedBox(
            //                             height: 5,
            //                           ),
            //                           Text(
            //                             'in Starter' as String,
            //                             style: subheadingstyle(),
            //                           ),
            //                           SizedBox(
            //                             height: 25,
            //                           ),
            //                           Text(
            //                             '₹ 200',
            //                             style: headingstyle(),
            //                           ),
            //                         ],
            //                       ),
            //                       Spacer(),
            //                       Container(
            //                         margin: EdgeInsets.only(top: 20, left: 35),
            //                         child: Column(
            //                           mainAxisSize: MainAxisSize.min,
            //                           children: [
            //                             GestureDetector(
            //                               child: Container(
            //                                 child: Icon(
            //                                   Icons.favorite,
            //                                   color: Colors.red,
            //                                 ),
            //                               ),
            //                             ),
            //                             GestureDetector(
            //                               onTap: () {},
            //                               child: Container(
            //                                 alignment: Alignment.center,
            //                                 margin: EdgeInsets.only(top: 25),
            //                                 height: Height / 25,
            //                                 width: Width / 5,
            //                                 decoration: BoxDecoration(
            //                                     color: Color(0xfffe0c00d),
            //                                     borderRadius:
            //                                         BorderRadius.circular(5)),
            //                                 child: Text(
            //                                   "Add",
            //                                   style: TextStyle(
            //                                       fontWeight: FontWeight.bold,
            //                                       color: Colors.white),
            //                                 ),
            //                               ),
            //                             )
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             );
            //           }),
            //       SizedBox(height: 10)
            //     ],
            //   ),
            // )
          ],
        ),
      )),
    );
  }
}
