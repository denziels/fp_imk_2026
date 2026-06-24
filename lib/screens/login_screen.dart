import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/google_button.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _auth = Get.find<AuthController>();

  final _childNameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isCreating = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Obx(() {
              if (_auth.parentId.value == null) {
                return _buildGoogleSignIn();
              }

              final users = _auth.users;
              if (users.isEmpty || _isCreating) {
                return _buildCreateForm();
              }

              return _buildUserList(users);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignIn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Login Orang Tua',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Text(
          'Masuk menggunakan akun Google Anda untuk menyimpan progres dan statistik anak di server.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Use the official Google Sign-In button for Web
        SizedBox(
          height: 48,
          child: buildGoogleSignInButton(),
        ),
        const SizedBox(height: 16),
        // Fallback or Mobile button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.grey),
          ),
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            final success = await _auth.signInWithGoogle();
            setState(() => _isLoading = false);
            
            if (!success && mounted) {
              Get.snackbar("Error", "Gagal login dengan Google.");
            }
          },
          icon: _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
          label: const Text('Mobile Login (Fallback)'),
        ),
      ],
    );
  }

  Widget _buildUserList(List users) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Halo, ${_auth.parentName.value}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih Profil Anak',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...users.map((user) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFFC7E5C4),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await _auth.login(user.id);
                  Get.offAll(() => const MainMenuScreen());
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Usia: ${user.age} Tahun',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _isCreating = true;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Profil Anak'),
        ),
        const Divider(),
        TextButton.icon(
          onPressed: () {
            _auth.logout();
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildCreateForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Profil Anak Baru',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _childNameController,
          decoration: const InputDecoration(
            labelText: 'Nama Anak',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Usia',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFC7E5C4),
            foregroundColor: Colors.black87,
          ),
          onPressed: _isLoading ? null : () async {
            if (_childNameController.text.isNotEmpty &&
                _ageController.text.isNotEmpty) {
              setState(() => _isLoading = true);
              await _auth.register(
                _childNameController.text,
                int.tryParse(_ageController.text) ?? 5,
              );
              setState(() => _isLoading = false);
              Get.offAll(() => const MainMenuScreen());
            }
          },
          child: _isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
            : const Text('Simpan & Masuk'),
        ),
        if (_auth.users.isNotEmpty) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isCreating = false;
              });
            },
            child: const Text('Batal'),
          ),
        ]
      ],
    );
  }
}
