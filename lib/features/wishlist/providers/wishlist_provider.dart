import 'package:flutter/material.dart';
import '../models/wishlist_model.dart';
import '../repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _repository;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WishlistProvider({WishlistRepository? repository})
      : _repository = repository ?? WishlistRepository();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Stream<List<WishlistModel>> getWishlistsStream(String userId) {
    return _repository.getUserWishlistsStream(userId);
  }

  Future<void> addWishlist(WishlistModel wishlist) async {
    _setLoading(true);
    try {
      await _repository.addWishlist(wishlist);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addSavings(String wishlistId, double currentAmount, double additionalAmount) async {
    try {
      final newTotal = currentAmount + additionalAmount;
      await _repository.updateCurrentAmount(wishlistId, newTotal);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWishlist(String documentId) async {
    try {
      await _repository.deleteWishlist(documentId);
    } catch (e) {
      rethrow;
    }
  }
}