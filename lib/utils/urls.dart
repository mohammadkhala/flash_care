import 'package:patient_flutter/utils/const_res.dart';

class Urls {
  ///------------------------ Urls ------------------------///

  static const String registration = '${ConstRes.baseUrl}registerUser';
  static const String updateUserDetails =
      '${ConstRes.baseUrl}updateUserDetails';
  static const String fetchNotification =
      '${ConstRes.baseUrl}fetchNotification';
  static const String fetchHomePageData =
      '${ConstRes.baseUrl}fetchHomePageData';
  static const String searchDoctor = '${ConstRes.baseUrl}searchDoctor';
  static const String fetchPatients = '${ConstRes.baseUrl}fetchPatients';
  static const String addPatient = '${ConstRes.baseUrl}addPatient';
  static const String editPatient = '${ConstRes.baseUrl}editPatient';
  static const String deletePatient = '${ConstRes.baseUrl}deletePatient';
  static const String fetchDoctorProfile =
      '${ConstRes.baseUrl}fetchDoctorProfile';
  static const String fetchDoctorReviews =
      '${ConstRes.baseUrl}fetchDoctorReviews';
  static const String fetchFavoriteDoctors =
      '${ConstRes.baseUrl}fetchFavoriteDoctors';
  static const String fetchCoupons = '${ConstRes.baseUrl}fetchCoupons';
  static const String fetchMyUserDetails =
      '${ConstRes.baseUrl}fetchMyUserDetails';
  static const String addMoneyToUserWallet =
      '${ConstRes.baseUrl}addMoneyToUserWallet';
  static const String addAppointment = '${ConstRes.baseUrl}addAppointment';
  static const String fetchUserWithdrawRequests =
      '${ConstRes.baseUrl}fetchUserWithdrawRequests';
  static const String fetchWalletStatement =
      '${ConstRes.baseUrl}fetchWalletStatement';
  static const String submitUserWithdrawRequest =
      '${ConstRes.baseUrl}submitUserWithdrawRequest';
  static const String fetchAppointmentDetails =
      '${ConstRes.baseUrl}fetchAppointmentDetails';
  static const String fetchMyPrescriptions =
      '${ConstRes.baseUrl}fetchMyPrescriptions';
  static const String fetchMyAppointments =
      '${ConstRes.baseUrl}fetchMyAppointments';
  static const String addRating = '${ConstRes.baseUrl}addRating';
  static const String rescheduleAppointment =
      '${ConstRes.baseUrl}rescheduleAppointment';
  static const String cancelAppointment =
      '${ConstRes.baseUrl}cancelAppointment';
  static const String logOut = '${ConstRes.baseUrl}logOut';
  static const String deleteUserAccount =
      '${ConstRes.baseUrl}deleteUserAccount';
  static const String fetchAcceptedPendingAppointmentsOfDoctorByDate =
      '${ConstRes.baseUrl}fetchAcceptedPendingAppointmentsOfDoctorByDate';
  static const String scheduleAppointmentReminders =
      '${ConstRes.baseUrl}scheduleAppointmentReminders';
  static const String fetchGlobalSettings =
      '${ConstRes.base}api/fetchGlobalSettings';
  static const String fetchFaqCats = '${ConstRes.base}api/fetchFaqCats';
  static const String uploadFileGivePath =
      '${ConstRes.base}api/uploadFileGivePath';
  static const String generateAgoraToken =
      '${ConstRes.base}api/generateAgoraToken';
  static const String pushNotificationToSingleUser =
      '${ConstRes.base}api/pushNotificationToSingleUser';
  static const String increaseReelViewCount =
      '${ConstRes.base}api/increaseReelViewCount';
  static const String fetchReelComments =
      '${ConstRes.base}api/fetchReelComments';
  static const String reportReel = '${ConstRes.base}api/reportReel';
  static const String fetchReelsPatientApp =
      '${ConstRes.baseUrl}fetchReelsPatientApp';
  static const String likeReelPatientApp =
      '${ConstRes.baseUrl}likeReelPatientApp';
  static const String addCommentOnReelPatientApp =
      '${ConstRes.baseUrl}addCommentOnReelPatientApp';
  static const String fetchReelByIdPatient =
      '${ConstRes.baseUrl}fetchReelByIdPatient';
  static const String fetchDoctorReels = '${ConstRes.baseUrl}fetchDoctorReels';
  static const String fetchSavedReels = '${ConstRes.base}api/fetchSavedReels';
  static const String fetchDoctorCategories =
      '${ConstRes.base}api/fetchDoctorCategories';

  static const String myHealthBotUrl =
      'https://api.openai.com/v1/chat/completions';

  // WhatsApp OTP & Phone Auth
  static const String sendOtp        = '${ConstRes.base}api/sendOtp';
  static const String verifyOtpUser  = '${ConstRes.base}api/verifyOtpUser';
  static const String loginWithPhone = '${ConstRes.base}api/loginWithPhone';
}

///------------------------ Params ------------------------///

const String pApikeyName = 'apikey';
const String pPost = 'POST';
const String pIdentity = 'identity';
const String pFullName = 'fullname';
const String pDeviceType = 'device_type';
const String pDeviceToken = 'device_token';
const String pLoginType = 'login_type';
const String pCountryCode = 'country_code';
const String pDob = 'dob';
const String pFavouriteDoctors = 'favourite_doctors';
const String pGender = 'gender';
const String pProfileImage = 'profile_image';
const String pStart = 'start';
const String pCount = 'count';
const String pUserId = 'user_id';
const String pPatientId = 'patient_id';
const String pDate = 'date';
const String pTime = 'time';
const String pOrderSummary = 'order_summary';
const String pTotalAmount = 'total_amount';
const String pPayableAmount = 'payable_amount';
const String pCategoryId = 'category_id';
const String pSortType = 'sort_type';
const String pKeyword = 'keyword';
const String pAge = 'age';
const String pRelation = 'relation';
const String pIsNotification = 'is_notification';
const String pImage = 'image';
const String pDocuments = 'documents[]';
const String pType = 'type';
const String pDoctorId = 'doctor_id';
const String pProblem = 'problem';
const String pAmount = 'amount';
const String pGateway = 'gateway';
const String pTransactionId = 'transaction_id';
const String pTransactionSummary = 'transaction_summary';
const String pIsCouponApplied = 'is_coupon_applied';
const String pDiscountAmount = 'discount_amount';
const String pServiceAmount = 'service_amount';
const String pSubtotal = 'subtotal';
const String pTotalTaxAmount = 'total_tax_amount';
const String pCouponTitle = 'coupon_title';
const String pCouponId = 'coupon_id';
const String pBankTitle = 'bank_title';
const String pAccountNumber = 'account_number';
const String pHolder = 'holder';
const String pSwiftCode = 'swift_code';
const String pAppointmentId = 'appointment_id';
const String pComment = 'comment';
const String pRating = 'rating';
const String pFile = 'file';
const String pChannelName = 'channelName';
const String pPhoneNumber = 'phone_number';
const String pIsLogin = 'is_login';
const String pReelId = 'reel_id';
const String pSavedReels = 'saved_reels';
const String pIds = 'ids';
const String pId = 'id';
const String pReason = 'reason';
const String pReportBy = 'report_by';
const String pDescription = 'description';
const String pScheduledAt = 'scheduled_at';
