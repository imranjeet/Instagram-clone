import 'package:flutter/material.dart';

class EmptyBoxScreen extends StatelessWidget {
  final double boxHeight;

  const EmptyBoxScreen({Key key, this.boxHeight}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          boxHeight == null ? Image.asset(
            "assets/images/empty1.png",
          ) : Image.asset(
            "assets/images/empty1.png",
            height: boxHeight,
          ),
          Text(
            "Whoops!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
          ),
          Text("it seems it's empty here.")
        ],
      ),
    );
  }
}
