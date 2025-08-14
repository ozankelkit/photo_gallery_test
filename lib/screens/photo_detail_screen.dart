import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import '../data/sample_images.dart';

class PhotoDetailScreen extends StatefulWidget {
  final List<SampleImage> photos;
  final int initialIndex;

  const PhotoDetailScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late GlobalKey<PageFlipWidgetState> _pageFlipKey;
  late int _currentIndex;
  Timer? _pageCheckTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageFlipKey = GlobalKey<PageFlipWidgetState>();

    // İlk sayfa olarak belirtilen index'e git
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex > 0) {
        _pageFlipKey.currentState?.goToPage(widget.initialIndex);
      }
      _startPageTracking();
    });
  }

  void _startPageTracking() {
    // PageFlipWidget'ın sayfa değişikliğini takip etmek için
    // sadece buton kontrollerini kullanacağız
  }

  @override
  void dispose() {
    _pageCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed:
                _currentIndex > 0
                    ? () {
                      setState(() {
                        _currentIndex--;
                      });
                      _pageFlipKey.currentState?.goToPage(_currentIndex);
                    }
                    : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed:
                _currentIndex < widget.photos.length - 1
                    ? () {
                      setState(() {
                        _currentIndex++;
                      });
                      _pageFlipKey.currentState?.goToPage(_currentIndex);
                    }
                    : null,
          ),
        ],
      ),
      body: PageFlipWidget(
        key: _pageFlipKey,
        backgroundColor: Colors.black,
        onPageFlipped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // isRightSwipe: true, // İsteğe bağlı - varsayılan false
        lastPage: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.black87, Colors.black],
              center: Alignment.center,
              radius: 1.0,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 80, color: Colors.white54),
                SizedBox(height: 16),
                Text(
                  'Son fotoğraf',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        children:
            widget.photos.map((photo) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.black87, Colors.black],
                    center: Alignment.center,
                    radius: 1.0,
                  ),
                ),
                child: Hero(
                  tag: '${photo.id}_detail',
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Image.asset(
                      photo.assetPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
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
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
