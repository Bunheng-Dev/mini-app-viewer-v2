import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_app_viewer/app_state.dart';
import 'package:mini_app_viewer/models/telegram_user.dart';
import 'package:mini_app_viewer/widgets/custom_text_field.dart';

class EditTelegramScreen extends StatefulWidget {
  const EditTelegramScreen({super.key});

  @override
  State<EditTelegramScreen> createState() => _EditTelegramScreenState();
}

class _EditTelegramScreenState extends State<EditTelegramScreen> {
  late TextEditingController _idController;
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _photoUrlController;
  late TextEditingController _languageCodeController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _idController = TextEditingController(
      text: appState.telegramUser.id.toString(),
    );
    _usernameController = TextEditingController(
      text: appState.telegramUser.username,
    );
    _firstNameController = TextEditingController(
      text: appState.telegramUser.firstName,
    );
    _lastNameController = TextEditingController(
      text: appState.telegramUser.lastName,
    );
    _photoUrlController = TextEditingController(
      text: appState.telegramUser.photoUrl,
    );
    _languageCodeController = TextEditingController(
      text: appState.telegramUser.languageCode,
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _photoUrlController.dispose();
    _languageCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TELEGRAM'.toUpperCase(),
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

              CustomTextField(
                controller: _idController,
                label: 'User ID',
                hint: 'e.g., 123456789',
                icon: Icons.fingerprint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'e.g., johnwick',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'e.g., John',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'e.g., Wick',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _photoUrlController,
                label: 'Photo URL',
                hint: 'https://example.com/photo.jpg',
                icon: Icons.image,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _languageCodeController,
                label: 'Language Code',
                hint: 'e.g., en',
                icon: Icons.language,
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

                    // Create updated user object
                    final updatedUser = TelegramUser(
                      id:
                          int.tryParse(_idController.text) ??
                          appState.telegramUser.id,
                      username: _usernameController.text,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      photoUrl: _photoUrlController.text,
                      languageCode: _languageCodeController.text,
                    );

                    // Update app state
                    appState.updateTelegramUser(updatedUser);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Telegram profile updated successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Go back
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0088CC),
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
