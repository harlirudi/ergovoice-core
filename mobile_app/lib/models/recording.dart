import 'package:isar/isar.dart';

part 'recording.g.dart';

@collection
class Recording {
  Id id = Isar.autoIncrement;
  String? title; // Nanti akan diisi Judul Dinamis dari Gemini
  DateTime? date;
  String? duration;
  String? templateType;
  String? summary; // Markdown summary bersih TANPA Participants
  String? transcript;
  bool isSynced = false;
  String? filePath;
  List<String>? participantNames; // KOTAK BARU UNTUK NAMA PARTISIPAN (Editable)
  List<ActionItem>? actionItems; 
}

@embedded
class ActionItem {
  String? text;
  bool isDone = false;
}