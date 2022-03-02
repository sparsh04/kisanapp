import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kisan/constant.dart';
import 'package:my_kisan/size_config.dart';
class SubscriptionDetails extends StatefulWidget {


  SubscriptionDetails({Key? key}) : super(key: key);

  @override
  State<SubscriptionDetails> createState() => _SubscriptionDetailsState();
}

class _SubscriptionDetailsState extends State<SubscriptionDetails> {
  String  category = "Active";
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription Details"),),
      body: Column(children: [
        const SizedBox(
          width: 10,height: 20,
        ),
        Row(
          children: [
            const SizedBox(
              width: 18,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  category = "Active";
                });
              },
              child: const Text("Active"),
              style: TextButton.styleFrom(
                side: BorderSide(color: greencolor),
                primary: category == "Active" ? Colors.white : greencolor,
                backgroundColor:
                category == "Active" ? greencolor : Colors.white,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  category = "Past";
                });
              },
              child: const Text("Past Subscription"),
              style: TextButton.styleFrom(
                side: BorderSide(color: greencolor),
                primary: category == "Past" ? Colors.white : greencolor,
                backgroundColor:
                category == "Past" ? greencolor : Colors.white,
              ),
            ),

          ],
        ),
        SizedBox(height: 30,),
     category == "Active"?
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection("users").doc(user!.phoneNumber).collection("activeSubscription").get(),
          builder: (ctx,d){
            if(d.hasData && d.connectionState == ConnectionState.done){
            final List<QueryDocumentSnapshot<Object?>>? documents = d.data?.docs;
            return
            Container(width: screenWidth(context) - 30,
            height: 400,
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: greencolor,width: 3),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Subscription Details",style: headingstyle(),),
              Text("Plan",style: headingstyle(),),
              Text("${documents?[0]["plan"]}",style: subheadingstyle(),),
              Text("Amount Received",style: headingstyle(),),
              Text("Rs.${documents?[0]["amountReceived"]}",style: subheadingstyle(),),
              Text("Billing Amount",style: headingstyle(),),
              Text("Rs."  + documents?[0]["billingAmount"],style: subheadingstyle(),),
              Text("Next Bill Date",style: headingstyle(),),
              Text(documents![0]["NextBillDate"].toString().split(" ").first.toString(),style: subheadingstyle(),),
              Text("Plan Features",style: headingstyle(),),
              Text(documents[0]["description"]
                ,style: subheadingstyle(),),
                Center(
                  child: MaterialButton(onPressed: (){},
                    minWidth: 200,
                    height: 45,
                    color: greencolor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: greencolor)
                    ),
                  child: Text("Cancel Subscription",style: TextStyle(color: Colors.white
                  ,fontSize: 18),),),
                )

            ],),
          );}
            else{
              return Center(child: CircularProgressIndicator());
            }
    }
        )
          : SizedBox(
       height: screenHeight(context) -200,
       width: screenWidth(context) - 30,
            child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection("users").doc(user!.phoneNumber).collection("pastSubscription").get(),
            builder: (ctx,d){
              if(d.hasData== true && d.connectionState == ConnectionState.done){
              final List<QueryDocumentSnapshot<Object?>>? documents = d.data?.docs;
              print(documents!.length);
              return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context,index){
                    print(documents.length);
                return  Container(width: screenWidth(context) - 30,
                  height: 250,
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: greencolor,width: 3),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Subscription Details",style: headingstyle(),),
                      SizedBox(height: 10,),
                      Text("Plan",style: headingstyle(),),              SizedBox(height: 10,),

                      Text("${documents[index]["plan"]}",style: subheadingstyle(),),
                      SizedBox(height: 10,),
                      Text("Billing Amount",style: headingstyle(),),
                      SizedBox(height: 10,),
                      Text("Rs.${documents[index]["billingAmount"]}",style: subheadingstyle(),),
                      SizedBox(height: 10,),

                      Text("Date",style: headingstyle(),),
                      SizedBox(height: 10,),
                      Text(documents[index]["dateTime"],style: subheadingstyle(),),


                    ],),
                ) ;
              });
              }
              // else {
              //   return   Center(child: Text("No Data Available"),);
              // }
              else{
                return Center(child: CircularProgressIndicator());
              }
    }
        ),
          )
      ],),
    );
  }
}
