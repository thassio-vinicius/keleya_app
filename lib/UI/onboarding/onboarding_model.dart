import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keleya_app/services/authentication_provider.dart';
import 'package:keleya_app/utils/strings.dart';
import 'package:keleya_app/utils/validator.dart';

enum OnboardingState { signIn, signUp, initial }

enum OnboardingSubmitState { cantSubmit, authException, success }

class OnboardingModel with TextFieldValidators, ChangeNotifier {
  OnboardingModel({
    required this.authProvider,
    this.state = OnboardingState.initial,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.submitted = false,
    this.privacy = false,
    this.terms = false,
  });

  final AuthenticationProvider authProvider;
  String email;
  String password;
  String confirmPassword;
  OnboardingState state;
  bool isLoading;
  bool submitted;
  bool privacy;
  bool terms;

  Future<OnboardingSubmitState> submit() async {
    print('submit');

    try {
      updateWith(submitted: true);
      if (!canSubmit) {
        print('cant submit');
        return OnboardingSubmitState.cantSubmit;
      }
      updateWith(isLoading: true);

      bool result;

      switch (state) {
        case OnboardingState.signIn:
          result = await authProvider.signIn(email: email, password: password);

          updateWith(isLoading: false);
          return result ? OnboardingSubmitState.success : OnboardingSubmitState.authException;
        case OnboardingState.signUp:
          result = await authProvider.signUp(
            email: email.trim(),
            password: password.trim(),
          );
          updateWith(isLoading: false);

          print('submit register');
          return result ? OnboardingSubmitState.success : OnboardingSubmitState.authException;
        default:
          return OnboardingSubmitState.cantSubmit;
      }
    } catch (e, stackTrace) {
      print(stackTrace);
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateEmail(String email) => updateWith(email: email);

  void updatePrivacy(bool? privacy) => updateWith(privacy: privacy);

  void updateTerms(bool? terms) => updateWith(terms: terms);

  void updatePassword(String password) => updateWith(password: password);

  void updateConfirmPassword(String confirmPassword) => updateWith(confirmPassword: confirmPassword);

  void updateWith({
    String? email,
    String? password,
    String? gender,
    String? year,
    String? confirmPassword,
    bool? isLoading,
    bool? submitted,
    OnboardingState? formType,
    bool? privacy,
    bool? terms,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.confirmPassword = confirmPassword ?? this.confirmPassword;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.state = formType ?? this.state;
    this.privacy = privacy ?? this.privacy;
    this.terms = terms ?? this.terms;
    notifyListeners();
  }

  void updateState(OnboardingState? formType) {
    updateWith(
      email: '',
      password: '',
      confirmPassword: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  // Getters

  String? get primaryButtonText {
    return <OnboardingState, String>{
      OnboardingState.signUp: Strings.createAcc,
      OnboardingState.signIn: Strings.signIn,
    }[state];
  }

  String? get errorAlertTitle {
    return <OnboardingState, String>{
      OnboardingState.signUp: Strings.signUpFailed,
      OnboardingState.signIn: Strings.signInFailed,
    }[state];
  }

  String? get title {
    return <OnboardingState, String>{
      OnboardingState.signUp: Strings.welcome,
      OnboardingState.signIn: Strings.welcomeBack,
      OnboardingState.initial: Strings.alreadyUser,
    }[state];
  }

  String? get formTitle {
    return <OnboardingState, String>{
      OnboardingState.signUp: Strings.createAcc,
      OnboardingState.signIn: Strings.signInKeleyaInfo,
    }[state];
  }

  String? get secondaryButtonText {
    return <OnboardingState, String>{
      OnboardingState.signUp: Strings.signIn,
    }[state];
  }

  OnboardingState? get secondaryActionState {
    return <OnboardingState, OnboardingState>{
      OnboardingState.signUp: OnboardingState.signIn,
      OnboardingState.signIn: OnboardingState.signUp,
    }[state];
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email) && email.isNotEmpty;
  }

  bool get canSubmitPassword {
    return passwordSubmitValidator.isValid(password) && password.isNotEmpty;
  }

  bool get canSubmitConfirmPassword {
    return confirmPasswordSubmitValidator.isValid(confirmPassword) && password == confirmPassword;
  }

  bool get canSubmit {
    late bool canSubmitFields;

    switch (state) {
      case OnboardingState.signIn:
        canSubmitFields = canSubmitEmail && canSubmitPassword;
        break;
      case OnboardingState.signUp:
        canSubmitFields = canSubmitEmail && canSubmitPassword && canSubmitConfirmPassword && terms && privacy;
        break;
      case OnboardingState.initial:
        canSubmitFields = true;
    }
    print(canSubmitFields);
    return canSubmitFields && !isLoading;
  }

  String? get emailErrorText {
    final bool showErrorText = submitted && !canSubmitEmail;
    final String errorText = email.isEmpty ? Strings.invalidEmailEmpty : Strings.invalidEmailErrorText;
    return showErrorText ? errorText : null;
  }

  String? get passwordErrorText {
    final bool showErrorText = submitted && !canSubmitPassword;
    final String errorText = password.isEmpty ? Strings.invalidPasswordEmpty : Strings.invalidPasswordTooShort;
    return showErrorText ? errorText : null;
  }

  String? get confirmPasswordErrorText {
    final bool showErrorText = submitted && !canSubmitConfirmPassword;
    final String errorText =
        confirmPassword.isEmpty ? Strings.invalidConfirmPasswordEmpty : Strings.invalidPasswordsNoMatch;
    return showErrorText ? errorText : null;
  }

  @override
  String toString() {
    return 'email: $email, password: $password, confirmPassword: $confirmPassword, isLoading: $isLoading, submitted: $submitted';
  }
}
