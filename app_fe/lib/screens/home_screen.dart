import 'package:flutter/material.dart';
import 'trouser_screen.dart';
import 'shirt_screen.dart';
import 'glasses_screen.dart';
import 'hat_screen.dart';
import 'search_screen.dart';
import '../widgets/category_button.dart';
<<<<<<< HEAD
import 'orders/my_orders_screen.dart';
=======
import 'cart_screen.dart';
>>>>>>> 4069e14fb82fa5f9c73de30ef0430dd4d86ec7c4

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Quần';
  int _currentIndex = 0;

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });

    Widget screen;
    switch (category) {
      case 'Áo':
        screen = const ShirtScreen();
        break;
      case 'Kính':
        screen = const GlassesScreen();
        break;
      case 'Mũ':
        screen = const HatScreen();
        break;
      case 'Quần':
      default:
        // SỬA LẠI ĐỂ ĐIỀU HƯỚNG ĐÚNG
        screen = const TrouserScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Category Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CategoryButton(
                  icon: Icons.checkroom,
                  label: 'Quần',
                  isSelected: selectedCategory == 'Quần',
                  onTap: () => _onCategorySelected('Quần'),
                ),
                CategoryButton(
                  icon: Icons.shopping_bag,
                  label: 'Áo',
                  isSelected: selectedCategory == 'Áo',
                  onTap: () => _onCategorySelected('Áo'),
                ),
                CategoryButton(
                  icon: Icons.remove_red_eye,
                  label: 'Kính',
                  isSelected: selectedCategory == 'Kính',
                  onTap: () => _onCategorySelected('Kính'),
                ),
                CategoryButton(
                  icon: Icons.emoji_emotions,
                  label: 'Mũ',
                  isSelected: selectedCategory == 'Mũ',
                  onTap: () => _onCategorySelected('Mũ'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1483985988355-763728e1935b',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bộ sưu tập',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mùa đông 2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Feature Products Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sản phẩm nổi bật',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Feature Products List
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildProductCard(
                  'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80',
                  'Quần Jeans',
                  '450,000 ₫',
                ),
                _buildProductCard(
                  'https://images.unsplash.com/photo-1539533018447-63fcce2678e3',
                  'Áo Sơ Mi',
                  '350,000 ₫',
                ),
                _buildProductCard(
                  'https://images.unsplash.com/photo-1572635196237-14b3f281503f',
                  'Kính Mát',
                  '280,000 ₫',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const Center(child: Text('Tìm kiếm'));
      case 2:
        return const Center(child: Text('AR Camera'));
      case 3:
        return MyOrdersScreen(); // My Orders
      case 4:
        return const Center(child: Text('Tài khoản'));
      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'AR Try-On',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Tab "Tìm kiếm"
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
              switch (index) {
                case 0:
                  // Home
                  break;
                case 1:
                  // Search
                  break;
                case 2:
                  // AR Camera
                  break;
                case 3:
                  // Cart
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                  break;
                case 4:
                  // Profile
                  break;
              }
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'AR Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }

  Widget _buildProductCard(String imageUrl, String name, String price) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
