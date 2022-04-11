import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? _authToken;
  String? userId;

  Products(this._items, this.userId, this._authToken);
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) async {
    final url = Uri.https('shops-app-5b7db-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$_authToken'});
    try {
      final value = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
            'isFavorite': product.isFavorite,
          }));

      final newProduct = Product(
          id: json.decode(value.body)['name'],
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String? id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      var url = Uri.https('shops-app-5b7db-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': '$_authToken'});
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProducts(String? id) async {
    final url = Uri.https('shops-app-5b7db-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$_authToken'});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);

      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var url = filterByUser
        ? Uri.https(
            'shops-app-5b7db-default-rtdb.firebaseio.com', '/products.json', {
            'auth': '$_authToken',
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"'
          })
        : Uri.https('shops-app-5b7db-default-rtdb.firebaseio.com',
            '/products.json', {'auth': '$_authToken'});
    try {
      final response = await http.get(url);
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      url = Uri.https(
          'shops-app-5b7db-default-rtdb.firebaseio.com', '/$userId.json', {
        'auth': '$_authToken',
      });
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            description: prodData['description'],
            title: prodData['title'],
            price: prodData['price'] + .0,
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
