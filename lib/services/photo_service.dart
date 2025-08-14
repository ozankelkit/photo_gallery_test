import 'package:photo_manager/photo_manager.dart';

class PhotoService {
  // İzin kontrolü ve isteme
  Future<bool> requestPermission() async {
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    return permission == PermissionState.authorized || permission == PermissionState.limited;
  }

  // Tüm fotoğrafları getir
  Future<List<AssetEntity>> getAllPhotos() async {
    final bool hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Galeri erişim izni verilmedi');
    }

    // Tüm albümleri al
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true, // Sadece "Tüm Fotoğraflar" albümünü al
    );

    if (albums.isEmpty) {
      return [];
    }

    // İlk albümdeki (Tüm Fotoğraflar) tüm fotoğrafları al
    final AssetPathEntity allPhotosAlbum = albums.first;
    final List<AssetEntity> photos = await allPhotosAlbum.getAssetListRange(
      start: 0,
      end: await allPhotosAlbum.assetCountAsync,
    );

    return photos;
  }

  // Fotoğrafları sayfalı olarak getir (performans için)
  Future<List<AssetEntity>> getPhotosWithPagination({
    int page = 0,
    int pageSize = 50,
  }) async {
    final bool hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Galeri erişim izni verilmedi');
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      return [];
    }

    final AssetPathEntity allPhotosAlbum = albums.first;
    final int start = page * pageSize;
    final int end = start + pageSize;
    
    final int totalCount = await allPhotosAlbum.assetCountAsync;
    if (start >= totalCount) {
      return [];
    }

    final List<AssetEntity> photos = await allPhotosAlbum.getAssetListRange(
      start: start,
      end: end > totalCount ? totalCount : end,
    );

    return photos;
  }
}