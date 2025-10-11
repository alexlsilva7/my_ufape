import 'package:my_ufape/data/services/block_of_profile/block_of_profile_service.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:result_dart/result_dart.dart';

import './block_of_profile_repository.dart';

class BlockOfProfileRepositoryImpl implements BlockOfProfileRepository {
  final BlockOfProfileService _service;
  BlockOfProfileRepositoryImpl(this._service);

  @override
  AsyncResult<int> addBlock(BlockOfProfile block) {
    return _service.addBlock(block);
  }

  @override
  AsyncResult<bool> deleteBlockById(int id) {
    return _service.deleteBlockById(id);
  }

  @override
  AsyncResult<List<BlockOfProfile>> getAllBlocks() {
    return _service.getAllBlocks();
  }

  @override
  AsyncResult<BlockOfProfile> getBlockById(int id) {
    return _service.getBlockById(id);
  }

  @override
  AsyncResult<List<BlockOfProfile>> getBlocksByName(String name) {
    return _service.getBlocksByName(name);
  }

  @override
  AsyncResult<bool> updateBlock(BlockOfProfile block) {
    return _service.updateBlock(block);
  }

  @override
  AsyncResult<bool> upsertBlock(BlockOfProfile block) async {
    try {
      BlockOfProfile? existing;

      await _service.getBlocksByName(block.name).onSuccess((list) {
        for (final b in list) {
          if (b.name.toLowerCase() == block.name.toLowerCase()) {
            existing = b;
            break;
          }
        }
      });

      if (existing != null) {
        // Caso já exista, atualize se houver necessidade (ex.: subjects)
        bool needsUpdate = false;
        // comparar por tamanho de links ou por subjectList quando disponível
        if (block.subjectList.isNotEmpty) {
          // se houver subjectList, considerar atualização
          needsUpdate = true;
        }

        if (needsUpdate) {
          // aqui você poderia sincronizar links; simplificamos chamando updateBlock
          return _service.updateBlock(existing!);
        } else {
          return Success(true);
        }
      } else {
        return _service.addBlock(block).map((_) => true);
      }
    } catch (e) {
      return Failure(Exception('Failed to upsert block: $e'));
    }
  }
}
