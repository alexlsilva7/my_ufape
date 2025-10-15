import 'package:isar_community/isar.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:result_dart/result_dart.dart';

class BlockOfProfileService {
  final Database _database;

  BlockOfProfileService(this._database);

  AsyncResult<List<BlockOfProfile>> getAllBlocks() async {
    try {
      final db = await _database.connection;
      final blocks = await db.blockOfProfiles.where().findAll();
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: '${blocks.length} items',
      );
      return Success(blocks.toList());
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Error: $e',
      );
      return Failure(Exception('Failed to fetch blocks: $e'));
    }
  }

  AsyncResult<BlockOfProfile> getBlockById(int id) async {
    try {
      final db = await _database.connection;
      final block = await db.blockOfProfiles.get(id);
      if (block != null) {
        logarte.database(
          source: 'Isar',
          target: 'BlockOfProfile',
          value: 'ID $id found',
        );
        return Success(block);
      } else {
        logarte.database(
          source: 'Isar',
          target: 'BlockOfProfile',
          value: 'ID $id not found',
        );
        return Failure(Exception('Block not found'));
      }
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Error getting ID $id: $e',
      );
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
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Query by name "$name" found ${blocks.length} items',
      );
      return Success(blocks.toList());
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Error querying by name "$name": $e',
      );
      return Failure(Exception('Failed to fetch blocks by name: $e'));
    }
  }

  AsyncResult<int> addBlock(BlockOfProfile block) async {
    try {
      final db = await _database.connection;
      final id = await db.writeTxnSync(() async {
        return db.blockOfProfiles.putSync(block);
      });
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Added new block with ID $id',
      );
      return Success(id);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Error adding block: $e',
      );
      return Failure(Exception('Failed to add block: $e'));
    }
  }

  AsyncResult<bool> updateBlock(BlockOfProfile block) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxnSync(() async {
        return db.blockOfProfiles.putSync(block) > 0;
      });
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Updated block with ID ${block.id}',
      );
      return Success(success);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Error updating block ID ${block.id}: $e',
      );
      return Failure(Exception('Failed to update block: $e'));
    }
  }

  AsyncResult<bool> deleteBlockById(int id) async {
    try {
      final db = await _database.connection;
      final success = await db.writeTxn(() async {
        return await db.blockOfProfiles.delete(id);
      });
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Deleted block with ID $id',
      );
      return Success(success);
    } catch (e) {
      logarte.database(
        source: 'Isar',
        target: 'BlockOfProfile',
        value: 'Error deleting block ID $id: $e',
      );
      return Failure(Exception('Failed to delete block: $e'));
    }
  }
}
