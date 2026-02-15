class AppValidator {
  static String? requiredField(context, String val) {
    if (val.isEmpty) {
      return 'Field is required';
    } else {
      return null;
    }
  }

  static String? emailVaidator(context, String val) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    if (val.isEmpty) {
      return 'Field is required';
    }
    if (!val.contains(RegExp(pattern))) {
      return 'Must be a valid email: Example@gmail.com';
    } else {
      return null;
    }
  }

  static String? phoneVaidator(context, String val) {
    String pattern = r"^(01)[0-9]{9}$";
    if (val.isEmpty) {
      return 'Field is required';
    }
    if (!val.contains(RegExp(pattern))) {
      return 'Please enter a valid phone number (e.g. 01012345678)';
    } else {
      return null;
    }
  }

  static String? passFieldValidator(context, String val) {
    if (val.isEmpty) {
      return 'Field is required';
    }

    if (!val.contains(RegExp(r'[a-z]'))) {
      return 'Must contain small char[a to z]';
    }
    if (!val.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain capital char[A to Z]';
    }
    if (!val.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      return 'Must contain signs[#@&*(){!}]';
    }
    if (!val.contains(RegExp(r'[0-9]'))) {
      return 'Must contain numbers';
    }
    if (val.length < 6) {
      return 'Should be more than 6 digits';
    } else {
      return null;
    }
  }
}
