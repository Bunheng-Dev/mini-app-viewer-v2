import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:mini_app_viewer/models/aba_profile.dart';
import 'package:mini_app_viewer/models/aba_account.dart';
import 'package:mini_app_viewer/widgets/custom_text_field.dart';

class EditABAScreen extends StatefulWidget {
  const EditABAScreen({super.key});

  @override
  State<EditABAScreen> createState() => _EditABAScreenState();
}

class _EditABAScreenState extends State<EditABAScreen> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _controllers = [
      TextEditingController(text: appState.abaProfile.appId),
      TextEditingController(text: appState.abaProfile.firstName),
      TextEditingController(text: appState.abaProfile.middleName),
      TextEditingController(text: appState.abaProfile.lastName),
      TextEditingController(text: appState.abaProfile.phone),
      TextEditingController(text: appState.abaProfile.email),
      TextEditingController(text: appState.abaProfile.sex),
      TextEditingController(text: appState.abaProfile.dobShort),
      TextEditingController(text: appState.abaProfile.nationality),
      TextEditingController(text: appState.abaProfile.lang),
      TextEditingController(text: appState.abaAccount.accountName),
      TextEditingController(text: appState.abaAccount.accountNumber),
      TextEditingController(text: appState.abaAccount.currency),
    ];
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ABA'.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: 'Roboto',
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey.shade200, height: 0.5),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Changes are saved automatically and persist across app restarts',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _controllers[0],
                label: 'App ID',
                hint: '',
                icon: Icons.fingerprint,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[1],
                label: 'First Name',
                hint: '',
                icon: Icons.person_outline,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[2],
                label: 'Middle Name',
                hint: '',
                icon: Icons.person,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[3],
                label: 'Last Name',
                hint: '',
                icon: Icons.person,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[4],
                label: 'Phone',
                hint: '',
                icon: Icons.phone,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[5],
                label: 'Email',
                hint: '',
                icon: Icons.email,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[6],
                label: 'Sex',
                hint: '',
                icon: Icons.wc,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[7],
                label: 'Date of Birth',
                hint: '',
                icon: Icons.cake,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[8],
                label: 'Nationality',
                hint: '',
                icon: Icons.flag,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[9],
                label: 'Language',
                hint: '',
                icon: Icons.language,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 32),

              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _controllers[10],
                label: 'Account Name',
                hint: '',
                icon: Icons.account_circle,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[11],
                label: 'Account Number',
                hint: '',
                icon: Icons.numbers,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controllers[12],
                label: 'Currency',
                hint: '',
                icon: Icons.attach_money,
                focusedBorderColor: const Color(0xFF005BAA),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final appState = Provider.of<AppState>(
                      context,
                      listen: false,
                    );

                    // Create updated profile and account objects
                    final updatedProfile = ABAProfile(
                      appId: _controllers[0].text,
                      firstName: _controllers[1].text,
                      middleName: _controllers[2].text,
                      lastName: _controllers[3].text,
                      fullName: appState.abaProfile.fullName,
                      sex: _controllers[6].text,
                      dobShort: _controllers[7].text,
                      nationality: _controllers[8].text,
                      phone: _controllers[4].text,
                      email: _controllers[5].text,
                      lang: _controllers[9].text,
                      id: appState.abaProfile.id,
                      appVersion: appState.abaProfile.appVersion,
                      osVersion: appState.abaProfile.osVersion,
                      address: appState.abaProfile.address,
                      city: appState.abaProfile.city,
                      country: appState.abaProfile.country,
                      dobFull: appState.abaProfile.dobFull,
                      nidNumber: appState.abaProfile.nidNumber,
                      nidType: appState.abaProfile.nidType,
                      nidExpiryDate: appState.abaProfile.nidExpiryDate,
                      nidDoc: appState.abaProfile.nidDoc,
                      occupation: appState.abaProfile.occupation,
                      addrCode: appState.abaProfile.addrCode,
                      secretKey: appState.abaProfile.secretKey,
                    );

                    final updatedAccount = ABAAccount(
                      accountName: _controllers[10].text,
                      accountNumber: _controllers[11].text,
                      currency: _controllers[12].text,
                    );

                    // Update app state
                    appState.updateABAProfile(updatedProfile);
                    appState.updateABAAccount(updatedAccount);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ABA profile updated successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Go back
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BAA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
