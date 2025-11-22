import 'package:flutter/material.dart';
import 'trouser_screen.dart';
import 'shirt_screen.dart';
import 'glasses_screen.dart';
import 'hat_screen.dart';
import 'search_screen.dart';
import '../widgets/category_button.dart';
import 'cart_screen.dart';
import '../widgets/chatbot_overlay.dart';
import 'my_order_screen.dart';   // <-- THÊM IMPORT NÀY
import 'product_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Trousers';
  int _currentIndex = 0;

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });

    // Navigate to corresponding screen
    Widget screen;
    switch (category) {
      case 'Clothes':
        screen = const ShirtScreen();
        break;
      case 'Glasses':
        screen = const GlassesScreen();
        break;
      case 'Hats':
        screen = const HatScreen();
        break;
      case 'Trousers':
      default:
        // SỬA LẠI ĐỂ ĐIỀU HƯỚNG ĐÚNG
        screen = const TrouserScreen();
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ChatbotOverlay(
      child: Scaffold(
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
        body: SingleChildScrollView(
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
                      label: 'Trousers',
                      isSelected: selectedCategory == 'Trousers',
                      onTap: () => _onCategorySelected('Trousers'),
                    ),
                    CategoryButton(
                      icon: Icons.shopping_bag,
                      label: 'Clothes',
                      isSelected: selectedCategory == 'Clothes',
                      onTap: () => _onCategorySelected('Clothes'),
                    ),
                    CategoryButton(
                      icon: Icons.remove_red_eye,
                      label: 'Kính',
                      isSelected: selectedCategory == 'Glasses',
                      onTap: () => _onCategorySelected('Glasses'),
                    ),
                    CategoryButton(
                      icon: Icons.emoji_emotions,
                      label: 'Hats',
                      isSelected: selectedCategory == 'Hats',
                      onTap: () => _onCategorySelected('Hats'),
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
                          'Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Winter 2024',
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
                      'Outstanding products',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
              ),

              const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildProductCard(
                    1,
                    'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80',
                    'Jeans',
                    '450,000 ₫',
                  ),
                  _buildProductCard(
                    2,
                    'https://images.unsplash.com/photo-1539533018447-63fcce2678e3',
                    'Shirt',
                    '350,000 ₫',
                  ),
                  _buildProductCard(
                    3,
                    'https://images.unsplash.com/photo-1572635196237-14b3f281503f',
                    'Sunglasses',
                    '280,000 ₫',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
              switch (index) {
                case 0:
                  break;
                case 1:
                  break;
                case 2:
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  break;
              }
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'AR Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    )
    );
  }

  Widget _buildProductCard(int id, String imageUrl, String name, String price) {
    // 2. Bọc Container bằng GestureDetector
    return GestureDetector(
        onTap: () {
          // 3. Thực hiện chuyển trang và truyền ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: id),
            ),
          );
        },
        child: Container(
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
        ),
    );
  }
}
