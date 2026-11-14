import '../../core/models/enums.dart';
import '../datasources/database.dart';
import '../models/transfer.dart' as model;

class TransferRepository {
  final AppDatabase _database;

  TransferRepository(this._database);

  Future<List<model.Transfer>> getAllTransfers() async {
    return await _database.getAllTransfers();
  }

  Future<model.Transfer?> getTransferById(String id) async {
    return await _database.getTransferById(id);
  }

  Future<void> addTransfer(model.Transfer transfer) async {
    await _database.addTransfer(transfer);
  }

  Future<void> updateTransfer(model.Transfer transfer) async {
    await _database.updateTransfer(transfer);
  }

  Future<void> deleteTransfer(String id) async {
    await _database.deleteTransfer(id);
  }

  Future<void> clearAllTransfers() async {
    await _database.clearAllTransfers();
  }

  Stream<List<model.Transfer>> watchAllTransfers() {
    return _database.watchAllTransfers();
  }

  Future<List<model.Transfer>> getActiveTransfers() async {
    final all = await getAllTransfers();
    return all
        .where((t) =>
            t.status == TransferStatus.sending ||
            t.status == TransferStatus.receiving)
        .toList();
  }

  Future<List<model.Transfer>> getTransfersByDirection(
      TransferDirection direction) async {
    return await _database.getTransfersByDirection(direction);
  }
}
