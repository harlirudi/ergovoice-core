import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  GeminiService();

  Future<Map<String, dynamic>> generateSummaryFromAudio(Uint8List audioBytes, String templateType) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 
    if (apiKey.isEmpty) return {};

    // REVISI 1: Menggunakan model Gemini 3 Flash Preview yang valid dan mendukung Audio Multimodal
    final model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);

    // LOGIKA PERCABANGAN PROMPT BERDASARKAN TEMPLATE
    String summaryFormat = "";
    String todoInstruction = "";
    
    if (templateType == 'Business') {
      summaryFormat = "#### **General Insights**\\n* **[Topik 1]:** [Wawasan 1]\\n* **[Topik 2]:** [Wawasan 2]\\n\\n#### **Key Outcomes**\\n* **[Keputusan]:** [Detail]\\n* **[Tindakan]:** [Detail]";
      todoInstruction = '"todos": ["Wajib diisi dengan tugas pertama dari rapat", "Wajib diisi dengan tugas kedua"],';
    
    } else if (templateType == 'Lecture') {
      summaryFormat = "#### **Core Concepts (Main Ideas)**\\n* **[Konsep 1]:** [Definisi atau penjelasan komprehensif]\\n* **[Konsep 2]:** [Definisi atau penjelasan]\\n\\n#### **Cues & Anticipated Questions**\\n* **[Pertanyaan/Petunjuk]:** [Hal yang perlu ditanyakan di office hours atau dipelajari lebih lanjut]\\n\\n#### **Typographic Mind-Map**\\n* **[Topik Sentral]**\\n  * **[Sub-topik A]:** [Detail singkat]\\n    * [Fakta pendukung]\\n  * **[Sub-topik B]:** [Detail singkat]";
      todoInstruction = '"todos": [],'; // Dikosongkan untuk Lecture
    
    } else {
      // PERSONAL VOICE NOTE (Idea)
      summaryFormat = "#### **The Core Thought**\\n* **[Gagasan Utama]:** [Deskripsikan inti pemikiran atau perasaan dari rekaman ini secara mendalam]\\n\\n#### **Brainstorming Branches**\\n* **[Eksplorasi Ide 1]:** [Pengembangan ide, pro/kontra, atau kemungkinan]\\n* **[Eksplorasi Ide 2]:** [Pengembangan ide lainnya]\\n\\n#### **Personal Reflections**\\n* **[Catatan Diri]:** [Wawasan pribadi, hambatan, atau motivasi yang tersirat]";
      todoInstruction = '"todos": [],'; // Dikosongkan untuk Idea
    }
    
    // REVISI 2: Memperbaiki struktur JSON Prompt agar tidak bentrok
    final prompt = '''
    Anda adalah asisten eksekutif AI profesional. DENGARKAN audio terlampir ini.
    Keluarkan HASIL HANYA dalam format JSON murni yang valid (tanpa ```json dan tanpa markdown bungkus lainnya).
    
    PENTING UNTUK SUMMARY (Gunakan Format Ini Persis di dalam string JSON "summary"):
    $summaryFormat

    KEMBALIKAN DALAM FORMAT JSON BERIKUT (Perhatikan tanda kutip dan koma):
    {
      "transcript": "[Speaker 1]: (teks obrolan)... \\n\\n[Speaker 2]: (teks obrolan)...",
      "summary_title": "Judul Spesifik Maksimal 6 Kata",
      "summary": "(MASUKKAN HASIL SUMMARY MARKDOWN ANDA KE SINI)",
      $todoInstruction
      "participant_list": ["Speaker 1", "Speaker 2"]
    }
    ''';

    try {
      // REVISI 3: Menggunakan MIME type dinamis atau audio umum (audio/mp4 mencakup m4a dan aac)
      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt), 
          DataPart('audio/mp4', audioBytes) 
        ])
      ]);
      
      // Membersihkan teks JSON dari Markdown (jika Gemini masih membandel)
      String rawText = (response.text ?? "{}").replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> parsedJson = jsonDecode(rawText);
      
      return {
        'transcript': parsedJson['transcript'] ?? "Tidak ada transkrip.",
        'summary': parsedJson['summary'] ?? "Tidak ada ringkasan.",
        'summary_title': parsedJson['summary_title'] ?? "Voice Note", 
        'todos': parsedJson['todos'] ?? [], 
        'participants': parsedJson['participant_list'] ?? [] 
      };
    } catch (e) {
      debugPrint("ERROR GEMINI API: $e"); // Debug print untuk melihat error asli di console
      return {
        'summary_title': "Gagal Diproses",
        'summary': "Gagal menganalisis audio. Error: $e", 
        'transcript': "Pastikan API Key valid dan koneksi internet stabil.", 
        'todos': [], 
        'participants': []
      };
    }
  }

  // FUNGSI CHATBOT (ASK ERGO)
  Future<String> askErgo(String question, String meetingContext) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return "Error: API Key tidak ditemukan. Harap periksa file .env";

    // Gunakan model yang sama
    final model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);

    final prompt = '''
    Anda adalah "Ergo", asisten eksekutif AI profesional tingkat tinggi.
    Tugas Anda adalah menjawab pertanyaan pengguna berdasarkan konteks rapat berikut.
    Jika jawaban TIDAK ADA di dalam konteks, katakan dengan sopan bahwa informasi tersebut tidak dibahas.
    Jawablah dengan ringkas, sangat natural, dan langsung ke intinya.

    KONTEKS RAPAT:
    $meetingContext

    PERTANYAAN PENGGUNA:
    $question
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "Maaf, saya tidak bisa merespons saat ini.";
    } catch (e) {
      return "Koneksi ke otak Ergo terputus: $e";
    }
  }
}