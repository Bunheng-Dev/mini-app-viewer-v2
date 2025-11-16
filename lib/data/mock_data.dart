import 'package:mini_app_viewer/models/telegram_user.dart';
import 'package:mini_app_viewer/models/aba_profile.dart';
import 'package:mini_app_viewer/models/aba_account.dart';

// Static Telegram user credentials
final TelegramUser mockTelegramUser = TelegramUser(
  id: 123456789,
  username: 'nealika',
  firstName: 'Nealika',
  lastName: 'Tester',
  photoUrl: 'https://i.pravatar.cc/150?img=12',
  languageCode: 'en',
);

// Static ABA user profile
final ABAProfile mockABAProfile = ABAProfile(
  // these fields are for basic profile
  appId: "123456",
  firstName: "nealika",
  middleName: "Unknown",
  lastName: "Tester",
  fullName: "",
  sex: "M",
  dobShort: "DD-MM",
  nationality: "KHM",
  phone: "+85512345678",
  email: "",
  lang: "en", // en, kh, zh
  id: "123456", // app id
  appVersion: "4.9.12",
  osVersion: "14.7.1",

  // these additional fields are for full profile
  address: "NA,NA,NA,Phum4 Tuek Lak Ti Muoy",
  city: "Phnom Penh",
  country: "KHM",
  dobFull: "DD-MM-YYYY",
  nidNumber: "061620247",
  nidType: "1",
  nidExpiryDate: 'DD-MM-YYYY',
  nidDoc: '',
  occupation: '',
  addrCode: '',
  secretKey: '',
);

// Static ABA default account
final ABAAccount mockABAAccount = ABAAccount(
  accountName: 'Nealika Tester',
  accountNumber: '000067106',
  currency: 'USD',
);
