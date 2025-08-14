import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoDetailScreen extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const PhotoDetailScreen({
    super.key,
    required this.assets,
    required this.initialIndex,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _preloadImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Mevcut ve yakın fotoğrafları önceden yükle
  Future<void> _preloadImages() async {
    final currentAsset = widget.assets[_currentIndex];
    await _loadImage(currentAsset);

    // Önceki fotoğrafı yükle
    if (_currentIndex > 0) {
      final prevAsset = widget.assets[_currentIndex - 1];
      _loadImage(prevAsset);
    }

    // Sonraki fotoğrafı yükle
    if (_currentIndex < widget.assets.length - 1) {
      final nextAsset = widget.assets[_currentIndex + 1];
      _loadImage(nextAsset);
    }
  }

  Future<Uint8List?> _loadImage(AssetEntity asset) async {
    if (_imageCache.containsKey(asset.id)) {
      return _imageCache[asset.id];
    }

    try {
      final bytes = await asset.originBytes;
      if (bytes != null) {
        _imageCache[asset.id] = bytes;
        if (mounted) setState(() {});
        return bytes;
      }
    } catch (e) {
      print('Fotoğraf yükleme hatası: $e');
    }
    return null;
  }

  // Sayfa değiştiğinde yakındaki fotoğrafları önceden yükle
  void _preloadNearbyImages(int currentIndex) {
    // Önceki fotoğrafı yükle
    if (currentIndex > 0) {
      final prevAsset = widget.assets[currentIndex - 1];
      if (!_imageCache.containsKey(prevAsset.id)) {
        _loadImage(prevAsset);
      }
    }

    // Sonraki fotoğrafı yükle
    if (currentIndex < widget.assets.length - 1) {
      final nextAsset = widget.assets[currentIndex + 1];
      if (!_imageCache.containsKey(nextAsset.id)) {
        _loadImage(nextAsset);
      }
    }

    // Memory kullanımını kontrol et - çok uzaktaki fotoğrafları temizle
    _cleanupDistantImages(currentIndex);
  }

  // Çok uzaktaki fotoğrafları cache'den temizle
  void _cleanupDistantImages(int currentIndex) {
    final keysToRemove = <String>[];

    _imageCache.forEach((key, value) {
      final assetIndex = widget.assets.indexWhere((asset) => asset.id == key);
      if (assetIndex != -1) {
        final distance = (assetIndex - currentIndex).abs();
        // 5'ten uzaktaki fotoğrafları temizle
        if (distance > 5) {
          keysToRemove.add(key);
        }
      }
    });

    for (final key in keysToRemove) {
      _imageCache.remove(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.assets.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPhotoInfo(context),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final asset = widget.assets[index];

          // Cache'den kontrol et
          if (_imageCache.containsKey(asset.id)) {
            return PhotoViewGalleryPageOptions.customChild(
              child: Image.memory(_imageCache[asset.id]!, fit: BoxFit.contain),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(
                tag: '${asset.id}_detail',
              ),
            );
          }

          // Cache'de yoksa yükle
          return PhotoViewGalleryPageOptions.customChild(
            child: FutureBuilder<Uint8List?>(
              future: _loadImage(asset),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Fotoğraf yüklenemedi',
                          style: TextStyle(color: Colors.white54, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                return Image.memory(snapshot.data!, fit: BoxFit.contain);
              },
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: '${asset.id}_detail'),
          );
        },
        itemCount: widget.assets.length,
        loadingBuilder:
            (context, event) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
          _preloadNearbyImages(index);
        },
      ),
    );
  }

  void _showPhotoInfo(BuildContext context) {
    final currentAsset = widget.assets[_currentIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Fotoğraf Bilgileri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Tip', _getAssetType(currentAsset)),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Boyut',
                  '${currentAsset.width} x ${currentAsset.height}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Oluşturulma Tarihi',
                  '${currentAsset.createDateTime.day}/${currentAsset.createDateTime.month}/${currentAsset.createDateTime.year} ${currentAsset.createDateTime.hour}:${currentAsset.createDateTime.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Değiştirilme Tarihi',
                  '${currentAsset.modifiedDateTime.day}/${currentAsset.modifiedDateTime.month}/${currentAsset.modifiedDateTime.year} ${currentAsset.modifiedDateTime.hour}:${currentAsset.modifiedDateTime.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Pozisyon',
                  '${_currentIndex + 1} / ${widget.assets.length}',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _getAssetType(AssetEntity asset) {
    switch (asset.type) {
      case AssetType.image:
        return 'Resim';
      case AssetType.video:
        return 'Video';
      case AssetType.audio:
        return 'Ses';
      case AssetType.other:
        return 'Diğer';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
