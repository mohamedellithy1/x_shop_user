import 'package:flutter/foundation.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class CustomValidator {

  static Future<PhoneValid> isPhoneValid(String number) async {
    String phone = '';
    String countryCode = '';
    bool isValid = false;
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if(!isValid) {
        isValid = phoneNumber.isValid();
      }
      countryCode = phoneNumber.countryCode;
      if(isValid) {
        phone = '+${phoneNumber.countryCode}${phoneNumber.nsn}';
      }
    } catch (e) {
      debugPrint('Phone Number is not parsing: $e');
      isValid = false;
    }
    return PhoneValid(isValid: isValid, countryCode: countryCode,  phone: phone);
  }

}

class PhoneValid {
  bool isValid;
  String countryCode;
  String phone;
  PhoneValid({required this.isValid, required this.countryCode, required this.phone});
}