import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recording.dart'; // Memanggil Blueprint kita tadi

class IsarService {
  late Future<Isar> db;

  // Saat mesin ini dipanggil, ia langsung membuka database
  IsarService() {
    db = openDB();
  }

  // Fungsi untuk membuka (atau membuat) file database di memori HP
  Future<Isar> openDB() async {
    // Mengecek apakah database sudah terbuka agar tidak dobel
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [RecordingSchema], // Menggunakan skema hasil generate tadi
        directory: dir.path,
        inspector: true, // Memudahkan kita melihat isi database nanti
      );
    }
    return Future.value(Isar.getInstance());
  }

  // ==========================================
  // FUNGSI CRUD (Create, Read, Update, Delete)
  // ==========================================

  // 1. Menyimpan data rapat baru
  Future<void> saveRecording(Recording newRecording) async {
    final isar = await db;
    // Menggunakan writeTxnSync untuk menulis data dengan aman
    isar.writeTxnSync<int>(() => isar.recordings.putSync(newRecording));
  }

  // 2. Mengambil SEMUA data rapat untuk ditampilkan di layar
  Future<List<Recording>> getAllRecordings() async {
    final isar = await db;
    return await isar.recordings.where().findAll();
  }

  // 3. Menghapus data rapat (jika nanti dibutuhkan)
  Future<void> deleteRecording(Id id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.recordings.deleteSync(id));
  }
}
