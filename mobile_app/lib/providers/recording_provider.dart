import 'package:flutter/foundation.dart'; // Tambahkan ini
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; 
import 'dart:typed_data'; 
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

  Future<void> syncWithPendant(String templateType) async {
    isSyncing = true;
    notifyListeners(); 

    try {
      final ByteData audioData = await rootBundle.load('assets/audio/testing_rapat.mp3');
      final Uint8List audioBytes = audioData.buffer.asUint8List();
      final aiResult = await _geminiService.generateSummaryFromAudio(audioBytes, templateType);

      List<ActionItem> extractedTodos = [];
      if (aiResult['todos'] is List) {
        for (var todoText in aiResult['todos']) {
          extractedTodos.add(ActionItem()..text = todoText.toString()..isDone = false);
        }
      }

      // Menerjemahkan JSON Participants ke Isar
      List<String> extractedParticipants = [];
      if (aiResult['participants'] is List) {
        for (var participant in aiResult['participants']) {
          extractedParticipants.add(participant.toString());
        }
      }

      final newRecord = Recording()
        ..title = aiResult['summary_title'] // REVISI 1: Menimpa Judul Teknis dengan Judul Dinamis Gemini!
        ..date = DateTime.now() // Otomatis
        ..duration = "00:03:15" 
        ..templateType = templateType
        ..summary = aiResult['summary'] // Summary bersih
        ..transcript = aiResult['transcript']
        ..actionItems = extractedTodos 
        ..participantNames = extractedParticipants // REVISI 2: Menyimpan data partisipan terpisah
        ..isSynced = true;

      await _isarService.saveRecording(newRecord);
      await fetchRecordings(); 
    } catch (e) { debugPrint("Error Sync: $e"); }

    isSyncing = false;
    notifyListeners();
  }

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

  // FUNGSI BARU: Apple UX - Mengubah nama Speaker langsung di tempat
  Future<void> updateParticipantName(int recordingId, int participantIndex, String newName) async {
    if (newName.trim().isEmpty) return; // JANGAN perbolehkan nama kosong

    final recordIndex = _recordings.indexWhere((r) => r.id == recordingId);
    if (recordIndex != -1) {
      final record = _recordings[recordIndex];
      if (record.participantNames != null && participantIndex < record.participantNames!.length) {
        // Melakukan update nama dalam list
        record.participantNames![participantIndex] = newName.trim();
        
        // Simpan ke database lokal
        await _isarService.saveRecording(record);
        
        // Beri tahu UI untuk merefresh tampilannya
        notifyListeners();
      }
    }
  }
  // FUNGSI BARU: Inline Editing untuk Judul Rapat
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
  // FUNGSI BARU: Menghapus rekaman (Sesuai Apple iOS paradigm)
  Future<void> deleteRecording(int recordingId) async {
    await _isarService.deleteRecording(recordingId); // Hapus dari database
    _recordings.removeWhere((r) => r.id == recordingId); // Hapus dari list di memori
    notifyListeners(); // Refresh UI seketika
  }
}