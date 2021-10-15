import 'package:flutter/material.dart';
import 'package:keleya_app/utils/adapt.dart';
import 'package:keleya_app/utils/localizations.dart';
import 'package:keleya_app/utils/strings.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({Key? key}) : super(key: key);

  @override
  _CongratulationsScreenState createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(Adapt.px(16)),
              child: Text(
                AppLocalizations.of(context).translate(Strings.congratulations),
                style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Flexible(flex: 7, child: Image.asset('assets/images/baby.png')),
        ],
      ),
    );
  }
}
