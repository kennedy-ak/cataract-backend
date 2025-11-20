import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Model for prediction records
class PredictionRecord {
  final int? id;
  final String imagePath;
  final double prediction;
  final int predictedClass;
  final String className;
  final double confidence;
  final double inferenceTime;
  final String timestamp;
  final String uploadStatus; // 'pending', 'uploading', 'uploaded', 'failed'
  final int retryCount;

  PredictionRecord({
    this.id,
    required this.imagePath,
    required this.prediction,
    required this.predictedClass,
    required this.className,
    required this.confidence,
    required this.inferenceTime,
    required this.timestamp,
    this.uploadStatus = 'pending',
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'prediction': prediction,
      'predictedClass': predictedClass,
      'className': className,
      'confidence': confidence,
      'inferenceTime': inferenceTime,
      'timestamp': timestamp,
      'uploadStatus': uploadStatus,
      'retryCount': retryCount,
    };
  }

  factory PredictionRecord.fromMap(Map<String, dynamic> map) {
    return PredictionRecord(
      id: map['id'],
      imagePath: map['imagePath'],
      prediction: map['prediction'],
      predictedClass: map['predictedClass'],
      className: map['className'],
      confidence: map['confidence'],
      inferenceTime: map['inferenceTime'],
      timestamp: map['timestamp'],
      uploadStatus: map['uploadStatus'] ?? 'pending',
      retryCount: map['retryCount'] ?? 0,
    );
  }
}

/// Service for managing local storage of predictions and images
class LocalStorageService {
  static const String _dbName = 'cataract_detection.db';
  static const String _tableName = 'predictions';
  static const int _dbVersion = 1;

  Database? _database;

  /// Get singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        prediction REAL NOT NULL,
        predictedClass INTEGER NOT NULL,
        className TEXT NOT NULL,
        confidence REAL NOT NULL,
        inferenceTime REAL NOT NULL,
        timestamp TEXT NOT NULL,
        uploadStatus TEXT NOT NULL,
        retryCount INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Save image to local storage
  Future<String> saveImage(Uint8List imageBytes, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/cataract_images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final imagePath = '${imagesDir.path}/$filename';
    final file = File(imagePath);
    await file.writeAsBytes(imageBytes);

    return imagePath;
  }

  /// Insert prediction record
  Future<int> insertPrediction(PredictionRecord record) async {
    final db = await database;
    return await db.insert(
      _tableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending uploads
  Future<List<PredictionRecord>> getPendingUploads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'uploadStatus = ?',
      whereArgs: ['pending'],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) => PredictionRecord.fromMap(maps[i]));
  }

  /// Get all failed uploads
  Future<List<PredictionRecord>> getFailedUploads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'uploadStatus = ?',
      whereArgs: ['failed'],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) => PredictionRecord.fromMap(maps[i]));
  }

  /// Update upload status
  Future<void> updateUploadStatus(int id, String status, {int? retryCount}) async {
    final db = await database;
    final Map<String, dynamic> updates = {'uploadStatus': status};
    if (retryCount != null) {
      updates['retryCount'] = retryCount;
    }

    await db.update(
      _tableName,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete prediction record and associated image
  Future<void> deletePrediction(int id) async {
    final db = await database;

    // Get the record first to delete the image
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final record = PredictionRecord.fromMap(maps.first);
      final file = File(record.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Delete the database record
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total pending count
  Future<int> getPendingCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE uploadStatus = ?',
      ['pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all records (for debugging)
  Future<List<PredictionRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => PredictionRecord.fromMap(maps[i]));
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
