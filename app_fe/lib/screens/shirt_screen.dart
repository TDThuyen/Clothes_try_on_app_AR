import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product/search_product_response.dart';
import '../models/product/filter_options.dart';
import '../widgets/product_card.dart';

class ShirtScreen extends StatefulWidget {
  const ShirtScreen({Key? key}) : super(key: key);

  @override
  State<ShirtScreen> createState() => _ShirtScreenState();
}

class _ShirtScreenState extends State<ShirtScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  GenderFilter _selectedGender = GenderFilter.all;
  SortOption _selectedSort = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    setState(() {
      _productsFuture = _apiService.searchProducts(
        categoryName: 'Áo',
        gender: _selectedGender == GenderFilter.male
            ? 'MALE'
            : _selectedGender == GenderFilter.female
            ? 'FEMALE'
            : null,
        sortBy: _selectedSort == SortOption.price_asc
            ? 'price_asc'
            : _selectedSort == SortOption.price_desc
            ? 'price_desc'
            : 'newest',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clothes'), centerTitle: true, elevation: 1),
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
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<GenderFilter>(
              segments: const [
                ButtonSegment(value: GenderFilter.all, label: Text('All')),
                ButtonSegment(value: GenderFilter.male, label: Text('Male')),
                ButtonSegment(value: GenderFilter.female, label: Text('Female')),
              ],
              selected: {_selectedGender},
              onSelectionChanged: (selection) {
                _selectedGender = selection.first;
                _fetchProducts();
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: Colors.black,
                selectedForegroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSortDropdown(),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<SortOption>(
      initialValue: _selectedSort,
      onSelected: (item) {
        _selectedSort = item;
        _fetchProducts();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: SortOption.newest, child: Text('Newest')),
        PopupMenuItem(
          value: SortOption.price_asc,
          child: Text('Ascending price'),
        ),
        PopupMenuItem(
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cannot load products.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không tìm thấy sản phẩm.'));
        }

        final products = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 160 / 250,
          ),
          itemCount: products.length,
          itemBuilder: (_, index) => ProductCard(product: products[index]),
        );
      },
    );
  }
}
