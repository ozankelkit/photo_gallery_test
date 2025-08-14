class SampleImage {
  final String id;
  final String description;
  final String assetPath;
  final DateTime dateAdded;

  SampleImage({
    required this.id,
    required this.description,
    required this.assetPath,
    required this.dateAdded,
  });
}

class SampleData {
  // ✨ FOTOĞRAF SIRALAMASINI DEĞİŞTİRMEK İÇİN:
  // Bu listedeki fotoğrafların sırasını değiştirerek galeri sıralamasını değiştirebilirsiniz
  // Örnek: İlk sırada 'photo6.jpg' göstermek için onu listenin başına taşıyın

  static final List<String> _imageOrder = [
    'assets/images/nature1.jpg', // 1. sırada gösterilecek
    'assets/images/city1.jpg', // 2. sırada gösterilecek
    'assets/images/sea1.jpg', // 3. sırada gösterilecek
    'assets/images/photo4.jpg', // 4. sırada gösterilecek
    'assets/images/photo5.jpg', // 5. sırada gösterilecek
    'assets/images/photo6.jpg', // 6. sırada gösterilecek
    'assets/images/photo7.jpg', // 7. sırada gösterilecek
    'assets/images/photo8.jpg', // 8. sırada gösterilecek
    'assets/images/photo9.jpg', // 9. sırada gösterilecek
    'assets/images/photo10.jpg', // 10. sırada gösterilecek
  ];

  static List<SampleImage> get images {
    return _imageOrder.asMap().entries.map((entry) {
      final index = entry.key;
      final assetPath = entry.value;

      return SampleImage(
        id: '${index + 1}',
        description: '',
        assetPath: assetPath,
        dateAdded: DateTime.now().subtract(Duration(days: index + 1)),
      );
    }).toList();
  }
}
