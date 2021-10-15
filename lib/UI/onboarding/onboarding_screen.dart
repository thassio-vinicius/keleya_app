import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keleya_app/UI/congratulations/congratulations_screen.dart';
import 'package:keleya_app/UI/onboarding/onboarding_model.dart';
import 'package:keleya_app/UI/post_signup/postsignup_screen.dart';
import 'package:keleya_app/UI/widgets/custom_alertdialog.dart';
import 'package:keleya_app/UI/widgets/custom_exceptiondialog.dart';
import 'package:keleya_app/UI/widgets/custom_primarybutton.dart';
import 'package:keleya_app/UI/widgets/custom_textfield.dart';
import 'package:keleya_app/models/firestore_user.dart';
import 'package:keleya_app/services/authentication_provider.dart';
import 'package:keleya_app/services/firestore_provider.dart';
import 'package:keleya_app/utils/adapt.dart';
import 'package:keleya_app/utils/localizations.dart';
import 'package:keleya_app/utils/strings.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    return ChangeNotifierProvider<OnboardingModel>(
      create: (_) => OnboardingModel(authProvider: authProvider),
      child: Consumer<OnboardingModel>(
        builder: (_, model, __) => _EmailSignOptionScreen(model: model),
      ),
    );
  }
}

class _EmailSignOptionScreen extends StatefulWidget {
  const _EmailSignOptionScreen({required this.model});
  final OnboardingModel model;

  @override
  _EmailSignOptionScreenState createState() => _EmailSignOptionScreenState();
}

class _EmailSignOptionScreenState extends State<_EmailSignOptionScreen> {
  final FocusScopeNode node = FocusScopeNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  OnboardingModel get model => widget.model;

  bool initialState = true;

  @override
  void dispose() {
    node.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showSignInError(OnboardingModel model, dynamic exception) async {
    await showExceptionAlertDialog(
      context: context,
      title: model.errorAlertTitle,
      exception: exception,
    );
  }

  Future<void> submit() async {
    if (model.state == OnboardingState.signUp && !(model.terms || model.privacy)) {
      showAlertDialog(
        context: context,
        title: translate(Strings.signUpFailed),
        content: translate(Strings.acceptPrivacyTermsFirst),
        defaultActionText: 'Ok',
      );
    } else {
      try {
        final OnboardingSubmitState result = await model.submit();
        if (result == OnboardingSubmitState.success) {
          if (model.state == OnboardingState.signIn) {
            Map<String, dynamic>? json = await Provider.of<FirestoreProvider>(context, listen: false)
                .fetchDocument(collectionPath: 'users', documentPath: FirebaseAuth.instance.currentUser!.uid);
            FirestoreUser user = FirestoreUser.fromMap(json!);
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => user.onboardingDone ? CongratulationsScreen() : PostSignupScreen()),
              );
            });
          } else {
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PostSignupScreen()),
              );
            });
          }
        } else {
          if (result == OnboardingSubmitState.authException) showSignInError(model, "unknown");
        }
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        showSignInError(model, e);
      }
    }
  }

  String translate(String? key) {
    return key == null ? '' : AppLocalizations.of(context).translate(key);
  }

  void updateState(OnboardingState? state) {
    initialState = false;
    model.updateState(state);
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void emailEditingComplete() {
    if (model.canSubmitEmail) {
      node.nextFocus();
    }
  }

  void passwordEditingComplete() {
    if (!model.canSubmitPassword) {
      node.nextFocus();
    }
  }

  void confirmPasswordEditingComplete() {
    if (!model.canSubmitPassword) {
      node.previousFocus();
      return;
    }
    submit();
  }

  Widget buildFields() {
    late List<Widget> children;

    switch (model.state) {
      case OnboardingState.signIn:
        children = [
          CustomTextField(
              controller: emailController,
              hint: translate(Strings.emailHint),
              errorText: translate(model.emailErrorText),
              onChanged: model.updateEmail,
              keyboardType: TextInputType.emailAddress,
              enabled: !model.isLoading,
              onEditingComplete: emailEditingComplete,
              inputFormatters: <TextInputFormatter>[model.emailInputFormatter]),
          CustomTextField(
            controller: passwordController,
            hint: translate(Strings.password),
            errorText: translate(model.passwordErrorText),
            enabled: !model.isLoading,
            obscureText: true,
            onChanged: model.updatePassword,
            onEditingComplete: passwordEditingComplete,
          ),
          Padding(
            padding: EdgeInsets.only(top: Adapt.px(8)),
            child: CustomPrimaryButton(
              label: translate(model.primaryButtonText!),
              loading: model.isLoading,
              onPressed: model.isLoading ? null : submit,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: Adapt.px(12)),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                translate(Strings.forgotPassword),
                style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: Adapt.px(15)),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ];
        break;
      case OnboardingState.signUp:
        children = <Widget>[
          CustomTextField(
              controller: emailController,
              hint: translate(Strings.emailHint),
              errorText: translate(model.emailErrorText),
              keyboardType: TextInputType.emailAddress,
              onChanged: model.updateEmail,
              enabled: !model.isLoading,
              onEditingComplete: emailEditingComplete,
              inputFormatters: <TextInputFormatter>[model.emailInputFormatter]),
          CustomTextField(
            controller: passwordController,
            hint: translate(Strings.password),
            errorText: translate(model.passwordErrorText),
            enabled: !model.isLoading,
            obscureText: true,
            onChanged: model.updatePassword,
            onEditingComplete: passwordEditingComplete,
          ),
          CustomTextField(
            controller: confirmPasswordController,
            hint: translate(Strings.password),
            errorText: translate(model.confirmPasswordErrorText),
            obscureText: true,
            enabled: !model.isLoading,
            textInputAction: TextInputAction.done,
            onChanged: model.updateConfirmPassword,
            onEditingComplete: confirmPasswordEditingComplete,
          ),
          CustomPrimaryButton(
            label: translate(model.primaryButtonText),
            loading: model.isLoading,
            onPressed: model.isLoading ? null : submit,
          ),
          Padding(
            padding: EdgeInsets.only(top: Adapt.px(12)),
            child: Row(
              children: [
                Checkbox(
                  value: model.privacy,
                  onChanged: model.updatePrivacy,
                  checkColor: Colors.white,
                  activeColor: Theme.of(context).backgroundColor,
                ),
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        translate(Strings.acceptConfirm),
                        style: Theme.of(context)
                            .textTheme
                            .headline3!
                            .copyWith(color: Colors.black, fontSize: Adapt.px(12), fontWeight: FontWeight.normal),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(left: Adapt.px(2)),
                          child: Text(
                            translate(Strings.privacyPolicy),
                            style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: Adapt.px(12)),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                  value: model.terms,
                  checkColor: Colors.white,
                  activeColor: Theme.of(context).backgroundColor,
                  onChanged: model.updateTerms),
              Flexible(
                child: Row(
                  children: [
                    Text(
                      translate(Strings.acceptConfirm),
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(color: Colors.black, fontSize: Adapt.px(12), fontWeight: FontWeight.normal),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: Adapt.px(2)),
                        child: Text(
                          translate(Strings.termsConditions),
                          style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: Adapt.px(12)),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                translate(Strings.alreadyHaveAcc),
                style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.black),
              ),
              Padding(
                padding: EdgeInsets.only(left: Adapt.px(4)),
                child: GestureDetector(
                  child: Text(
                    translate(model.secondaryButtonText!),
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  onTap: model.isLoading ? null : () => updateState(model.secondaryActionState),
                ),
              ),
            ],
          ),
        ];
        break;
      case OnboardingState.initial:
        children = [
          Padding(
            padding: EdgeInsets.only(top: Adapt.px(126)),
            child: CustomPrimaryButton(
              onPressed: () => updateState(OnboardingState.signIn),
              label: translate('yesKeleyaUser'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: Adapt.px(22)),
            child: CustomPrimaryButton(
              onPressed: () => updateState(OnboardingState.signUp),
              label: translate('noKeleyaUser'),
              lightTheme: true,
            ),
          ),
        ];
    }
    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: Adapt().hp(100),
          child: Column(
            children: [
              Flexible(
                flex: 25,
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.all(Adapt.px(16)),
                    child: Center(
                      child: Text(
                        translate(model.title),
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 75,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Adapt.px(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Adapt.px(46)),
                      topRight: Radius.circular(Adapt.px(46)),
                    ),
                  ),
                  child: Center(
                    child: ListView(
                      children: [
                        if (model.state != OnboardingState.initial)
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: Adapt.px(22.0)),
                              child: Text(
                                translate(model.formTitle!),
                                style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.black),
                              ),
                            ),
                          ),
                        FocusScope(
                          node: node,
                          child: buildFields(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
