import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';

class ConstRes {
  ///------------------------ Backend urls and key ------------------------///
  static const String base = 'https://doctor.baitpait.space/';
  static const String itemBaseURL = '${base}public/storage/';
  static const String privacyPolicy = '${base}privacypolicy';
  static const String termsOfUse = '${base}termsOfUse';
  static const String baseUrl = '${base}api/user/';
  static const String apiKey = '123';

  ///------------------------ Subscribe Token ------------------------///
  static const String subscribeTopic = 'patient';

  ///------------------------ Agora app Id ------------------------///
  static const String agoraAppId = "ENTER APP ID";
}

// PaymentGateway
// SSLCommerze
String sslSdkType = SSLCSdkType.TESTBOX;
String sslProductCategory = "Money Add to Wallet";
String sslTransactionId = "custom_transaction_id";

// App Default Language only use This code :-  ('ar', 'da','nl','en','fr','de','el','hi','id','it','ja','ko','nb','pl','pt','ru','zh','es','th','tr','vi')
const appLanguageCode = 'ar';

// For Phone Number field
const countryName = 'India';
const countryCode = 'IN';
const phoneCode = '+91';

// App Default Currency
const defaultCurrency = 'USD';
const defaultCurrencyIcon = '\$';

// Image quality
const int imageQuality = 40;
const double maxWidth = 720;
const double maxHeight = 720;

//  App Name
const String appName = 'Flash Care';

// Pagination limit
const int paginationLimit = 10;

// Date Selector
const int dateLimit = 90;

// Minimum amount to withdraw
const int minimumAmountWithdraw = 100;

// Fot Chat Gpt
const chatGptRole = 'system';
const chatGptMaxConversationPrompt = 2;
const defaultChatGptName = 'HealthBot';
const defaultChatGptDescription = 'Ask Me Anything...';

String chatGptFirstPrompt(String? name) =>
    'You are an AI assistant named ${name ?? defaultChatGptName}.'
    'You are a virtual health assistant designed to provide general medical advice and support to patients. '
    'You can answer questions, provide health tips, and guide patients about common symptoms or conditions. '
    'However, you must always remind users that your advice is not a substitute for professional medical consultation with their doctor. '
    'If the question is beyond your scope, encourage users to contact their doctor. '
    'Please respond in a friendly and empathetic tone.';

List<String> reportReason = [
  'Copyright Infringement',
  'Hate Speech',
  'Harassment or Bullying',
  'Violence or Threats',
  'Nudity or Sexual Content',
  'Terrorism or Extremist Content',
  'Scams or Fraud',
  'Spam',
  'Impersonation',
  'Misinformation'
];
