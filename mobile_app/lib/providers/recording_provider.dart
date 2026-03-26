import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:path_provider/path_provider.dart'; // WAJIB TAMBAHKAN INI
import '../models/recording.dart';
import '../services/isar_service.dart';
import '../services/gemini_service.dart';

class RecordingProvider extends ChangeNotifier {
  final IsarService _isarService = IsarService();
  final GeminiService _geminiService = GeminiService(); 
  List<Recording> _recordings = [];
  List<Recording> get recordings => _recordings;
  bool isSyncing = false; 
  

  RecordingProvider() { fetchRecordings(); }

  Future<void> fetchRecordings() async {
    _recordings = await _isarService.getAllRecordings();
    notifyListeners();
  }

  Future<void> syncWithPendant(String templateType, {required String audioPath}) async {
    isSyncing = true;
    notifyListeners(); 

    try {
      // 1. Membaca file audio asli dari memori HP
      final File tempAudioFile = File(audioPath);
      final Uint8List audioBytes = await tempAudioFile.readAsBytes();

      // REVISI 1: Pindahkan file ke penyimpanan permanen aplikasi agar bisa diputar di Workspace
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = "ergo_${DateTime.now().millisecondsSinceEpoch}.m4a";
      final permanentAudioFile = await tempAudioFile.copy('${appDir.path}/$fileName');

      // 2. Mengirim audio ke Gemini AI 
      final aiResult = await _geminiService.generateSummaryFromAudio(audioBytes, templateType);

      // 3. Ekstrak To-Do List
      List<ActionItem> extractedTodos = [];
      if (aiResult['todos'] is List) {
        for (var todoText in aiResult['todos']) {
          extractedTodos.add(ActionItem()..text = todoText.toString()..isDone = false);
        }
      }

      // 4. Ekstrak Daftar Partisipan
      List<String> extractedParticipants = [];
      if (aiResult['participants'] is List) {
        for (var participant in aiResult['participants']) {
          extractedParticipants.add(participant.toString());
        }
      }

      // 5. Kalkulasi Durasi Asli
      int estimatedSeconds = (audioBytes.length / 16000).round();
      if (estimatedSeconds < 1) estimatedSeconds = 1;
      final m = (estimatedSeconds / 60).floor().toString().padLeft(2, '0');
      final s = (estimatedSeconds % 60).toString().padLeft(2, '0');
      final realDuration = "$m:$s";

      // 6. Merakit Objek Database (Isar)
      final newRecord = Recording()
        ..title = aiResult['summary_title'] ?? "Voice Note Baru"
        ..date = DateTime.now() 
        ..duration = realDuration
        ..filePath = permanentAudioFile.path // REVISI 2: Menyimpan jalur audio asli ke Database!
        ..templateType = templateType
        ..summary = aiResult['summary'] ?? "Tidak ada ringkasan."
        ..transcript = aiResult['transcript'] ?? "Tidak ada transkrip."
        ..actionItems = extractedTodos 
        ..participantNames = extractedParticipants 
        ..isSynced = true;
        

      await _isarService.saveRecording(newRecord);
      await fetchRecordings(); 
      
      // 7. Bersihkan file temporary (File permanen tetap aman)
      if (await tempAudioFile.exists()) {
        await tempAudioFile.delete();
      }
      
    } catch (e) { debugPrint("Error Sync: $e"); }

    isSyncing = false;
    notifyListeners();
  }

  // ... (fungsi toggleTodo, updateParticipantName, updateRecordingTitle, deleteRecording dibiarkan persis sama seperti sebelumnya)
  Future<void> toggleTodo(int recordingId, int todoIndex, bool isDone) async {
    final recordIndex = _recordings.indexWhere((r) => r.id == recordingId);
    if (recordIndex != -1) {
      final record = _recordings[recordIndex];
      if (record.actionItems != null && todoIndex < record.actionItems!.length) {
        final updatedTodos = List<ActionItem>.from(record.actionItems!);
        updatedTodos[todoIndex].isDone = isDone;
        record.actionItems = updatedTodos;
        await _isarService.saveRecording(record);
        notifyListeners();
      }
    }
  }

  Future<void> updateParticipantName(int recordingId, int participantIndex, String newName) async {
    if (newName.trim().isEmpty) return;
    final recordIndex = _recordings.indexWhere((r) => r.id == recordingId);
    if (recordIndex != -1) {
      final record = _recordings[recordIndex];
      if (record.participantNames != null && participantIndex < record.participantNames!.length) {
        record.participantNames![participantIndex] = newName.trim();
        await _isarService.saveRecording(record);
        notifyListeners();
      }
    }
  }

  Future<void> updateRecordingTitle(int recordingId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    final recordIndex = _recordings.indexWhere((r) => r.id == recordingId);
    if (recordIndex != -1) {
      final record = _recordings[recordIndex];
      record.title = newTitle.trim();
      await _isarService.saveRecording(record);
      notifyListeners();
    }
  }

  Future<void> deleteRecording(int recordingId) async {
    await _isarService.deleteRecording(recordingId); 
    _recordings.removeWhere((r) => r.id == recordingId); 
    notifyListeners(); 
  }
}