import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product/search_product_response.dart';
import '../widgets/product_card.dart';

enum GenderFilter { all, male, female }

// Sửa tên enum để rõ ràng hơn
enum SortOption { newest, price_asc, price_desc }

class TrouserScreen extends StatefulWidget {
  const TrouserScreen({Key? key}) : super(key: key);

  @override
  State<TrouserScreen> createState() => _TrouserScreenState();
}

class _TrouserScreenState extends State<TrouserScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  GenderFilter _selectedGender = GenderFilter.all;
  // Sửa lại biến state để khớp với enum mới
  SortOption _selectedSort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    setState(() {
      _productsFuture = _apiService.searchProducts(
        // Gửi đúng tên tham số mà backend cần: 'categoryName'
        categoryName: 'Quần',
        gender: _selectedGender == GenderFilter.male
            ? 'MALE'
            : _selectedGender == GenderFilter.female
            ? 'FEMALE'
            : null,
        // Gửi đúng tên tham số 'sortBy' và các giá trị tương ứng
        sortBy: _selectedSort == SortOption.price_asc
            ? 'price_asc'
            : _selectedSort == SortOption.price_desc
            ? 'price_desc'
            : 'newest', // Mặc định là 'newest'
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouser'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      // SỬA LẠI WIDGET ROW
      child: Row(
        children: [
          // Bọc SegmentedButton trong Expanded để nó chiếm không gian còn lại
          Expanded(
            child: SegmentedButton<GenderFilter>(
              segments: const [
                ButtonSegment(value: GenderFilter.all, label: Text('All')),
                ButtonSegment(value: GenderFilter.male, label: Text('Male')),
                ButtonSegment(value: GenderFilter.female, label: Text('Female')),
              ],
              selected: {_selectedGender},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedGender = newSelection.first;
                  _fetchProducts();
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: Colors.black,
                selectedForegroundColor: Colors.white,
                // Giảm padding để tiết kiệm không gian
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          // Thêm một khoảng trống nhỏ
          const SizedBox(width: 12),
          // Sort Dropdown giữ nguyên
          _buildSortDropdown(),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    // Sửa lại PopupMenuButton để dùng SortOption
    return PopupMenuButton<SortOption>(
      initialValue: _selectedSort,
      onSelected: (SortOption item) {
        setState(() {
          _selectedSort = item;
          _fetchProducts();
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
        const PopupMenuItem<SortOption>(
          value: SortOption.newest,
          child: Text('Newest'),
        ),
        const PopupMenuItem<SortOption>(
          value: SortOption.price_asc,
          child: Text('Ascending price'),
        ),
        const PopupMenuItem<SortOption>(
          value: SortOption.price_desc,
          child: Text('Descending price'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.sort, size: 20),
            SizedBox(width: 8),
            Text('Sort'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // Hiển thị lỗi một cách thân thiện hơn
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Cannot load products. Please try again.\n\nDetail: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Products not found.'));
        }

        final products = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 160 / 250, // width / (imageHeight + textHeight)
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
