import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ar_view.dart';

/// Model đại diện cho sản phẩm AR
class ArProduct {
  final int id;
  final String name;
  final String imageUrl;
  final String effectName;
  final int? categoryId;

  ArProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.effectName,
    this.categoryId,
  });

  factory ArProduct.fromJson(Map<String, dynamic> json) {
    String name = json['name'] ?? '';
    String effectName = name
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '');

    return ArProduct(
      id: json['id'] ?? 0,
      name: name,
      imageUrl: json['imageUrl'] ?? '',
      effectName: effectName,
      categoryId: json['categoryId'] ?? json['category_id'],
    );
  }

  /// Kiểm tra sản phẩm có phải là kính không
  bool get isGlasses {
    final lowerName = name.toLowerCase();
    return lowerName.contains('glass') ||
        lowerName.contains('kính') ||
        categoryId == 1 ||
        categoryId == 2;
  }

  /// Kiểm tra sản phẩm có phải là mũ không
  bool get isHat {
    final lowerName = name.toLowerCase();
    return lowerName.contains('hat') ||
        lowerName.contains('mũ') ||
        lowerName.contains('nón') ||
        categoryId == 7 ||
        categoryId == 8;
  }

  /// Kiểm tra sản phẩm có phải là áo không
  bool get isShirt {
    final lowerName = name.toLowerCase();
    return lowerName.contains('shirt') ||
        lowerName.contains('áo') ||
        categoryId == 3 ||
        categoryId == 4;
  }

  /// Kiểm tra sản phẩm có phải là quần không
  bool get isTrouser {
    final lowerName = name.toLowerCase();
    return lowerName.contains('trouser') ||
        lowerName.contains('quần') ||
        lowerName.contains('pant') ||
        categoryId == 5 ||
        categoryId == 6;
  }
}

/// Enum định nghĩa nhóm sản phẩm
enum ProductGroup { faceAccessories, clothing }

class ArSelectionScreen extends StatefulWidget {
  const ArSelectionScreen({super.key});

  @override
  State<ArSelectionScreen> createState() => _ArSelectionScreenState();
}

class _ArSelectionScreenState extends State<ArSelectionScreen>
    with SingleTickerProviderStateMixin {
  // Trạng thái chọn category
  bool _isGlassesSelected = false;
  bool _isHatSelected = false;
  bool _isShirtSelected = false;
  bool _isTrouserSelected = false;

  // Sản phẩm đã chọn trong mỗi category
  ArProduct? _selectedGlasses;
  ArProduct? _selectedHat;
  ArProduct? _selectedShirt;
  ArProduct? _selectedTrouser;

  // Danh sách sản phẩm từ API (đã filter)
  List<ArProduct> _glassesList = [];
  List<ArProduct> _hatList = [];
  List<ArProduct> _shirtList = [];
  List<ArProduct> _trouserList = [];

  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _loadProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load sản phẩm từ API theo category
  Future<void> _loadProducts() async {
    try {
      final apiService = ApiService();

      // Load song song tất cả categories
      final results = await Future.wait([
        apiService.getProductsByCategoryId(1), // Kính Nam
        apiService.getProductsByCategoryId(2), // Kính Nữ
        apiService.getProductsByCategoryId(7), // Mũ Nam
        apiService.getProductsByCategoryId(8), // Mũ Nữ
        apiService.getProductsByCategoryId(3), // Áo Nam
        apiService.getProductsByCategoryId(4), // Áo Nữ
        apiService.getProductsByCategoryId(5), // Quần Nam
        apiService.getProductsByCategoryId(6), // Quần Nữ
      ]);

      // Convert và filter theo category
      final allGlasses = [
        ...results[0].map((e) => ArProduct.fromJson(e)),
        ...results[1].map((e) => ArProduct.fromJson(e)),
      ];

      final allHats = [
        ...results[2].map((e) => ArProduct.fromJson(e)),
        ...results[3].map((e) => ArProduct.fromJson(e)),
      ];

      final allShirts = [
        ...results[4].map((e) => ArProduct.fromJson(e)),
        ...results[5].map((e) => ArProduct.fromJson(e)),
      ];

      final allTrousers = [
        ...results[6].map((e) => ArProduct.fromJson(e)),
        ...results[7].map((e) => ArProduct.fromJson(e)),
      ];

      setState(() {
        // Filter để đảm bảo chỉ đúng category
        _glassesList = allGlasses.where((p) => p.isGlasses).toList();
        _hatList = allHats.where((p) => p.isHat).toList();
        _shirtList = allShirts.where((p) => p.isShirt).toList();
        _trouserList = allTrousers.where((p) => p.isTrouser).toList();

        // Nếu filter quá strict, fallback về list gốc
        if (_glassesList.isEmpty && allGlasses.isNotEmpty) {
          _glassesList = allGlasses;
        }
        if (_hatList.isEmpty && allHats.isNotEmpty) {
          _hatList = allHats;
        }
        if (_shirtList.isEmpty && allShirts.isNotEmpty) {
          _shirtList = allShirts;
        }
        if (_trouserList.isEmpty && allTrousers.isNotEmpty) {
          _trouserList = allTrousers;
        }

        _isLoading = false;

        debugPrint('=== LOADED PRODUCTS ===');
        debugPrint('Glasses: ${_glassesList.length} items');
        debugPrint('Hats: ${_hatList.length} items');
        debugPrint('Shirts: ${_shirtList.length} items');
        debugPrint('Trousers: ${_trouserList.length} items');
      });
    } catch (e) {
      debugPrint('Lỗi load products: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Xác định nhóm hiện tại đang chọn
  ProductGroup? get _currentGroup {
    if (_isGlassesSelected || _isHatSelected) {
      return ProductGroup.faceAccessories;
    }
    if (_isShirtSelected || _isTrouserSelected) {
      return ProductGroup.clothing;
    }
    return null;
  }

  /// Kiểm tra xem category có thể chọn được không
  bool _canSelectCategory(String category) {
    if (_currentGroup == null) return true;

    switch (category) {
      case 'glasses':
      case 'hat':
        return _currentGroup == ProductGroup.faceAccessories;
      case 'shirt':
      case 'trouser':
        return _currentGroup == ProductGroup.clothing;
      default:
        return false;
    }
  }

  /// Toggle chọn category
  void _toggleCategory(String category) {
    if (!_canSelectCategory(category)) {
      _showGroupWarning();
      return;
    }

    setState(() {
      switch (category) {
        case 'glasses':
          _isGlassesSelected = !_isGlassesSelected;
          if (!_isGlassesSelected) _selectedGlasses = null;
          break;
        case 'hat':
          _isHatSelected = !_isHatSelected;
          if (!_isHatSelected) _selectedHat = null;
          break;
        case 'shirt':
          _isShirtSelected = !_isShirtSelected;
          if (!_isShirtSelected) _selectedShirt = null;
          break;
        case 'trouser':
          _isTrouserSelected = !_isTrouserSelected;
          if (!_isTrouserSelected) _selectedTrouser = null;
          break;
      }
    });
  }

  void _showGroupWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentGroup == ProductGroup.faceAccessories
              ? 'Bạn đang chọn Kính/Mũ. Không thể chọn Áo/Quần cùng lúc!'
              : 'Bạn đang chọn Áo/Quần. Không thể chọn Kính/Mũ cùng lúc!',
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Kiểm tra có thể bấm "Thử ngay" không
  bool get _canTryOn {
    return _selectedGlasses != null ||
        _selectedHat != null ||
        _selectedShirt != null ||
        _selectedTrouser != null;
  }

  /// Chuyển sang màn hình AR
  void _goToArView() {
    if (!_canTryOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn ít nhất 1 sản phẩm để thử!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    List<String> effectNames = [];

    if (_selectedGlasses != null) {
      effectNames.add(_selectedGlasses!.effectName);
      debugPrint("Selected glasses: ${_selectedGlasses!.effectName}");
    }
    if (_selectedHat != null) {
      effectNames.add(_selectedHat!.effectName);
      debugPrint("Selected hat: ${_selectedHat!.effectName}");
    }

    debugPrint("Navigating to AR with effects: $effectNames");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArView(effectNames: effectNames)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn sản phẩm thử',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildCategorySelector(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildProductLists()),
                  _buildTryOnButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryCircle(
            icon: Icons.visibility,
            label: 'Kính',
            count: _glassesList.length,
            isSelected: _isGlassesSelected,
            isDisabled: !_canSelectCategory('glasses'),
            onTap: () => _toggleCategory('glasses'),
            selectedProduct: _selectedGlasses,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
          _buildCategoryCircle(
            icon: Icons.face,
            label: 'Mũ',
            count: _hatList.length,
            isSelected: _isHatSelected,
            isDisabled: !_canSelectCategory('hat'),
            onTap: () => _toggleCategory('hat'),
            selectedProduct: _selectedHat,
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
          ),
          _buildCategoryCircle(
            icon: Icons.checkroom,
            label: 'Áo',
            count: _shirtList.length,
            isSelected: _isShirtSelected,
            isDisabled: !_canSelectCategory('shirt'),
            onTap: () => _toggleCategory('shirt'),
            selectedProduct: _selectedShirt,
            gradient: const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
            ),
          ),
          _buildCategoryCircle(
            icon: Icons.accessibility_new,
            label: 'Quần',
            count: _trouserList.length,
            isSelected: _isTrouserSelected,
            isDisabled: !_canSelectCategory('trouser'),
            onTap: () => _toggleCategory('trouser'),
            selectedProduct: _selectedTrouser,
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCircle({
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback onTap,
    required Gradient gradient,
    ArProduct? selectedProduct,
  }) {
    return GestureDetector(
      onTap: isDisabled ? () => _showGroupWarning() : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? gradient : null,
                color: isDisabled
                    ? Colors.grey.withOpacity(0.3)
                    : (isSelected ? null : Colors.white.withOpacity(0.1)),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : (isDisabled
                            ? Colors.grey
                            : Colors.white.withOpacity(0.3)),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: isDisabled ? Colors.grey : Colors.white,
                    size: 30,
                  ),
                  if (isSelected)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  // Badge số lượng
                  if (count > 0 && !isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A1A2E),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.grey : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (selectedProduct != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedProduct.name.length > 8
                      ? '${selectedProduct.name.substring(0, 8)}...'
                      : selectedProduct.name,
                  style: const TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLists() {
    List<Widget> sections = [];

    // CHỈ hiển thị section của category đã chọn
    if (_isGlassesSelected) {
      sections.add(_buildProductSection('Chọn Kính', _glassesList, 'glasses'));
    }
    if (_isHatSelected) {
      sections.add(_buildProductSection('Chọn Mũ', _hatList, 'hat'));
    }
    if (_isShirtSelected) {
      sections.add(_buildProductSection('Chọn Áo', _shirtList, 'shirt'));
    }
    if (_isTrouserSelected) {
      sections.add(_buildProductSection('Chọn Quần', _trouserList, 'trouser'));
    }

    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn loại sản phẩm bạn muốn thử',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(Kính + Mũ) hoặc (Áo + Quần)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: sections,
    );
  }

  Widget _buildProductSection(
    String title,
    List<ArProduct> products,
    String category,
  ) {
    ArProduct? selectedProduct;
    switch (category) {
      case 'glasses':
        selectedProduct = _selectedGlasses;
        break;
      case 'hat':
        selectedProduct = _selectedHat;
        break;
      case 'shirt':
        selectedProduct = _selectedShirt;
        break;
      case 'trouser':
        selectedProduct = _selectedTrouser;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${products.length} sản phẩm',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: products.isEmpty
              ? Center(
                  child: Text(
                    'Không có sản phẩm',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isSelected = selectedProduct?.id == product.id;

                    return GestureDetector(
                      onTap: () => _selectProduct(category, product),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _selectProduct(String category, ArProduct product) {
    setState(() {
      switch (category) {
        case 'glasses':
          _selectedGlasses = _selectedGlasses?.id == product.id
              ? null
              : product;
          break;
        case 'hat':
          _selectedHat = _selectedHat?.id == product.id ? null : product;
          break;
        case 'shirt':
          _selectedShirt = _selectedShirt?.id == product.id ? null : product;
          break;
        case 'trouser':
          _selectedTrouser = _selectedTrouser?.id == product.id
              ? null
              : product;
          break;
      }
    });
  }

  Widget _buildTryOnButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _canTryOn ? _goToArView : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canTryOn ? Colors.green : Colors.grey[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: _canTryOn ? 8 : 0,
            shadowColor: Colors.green.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                color: _canTryOn ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                'THỬ NGAY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _canTryOn ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
