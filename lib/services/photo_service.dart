import '../data/sample_images.dart';

class PhotoService {
  // Tüm sample fotoğrafları getir
  List<SampleImage> getAllPhotos() {
    return SampleData.images;
  }

  // Sayfalı olarak fotoğrafları getir
  List<SampleImage> getPhotosWithPagination({
    int page = 0,
    int pageSize = 50,
  }) {
    final allPhotos = SampleData.images;
    final start = page * pageSize;
    final end = start + pageSize;
    
    if (start >= allPhotos.length) {
      return [];
    }
    
    return allPhotos.sublist(
      start,
      end > allPhotos.length ? allPhotos.length : end,
    );
  }

  // ID'ye göre fotoğraf bul
  SampleImage? getPhotoById(String id) {
    try {
      return SampleData.images.firstWhere((photo) => photo.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fotoğraf sayısını getir
  int getPhotoCount() {
    return SampleData.images.length;
  }
}