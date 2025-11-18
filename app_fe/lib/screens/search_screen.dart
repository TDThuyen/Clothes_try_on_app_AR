// lib/screens/search_screen.dart
import 'package:flutter/material.dart';

import 'found_result.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentSearches = [];

  final List<Map<String, String>> _popularProducts = [
    {
      'image':
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600',
      'name': 'Lihua Tunic White',
      'price': '\$ 53.00',
    },
    {
      'image':
      'https://images.unsplash.com/photo-1445205170230-053b83016050?w=600',
      'name': 'Skirt Dress',
      'price': '\$ 34.00',
    },
  ];

  // filter state
  RangeValues _priceRange = const RangeValues(10,1000000);
  final List<String> _categories = ['Tất cả', 'Quần', 'Áo', 'Kính', 'Mũ'];
  String _selectedCategory = 'Tất cả';

  final List<String> _genders = ['Tất cả', 'Nam', 'Nữ'];
  String _selectedGender = 'Tất cả';

  // =============== Điều hướng sang trang kết quả =================

  void _goToResultScreen(String query) {
    if (query.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoundResultScreen(
          title: query,
          query: query,
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
          categoryName:
          _selectedCategory == 'Tất cả' ? null : _selectedCategory,
          gender:
          _selectedGender == 'Tất cả' ? null : _selectedGender.toLowerCase(),
        ),
      ),
    );
  }

  // =============== Bottom sheet filter =================

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000000,
                      divisions: 20,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}',
                        '\$${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setModalState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${_priceRange.start.round()}'),
                        Text('\$${_priceRange.end.round()}'),
                      ],
                    ),
                    const SizedBox(height: 24),

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
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: selected ? Colors.pink : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: selected,
                          selectedColor: Colors.pink.shade100,
                          backgroundColor: const Color(0xFFF5F5F7),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color:
                              selected ? Colors.pink : Colors.transparent,
                            ),
                          ),
                          onSelected: (bool isSelected) {
                            setModalState(() {
                              _selectedCategory =
                              isSelected ? cat : 'Tất cả';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

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
                      children: _genders.map((g) {
                        final selected = _selectedGender == g;
                        return ChoiceChip(
                          label: Text(
                            g,
                            style: TextStyle(
                              color: selected ? Colors.pink : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: selected,
                          selectedColor: Colors.pink.shade100,
                          backgroundColor: const Color(0xFFF5F5F7),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color:
                              selected ? Colors.pink : Colors.transparent,
                            ),
                          ),
                          onSelected: (bool isSelected) {
                            setModalState(() {
                              _selectedGender = isSelected ? g : 'Tất cả';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Spacer(),

                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _priceRange = const RangeValues(10, 1000000);
                              _selectedCategory = 'Tất cả';
                              _selectedGender = 'Tất cả';
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
                              Navigator.pop(context);
                              final q = _searchController.text.trim();
                              if (q.isNotEmpty) {
                                _goToResultScreen(q);
                              }
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

  void _onSearchSubmitted(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    setState(() {
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
      }
    });

    _goToResultScreen(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _onSearchSubmitted,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search',
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openFilterSheet,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent searches
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _recentSearches.isEmpty
                    ? const Text(
                  'No recent searches',
                  style: TextStyle(color: Colors.grey),
                )
                    : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((text) {
                    return Chip(
                      label: Text(text),
                      deleteIcon:
                      const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _recentSearches.remove(text);
                        });
                      },
                      backgroundColor:
                      const Color(0xFFF5F5F7),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Popular this week
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Popular this week',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Show Tất cả',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _popularProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final p = _popularProducts[index];
                    return _buildProductCard(
                      p['image']!,
                      p['name']!,
                      p['price']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(String imageUrl, String name, String price) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF5F5F7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
