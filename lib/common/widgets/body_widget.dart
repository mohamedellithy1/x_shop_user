import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/app_bar_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class BodyWidget extends StatefulWidget {
  final Widget body;
  final AppBarWidget appBar;
  final double topMargin;
  const BodyWidget({super.key, required this.body, required this.appBar, this.topMargin = 10});

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  @override
  Widget build(BuildContext context) {
    return  Column(children: [
      widget.appBar,

      Expanded(child: Container(
        margin: EdgeInsets.only(top: widget.topMargin),
        width: Dimensions.webMaxWidth,
        decoration:  BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(25), topLeft: Radius.circular(25),
        ),
          color:Color(0xFFfafef5),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
            child: widget.body,
        ),
      )),

    ]);
  }
}
