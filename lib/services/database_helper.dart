import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:farmora/models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmora_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        await _insertDummyData(db);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _insertDummyData(Database db) async {
    var count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    if (count != null && count > 0) return;

    List<Map<String, dynamic>> dummyProducts = [
      {
        'name': 'Organic Tomatoes',
        'description': 'Fresh organic tomatoes grown without pesticides. Perfect for salads and cooking.',
        'price': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1524593166156-312f362cada0?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
      {
        'name': 'Fresh Carrots Bundle',
        'description': 'A bundle of fresh farm carrots. Rich in vitamins and perfect for juicing or cooking.',
        'price': 2.49,
        'imageUrl': 'https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      },
      {
        'name': 'Avocado Set',
        'description': 'Premium avocados ready to eat. High in healthy fats and perfect for sandwiches and salads.',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1519162808019-7de1683fa2ad?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      },
      {
        'name': 'Farm Fresh Eggs',
        'description': 'Free-range eggs from our local farm. Ethically sourced and perfect for breakfast.',
        'price': 4.50,
        'imageUrl': 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'name': 'Organic Spinach',
        'description': 'Fresh organic spinach leaves. Rich in iron and perfect for smoothies and salads.',
        'price': 2.99,
        'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
      },
      {
        'name': 'Sweet Potatoes',
        'description': 'Delicious and nutritious sweet potatoes, perfect for baking, roasting, or mashing.',
        'price': 3.25,
        'imageUrl': 'https://images.unsplash.com/photo-1617635149220-9a15f6ef8f4c?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
      },
      {
        'name': 'Fresh Strawberries',
        'description': 'Sweet and juicy strawberries, perfect for snacking or adding to desserts.',
        'price': 4.99,
        'imageUrl': 'https://images.unsplash.com/photo-1587733706435-ec6c4a6a97c8?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
      {
        'name': 'Organic Apples',
        'description': 'Crisp and delicious organic apples, perfect for snacking and baking.',
        'price': 2.99,
        'imageUrl': 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
      },
      {
        'name': 'Fresh Blueberries',
        'description': 'Plump and sweet blueberries, perfect for smoothies, baking, or snacking.',
        'price': 5.99,
        'imageUrl': 'https://images.unsplash.com/photo-1591195851117-18c2d96f15fe?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
      },
      {
        'name': 'Organic Kale',
        'description': 'Nutritious and versatile organic kale, perfect for salads, smoothies, and cooking.',
        'price': 3.49,
        'imageUrl': 'https://images.unsplash.com/photo-1576765607921-83b32b4f7e6e?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      },
      {
        'name': 'Fresh Broccoli',
        'description': 'Fresh broccoli rich in vitamins and minerals, perfect for steaming, roasting, or adding to stir-fries.',
        'price': 2.75,
        'imageUrl': 'https://images.unsplash.com/photo-1575936123452-b67c3203c357?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      },
      {
        'name': 'Juicy Oranges',
        'description': 'Sweet and juicy oranges, perfect for snacking and juicing.',
        'price': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1617635149220-9a15f6ef8f4c?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      },
      {
        'name': 'Cucumber Pack',
        'description': 'Fresh cucumbers perfect for salads and snacking.',
        'price': 1.99,
        'imageUrl': 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=500&q=60',
        'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
    ];

    for (var product in dummyProducts) {
      await db.insert('products', product);
    }
  }

  // CRUD operations
  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
