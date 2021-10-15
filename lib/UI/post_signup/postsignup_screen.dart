import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keleya_app/UI/congratulations/congratulations_screen.dart';
import 'package:keleya_app/UI/onboarding/onboarding_screen.dart';
import 'package:keleya_app/UI/widgets/custom_alertdialog.dart';
import 'package:keleya_app/UI/widgets/custom_primarybutton.dart';
import 'package:keleya_app/UI/widgets/custom_textfield.dart';
import 'package:keleya_app/services/firestore_provider.dart';
import 'package:keleya_app/utils/adapt.dart';
import 'package:keleya_app/utils/localizations.dart';
import 'package:keleya_app/utils/strings.dart';
import 'package:keleya_app/utils/validator.dart';
import 'package:provider/provider.dart';

class PostSignupScreen extends StatefulWidget {
  const PostSignupScreen({Key? key}) : super(key: key);

  @override
  _PostSignupScreenState createState() => _PostSignupScreenState();
}

enum PostSignUpState { name, date }

class _PostSignupScreenState extends State<PostSignupScreen> with TextFieldValidators {
  TextEditingController nameController = TextEditingController();
  late TextEditingController dateController;
  PostSignUpState state = PostSignUpState.name;
  DateTime babyDate = DateTime.now();

  String formatDate({DateTime? date}) {
    if (date == null) date = DateTime.now();
    int day = date.day;
    int month = date.month;
    int year = date.year;
    return '$day.$month.${year.toString().substring(2)}';
  }

  initState() {
    super.initState();
    dateController = TextEditingController(text: formatDate());
  }

  String translate(String? key) {
    return key == null ? '' : AppLocalizations.of(context).translate(key);
  }

  bool loading = false;

  Widget buildFields() {
    late List<Widget> children;

    switch (state) {
      case PostSignUpState.name:
        children = [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () =>
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingScreen())),
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          Text(
            translate(Strings.yourName),
            style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Adapt.px(16)),
            child: CustomTextField(
              controller: nameController,
              hint: translate(Strings.nameHint),
              enabled: !loading,
              textInputAction: TextInputAction.done,
              onEditingComplete: submit,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPrimaryButton(
              onPressed: submit,
              label: translate(Strings.nextQuestion),
              loading: loading,
            ),
          ),
        ];
        break;
      case PostSignUpState.date:
        children = [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => setState(() => state = PostSignUpState.name),
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          Text(
            translate(Strings.whenBabyBorn),
            style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Adapt.px(16)),
            child: Text(
              translate(Strings.babyBornDescription),
              style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () async {
              DateTime result = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 1000)),
                    lastDate: DateTime.now(),
                  ) ??
                  DateTime.now();
              setState(() {
                dateController.text = formatDate(date: result);
                babyDate = result;
              });
            },
            child: CustomTextField(
              controller: dateController,
              enabled: false,
              textInputAction: TextInputAction.done,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPrimaryButton(
              onPressed: submit,
              label: translate(Strings.nextQuestion),
              loading: loading,
            ),
          ),
        ];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(Adapt.px(16)),
      child: buildFields(),
    ));
  }

  void submit() async {
    setState(() {
      loading = true;
    });
    if (state == PostSignUpState.name) {
      if (displayNameSubmitValidator.isValid(nameController.text)) {
        await Provider.of<FirestoreProvider>(context, listen: false).updateData(
          collectionPath: 'users',
          documentPath: FirebaseAuth.instance.currentUser!.uid,
          data: {'name': nameController.text},
        );
        setState(() {
          state = PostSignUpState.date;
        });
      } else {
        showAlertDialog(context: context, title: translate(nameErrorText()), content: '', defaultActionText: 'Ok');
      }
    } else {
      await Provider.of<FirestoreProvider>(context, listen: false).updateData(
        collectionPath: 'users',
        documentPath: FirebaseAuth.instance.currentUser!.uid,
        data: {'babyBirthDate': babyDate, 'onboardingDone': true},
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => CongratulationsScreen()));
    }
    if (mounted) setState(() => loading = false);
  }

  String? nameErrorText() {
    final String errorText =
        nameController.text.isEmpty ? Strings.invalidDisplayNameEmpty : Strings.invalidDisplayNameTooShort;
    return errorText;
  }
}
