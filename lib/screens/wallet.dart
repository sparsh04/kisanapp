import 'package:flutter/material.dart';
import 'package:my_kisan/constant.dart';

class MyWallet extends StatelessWidget {
  static String routName = "/my_wallet";
  const MyWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet"),
      ),
      body: Container(
        //height: 100,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text("My kisan Wallet"),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        alignment: Alignment.centerLeft, child: Text("₹ 310")),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange.shade200,
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  // decoration:
                  //     BoxDecoration(border: Border.all(color: Colors.black)),
                  width: 100,
                  height: 50,
                  // height: 100,
                  child: TextFormField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: orangecolor, width: 1),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangecolor, width: 1)),
                      prefixText: "₹",
                      hintText: "Amount (₹)",
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {},
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: orangecolor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text("Add money",
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
            //t            ransaction tab bar

            //transaction card
            Container(
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0, 0),
                        blurRadius: 5)
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "2021-12-08",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text("refunded",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.7))),
                      Text("11:19:36",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.7))),
                    ],
                  ),
                  Text(
                    "+60.00",
                    style: TextStyle(color: greencolor),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
