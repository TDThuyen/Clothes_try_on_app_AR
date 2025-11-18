// lib/screens/found_result.dart
import 'package:flutter/material.dart';

import '../apis/product.dart';
import '../models/product/search_product_response.dart';

class FoundResultScreen extends StatefulWidget {
  final String title;
  final String query;
  final double minPrice;
  final double maxPrice;
  final String? categoryName;
  final String? gender; // male / female (lowercase)

  const FoundResultScreen({
    super.key,
    required this.title,
    required this.query,
    required this.minPrice,
    required this.maxPrice,
    this.categoryName,
    this.gender,
  });

  @override
  State<FoundResultScreen> createState() => _FoundResultScreenState();
}

class _FoundResultScreenState extends State<FoundResultScreen> {
  bool _isLoading = false;
  String? _error;
  List<Product> _items = [];
  int _total = 0;

  late double _minPrice;
  late double _maxPrice;
  String? _categoryName;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _categoryName = widget.categoryName;
    _gender = widget.gender;
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ProductService().searchProducts(
        q: widget.query,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        categoryName: _categoryName == 'All' ? null : _categoryName,
        gender: _gender == 'all' ? null : _gender,
        page: 1,
        limit: 20,
        sortBy: 'newest',
      );

      final items = data.items;
      final total = data.total;

      setState(() {
        _items = items;
        _total = total;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.message;
        _items = [];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Unexpected error: $e';
        _items = [];
      });
    }
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // copy state hiện tại sang local
        double localMin = _minPrice;
        double localMax = _maxPrice;
        String? localCat = _categoryName;
        String? localGender = _gender;
        const double _sliderMin = 10;
        const double _sliderMax = 10_000_000;

        localMin = localMin.clamp(_sliderMin, _sliderMax);
        localMax = localMax.clamp(_sliderMin, _sliderMax);
        if (localMin > localMax) {
          final tmp = localMin;
          localMin = localMax;
          localMax = tmp;
        }

        final genders = ['All', 'Male', 'Female'];
        final categories = ['All', 'Quần', 'Áo', 'Kính', 'Mũ'];
        final Map<String, String> _categoryDisplayText = {
          'All': 'All',
          'Quần': 'Trousers',
          'Áo': 'Clothes',
          'Kính': 'Glasses',
          'Mũ': 'Hats',
        };

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom:
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.tune_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // PRICE
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RangeSlider(
                      values: RangeValues(localMin, localMax),
                      min: _sliderMin,
                      max: _sliderMax,
                      labels: RangeLabels(
                        '\$${localMin.round()}',
                        '\$${localMax.round()}',
                      ),
                      onChanged: (values) {
                        setModalState(() {
                          localMin = values.start;
                          localMax = values.end;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${localMin.round()}'),
                        Text('\$${localMax.round()}'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CATEGORY
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((c) {
                        final isAll = c == 'All';
                        final selected = isAll
                            ? (localCat == null || localCat!.isEmpty)
                            : localCat == c;
                        return ChoiceChip(
                          label: Text(
                            _categoryDisplayText[c] ?? c,
                            style: TextStyle(
                              color:
                              selected ? Colors.pink : Colors.black,
                            ),
                          ),
                          selected: selected,
                          selectedColor: Colors.pink.shade100,
                          onSelected: (_) {
                            setModalState(() {
                              localCat = isAll ? null : c;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // GENDER
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genders.map((g) {
                        final isAll = g == 'All';
                        final selected = isAll
                            ? (localGender == null ||
                            localGender!.isEmpty)
                            : localGender == g;
                        return ChoiceChip(
                          label: Text(
                            isAll
                                ? 'All'
                                : (g[0].toUpperCase() +
                                g.substring(1)),
                            style: TextStyle(
                              color:
                              selected ? Colors.pink : Colors.black,
                            ),
                          ),
                          selected: selected,
                          selectedColor: Colors.pink.shade100,
                          onSelected: (_) {
                            setModalState(() {
                              localGender = isAll ? null : g;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // BUTTONS
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              localMin = 10;
                              localMax = 80;
                              localCat = null;
                              localGender = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 140,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _minPrice = localMin;
                                _maxPrice = localMax;
                                _categoryName = localCat;
                                _gender = localGender;
                              });
                              Navigator.pop(context);
                              _fetchProducts();
                            },
                            child: const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final title = widget.title;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _openFilter,
            icon: const Icon(Icons.tune, color: Colors.black, size: 18),
            label: const Text(
              'Filter',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Found',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_total Results',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _items.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 250,
                ),
                itemBuilder: (context, index) {
                  final p = _items[index];
                  final imageUrl = p.imageUrl ?? '';
                  final name = p.name.toString();
                  final priceValue = p.price;
                  final priceText =
                      '\ ${priceValue.toString()} đ';
                  final rating = p.ratingAvg.toString();

                  return _ProductCard(
                    imageUrl: imageUrl,
                    name: name,
                    priceText: priceText,
                    ratingText: rating,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String priceText;
  final String ratingText;

  const _ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.priceText,
    required this.ratingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              priceText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  ratingText,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Text(
                  '(120)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
