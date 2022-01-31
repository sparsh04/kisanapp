import 'package:flutter/material.dart';
import 'package:my_kisan/constant.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Height = MediaQuery.of(context).size.height;
    final Width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Container(
            height: Height / 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: whitecolors,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                  icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      color: orangecolor,
                    ),
                  ),
                  border: InputBorder.none,
                  hintText: "Search Here"),
            ),
          ),
        ],
      ),
    ));
  }
}
