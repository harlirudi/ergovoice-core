import 'package:isar/isar.dart';

// Baris ini krusial! Ini memberi tahu Isar untuk 
// membuatkan kode rahasianya di file terpisah.
part 'recording.g.dart'; 

@collection
class Recording {
  // KTP Data: ID unik yang dibuat otomatis
  Id id = Isar.autoIncrement; 

  // Metadata Rapat
  String? title;
  DateTime? createdAt;
  int? durationSeconds;
  
  // Tag / Kategori (Misal: meeting, lecture, idea)
  String? templateType;
  
  // ALAMAT AUDIO (Kita HANYA menyimpan alamat letak file mp3-nya, 
  // bukan filenya, agar database tidak lemot)
  String? audioFilePath;
  
  // Hasil Otak Gemini
  String? rawTranscript;
  String? aiSummary;
}