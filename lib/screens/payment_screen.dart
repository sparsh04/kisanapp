import 'package:flutter/material.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/screens/Cart_Screen.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PaymentDetail(
                prodDiscount: '₹310.00',
                totalAmt: '₹00.00',
                totalMrp: '₹310.00',
                total: 0,
              ),
            ),
            Spacer(),
            MaterialButton(
              height: Height / 22,
              minWidth: Width * 0.8,
              onPressed: () {},
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
