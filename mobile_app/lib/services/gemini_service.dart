import 'dart:convert';
import 'dart:typed_data'; 
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  GeminiService();

  Future<Map<String, dynamic>> generateSummaryFromAudio(Uint8List audioBytes, String templateType) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 
    if (apiKey.isEmpty) return {};

    final model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);

    // LOGIKA PERCABANGAN PROMPT BERDASARKAN TEMPLATE
    String summaryFormat = "";
    String todoInstruction = "";
    
    if (templateType == 'Business') {
      summaryFormat = "#### **General Insights**\\n* **[Topik 1]:** [Wawasan 1]\\n* **[Topik 2]:** [Wawasan 2]\\n\\n#### **Key Outcomes**\\n* **[Keputusan]:** [Detail]\\n* **[Tindakan]:** [Detail]";
      todoInstruction = '"todos": ["Wajib diisi dengan tugas pertama dari rapat", "Wajib diisi dengan tugas kedua"], // PENTING: Anda WAJIB mengekstrak semua Action Items ke dalam array ini!';
    
    } else if (templateType == 'Lecture') {
      // MIT NOTE-TAKING STYLE & TYPOGRAPHIC MIND-MAP
      summaryFormat = "#### **Core Concepts (Main Ideas)**\\n* **[Konsep 1]:** [Definisi atau penjelasan komprehensif]\\n* **[Konsep 2]:** [Definisi atau penjelasan]\\n\\n#### **Cues & Anticipated Questions**\\n* **[Pertanyaan/Petunjuk]:** [Hal yang perlu ditanyakan di office hours atau dipelajari lebih lanjut]\\n\\n#### **Typographic Mind-Map**\\n* **[Topik Sentral]**\\n  * **[Sub-topik A]:** [Detail singkat]\\n    * [Fakta pendukung]\\n  * **[Sub-topik B]:** [Detail singkat]";
      todoInstruction = '"todos": [], // WAJIB KOSONGKAN ARRAY INI';
    
    } else {
      // PERSONAL VOICE NOTE (Journal / Brainstorm Style)
      summaryFormat = "#### **The Core Thought**\\n* **[Gagasan Utama]:** [Deskripsikan inti pemikiran atau perasaan dari rekaman ini secara mendalam]\\n\\n#### **Brainstorming Branches**\\n* **[Eksplorasi Ide 1]:** [Pengembangan ide, pro/kontra, atau kemungkinan]\\n* **[Eksplorasi Ide 2]:** [Pengembangan ide lainnya]\\n\\n#### **Personal Reflections**\\n* **[Catatan Diri]:** [Wawasan pribadi, hambatan, atau motivasi yang tersirat]";
      todoInstruction = '"todos": [], // WAJIB KOSONGKAN ARRAY INI';
    }
    

    final prompt = '''
    Anda adalah asisten eksekutif AI profesional tingkat tinggi. DENGARKAN audio ini.
    Keluarkan HASIL HANYA dalam format JSON murni (tanpa ```json).
    TANPA sapaan. TANPA emoji.

    PENTING UNTUK SUMMARY:
    Anda WAJIB menggunakan format markdown persis seperti cetak biru di bawah ini. Pertahankan struktur heading (####) dan hierarki peluru (*).
    
    CETAK BIRU FORMAT:
    $summaryFormat

    {
      "transcript": "[Speaker 1]: Teks... \\n\\n[Speaker 2]: Teks...",
      "summary_title": "Buat Judul Spesifik (Maks 6 Kata)",
      "summary": "MASUKKAN HASIL MARKDOWN ANDA BERDASARKAN CETAK BIRU DI ATAS KE SINI", $todoInstruction
      "todos": ["Tugas/Action Item 1", "Tugas/Action Item 2"],
      "participant_list": ["Speaker 1", "Speaker 2"]
    }
    ''';

    try {
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart('audio/mp3', audioBytes)])
      ]);
      String rawText = (response.text ?? "{}").replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> parsedJson = jsonDecode(rawText);
      return {
        'transcript': parsedJson['transcript'] ?? "Gagal mendapatkan transkrip.",
        'summary': parsedJson['summary'] ?? "Gagal mendapatkan ringkasan.",
        'summary_title': parsedJson['summary_title'] ?? "Sync: $templateType", 
        'todos': parsedJson['todos'] ?? [], 
        'participants': parsedJson['participant_list'] ?? [] 
      };
    } catch (e) {
      return {'summary': "Error AI: $e", 'transcript': "Error AI: $e", 'todos': [], 'participants': []};
    }
  }
}