import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class BlockOfProfileRepository {
  AsyncResult<List<BlockOfProfile>> getAllBlocks();
  AsyncResult<BlockOfProfile> getBlockById(int id);
  AsyncResult<List<BlockOfProfile>> getBlocksByName(String name);
  AsyncResult<int> addBlock(BlockOfProfile block);
  AsyncResult<bool> updateBlock(BlockOfProfile block);
  AsyncResult<bool> deleteBlockById(int id);

  /// Insere ou atualiza um bloco de perfil. Retorna true se operação bem-sucedida.
  AsyncResult<bool> upsertBlock(BlockOfProfile block);
}
