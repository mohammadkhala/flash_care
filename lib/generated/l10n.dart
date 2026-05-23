// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flash Care`
  String get doctorIo {
    return Intl.message('Flash Care', name: 'doctorIo', desc: '', args: []);
  }

  /// `Continue`
  String get continueText {
    return Intl.message('Continue', name: 'continueText', desc: '', args: []);
  }

  /// `Enter your phone number to continue.\nWe will send an OTP for verification`
  String get enterYourPhoneNumberEtc {
    return Intl.message(
      'Enter your phone number to continue.\nWe will send an OTP for verification',
      name: 'enterYourPhoneNumberEtc',
      desc: '',
      args: [],
    );
  }

  /// `Phone Verification`
  String get phoneVerification {
    return Intl.message(
      'Phone Verification',
      name: 'phoneVerification',
      desc: '',
      args: [],
    );
  }

  /// `We have sent OTP verification code\non phone number you entered.`
  String get weHaveSentOTPEtc {
    return Intl.message(
      'We have sent OTP verification code\non phone number you entered.',
      name: 'weHaveSentOTPEtc',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your OTP`
  String get enterYourOTP {
    return Intl.message(
      'Enter Your OTP',
      name: 'enterYourOTP',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `ReSend`
  String get reSend {
    return Intl.message('ReSend', name: 'reSend', desc: '', args: []);
  }

  /// `Complete Registration`
  String get completeRegistration {
    return Intl.message(
      'Complete Registration',
      name: 'completeRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Your phone number has been verified`
  String get yourPhoneNumberHasEtc {
    return Intl.message(
      'Your phone number has been verified',
      name: 'yourPhoneNumberHasEtc',
      desc: '',
      args: [],
    );
  }

  /// `Your Fullname`
  String get yourFullname {
    return Intl.message(
      'Your Fullname',
      name: 'yourFullname',
      desc: '',
      args: [],
    );
  }

  /// `Select Country`
  String get selectCountry {
    return Intl.message(
      'Select Country',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Select Gender`
  String get selectGender {
    return Intl.message(
      'Select Gender',
      name: 'selectGender',
      desc: '',
      args: [],
    );
  }

  /// `Date Of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date Of Birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Specialists`
  String get specialists {
    return Intl.message('Specialists', name: 'specialists', desc: '', args: []);
  }

  /// `Appointments`
  String get appointments {
    return Intl.message(
      'Appointments',
      name: 'appointments',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `How are you feeling today?`
  String get howAreYouEtc {
    return Intl.message(
      'How are you feeling today?',
      name: 'howAreYouEtc',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get hello {
    return Intl.message('Hello', name: 'hello', desc: '', args: []);
  }

  /// `Search for doctor or clinic..`
  String get searchForDoctorEtc {
    return Intl.message(
      'Search for doctor or clinic..',
      name: 'searchForDoctorEtc',
      desc: '',
      args: [],
    );
  }

  /// `Appointments For Today`
  String get appointmentsForToday {
    return Intl.message(
      'Appointments For Today',
      name: 'appointmentsForToday',
      desc: '',
      args: [],
    );
  }

  /// `Find by Specialities`
  String get findBySpecialities {
    return Intl.message(
      'Find by Specialities',
      name: 'findBySpecialities',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get viewAll {
    return Intl.message('View all', name: 'viewAll', desc: '', args: []);
  }

  /// `DENTIST`
  String get dentist {
    return Intl.message('DENTIST', name: 'dentist', desc: '', args: []);
  }

  /// `PATHOLOGIST`
  String get pathologist {
    return Intl.message('PATHOLOGIST', name: 'pathologist', desc: '', args: []);
  }

  /// `ORTHOPEDIST`
  String get orthopedist {
    return Intl.message('ORTHOPEDIST', name: 'orthopedist', desc: '', args: []);
  }

  /// `NEUROLOGIST`
  String get neurologist {
    return Intl.message('NEUROLOGIST', name: 'neurologist', desc: '', args: []);
  }

  /// `OPHTHALMOLOGIST`
  String get ophthalmologist {
    return Intl.message(
      'OPHTHALMOLOGIST',
      name: 'ophthalmologist',
      desc: '',
      args: [],
    );
  }

  /// `PEDIATRICIAN`
  String get pediatrician {
    return Intl.message(
      'PEDIATRICIAN',
      name: 'pediatrician',
      desc: '',
      args: [],
    );
  }

  /// `DERMATOLOGIST`
  String get dermatologist {
    return Intl.message(
      'DERMATOLOGIST',
      name: 'dermatologist',
      desc: '',
      args: [],
    );
  }

  /// `CARDIOLOGIST`
  String get cardiologist {
    return Intl.message(
      'CARDIOLOGIST',
      name: 'cardiologist',
      desc: '',
      args: [],
    );
  }

  /// `Best Dermatologists`
  String get bestDermatologists {
    return Intl.message(
      'Best Dermatologists',
      name: 'bestDermatologists',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming`
  String get upcoming {
    return Intl.message('Upcoming', name: 'upcoming', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Edit Details`
  String get editDetails {
    return Intl.message(
      'Edit Details',
      name: 'editDetails',
      desc: '',
      args: [],
    );
  }

  /// `Push Notification`
  String get pushNotification {
    return Intl.message(
      'Push Notification',
      name: 'pushNotification',
      desc: '',
      args: [],
    );
  }

  /// `Keep it On, if you want to receive notifications`
  String get keepItOnIfYou {
    return Intl.message(
      'Keep it On, if you want to receive notifications',
      name: 'keepItOnIfYou',
      desc: '',
      args: [],
    );
  }

  /// `Saved Doctors`
  String get savedDoctors {
    return Intl.message(
      'Saved Doctors',
      name: 'savedDoctors',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get wallet {
    return Intl.message('Wallet', name: 'wallet', desc: '', args: []);
  }

  /// `Manage Patients`
  String get managePatients {
    return Intl.message(
      'Manage Patients',
      name: 'managePatients',
      desc: '',
      args: [],
    );
  }

  /// `Home Program`
  String get prescriptions {
    return Intl.message(
      'Home Program',
      name: 'prescriptions',
      desc: '',
      args: [],
    );
  }

  /// `Terms Of Use`
  String get termsOfUse {
    return Intl.message('Terms Of Use', name: 'termsOfUse', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Help & FAQ`
  String get helpAndFAQ {
    return Intl.message('Help & FAQ', name: 'helpAndFAQ', desc: '', args: []);
  }

  /// `Delete My Account`
  String get deleteMyAccount {
    return Intl.message(
      'Delete My Account',
      name: 'deleteMyAccount',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Exp`
  String get expShort {
    return Intl.message('Exp', name: 'expShort', desc: '', args: []);
  }

  /// `years`
  String get years {
    return Intl.message('years', name: 'years', desc: '', args: []);
  }

  /// `Fees`
  String get fees {
    return Intl.message('Fees', name: 'fees', desc: '', args: []);
  }

  /// `Withdraw`
  String get withdraw {
    return Intl.message('Withdraw', name: 'withdraw', desc: '', args: []);
  }

  /// `Statement`
  String get statement {
    return Intl.message('Statement', name: 'statement', desc: '', args: []);
  }

  /// `Deposit`
  String get deposit {
    return Intl.message('Deposit', name: 'deposit', desc: '', args: []);
  }

  /// `Purchase`
  String get purchase {
    return Intl.message('Purchase', name: 'purchase', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Withdraw Request`
  String get withdrawRequest {
    return Intl.message(
      'Withdraw Request',
      name: 'withdrawRequest',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Swift Code`
  String get swiftCode {
    return Intl.message('Swift Code', name: 'swiftCode', desc: '', args: []);
  }

  /// `Holders Name`
  String get holdersName {
    return Intl.message(
      'Holders Name',
      name: 'holdersName',
      desc: '',
      args: [],
    );
  }

  /// `Re-Enter Account Number`
  String get reEnterAccountNumber {
    return Intl.message(
      'Re-Enter Account Number',
      name: 'reEnterAccountNumber',
      desc: '',
      args: [],
    );
  }

  /// `Account Number`
  String get accountNumber {
    return Intl.message(
      'Account Number',
      name: 'accountNumber',
      desc: '',
      args: [],
    );
  }

  /// `Bank Name`
  String get bankName {
    return Intl.message('Bank Name', name: 'bankName', desc: '', args: []);
  }

  /// `Recharge wallet`
  String get rechargeWallet {
    return Intl.message(
      'Recharge wallet',
      name: 'rechargeWallet',
      desc: '',
      args: [],
    );
  }

  /// `Add money to your wallet`
  String get addMoneyToYourWallet {
    return Intl.message(
      'Add money to your wallet',
      name: 'addMoneyToYourWallet',
      desc: '',
      args: [],
    );
  }

  /// `Please recharge\nyour wallet to continue booking`
  String get pleaseRechargeEtc {
    return Intl.message(
      'Please recharge\nyour wallet to continue booking',
      name: 'pleaseRechargeEtc',
      desc: '',
      args: [],
    );
  }

  /// `Select Amount`
  String get selectAmount {
    return Intl.message(
      'Select Amount',
      name: 'selectAmount',
      desc: '',
      args: [],
    );
  }

  /// `Enter Amount Of Your Choice`
  String get enterAmountOfYourChoice {
    return Intl.message(
      'Enter Amount Of Your Choice',
      name: 'enterAmountOfYourChoice',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clearAll {
    return Intl.message('Clear All', name: 'clearAll', desc: '', args: []);
  }

  /// `Show This QR at Clinic`
  String get showThisQRAtClinic {
    return Intl.message(
      'Show This QR at Clinic',
      name: 'showThisQRAtClinic',
      desc: '',
      args: [],
    );
  }

  /// `Offer this QR at clinic shop, they will\nscan it and will have all the details`
  String get offerThisQRAtClinicShop {
    return Intl.message(
      'Offer this QR at clinic shop, they will\nscan it and will have all the details',
      name: 'offerThisQRAtClinicShop',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete your account? all of your data will deleted and you won’t be able to recover it again !\n\nDo you really want to proceed?`
  String get doYouReallyWantToEtc {
    return Intl.message(
      'Do you really want to delete your account? all of your data will deleted and you won’t be able to recover it again !\n\nDo you really want to proceed?',
      name: 'doYouReallyWantToEtc',
      desc: '',
      args: [],
    );
  }

  /// `Apply Search Filters`
  String get applySearchFilters {
    return Intl.message(
      'Apply Search Filters',
      name: 'applySearchFilters',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sortBy {
    return Intl.message('Sort by', name: 'sortBy', desc: '', args: []);
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Search Doctor`
  String get searchDoctor {
    return Intl.message(
      'Search Doctor',
      name: 'searchDoctor',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `ABOUT DR.`
  String get aboutDr {
    return Intl.message('ABOUT DR.', name: 'aboutDr', desc: '', args: []);
  }

  /// `LANGUAGES`
  String get languages {
    return Intl.message('LANGUAGES', name: 'languages', desc: '', args: []);
  }

  /// `SERVICES`
  String get services {
    return Intl.message('SERVICES', name: 'services', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Reviews`
  String get reviews {
    return Intl.message('Reviews', name: 'reviews', desc: '', args: []);
  }

  /// `Education`
  String get education {
    return Intl.message('Education', name: 'education', desc: '', args: []);
  }

  /// `Experience`
  String get experience {
    return Intl.message('Experience', name: 'experience', desc: '', args: []);
  }

  /// `EXPERTISE`
  String get expertise {
    return Intl.message('EXPERTISE', name: 'expertise', desc: '', args: []);
  }

  /// `SERVICES LOCATIONS`
  String get servicesLocation {
    return Intl.message(
      'SERVICES LOCATIONS',
      name: 'servicesLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Date & Time`
  String get selectDateAndTime {
    return Intl.message(
      'Select Date & Time',
      name: 'selectDateAndTime',
      desc: '',
      args: [],
    );
  }

  /// `HAPPY PATIENTS`
  String get happyPatients {
    return Intl.message(
      'HAPPY PATIENTS',
      name: 'happyPatients',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `Select Time`
  String get selectTime {
    return Intl.message('Select Time', name: 'selectTime', desc: '', args: []);
  }

  /// `Appointment Type`
  String get appointmentType {
    return Intl.message(
      'Appointment Type',
      name: 'appointmentType',
      desc: '',
      args: [],
    );
  }

  /// `Patient`
  String get patient {
    return Intl.message('Patient', name: 'patient', desc: '', args: []);
  }

  /// `Explain Your Problem Briefly`
  String get explainYourProblemBriefly {
    return Intl.message(
      'Explain Your Problem Briefly',
      name: 'explainYourProblemBriefly',
      desc: '',
      args: [],
    );
  }

  /// `Attach Photo`
  String get attachPhoto {
    return Intl.message(
      'Attach Photo',
      name: 'attachPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Make Payment`
  String get makePayment {
    return Intl.message(
      'Make Payment',
      name: 'makePayment',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Booking`
  String get confirmBooking {
    return Intl.message(
      'Confirm Booking',
      name: 'confirmBooking',
      desc: '',
      args: [],
    );
  }

  /// `Apply Coupon`
  String get applyCoupon {
    return Intl.message(
      'Apply Coupon',
      name: 'applyCoupon',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Coupon Discount`
  String get couponDiscount {
    return Intl.message(
      'Coupon Discount',
      name: 'couponDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Consultation Charge`
  String get consultationCharge {
    return Intl.message(
      'Consultation Charge',
      name: 'consultationCharge',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Online`
  String get online {
    return Intl.message('Online', name: 'online', desc: '', args: []);
  }

  /// `At Clinic`
  String get clinic {
    return Intl.message('At Clinic', name: 'clinic', desc: '', args: []);
  }

  /// `Tap on a coupon to apply it`
  String get tapOnACouponEtc {
    return Intl.message(
      'Tap on a coupon to apply it',
      name: 'tapOnACouponEtc',
      desc: '',
      args: [],
    );
  }

  /// `Pay Now`
  String get payNow {
    return Intl.message('Pay Now', name: 'payNow', desc: '', args: []);
  }

  /// `Cash payment upon arrival`
  String get cashOnly {
    return Intl.message(
      'Cash payment upon arrival',
      name: 'cashOnly',
      desc: '',
      args: [],
    );
  }

  /// `Please prepare the amount in cash for your appointment`
  String get cashPaymentNote {
    return Intl.message(
      'Please prepare the amount in cash for your appointment',
      name: 'cashPaymentNote',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient Balance`
  String get insufficientBalance {
    return Intl.message(
      'Insufficient Balance',
      name: 'insufficientBalance',
      desc: '',
      args: [],
    );
  }

  /// `There is not enough funds in wallet`
  String get thereIsNotEnoughEtc {
    return Intl.message(
      'There is not enough funds in wallet',
      name: 'thereIsNotEnoughEtc',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Successful`
  String get transactionSuccessful {
    return Intl.message(
      'Transaction Successful',
      name: 'transactionSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Funds have been added\nto your account successfully!`
  String get fundsHaveBeenAddedEtc {
    return Intl.message(
      'Funds have been added\nto your account successfully!',
      name: 'fundsHaveBeenAddedEtc',
      desc: '',
      args: [],
    );
  }

  /// `Now you can book appointments\nwith single click to avoid disturbance.`
  String get nowYouCanBookAppointmentsEtc {
    return Intl.message(
      'Now you can book appointments\nwith single click to avoid disturbance.',
      name: 'nowYouCanBookAppointmentsEtc',
      desc: '',
      args: [],
    );
  }

  /// `Appointment Booked`
  String get appointmentBooked {
    return Intl.message(
      'Appointment Booked',
      name: 'appointmentBooked',
      desc: '',
      args: [],
    );
  }

  /// `Your appointment\nhas been booked successfully`
  String get yourAppointmentHasEtc {
    return Intl.message(
      'Your appointment\nhas been booked successfully',
      name: 'yourAppointmentHasEtc',
      desc: '',
      args: [],
    );
  }

  /// `My Appointments`
  String get myAppointments {
    return Intl.message(
      'My Appointments',
      name: 'myAppointments',
      desc: '',
      args: [],
    );
  }

  /// `Your Problem`
  String get yourProblem {
    return Intl.message(
      'Your Problem',
      name: 'yourProblem',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get attachments {
    return Intl.message('Attachments', name: 'attachments', desc: '', args: []);
  }

  /// `Appointment Details`
  String get appointmentDetails {
    return Intl.message(
      'Appointment Details',
      name: 'appointmentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Diagnosed With`
  String get diagnosedWith {
    return Intl.message(
      'Diagnosed With',
      name: 'diagnosedWith',
      desc: '',
      args: [],
    );
  }

  /// `Home Program`
  String get medicalPrescription {
    return Intl.message(
      'Home Program',
      name: 'medicalPrescription',
      desc: '',
      args: [],
    );
  }

  /// `Specialist has sent you your home program`
  String get drHasSentYouEtc {
    return Intl.message(
      'Specialist has sent you your home program',
      name: 'drHasSentYouEtc',
      desc: '',
      args: [],
    );
  }

  /// `Rate Your Experience`
  String get rateYourExperience {
    return Intl.message(
      'Rate Your Experience',
      name: 'rateYourExperience',
      desc: '',
      args: [],
    );
  }

  /// `Add Ratings`
  String get addRatings {
    return Intl.message('Add Ratings', name: 'addRatings', desc: '', args: []);
  }

  /// `Share your experience in few words`
  String get shareYourExperienceEtc {
    return Intl.message(
      'Share your experience in few words',
      name: 'shareYourExperienceEtc',
      desc: '',
      args: [],
    );
  }

  /// `Your Review`
  String get yourReview {
    return Intl.message('Your Review', name: 'yourReview', desc: '', args: []);
  }

  /// `Note: Only if you feel fever and headace`
  String get noteOnlyIfYouEtc {
    return Intl.message(
      'Note: Only if you feel fever and headace',
      name: 'noteOnlyIfYouEtc',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Write Here`
  String get writeHere {
    return Intl.message('Write Here', name: 'writeHere', desc: '', args: []);
  }

  /// `Download Prescription`
  String get downloadPrescription {
    return Intl.message(
      'Download Prescription',
      name: 'downloadPrescription',
      desc: '',
      args: [],
    );
  }

  /// `Patients`
  String get patients {
    return Intl.message('Patients', name: 'patients', desc: '', args: []);
  }

  /// `Add Patient`
  String get addPatient {
    return Intl.message('Add Patient', name: 'addPatient', desc: '', args: []);
  }

  /// `Relation`
  String get relation {
    return Intl.message('Relation', name: 'relation', desc: '', args: []);
  }

  /// `Age`
  String get age {
    return Intl.message('Age', name: 'age', desc: '', args: []);
  }

  /// `Full Name`
  String get fullName {
    return Intl.message('Full Name', name: 'fullName', desc: '', args: []);
  }

  /// `Check Appointments tab\nfor all your upcoming appointments`
  String get checkAppointmentsEtc {
    return Intl.message(
      'Check Appointments tab\nfor all your upcoming appointments',
      name: 'checkAppointmentsEtc',
      desc: '',
      args: [],
    );
  }

  /// `Jan`
  String get jan {
    return Intl.message('Jan', name: 'jan', desc: '', args: []);
  }

  /// `Feb`
  String get feb {
    return Intl.message('Feb', name: 'feb', desc: '', args: []);
  }

  /// `Mar`
  String get mar {
    return Intl.message('Mar', name: 'mar', desc: '', args: []);
  }

  /// `Apr`
  String get apr {
    return Intl.message('Apr', name: 'apr', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `Jun`
  String get jun {
    return Intl.message('Jun', name: 'jun', desc: '', args: []);
  }

  /// `Jul`
  String get jul {
    return Intl.message('Jul', name: 'jul', desc: '', args: []);
  }

  /// `Aug`
  String get aug {
    return Intl.message('Aug', name: 'aug', desc: '', args: []);
  }

  /// `Sep`
  String get sep {
    return Intl.message('Sep', name: 'sep', desc: '', args: []);
  }

  /// `Oct`
  String get oct {
    return Intl.message('Oct', name: 'oct', desc: '', args: []);
  }

  /// `Nov`
  String get nov {
    return Intl.message('Nov', name: 'nov', desc: '', args: []);
  }

  /// `Dec`
  String get dec {
    return Intl.message('Dec', name: 'dec', desc: '', args: []);
  }

  /// `Select Month`
  String get selectMonth {
    return Intl.message(
      'Select Month',
      name: 'selectMonth',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Enter here...`
  String get enterHere {
    return Intl.message('Enter here...', name: 'enterHere', desc: '', args: []);
  }

  /// `Enter Mobile Number`
  String get enterMobileNumber {
    return Intl.message(
      'Enter Mobile Number',
      name: 'enterMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Mobile Number`
  String get pleaseEnterMobileNumber {
    return Intl.message(
      'Please Enter Mobile Number',
      name: 'pleaseEnterMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `The provided phone number is not valid.`
  String get theProvidedPhoneEtc {
    return Intl.message(
      'The provided phone number is not valid.',
      name: 'theProvidedPhoneEtc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your otp.`
  String get pleaseEnterYourOtp {
    return Intl.message(
      'Please enter your otp.',
      name: 'pleaseEnterYourOtp',
      desc: '',
      args: [],
    );
  }

  /// `SMS verification code used to create the phone auth credential is invalid`
  String get smsVerificationCodeEtc {
    return Intl.message(
      'SMS verification code used to create the phone auth credential is invalid',
      name: 'smsVerificationCodeEtc',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Full Name`
  String get pleaseEnterFullName {
    return Intl.message(
      'Please Enter Full Name',
      name: 'pleaseEnterFullName',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Both`
  String get both {
    return Intl.message('Both', name: 'both', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Fees : Low`
  String get feesLow {
    return Intl.message('Fees : Low', name: 'feesLow', desc: '', args: []);
  }

  /// `Fees : High`
  String get feesHigh {
    return Intl.message('Fees : High', name: 'feesHigh', desc: '', args: []);
  }

  /// `Ratings`
  String get rating {
    return Intl.message('Ratings', name: 'rating', desc: '', args: []);
  }

  /// `Please Add your Photo`
  String get pleaseAddYourPhoto {
    return Intl.message(
      'Please Add your Photo',
      name: 'pleaseAddYourPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Edit Patient`
  String get editPatient {
    return Intl.message(
      'Edit Patient',
      name: 'editPatient',
      desc: '',
      args: [],
    );
  }

  /// `MAX`
  String get max {
    return Intl.message('MAX', name: 'max', desc: '', args: []);
  }

  /// `No Slot Available`
  String get noSlotAvailable {
    return Intl.message(
      'No Slot Available',
      name: 'noSlotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Refund`
  String get refund {
    return Intl.message('Refund', name: 'refund', desc: '', args: []);
  }

  /// `Reschedule`
  String get reschedule {
    return Intl.message('Reschedule', name: 'reschedule', desc: '', args: []);
  }

  /// `After Meal`
  String get afterMeal {
    return Intl.message('After Meal', name: 'afterMeal', desc: '', args: []);
  }

  /// `Before Meal`
  String get beforeMeal {
    return Intl.message('Before Meal', name: 'beforeMeal', desc: '', args: []);
  }

  /// `Completion OTP`
  String get completionOTP {
    return Intl.message(
      'Completion OTP',
      name: 'completionOTP',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for confirmation`
  String get waitingForConfirmation {
    return Intl.message(
      'Waiting for confirmation',
      name: 'waitingForConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message('Accepted', name: 'accepted', desc: '', args: []);
  }

  /// `Declined`
  String get declined {
    return Intl.message('Declined', name: 'declined', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `Rejected`
  String get rejected {
    return Intl.message('Rejected', name: 'rejected', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Withdraw Requests`
  String get withdrawRequests {
    return Intl.message(
      'Withdraw Requests',
      name: 'withdrawRequests',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Sub Total`
  String get subTotal {
    return Intl.message('Sub Total', name: 'subTotal', desc: '', args: []);
  }

  /// `Payable Amount`
  String get payableAmount {
    return Intl.message(
      'Payable Amount',
      name: 'payableAmount',
      desc: '',
      args: [],
    );
  }

  /// `Less`
  String get less {
    return Intl.message('Less', name: 'less', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `UnKnown`
  String get unKnown {
    return Intl.message('UnKnown', name: 'unKnown', desc: '', args: []);
  }

  /// `Exp`
  String get exp {
    return Intl.message('Exp', name: 'exp', desc: '', args: []);
  }

  /// `Awards`
  String get awards {
    return Intl.message('Awards', name: 'awards', desc: '', args: []);
  }

  /// `Please at least rating add.`
  String get pleaseAtLeastRatingAdd {
    return Intl.message(
      'Please at least rating add.',
      name: 'pleaseAtLeastRatingAdd',
      desc: '',
      args: [],
    );
  }

  /// `Please Add comment`
  String get pleaseAddComment {
    return Intl.message(
      'Please Add comment',
      name: 'pleaseAddComment',
      desc: '',
      args: [],
    );
  }

  /// `No Medical Prescription Add`
  String get noMedicalPrescriptionAdd {
    return Intl.message(
      'No Medical Prescription Add',
      name: 'noMedicalPrescriptionAdd',
      desc: '',
      args: [],
    );
  }

  /// `Ratings`
  String get ratings {
    return Intl.message('Ratings', name: 'ratings', desc: '', args: []);
  }

  /// `Book Now`
  String get bookNow {
    return Intl.message('Book Now', name: 'bookNow', desc: '', args: []);
  }

  /// `Appointment ID`
  String get appointmentID {
    return Intl.message(
      'Appointment ID',
      name: 'appointmentID',
      desc: '',
      args: [],
    );
  }

  /// `No Service Location`
  String get noServiceLocation {
    return Intl.message(
      'No Service Location',
      name: 'noServiceLocation',
      desc: '',
      args: [],
    );
  }

  /// `No Patient`
  String get noPatient {
    return Intl.message('No Patient', name: 'noPatient', desc: '', args: []);
  }

  /// `Dr.`
  String get dr {
    return Intl.message('Dr.', name: 'dr', desc: '', args: []);
  }

  /// `Do you really want to logout your account?\n\nAre you sure?`
  String get doYouReallyWantToLogoutEtc {
    return Intl.message(
      'Do you really want to logout your account?\n\nAre you sure?',
      name: 'doYouReallyWantToLogoutEtc',
      desc: '',
      args: [],
    );
  }

  /// `Please Explain your Problem`
  String get pleaseExplainYourProblem {
    return Intl.message(
      'Please Explain your Problem',
      name: 'pleaseExplainYourProblem',
      desc: '',
      args: [],
    );
  }

  /// `Please select Appointment Time`
  String get pleaseSelectAppointmentTime {
    return Intl.message(
      'Please select Appointment Time',
      name: 'pleaseSelectAppointmentTime',
      desc: '',
      args: [],
    );
  }

  /// `Please select Appointment Type`
  String get pleaseSelectAppointmentType {
    return Intl.message(
      'Please select Appointment Type',
      name: 'pleaseSelectAppointmentType',
      desc: '',
      args: [],
    );
  }

  /// `Not enough balance to withdraw!`
  String get notEnoughBalanceToWithdraw {
    return Intl.message(
      'Not enough balance to withdraw!',
      name: 'notEnoughBalanceToWithdraw',
      desc: '',
      args: [],
    );
  }

  /// `Correct Swift Code`
  String get correctSwiftCode {
    return Intl.message(
      'Correct Swift Code',
      name: 'correctSwiftCode',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?\n do want to logout?`
  String get areYouSureLogout {
    return Intl.message(
      'Are you sure?\n do want to logout?',
      name: 'areYouSureLogout',
      desc: '',
      args: [],
    );
  }

  /// `Please Account Number same`
  String get pleaseAccountNumberSame {
    return Intl.message(
      'Please Account Number same',
      name: 'pleaseAccountNumberSame',
      desc: '',
      args: [],
    );
  }

  /// `Payment Failed`
  String get paymentFailed {
    return Intl.message(
      'Payment Failed',
      name: 'paymentFailed',
      desc: '',
      args: [],
    );
  }

  /// `Payment Cancelled`
  String get paymentCancelled {
    return Intl.message(
      'Payment Cancelled',
      name: 'paymentCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Something  went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something  went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Minimum amount 50 add to your wallet`
  String get minimumAmountAddEtc {
    return Intl.message(
      'Minimum amount 50 add to your wallet',
      name: 'minimumAmountAddEtc',
      desc: '',
      args: [],
    );
  }

  /// `Please, provide this OTP to doctor when asked, only after you get your services as per the order.`
  String get pleaseProvideThisOTPEtc {
    return Intl.message(
      'Please, provide this OTP to doctor when asked, only after you get your services as per the order.',
      name: 'pleaseProvideThisOTPEtc',
      desc: '',
      args: [],
    );
  }

  /// `Send Media`
  String get sendMedia {
    return Intl.message('Send Media', name: 'sendMedia', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Waiting for`
  String get waitingFor {
    return Intl.message('Waiting for', name: 'waitingFor', desc: '', args: []);
  }

  /// `Mute Audio`
  String get muteAudio {
    return Intl.message('Mute Audio', name: 'muteAudio', desc: '', args: []);
  }

  /// `Join a channel`
  String get joinAChannel {
    return Intl.message(
      'Join a channel',
      name: 'joinAChannel',
      desc: '',
      args: [],
    );
  }

  /// `Id`
  String get id {
    return Intl.message('Id', name: 'id', desc: '', args: []);
  }

  /// `Doctor Details`
  String get doctorDetail {
    return Intl.message(
      'Doctor Details',
      name: 'doctorDetail',
      desc: '',
      args: [],
    );
  }

  /// `Patient Details`
  String get patientDetail {
    return Intl.message(
      'Patient Details',
      name: 'patientDetail',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Designation`
  String get designation {
    return Intl.message('Designation', name: 'designation', desc: '', args: []);
  }

  /// `degrees`
  String get degrees {
    return Intl.message('degrees', name: 'degrees', desc: '', args: []);
  }

  /// `Doses`
  String get doses {
    return Intl.message('Doses', name: 'doses', desc: '', args: []);
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Select Message`
  String get selectMsg {
    return Intl.message(
      'Select Message',
      name: 'selectMsg',
      desc: '',
      args: [],
    );
  }

  /// `Delete message`
  String get deleteMessage {
    return Intl.message(
      'Delete message',
      name: 'deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete for me`
  String get deleteForMe {
    return Intl.message(
      'Delete for me',
      name: 'deleteForMe',
      desc: '',
      args: [],
    );
  }

  /// `Delete Chat`
  String get deleteChat {
    return Intl.message('Delete Chat', name: 'deleteChat', desc: '', args: []);
  }

  /// `Message will only be removed from this device\nAre you sure?`
  String get messageWillOnlyBeRemovedEtc {
    return Intl.message(
      'Message will only be removed from this device\nAre you sure?',
      name: 'messageWillOnlyBeRemovedEtc',
      desc: '',
      args: [],
    );
  }

  /// `CONSULTATION`
  String get consultation {
    return Intl.message(
      'CONSULTATION',
      name: 'consultation',
      desc: '',
      args: [],
    );
  }

  /// `VIDEO`
  String get video {
    return Intl.message('VIDEO', name: 'video', desc: '', args: []);
  }

  /// `is asking you to join the video consultation.`
  String get isAskingYouToJoinEtc {
    return Intl.message(
      'is asking you to join the video consultation.',
      name: 'isAskingYouToJoinEtc',
      desc: '',
      args: [],
    );
  }

  /// `Please wait Your meeting not Start`
  String get pleaseWaitYourMeetingEtc {
    return Intl.message(
      'Please wait Your meeting not Start',
      name: 'pleaseWaitYourMeetingEtc',
      desc: '',
      args: [],
    );
  }

  /// `Meeting end`
  String get meetingEnd {
    return Intl.message('Meeting end', name: 'meetingEnd', desc: '', args: []);
  }

  /// `Join Meeting`
  String get joinMeeting {
    return Intl.message(
      'Join Meeting',
      name: 'joinMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Meeting Ended`
  String get endMeeting {
    return Intl.message(
      'Meeting Ended',
      name: 'endMeeting',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `This Month Now Allow`
  String get thisMonthNowAllow {
    return Intl.message(
      'This Month Now Allow',
      name: 'thisMonthNowAllow',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message('Just now', name: 'justNow', desc: '', args: []);
  }

  /// `Minutes`
  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Minute`
  String get minute {
    return Intl.message('Minute', name: 'minute', desc: '', args: []);
  }

  /// `Hours`
  String get hours {
    return Intl.message('Hours', name: 'hours', desc: '', args: []);
  }

  /// `Hour`
  String get hour {
    return Intl.message('Hour', name: 'hour', desc: '', args: []);
  }

  /// `Days`
  String get days {
    return Intl.message('Days', name: 'days', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Week`
  String get week {
    return Intl.message('Week', name: 'week', desc: '', args: []);
  }

  /// `Weeks`
  String get weeks {
    return Intl.message('Weeks', name: 'weeks', desc: '', args: []);
  }

  /// `Months`
  String get months {
    return Intl.message('Months', name: 'months', desc: '', args: []);
  }

  /// `Month`
  String get month {
    return Intl.message('Month', name: 'month', desc: '', args: []);
  }

  /// `Year`
  String get year {
    return Intl.message('Year', name: 'year', desc: '', args: []);
  }

  /// `No Data`
  String get noData {
    return Intl.message('No Data', name: 'noData', desc: '', args: []);
  }

  /// `Too Large`
  String get tooLarge {
    return Intl.message('Too Large', name: 'tooLarge', desc: '', args: []);
  }

  /// `Select another`
  String get selectAnother {
    return Intl.message(
      'Select another',
      name: 'selectAnother',
      desc: '',
      args: [],
    );
  }

  /// `Are you Sure?`
  String get areYouSure {
    return Intl.message(
      'Are you Sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get end {
    return Intl.message('End', name: 'end', desc: '', args: []);
  }

  /// `This video is greater than 50 mb\nPlease select another...`
  String get thisVideoIsGreaterThan15MbEtc {
    return Intl.message(
      'This video is greater than 50 mb\nPlease select another...',
      name: 'thisVideoIsGreaterThan15MbEtc',
      desc: '',
      args: [],
    );
  }

  /// `No Data Available`
  String get noDataAvailable {
    return Intl.message(
      'No Data Available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No Withdraw Request Available`
  String get noWithdrawRequestAvailable {
    return Intl.message(
      'No Withdraw Request Available',
      name: 'noWithdrawRequestAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No Appointments Available`
  String get noAppointmentsAvailable {
    return Intl.message(
      'No Appointments Available',
      name: 'noAppointmentsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No Service Available`
  String get noServiceAvailable {
    return Intl.message(
      'No Service Available',
      name: 'noServiceAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No Expertise Available`
  String get noExpertiseAvailable {
    return Intl.message(
      'No Expertise Available',
      name: 'noExpertiseAvailable',
      desc: '',
      args: [],
    );
  }

  /// `DOB`
  String get bod {
    return Intl.message('DOB', name: 'bod', desc: '', args: []);
  }

  /// `Medicine Name`
  String get medicalName {
    return Intl.message(
      'Medicine Name',
      name: 'medicalName',
      desc: '',
      args: [],
    );
  }

  /// `Dose Time`
  String get doseTime {
    return Intl.message('Dose Time', name: 'doseTime', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `Do you want to cancel this Appointment?`
  String get doYouWantToCancelThisAppointment {
    return Intl.message(
      'Do you want to cancel this Appointment?',
      name: 'doYouWantToCancelThisAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Slot not available`
  String get slotNotAvailable {
    return Intl.message(
      'Slot not available',
      name: 'slotNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `You have already booked this slot`
  String get youHaveAlreadyBookedThisSlot {
    return Intl.message(
      'You have already booked this slot',
      name: 'youHaveAlreadyBookedThisSlot',
      desc: '',
      args: [],
    );
  }

  /// `Not Available`
  String get notAvailable {
    return Intl.message(
      'Not Available',
      name: 'notAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Slots Available`
  String get slotsAvailable {
    return Intl.message(
      'Slots Available',
      name: 'slotsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Forget Password?`
  String get forgetPassword {
    return Intl.message(
      'Forget Password?',
      name: 'forgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Appointment, Online Diagnostic, Booking, Management Multi-Vendor App`
  String get appointmentOnlineDiagnosticBookingManagementMultivendorApp {
    return Intl.message(
      'Appointment, Online Diagnostic, Booking, Management Multi-Vendor App',
      name: 'appointmentOnlineDiagnosticBookingManagementMultivendorApp',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Already have an account?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get logIn {
    return Intl.message('Log in', name: 'logIn', desc: '', args: []);
  }

  /// `Please select your country`
  String get pleaseSelectYourCountry {
    return Intl.message(
      'Please select your country',
      name: 'pleaseSelectYourCountry',
      desc: '',
      args: [],
    );
  }

  /// `Registration successfully done. Please login to continue`
  String get registrationSuccessfullyDonePleaseLoginToContinue {
    return Intl.message(
      'Registration successfully done. Please login to continue',
      name: 'registrationSuccessfullyDonePleaseLoginToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password`
  String get forgotPassword {
    return Intl.message(
      'Forgot password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid email`
  String get pleaseEnterValidEmail {
    return Intl.message(
      'Please enter valid email',
      name: 'pleaseEnterValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please verified your email`
  String get pleaseVerifiedYourEmail {
    return Intl.message(
      'Please verified your email',
      name: 'pleaseVerifiedYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `No user found for this email`
  String get noUserFoundForThisEmail {
    return Intl.message(
      'No user found for this email',
      name: 'noUserFoundForThisEmail',
      desc: '',
      args: [],
    );
  }

  /// `password doesn't match`
  String get passwordDoesntMatch {
    return Intl.message(
      'password doesn\'t match',
      name: 'passwordDoesntMatch',
      desc: '',
      args: [],
    );
  }

  /// `Please enter mail`
  String get pleaseEnterMail {
    return Intl.message(
      'Please enter mail',
      name: 'pleaseEnterMail',
      desc: '',
      args: [],
    );
  }

  /// `Email sent successfully sent your mail`
  String get emailSentSuccessfullySentYourMail {
    return Intl.message(
      'Email sent successfully sent your mail',
      name: 'emailSentSuccessfullySentYourMail',
      desc: '',
      args: [],
    );
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Please fill your details and complete registration to start find doctors, book appointments have digital consultation, get prescription and live healthy life.`
  String get pleaseFillYourDetailsAndCompleteRegistrationToStartFind {
    return Intl.message(
      'Please fill your details and complete registration to start find doctors, book appointments have digital consultation, get prescription and live healthy life.',
      name: 'pleaseFillYourDetailsAndCompleteRegistrationToStartFind',
      desc: '',
      args: [],
    );
  }

  /// `Fullname`
  String get fullname {
    return Intl.message('Fullname', name: 'fullname', desc: '', args: []);
  }

  /// `Re-type Password`
  String get retypePassword {
    return Intl.message(
      'Re-type Password',
      name: 'retypePassword',
      desc: '',
      args: [],
    );
  }

  /// `By proceeding forward, You agree to the\n`
  String get byProceedingForwardYouAgreeToThen {
    return Intl.message(
      'By proceeding forward, You agree to the\n',
      name: 'byProceedingForwardYouAgreeToThen',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get and {
    return Intl.message('and', name: 'and', desc: '', args: []);
  }

  /// `Terms & Conditions`
  String get termsConditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'termsConditions',
      desc: '',
      args: [],
    );
  }

  /// `Password dosen't match! Enter same password.`
  String get passwordDosentMatchEnterSamePassword {
    return Intl.message(
      'Password dosen\'t match! Enter same password.',
      name: 'passwordDosentMatchEnterSamePassword',
      desc: '',
      args: [],
    );
  }

  /// `The password provided is too weak.`
  String get thePasswordProvidedIsTooWeak {
    return Intl.message(
      'The password provided is too weak.',
      name: 'thePasswordProvidedIsTooWeak',
      desc: '',
      args: [],
    );
  }

  /// `The account already exists for that email.`
  String get theAccountAlreadyExistsForThatEmail {
    return Intl.message(
      'The account already exists for that email.',
      name: 'theAccountAlreadyExistsForThatEmail',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number`
  String get mobileNumber {
    return Intl.message(
      'Mobile number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Left the meeting`
  String get leftTheMeeting {
    return Intl.message(
      'Left the meeting',
      name: 'leftTheMeeting',
      desc: '',
      args: [],
    );
  }

  /// `Mute the Audio`
  String get muteTheAudio {
    return Intl.message(
      'Mute the Audio',
      name: 'muteTheAudio',
      desc: '',
      args: [],
    );
  }

  /// `Find doctors, book appointments,\nhave digital consultation & get \nprescription Anytime Anywhere!`
  String get findDoctorsBookAppointmentEtc {
    return Intl.message(
      'Find doctors, book appointments,\nhave digital consultation & get \nprescription Anytime Anywhere!',
      name: 'findDoctorsBookAppointmentEtc',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to Continue`
  String get signInToContinue {
    return Intl.message(
      'Sign in to Continue',
      name: 'signInToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `New User? Register Here`
  String get newUserRegisterHere {
    return Intl.message(
      'New User? Register Here',
      name: 'newUserRegisterHere',
      desc: '',
      args: [],
    );
  }

  /// `Verify the link sent to your email, then complete the form.`
  String get verifyTheLinkSentToYourEmailThenCompleteThe {
    return Intl.message(
      'Verify the link sent to your email, then complete the form.',
      name: 'verifyTheLinkSentToYourEmailThenCompleteThe',
      desc: '',
      args: [],
    );
  }

  /// `The email is already in use in the doctor app. Please use a different email address.`
  String get theEmailIsAlreadyInUseInTheDoctorApp {
    return Intl.message(
      'The email is already in use in the doctor app. Please use a different email address.',
      name: 'theEmailIsAlreadyInUseInTheDoctorApp',
      desc: '',
      args: [],
    );
  }

  /// `Med Reels`
  String get medReels {
    return Intl.message('Med Reels', name: 'medReels', desc: '', args: []);
  }

  /// `Doctors`
  String get doctors {
    return Intl.message('Doctors', name: 'doctors', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Cancel Appointment`
  String get cancelAppointment {
    return Intl.message(
      'Cancel Appointment',
      name: 'cancelAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel your doctor appointment? This action cannot be undone, and your appointment will be removed.`
  String get areYouSureYouWantToCancelYourDoctorAppointment {
    return Intl.message(
      'Are you sure you want to cancel your doctor appointment? This action cannot be undone, and your appointment will be removed.',
      name: 'areYouSureYouWantToCancelYourDoctorAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Reschedule Appointment`
  String get rescheduleAppointment {
    return Intl.message(
      'Reschedule Appointment',
      name: 'rescheduleAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reschedule your doctor appointment? You can choose a new time slot for your appointment.`
  String get areYouSureYouWantToRescheduleYourDoctorAppointment {
    return Intl.message(
      'Are you sure you want to reschedule your doctor appointment? You can choose a new time slot for your appointment.',
      name: 'areYouSureYouWantToRescheduleYourDoctorAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this message? Once deleted, it cannot be recovered.`
  String get areYouSureYouWantToDeleteThisMessageOnce {
    return Intl.message(
      'Are you sure you want to delete this message? Once deleted, it cannot be recovered.',
      name: 'areYouSureYouWantToDeleteThisMessageOnce',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this chat? This action will permanently remove the conversation and cannot be undone.`
  String get areYouSureYouWantToDeleteThisChatThis {
    return Intl.message(
      'Are you sure you want to delete this chat? This action will permanently remove the conversation and cannot be undone.',
      name: 'areYouSureYouWantToDeleteThisChatThis',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave the meeting? You can rejoin later if the doctor is available.`
  String get areYouSureYouWantToLeaveTheMeetingYou {
    return Intl.message(
      'Are you sure you want to leave the meeting? You can rejoin later if the doctor is available.',
      name: 'areYouSureYouWantToLeaveTheMeetingYou',
      desc: '',
      args: [],
    );
  }

  /// `Leave Meeting`
  String get leaveMeeting {
    return Intl.message(
      'Leave Meeting',
      name: 'leaveMeeting',
      desc: '',
      args: [],
    );
  }

  /// `More here..`
  String get moreHere {
    return Intl.message('More here..', name: 'moreHere', desc: '', args: []);
  }

  /// `Views`
  String get views {
    return Intl.message('Views', name: 'views', desc: '', args: []);
  }

  /// `Comments`
  String get comments {
    return Intl.message('Comments', name: 'comments', desc: '', args: []);
  }

  /// `No Comments`
  String get noComments {
    return Intl.message('No Comments', name: 'noComments', desc: '', args: []);
  }

  /// `Submit Report`
  String get submitReport {
    return Intl.message(
      'Submit Report',
      name: 'submitReport',
      desc: '',
      args: [],
    );
  }

  /// `Please explain the issue briefly. We will surely notify this to admin.`
  String get pleaseExplainTheIssueBrieflyWeWillSurelyNotifyThis {
    return Intl.message(
      'Please explain the issue briefly. We will surely notify this to admin.',
      name: 'pleaseExplainTheIssueBrieflyWeWillSurelyNotifyThis',
      desc: '',
      args: [],
    );
  }

  /// `Select Reason`
  String get selectReason {
    return Intl.message(
      'Select Reason',
      name: 'selectReason',
      desc: '',
      args: [],
    );
  }

  /// `Please explain your reason briefly.`
  String get pleaseExplainYourReasonBriefly {
    return Intl.message(
      'Please explain your reason briefly.',
      name: 'pleaseExplainYourReasonBriefly',
      desc: '',
      args: [],
    );
  }

  /// `Reels`
  String get reels {
    return Intl.message('Reels', name: 'reels', desc: '', args: []);
  }

  /// `No Reels`
  String get noReels {
    return Intl.message('No Reels', name: 'noReels', desc: '', args: []);
  }

  /// `Explain Here`
  String get explainHere {
    return Intl.message(
      'Explain Here',
      name: 'explainHere',
      desc: '',
      args: [],
    );
  }

  /// `Saved Reels`
  String get savedReels {
    return Intl.message('Saved Reels', name: 'savedReels', desc: '', args: []);
  }

  /// `No Saved Doctors`
  String get noSavedDoctors {
    return Intl.message(
      'No Saved Doctors',
      name: 'noSavedDoctors',
      desc: '',
      args: [],
    );
  }

  /// `No Users`
  String get noUsers {
    return Intl.message('No Users', name: 'noUsers', desc: '', args: []);
  }

  /// `Please enter email`
  String get pleaseEnterEmail {
    return Intl.message(
      'Please enter email',
      name: 'pleaseEnterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter password`
  String get pleaseEnterPassword {
    return Intl.message(
      'Please enter password',
      name: 'pleaseEnterPassword',
      desc: '',
      args: [],
    );
  }

  /// `No Doctors`
  String get noDoctors {
    return Intl.message('No Doctors', name: 'noDoctors', desc: '', args: []);
  }

  /// `You are already registered with this email.`
  String get youAreAlreadyRegisteredWithThisEmail {
    return Intl.message(
      'You are already registered with this email.',
      name: 'youAreAlreadyRegisteredWithThisEmail',
      desc: '',
      args: [],
    );
  }

  /// `Fill in your details to begin your digital healthcare journey. Connect with doctors and easily book appointments.`
  String get fillInYourDetailsToBeginYourDigitalHealthcareJourney {
    return Intl.message(
      'Fill in your details to begin your digital healthcare journey. Connect with doctors and easily book appointments.',
      name: 'fillInYourDetailsToBeginYourDigitalHealthcareJourney',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'nb'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'th'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
