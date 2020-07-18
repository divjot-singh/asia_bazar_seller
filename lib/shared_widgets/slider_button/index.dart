import 'package:asia_bazar_seller/shared_widgets/slider_button/shimmer.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class CenterSliderButton extends StatelessWidget {
  final double iconHeight, buttonHeight;
  final Widget centerChild, leftChild, rightChild;
  final Decoration iconDecoration, leftChildDecoration, rightChildDecoration;
  final bool showShimmer;
  final Function onDismiss, confirmDismiss;
  final ShimmerDirection leftShimmerDirection, rightShimmerDirection;
  final Color leftShimmerHighlightColor,
      rightShimmerHighlightColor,
      leftShimmerBaseColor,
      rightShimmerBaseColor;
  CenterSliderButton({
    this.iconHeight = 72,
    this.buttonHeight = 72,
    this.showShimmer = true,
    @required this.onDismiss,
    this.confirmDismiss,
    this.leftShimmerDirection = ShimmerDirection.rtl,
    this.rightShimmerDirection = ShimmerDirection.ltr,
    this.leftShimmerBaseColor = ColorShades.white,
    this.rightShimmerBaseColor = ColorShades.white,
    this.leftShimmerHighlightColor = ColorShades.faluRed,
    this.rightShimmerHighlightColor = ColorShades.elfGreen,
    @required this.centerChild,
    @required this.leftChild,
    @required this.rightChild,
    this.rightChildDecoration = const BoxDecoration(
      color: ColorShades.elfGreen,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(100),
        bottomRight: Radius.circular(100),
      ),
    ),
    this.leftChildDecoration = const BoxDecoration(
      color: ColorShades.redOrange,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(100),
        bottomLeft: Radius.circular(100),
      ),
    ),
    this.iconDecoration = const BoxDecoration(
      color: ColorShades.white,
      boxShadow: [
        BoxShadow(
          color: ColorShades.darkGreenBg,
          blurRadius: 4,
        )
      ],
      shape: BoxShape.circle,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: buttonHeight,
            decoration: BoxDecoration(
                color: ColorShades.grey100,
                boxShadow: [
                  BoxShadow(
                    color: ColorShades.grey200,
                    blurRadius: 4,
                  ),
                ],
                borderRadius: BorderRadius.circular(100)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: leftChildDecoration,
                    child: Shimmer.fromColors(
                      direction: leftShimmerDirection,
                      baseColor: leftShimmerBaseColor,
                      highlightColor: leftShimmerHighlightColor,
                      child: Center(
                        child: leftChild,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: rightChildDecoration,
                    child: showShimmer
                        ? Shimmer.fromColors(
                            direction: rightShimmerDirection,
                            baseColor: rightShimmerBaseColor,
                            highlightColor: rightShimmerHighlightColor,
                            child: Center(
                              child: rightChild,
                            ),
                          )
                        : rightChild,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            child: Dismissible(
              dismissThresholds: {
                DismissDirection.horizontal: 0.5,
              },
              onDismissed: onDismiss,
              confirmDismiss: confirmDismiss,
              key: Key('slider'),
              child: Container(
                  height: iconHeight,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      height: iconHeight,
                      width: iconHeight,
                      decoration: iconDecoration,
                      child: Center(child: centerChild))),
            ),
          ),
        ),
      ],
    );
  }
}

class SliderButton extends StatefulWidget {
  ///To make button more customizable add your child widget
  final Widget child;

  ///Sets the radius of corners of a button.
  final double radius;

  ///Use it to define a height and width of widget.
  final double height;
  final double width;
  final double buttonSize;

  ///Use it to define a color of widget.
  final Color backgroundColor;
  final Color baseColor;
  final Color highlightedColor;
  final Color buttonColor;

  ///Change it to gave a label on a widget of your choice.
  final Text label;

  ///Gives a alignment to a slidder icon.
  final Alignment alignLabel;
  final BoxShadow boxShadow, buttonBoxShadow;
  final Widget icon;
  final Function action;

  ///Make it false if you want to deactivate the shimmer effect.
  final bool shimmer;

  ///Make it false if you want maintain the widget in the tree.
  final bool dismissible;

  final bool vibrationFlag;

  ///The offset threshold the item has to be dragged in order to be considered
  ///dismissed e.g. if it is 0.4, then the item has to be dragged
  /// at least 40% towards one direction to be considered dismissed
  final double dismissThresholds;

  SliderButton({
    @required this.action,
    this.radius = 100,
    this.boxShadow = const BoxShadow(
      color: Colors.black,
      blurRadius: 4,
    ),
    this.child,
    this.buttonBoxShadow,
    this.vibrationFlag = true,
    this.shimmer = true,
    this.height = 48,
    this.buttonSize = 48,
    this.width = 250,
    this.alignLabel = const Alignment(0.4, 0),
    this.backgroundColor = const Color(0xffe0e0e0),
    this.baseColor = Colors.black87,
    this.buttonColor = Colors.white,
    this.highlightedColor = Colors.white,
    this.label = const Text(
      "Slide to cancel !",
      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
    ),
    this.icon = const Icon(
      Icons.power_settings_new,
      color: Colors.red,
      size: 30.0,
      semanticLabel: 'Text to announce in accessibility modes',
    ),
    this.dismissible = true,
    this.dismissThresholds = 1.0,
  }) : assert(buttonSize <= height);

  @override
  _SliderButtonState createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  bool flag;

  @override
  void initState() {
    super.initState();
    flag = true;
  }

  @override
  Widget build(BuildContext context) {
    return flag == true
        ? _control()
        : widget.dismissible == true
            ? Container()
            : Container(
                child: _control(),
              );
  }

  Widget _control() => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
            boxShadow: [widget.buttonBoxShadow],
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.radius)),
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              alignment: widget.alignLabel,
              child: widget.shimmer
                  ? Shimmer.fromColors(
                      baseColor: widget.baseColor,
                      highlightColor: widget.highlightedColor,
                      child: widget.label,
                    )
                  : widget.label,
            ),
            Dismissible(
              key: Key("cancel"),
              direction: DismissDirection.startToEnd,
              dismissThresholds: {
                DismissDirection.startToEnd: widget.dismissThresholds
              },

              ///gives direction of swipping in argument.
              onDismissed: (dir) async {
                setState(() {
                  if (widget.dismissible) {
                    flag = false;
                  } else {
                    flag = !flag;
                  }
                });
                if (widget.vibrationFlag && await Vibration.hasVibrator()) {
                  try {
                    Vibration.vibrate(duration: 200);
                  } catch (e) {
                    print(e);
                  }
                }

                widget.action();
              },
              child: Container(
                width: MediaQuery.of(context).size.width -
                    widget.height -
                    (0.5 * widget.buttonSize),
                height: widget.height,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  left: (widget.height - widget.buttonSize) / 2,
                ),
                child: widget.child ??
                    Container(
                      height: widget.buttonSize,
                      width: widget.buttonSize,
                      decoration: BoxDecoration(
                        boxShadow: [
                          widget.boxShadow,
                        ],
                        shape: BoxShape.circle,
                        color: widget.buttonColor,
                      ),
                      child: Center(child: widget.icon),
                    ),
              ),
            ),
          ],
        ),
      );
}
