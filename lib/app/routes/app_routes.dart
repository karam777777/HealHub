part of 'app_pages.dart';

abstract class AppRoutes {
  AppRoutes._();
  static const SPLASH = _Paths.SPLASH;
  static const FIREBASE_SETUP = _Paths.FIREBASE_SETUP;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const USER_TYPE_SELECTION = _Paths.USER_TYPE_SELECTION;
  static const DOCTOR_PROFILE_SETUP = _Paths.DOCTOR_PROFILE_SETUP;
  static const PATIENT_PROFILE_SETUP = _Paths.PATIENT_PROFILE_SETUP;
  static const DOCTOR_HOME = _Paths.DOCTOR_HOME;
  static const PATIENT_HOME = _Paths.PATIENT_HOME;
  static const DOCTOR_APPOINTMENTS = _Paths.DOCTOR_APPOINTMENTS;
  static const PATIENT_APPOINTMENTS = _Paths.PATIENT_APPOINTMENTS;
  static const APPOINTMENT_BOOKING = _Paths.APPOINTMENT_BOOKING;
  static const PRESCRIPTION_WRITE = _Paths.PRESCRIPTION_WRITE;
  static const PRESCRIPTION_VIEW = _Paths.PRESCRIPTION_VIEW;
  static const DOCTOR_LIST = _Paths.DOCTOR_LIST;
  static const DOCTOR_DETAIL = _Paths.DOCTOR_DETAIL;
  static const COMMUNITY = _Paths.COMMUNITY;
  static const DOCTOR_CONFIRMED_APPOINTMENTS = _Paths.DOCTOR_CONFIRMED_APPOINTMENTS;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const FIREBASE_SETUP = '/firebase-setup';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const USER_TYPE_SELECTION = '/user-type-selection';
  static const DOCTOR_PROFILE_SETUP = '/doctor-profile-setup';
  static const PATIENT_PROFILE_SETUP = '/patient-profile-setup';
  static const DOCTOR_HOME = '/doctor-home';
  static const PATIENT_HOME = '/patient-home';
  static const DOCTOR_APPOINTMENTS = '/doctor-appointments';
  static const PATIENT_APPOINTMENTS = '/patient-appointments';
  static const APPOINTMENT_BOOKING = '/appointment-booking';
  static const PRESCRIPTION_WRITE = '/prescription-write';
  static const PRESCRIPTION_VIEW = '/prescription-view';
  static const DOCTOR_LIST = '/doctor-list';
  static const DOCTOR_DETAIL = '/doctor-detail';
  static const COMMUNITY = "/community";
  static const NOTIFICATIONS = '/notifications';
  static const DOCTOR_CONFIRMED_APPOINTMENTS = '/doctor-confirmed-appointments';
}
