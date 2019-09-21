class Debug {
  static bool isDebugModeEnabled = true;
  static bool isDemoMode = false;

  static String email = 'sk@gmail.com';
  static String password = 'Qazxsw123';
  static String fullName = 'John Doe';
  static String firstName = 'John';
  static String lastName = 'Doe';
  static String phone = '+79272222222';
  static String company = 'OncoPharma';
  static String country = 'USA';
  static String city = 'Boston';
  static String suffix = 'Ph.D.';
  static String title = 'CEO';
  static String resetToken = '';
  static String language = 'English';
}

void debug(void Function() debugAction) {
  if (Debug.isDebugModeEnabled) {
    debugAction();
  }
}

void demo(void Function() demoAction) {
  if (Debug.isDemoMode) {
    demoAction();
  }
}

T demoValue<T>(T debugValue) {
  if (Debug.isDemoMode) {
    return debugValue;
  }
  return null;
}
