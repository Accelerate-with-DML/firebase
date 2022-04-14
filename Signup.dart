import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SignupController extends GetxController {
  RxBool showLoader = false.obs;
  var isSell = false.obs;
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController phoneNumberTextController = TextEditingController();
  TextEditingController otpTextController = TextEditingController();
  //RxString dialCode = "".obs;
  RxString verificationId = "".obs;
  RxString selectedCountryCode = "".obs;
  RxString selectedRegion = "".obs;
  final PhoneNumberUtil _phoneNumberUtil = PhoneNumberUtil();

  @override
  void onInit() {
    super.onInit();
  }


  Future<void> verifyPhoneNumberFunction() async {
    print("Phone number under verification");
    if (phoneNumberTextController.text.trim() == "") {
      showToastMsg("Enter phone number.");
    } else if (!await _phoneNumberUtil.validate(

        phoneNumberTextController.text.trim(), selectedRegion.value)) {
      showToastMsg("Enter valid phone number.");
    } else {
      print("Phone number is Valid");

     try{
       await auth.verifyPhoneNumber(
           phoneNumber:
           selectedCountryCode.value + phoneNumberTextController.text.trim(),
           verificationCompleted: _onVerificationCompleted,
           verificationFailed: _onVerificationFailed,
           codeSent: _onCodeSent,
           codeAutoRetrievalTimeout: _onCodeTimeout);
     }
     catch(e){
       print("Exception : $e");
     }
    }
  }


  _onVerificationCompleted(PhoneAuthCredential authCredential) async {}

  _onVerificationFailed(FirebaseAuthException exception) {
    print("Verification failed: ${exception.message}");
    Get.back();
    if (exception.code == 'invalid-phone-number') {
      showToastMsg("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationIdValue, int? forceResendingToken) async {
    print("Sending Code");
    Get.back();
    verificationId.value = verificationIdValue;
    print("VERIFICATION CODE----" + verificationId.value);
    debugPrint(forceResendingToken.toString());
    showToastMsg("OTP has been sent on your mobile number");
    await Get.to(
        () => OtpView(
            dialCode: selectedCountryCode.value,
            verificationCode: verificationId.value,
            phoneNumber: phoneNumberTextController.text),
        arguments: {
          "verificationId": verificationId.value,
          "phoneNumber": phoneNumberTextController.text.trim(),
          "dialCode": selectedCountryCode.value
        });
  }

  _onCodeTimeout(String timeout) {
    return null;
  }
}
