import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:result_dart/result_dart.dart';

class BlockOfProfileService {
  final Database _database;

  BlockOfProfileService(this._database);

  AsyncResult<List<BlockOfProfile>> getAllBlocks() async {
    try {
      final db = await _database.connection;
      final blocks = await db.blockOfProfiles.where().findAll();
      return Success(blocks.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch blocks: $e'));
    }
  }

  AsyncResult<BlockOfProfile> getBlockById(int id) async {
    try {
      final db = await _database.connection;
      final block = await db.blockOfProfiles.get(id);
      if (block != null) {
        return Success(block);
      } else {
        return Failure(Exception('Block not found'));
      }
    } catch (e) {
      return Failure(Exception('Failed to fetch block by ID: $e'));
    }
  }

  AsyncResult<List<BlockOfProfile>> getBlocksByName(String name) async {
    try {
      final db = await _database.connection;
      final blocks = await db.blockOfProfiles
          .filter()
          .nameContains(name, caseSensitive: false)
          .findAll();
      return Success(blocks.toList());
    } catch (e) {
      return Failure(Exception('Failed to fetch blocks by name: $e'));
    }
  }

  AsyncResult<int> addBlock(BlockOfProfile block) async {
    try {
      final db = await _database.connection;
      final id = await db.writeTxnSync(() async {
        return db.blockOfProfiles.putSync(block);
      });
      return Success(id);
    } catch (e) {
      return Failure(Exception('Failed to add block: $e'));
    }
  }

  AsyncResult<bool> updateBlock(BlockOfProfile block) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxnSync(() async {
        return db.blockOfProfiles.putSync(block) > 0;
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to update block: $e'));
    }
  }

  AsyncResult<bool> deleteBlockById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.blockOfProfiles.delete(id);
      });
      return Success(success);
    } catch (e) {
      return Failure(Exception('Failed to delete block: $e'));
    }
  }
}
