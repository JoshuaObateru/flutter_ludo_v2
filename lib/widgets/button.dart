import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String buttonText;
  final void Function() onPressed;
  final double height, textSize, borderRadius;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final double width;
  final Color buttonColor;
  final Color textColor;
  final bool elevation;
  final bool isBold;
  const Button(
      {Key key,
      @required this.buttonText,
      this.onPressed,
      this.borderRadius,
      this.prefixIcon,
      this.suffixIcon,
      this.textSize,
      this.isBold = false,
      this.elevation = false,
      this.height,
      this.width,
      this.buttonColor,
      this.textColor})
      : super(key: key);
  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height / 15,
      width: widget.width ?? MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: widget.onPressed ?? () {},
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(widget.buttonColor),
          elevation: widget.elevation
              ? MaterialStateProperty.all<double>(1.0)
              : MaterialStateProperty.all<double>(0.0),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                widget.borderRadius != null ? widget.borderRadius : 20.0),
          )),
        ),
        child: widget.prefixIcon == null
            ? widget.suffixIcon != null
                ? FittedBox(
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.buttonText,
                        style: TextStyle(
                            color: widget.textColor ?? Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      SizedBox(width: 15),
                      widget.suffixIcon,
                    ],
                  ))
                : FittedBox(
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontWeight:
                              widget.isBold ? FontWeight.bold : FontWeight.w400,
                          fontSize:
                              widget.textSize != null ? widget.textSize : 14),
                    ),
                  )
            : FittedBox(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.prefixIcon,
                  SizedBox(width: 15),
                  Text(
                    widget.buttonText,
                    style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              )),
      ),
    );
  }
}
