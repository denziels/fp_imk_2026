import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final user = auth.activeUser.value;
        if (user == null) {
          return const Center(child: Text('Tidak ada profil yang aktif.'));
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    final base64Image = base64Encode(bytes);
                    await auth.updateProfilePicture(user.id, base64Image);
                  }
                },
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF9885D6),
                        backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                            ? MemoryImage(base64Decode(user.profilePicture!))
                            : null,
                        child: user.profilePicture == null || user.profilePicture!.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nama Anak', user.name),
                      const Divider(),
                      _buildInfoRow('Usia', '${user.age} Tahun'),
                      const Divider(),
                      _buildInfoRow('Nama Orang Tua', user.parentName),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () async {
                  await auth.logout();
                  Get.offAll(() => const LoginScreen());
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar (Ganti Profil)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Hapus Profil?",
                    middleText: "Apakah Anda yakin ingin menghapus profil ini? Semua data progres akan hilang.",
                    textCancel: "Batal",
                    textConfirm: "Ya, Hapus",
                    confirmTextColor: Colors.white,
                    onConfirm: () async {
                      Get.back(); // close dialog
                      await auth.deleteChild(user.id);
                      Get.offAll(() => const LoginScreen());
                    },
                  );
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Hapus Profil'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
