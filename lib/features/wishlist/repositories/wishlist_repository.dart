import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/wishlist_model.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _wishlists =>
      _firestore.collection(AppConstants.wishlistCollection);

  Future<void> addWishlist(WishlistModel wishlist) async {
    try {
      await _wishlists.add(wishlist.toMap());
    } catch (e) {
      throw 'Gagal menambahkan wishlist: $e';
    }
  }

  Stream<List<WishlistModel>> getUserWishlistsStream(String userId) {
    return _wishlists
        .where('userId', isEqualTo: userId)
        // HAPUS baris orderBy ini:
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return WishlistModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Kita urutkan secara manual di aplikasi: Dari deadline (tenggat waktu) terdekat
      list.sort((a, b) => a.deadline.compareTo(b.deadline));
      
      return list;
    });
  }

  Future<void> updateCurrentAmount(String documentId, double newAmount) async {
    try {
      await _wishlists.doc(documentId).update({'currentAmount': newAmount});
    } catch (e) {
      throw 'Gagal memperbarui tabungan: $e';
    }
  }

  Future<void> deleteWishlist(String documentId) async {
    try {
      await _wishlists.doc(documentId).delete();
    } catch (e) {
      throw 'Gagal menghapus wishlist: $e';
    }
  }
}