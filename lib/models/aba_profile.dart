class ABAProfile {
  final String appId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String fullName;
  final String sex;
  final String dobShort;
  final String nationality;
  final String phone;
  final String email;
  final String lang;
  final String id;
  final String appVersion;
  final String osVersion;
  final String address;
  final String city;
  final String country;
  final String dobFull;
  final String nidNumber;
  final String nidType;
  final String nidExpiryDate;
  final String nidDoc;
  final String occupation;
  final String addrCode;
  final String secretKey;

  ABAProfile({
    required this.appId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.sex,
    required this.dobShort,
    required this.nationality,
    required this.phone,
    required this.email,
    required this.lang,
    required this.id,
    required this.appVersion,
    required this.osVersion,
    required this.address,
    required this.city,
    required this.country,
    required this.dobFull,
    required this.nidNumber,
    required this.nidType,
    required this.nidExpiryDate,
    required this.nidDoc,
    required this.occupation,
    required this.addrCode,
    required this.secretKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'fullName': fullName,
      'sex': sex,
      'dobShort': dobShort,
      'nationality': nationality,
      'phone': phone,
      'email': email,
      'lang': lang,
      'id': id,
      'appVersion': appVersion,
      'osVersion': osVersion,
      'address': address,
      'city': city,
      'country': country,
      'dobFull': dobFull,
      'nidNumber': nidNumber,
      'nidType': nidType,
      'nidExpiryDate': nidExpiryDate,
      'nidDoc': nidDoc,
      'occupation': occupation,
      'addrCode': addrCode,
      'secret_key': secretKey,
    };
  }
}
