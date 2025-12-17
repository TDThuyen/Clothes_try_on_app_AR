import 'package:flutter/material.dart';
import '../apis/auth.dart';
import '../models/auth/user_model.dart';
import 'login_screen.dart'; // Import màn hình Login để quay về khi logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel?> _userFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getProfile();
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      // Xóa hết stack màn hình cũ và chuyển về Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _handleLogout,
            tooltip: "Đăng xuất",
          )
        ],
        title: const Text("Tài khoản", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Bỏ nút back mặc định
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Lỗi hoặc chưa đăng nhập
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Phiên đăng nhập hết hạn hoặc chưa đăng nhập"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleLogout, // Quay về màn hình login
                    child: const Text("Đăng nhập lại"),
                  )
                ],
              ),
            );
          }

          // 3. Hiển thị thông tin
          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 15),

                // Tên & Email
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 30),
                const Divider(),

                // Các mục thông tin (ListTile)
                _buildProfileItem(Icons.location_on, "Địa chỉ", user.address ?? "Chưa cập nhật"),
                _buildProfileItem(Icons.phone, "Số điện thoại", "Chưa cập nhật"),
                _buildProfileItem(Icons.history, "Lịch sử đơn hàng", "Xem ngay", onTap: () {
                  // Navigate to Order History
                }),
                _buildProfileItem(Icons.settings, "Cài đặt", "Chỉnh sửa", onTap: () {}),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

