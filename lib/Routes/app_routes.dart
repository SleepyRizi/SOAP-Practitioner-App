part of 'app_pages.dart';

abstract class Routes {
  static const splash        = '/';
  static const welcome       = '/welcome';
  static const login         = '/login';
  static const signup        = '/signup';
  static const otp           = '/otp';
  static const pickPassword  = '/pick-password';
  static const forgot        = '/forgot';
  static const resetSuccess  = '/reset-success';
  static const passwordUpdateSuccess = '/password-update-success';

  static const home          = '/home';

  /* Patient-side */
  static const patientDetail = '/patient-detail';   // AssessmentView
  static const formDetail    = '/form-detail';      // FormDetailView
}
