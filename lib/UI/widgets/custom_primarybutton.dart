import 'package:flutter/material.dart';
import 'package:keleya_app/utils/adapt.dart';

class CustomPrimaryButton extends StatelessWidget {
  final Function? onPressed;
  final String? label;
  final bool loading;
  final bool lightTheme;
  final bool enabled;
  const CustomPrimaryButton({
    required this.onPressed,
    required this.label,
    this.enabled = true,
    this.lightTheme = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Center(
        child: loading
            ? CircularProgressIndicator(color: Theme.of(context).backgroundColor)
            : FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  label!,
                  style: lightTheme
                      ? Theme.of(context).textTheme.headline3!
                      : Theme.of(context).textTheme.headline2!.copyWith(
                          color: Theme.of(context).textTheme.headline2!.color!.withOpacity(enabled ? 1 : 0.9)),
                ),
              ),
      ),
      onPressed: loading
          ? null
          //To avoid the call of the onPressed method even with the button disabled
          : enabled
              ? onPressed as void Function()?
              : () {
                  debugPrint("button disabled");
                },
      color: lightTheme
          ? Theme.of(context).secondaryHeaderColor
          : Theme.of(context).backgroundColor.withOpacity(enabled ? 1 : 0.5),
      height: Adapt().hp(8),
      shape:
          RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(Adapt.px(8)))),
    );
  }
}
