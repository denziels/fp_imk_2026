import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  // Masukkan Client ID yang baru kamu copy di sini
  final String _clientId = '822062758717-fgtgmt6rh4pf8aei9trllta5h8bufq7p.apps.googleusercontent.com';

  
  // URL to your XAMPP backend
  final String apiUrl = 'http://localhost/readlexia/'; 
  
  final users = <UserProfile>[].obs;
  final activeUser = Rxn<UserProfile>();
  
  // Track the logged in parent
  final RxnInt parentId = RxnInt();
  final RxString parentName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize Google Sign In for v7.x API
    _googleSignIn.initialize(clientId: _clientId);
    
    // Listen to authentication events (this is how the Web button returns data)
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _handleGoogleUser(event.user);
      }
    });

    // Try to restore session from local storage if available
    _restoreLocalSession();
  }

  Future<void> _restoreLocalSession() async {
    final activeId = _storage.getActiveUserId();
    if (activeId != null) {
      // For a real app we might fetch from API again, but local is fine for cache
      final loadedUsers = await _storage.getUsers();
      users.assignAll(loadedUsers);
      activeUser.value = users.firstWhereOrNull((u) => u.id == activeId);
    }
  }

  // Helper for both Web and Mobile sign in results
  Future<void> _handleGoogleUser(GoogleSignInAccount googleUser) async {
    try {
      // Send to backend
      final response = await http.post(
        Uri.parse('${apiUrl}login.php'),
        body: jsonEncode({
          'google_id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName ?? 'Parent',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        parentId.value = int.parse(data['parent_id'].toString());
        parentName.value = data['name'];
        await _fetchChildren();
      } else {
        Get.snackbar("Error", "Gagal login: ${data['message'] ?? 'Kesalahan tidak diketahui'}");
      }
    } catch (e) {
      print("Backend Login Error: $e");
      Get.snackbar("Error", "Gagal menyimpan data ke server.");
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate(scopeHint: ['email']);
      if (googleUser == null) return false;
      await _handleGoogleUser(googleUser);
      return true;
    } catch (e) {
      print("Google Sign In Error: $e");
    }
    return false;
  }

  Future<void> _fetchChildren() async {
    if (parentId.value == null) return;
    
    try {
      final response = await http.get(Uri.parse('${apiUrl}children.php?parent_id=${parentId.value}'));
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        List<UserProfile> loaded = [];
        for (var child in data['data']) {
          loaded.add(UserProfile(
            id: child['id'].toString(),
            name: child['name'],
            age: int.parse(child['age'].toString()),
            parentName: parentName.value,
            profilePicture: child['profile_picture'],
          ));
        }
        users.assignAll(loaded);
      }
    } catch (e) {
      print("Fetch Children Error: $e");
    }
  }

  Future<void> register(String name, int age) async {
    if (parentId.value == null) return;

    try {
      final response = await http.post(
        Uri.parse('${apiUrl}children.php'),
        body: jsonEncode({
          'parent_id': parentId.value,
          'name': name,
          'age': age,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final newUser = UserProfile(
          id: data['child_id'].toString(),
          name: name,
          age: age,
          parentName: parentName.value,
        );
        users.add(newUser);
        await login(newUser.id);
      }
    } catch (e) {
      print("Register Error: $e");
    }
  }

  Future<void> updateProfilePicture(String childId, String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}update_profile.php'),
        body: jsonEncode({
          'child_id': childId,
          'profile_picture': base64Image,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Update local state
        int idx = users.indexWhere((u) => u.id == childId);
        if (idx != -1) {
          users[idx].profilePicture = base64Image;
          users.refresh();
          if (activeUser.value?.id == childId) {
            activeUser.value?.profilePicture = base64Image;
            activeUser.refresh();
          }
        }
        Get.snackbar("Sukses", "Foto profil berhasil diperbarui!");
      } else {
        Get.snackbar("Error", data['message'] ?? "Gagal memperbarui foto profil");
      }
    } catch (e) {
      print("Update Profile Error: $e");
      Get.snackbar("Error", "Gagal menghubungi server");
    }
  }

  Future<void> login(String id) async {
    await _storage.setActiveUserId(id);
    activeUser.value = users.firstWhereOrNull((u) => u.id == id);
  }

  Future<void> deleteChild(String childId) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}children.php'),
        body: jsonEncode({
          'action': 'delete',
          'child_id': childId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        users.removeWhere((u) => u.id == childId);
        users.refresh();
        if (activeUser.value?.id == childId) {
          await logoutChild();
        }
        Get.snackbar("Sukses", "Profil anak berhasil dihapus");
      } else {
        Get.snackbar("Error", data['message'] ?? "Gagal menghapus profil");
      }
    } catch (e) {
      print("Delete Child Error: $e");
      Get.snackbar("Error", "Gagal menghubungi server");
    }
  }

  Future<void> logoutChild() async {
    await _storage.setActiveUserId('');
    activeUser.value = null;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.setActiveUserId('');
    activeUser.value = null;
    parentId.value = null;
    parentName.value = '';
    users.clear();
  }
}
