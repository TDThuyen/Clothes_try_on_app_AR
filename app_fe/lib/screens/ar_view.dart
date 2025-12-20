import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banuba_sdk/banuba_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ArView extends StatefulWidget {
  /// Danh sách tên effect cần load (glassmen2, hatmen3, ...)
  final List<String>? effectNames;

  /// Folder chứa effect (men_glasses, men_hat, women_glasses, women_hat)
  /// Nếu null, sẽ tự động detect từ tên effect
  final String? effectFolder;

  const ArView({super.key, this.effectNames, this.effectFolder});

  @override
  _ArViewState createState() => _ArViewState();
}

class _ArViewState extends State<ArView> with WidgetsBindingObserver {
  final BanubaSdkManager _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);

  bool _isInitialized = false;
  String _statusMessage = "Đang khởi tạo camera...";

  // Index của effect hiện tại
  int _currentEffectIndex = 0;
  List<String> _loadedEffectPaths = [];
  List<String> _loadedEffectNames = [];

  // Lấy token từ .env
  String get _token => dotenv.env['BANUBA_TOKEN'] ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSDK();
  }

  Future<void> _initSDK() async {
    if (!await _requestPermissions()) {
      setState(() {
        _statusMessage = "Không có quyền truy cập Camera/Microphone";
      });
      return;
    }

    try {
      await _banubaSdkManager.initialize([], _token, SeverityLevel.info);
      if (!mounted) return;

      await _banubaSdkManager.openCamera();
      await _banubaSdkManager.attachWidget(_epWidget.banubaId);
      await _banubaSdkManager.startPlayer();

      // Load effects
      await _loadEffects();

      setState(() {
        _isInitialized = true;
        _statusMessage = "Camera đã sẵn sàng!";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Lỗi: ${e.toString()}";
      });
      debugPrint("Lỗi khởi tạo Banuba SDK: $e");
    }
  }

  Future<void> _loadEffects() async {
    try {
      if (widget.effectNames == null || widget.effectNames!.isEmpty) {
        debugPrint("No effect names provided");
        return;
      }

      setState(() {
        _statusMessage = "Đang tải ${widget.effectNames!.length} effect...";
      });

      debugPrint("=== BẮT ĐẦU LOAD EFFECTS ===");
      debugPrint("Effect names: ${widget.effectNames}");

      _loadedEffectPaths.clear();
      _loadedEffectNames.clear();

      for (String effectName in widget.effectNames!) {
        final folder = _detectEffectFolder(effectName);
        debugPrint("Effect: $effectName -> Folder: $folder");

        final effectPath = await _copyEffectToDocuments(effectName, folder);
        if (effectPath != null) {
          _loadedEffectPaths.add(effectPath);
          _loadedEffectNames.add(effectName);
          debugPrint("✓ Loaded: $effectName");
        } else {
          debugPrint("✗ Failed: $effectName");
        }
      }

      // Load effect đầu tiên
      if (_loadedEffectPaths.isNotEmpty) {
        _currentEffectIndex = 0;
        await _banubaSdkManager.loadEffect(_loadedEffectPaths[0], false);
        debugPrint("=== ACTIVE: ${_loadedEffectNames[0]} ===");
      }
    } catch (e) {
      debugPrint("Lỗi load effects: $e");
    }
  }

  String _detectEffectFolder(String effectName) {
    final name = effectName.toLowerCase();

    if (name.startsWith('glass')) {
      return name.contains('women') ? 'women_glasses' : 'men_glasses';
    } else if (name.startsWith('hat')) {
      return name.contains('women') ? 'women_hat' : 'men_hat';
    }

    return widget.effectFolder ?? 'men_glasses';
  }

  Future<bool> _requestPermissions() async {
    final permissions = [Permission.camera, Permission.microphone];
    for (var permission in permissions) {
      var status = await permission.status;
      if (!status.isGranted) {
        status = await permission.request();
        if (!status.isGranted) return false;
      }
    }
    return true;
  }

  Future<String?> _copyEffectToDocuments(
    String effectName,
    String folder,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final effectDir = Directory('${directory.path}/effects/$effectName');

      if (await effectDir.exists()) {
        await effectDir.delete(recursive: true);
      }
      await effectDir.create(recursive: true);

      final assetBasePath = 'assets/effects/$folder/$effectName';
      debugPrint("Asset path: $assetBasePath");

      // Copy config files
      bool configCopied = false;
      for (final fileName in ['config.json', 'config.js']) {
        try {
          final data = await rootBundle.load('$assetBasePath/$fileName');
          final file = File('${effectDir.path}/$fileName');
          await file.writeAsBytes(data.buffer.asUint8List());
          debugPrint("  ✓ $fileName");
          configCopied = true;
        } catch (e) {
          // File không tồn tại
        }
      }

      if (!configCopied) {
        debugPrint("  ⚠ No config for $effectName");
        return null;
      }

      // Copy assets
      await _copyAssetFiles(assetBasePath, effectDir.path);

      return effectDir.path;
    } catch (e) {
      debugPrint("Error copy $effectName: $e");
      return null;
    }
  }

  Future<void> _copyAssetFiles(String assetBasePath, String destPath) async {
    try {
      final assetsDir = Directory('$destPath/assets');
      await assetsDir.create(recursive: true);

      final modelFiles = [
        'glass1.glb',
        'glass2.glb',
        'glass3.glb',
        'glass4.glb',
        'glasses.glb',
        'glassmen1.glb',
        'glassmen2.glb',
        'glasswomen1.glb',
        'glasswomen2.glb',
        'hat.glb',
        'hat1.glb',
        'hat2.glb',
        'hat3.glb',
        'hat4.glb',
        'hatmen1.glb',
        'hatmen2.glb',
        'hatmen3.glb',
        'hatmen4.glb',
        'hatwomen1.glb',
        'hatwomen2.glb',
        'model.glb',
        'main.glb',
      ];

      for (final fileName in modelFiles) {
        try {
          final data = await rootBundle.load('$assetBasePath/assets/$fileName');
          final file = File('${assetsDir.path}/$fileName');
          await file.writeAsBytes(data.buffer.asUint8List());
          debugPrint("  ✓ $fileName");
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Error copy assets: $e");
    }
  }

  /// Chuyển sang effect tiếp theo
  Future<void> _switchToNextEffect() async {
    if (_loadedEffectPaths.length <= 1) return;

    setState(() {
      _currentEffectIndex =
          (_currentEffectIndex + 1) % _loadedEffectPaths.length;
    });

    try {
      await _banubaSdkManager.loadEffect(
        _loadedEffectPaths[_currentEffectIndex],
        false,
      );
      debugPrint("Switched to: ${_loadedEffectNames[_currentEffectIndex]}");
    } catch (e) {
      debugPrint("Error switch: $e");
    }
  }

  /// Chuyển sang effect cụ thể theo index
  Future<void> _switchToEffect(int index) async {
    if (index < 0 || index >= _loadedEffectPaths.length) return;
    if (index == _currentEffectIndex) return;

    setState(() {
      _currentEffectIndex = index;
    });

    try {
      await _banubaSdkManager.loadEffect(_loadedEffectPaths[index], false);
      debugPrint("Switched to: ${_loadedEffectNames[index]}");
    } catch (e) {
      debugPrint("Error switch: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _banubaSdkManager.startPlayer();
    } else {
      _banubaSdkManager.stopPlayer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _banubaSdkManager.stopPlayer();
    _banubaSdkManager.closeCamera();
    _banubaSdkManager.deinitialize();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _loadedEffectNames.isNotEmpty
              ? "AR: ${_loadedEffectNames[_currentEffectIndex]}"
              : "AR Try-On",
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _epWidget),

          // Loading overlay
          if (!_isInitialized)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Effect selector pills (hiển thị khi có nhiều effect)
          if (_isInitialized && _loadedEffectPaths.length > 1)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: _buildEffectSelector(),
            ),

          // Bottom controls
          if (_isInitialized)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nút chuyển effect
                  if (_loadedEffectPaths.length > 1)
                    FloatingActionButton(
                      heroTag: 'switch',
                      onPressed: _switchToNextEffect,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.swap_horiz, color: Colors.black),
                    ),

                  // Nút chụp ảnh
                  FloatingActionButton(
                    heroTag: 'capture',
                    onPressed: _takePhoto,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Widget hiển thị danh sách effect có thể chọn
  Widget _buildEffectSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_loadedEffectNames.length, (index) {
              final isActive = index == _currentEffectIndex;
              final effectName = _loadedEffectNames[index];
              final isGlasses = effectName.toLowerCase().contains('glass');

              return GestureDetector(
                onTap: () => _switchToEffect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isGlasses ? Colors.purple : Colors.orange)
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? Colors.white : Colors.white30,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: (isGlasses ? Colors.purple : Colors.orange)
                                  .withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGlasses ? Icons.visibility : Icons.face,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        effectName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tính năng chụp ảnh đang phát triển")),
    );
  }
}
