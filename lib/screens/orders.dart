import 'package:flutter/material.dart';
import 'package:my_kisan/screens/track_order.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List items = [
    {'name': 'Dosa', 'count': '2'},
    {'name': 'Paneer', 'count': '2'},
    {'name': 'Cake', 'count': '1'},
    {'name': 'Dosa', 'count': '4'}
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // scrollDirection: Axis.vertical,
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 1,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                                2.0, 2.0), // shadow direction: bottom right
                          )
                        ],
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Color(0xfffe0c00d),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Text('Rolex Hotel',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  Spacer(),
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Text('01/02/2022 11:30 PM',
                                          style:
                                              TextStyle(color: Colors.white)))
                                ],
                              ),

                              SizedBox(height: 10),
                              Wrap(
                                children: items
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: Chip(
                                            label: Text(
                                                '${e['name']}  X ${e['count']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                )),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              // ListView.builder(
                              //     shrinkWrap: true,
                              //     scrollDirection: Axis.vertical,
                              //     physics: NeverScrollableScrollPhysics(),
                              //     itemCount: 2,
                              //     itemBuilder: (context, index) {
                              //       return Text(
                              //         '${'Dosa'}  X 2',
                              //         style: TextStyle(
                              //           fontSize: 18,
                              //         ),
                              //       );
                              //     }),
                              SizedBox(height: 10),
                              Row(children: [
                                Text(
                                  "Total:",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "₹ 500",
                                )
                              ]),
                              SizedBox(height: 20),
                              Row(children: [
                                Flexible(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TrackOrder()));
                                    },
                                    child: Container(
                                        // width:
                                        //     MediaQuery.of(context)
                                        //             .size
                                        //             .width *
                                        //         0.35,
                                        height: 42,
                                        child: Center(
                                            child: Text(
                                          "Track order",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        )),
                                        decoration: BoxDecoration(
                                            color: Color(0xfffe0c00d),
                                            border: Border.all(
                                              color: Color(0xfffe0c00d),
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)))),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Flexible(
                                  flex: 3,
                                  child: GestureDetector(
                                    child: Container(
                                        // width:
                                        //     MediaQuery.of(context)
                                        //             .size
                                        //             .width *
                                        //         0.4,
                                        height: 42,
                                        child: Center(
                                            child: Text(
                                          "Cancel Order",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xfffe0c00d),
                                          ),
                                        )),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xfffe0c00d),
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)))),
                                  ),
                                )
                              ])
                            ]),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        )),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
