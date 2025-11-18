import 'package:flutter/material.dart';
import 'trouser_screen.dart';
import 'shirt_screen.dart';
import 'glasses_screen.dart';
import 'hat_screen.dart';
import 'search_screen.dart';
import '../widgets/category_button.dart';
import 'orders/my_orders_screen.dart';  // GIỮ ĐÚNG NHU CẦU CỦA BẠN (ĐƠN HÀNG)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Quần';
  int _currentIndex = 0;

  void _onCategorySelected(String category) {
    setState(() => selectedCategory = category);

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
        screen = const TrouserScreen();
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Trang Home
  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // DANH MỤC
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

          // BANNER
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
            ),
          ),

          const SizedBox(height: 30),

          // FEATURED PRODUCTS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Sản phẩm nổi bật',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 250,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BODY THEO TAB
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const SearchScreen();
      case 2:
        return const Center(child: Text("AR Camera"));
      case 3:
        return const MyOrdersScreen(); // GIỮ ĐÚNG: TAB NÀY LÀ "ĐƠN HÀNG"
      case 4:
        return const Center(child: Text("Tài khoản"));
      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Try-On"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'AR Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }

  Widget _buildProductCard(String imageUrl, String name, String price) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(price, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}
