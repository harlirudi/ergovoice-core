import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:provider/provider.dart'; 
import '../screens/workspace_screen.dart'; 
import '../providers/recording_provider.dart'; 

class TemplateBottomSheet extends StatelessWidget {
  // 1. TAMBAHAN PENERIMA DATA DARI DASHBOARD
  final String pendingAudioPath;
  final VoidCallback onSyncComplete;

  const TemplateBottomSheet({
    super.key,
    required this.pendingAudioPath,
    required this.onSyncComplete,
  });

  void _showProcessingDialog(BuildContext context, String selectedTemplate) async {
    final navigator = Navigator.of(context);
    final provider = context.read<RecordingProvider>(); 

    navigator.pop(); // Tutup Bottom Sheet

    // Munculkan Pop-up Loading ala iOS (HUD Style)
    showDialog(
      context: context,
      barrierDismissible: false, 
      barrierColor: Colors.black.withValues(alpha: 0.2), 
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), 
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))
              ]
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(radius: 14), 
                SizedBox(height: 20),
                Text('Extracting Intelligence...', style: TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black, decoration: TextDecoration.none)),
                SizedBox(height: 6),
                Text('Gemini AI is analyzing your audio', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13, decoration: TextDecoration.none))
              ],
            ),
          ),
        );
      },
    );

    // 2. MENGHUBUNGI OTAK AI (Sekarang membawa Audio Path asli dari antrean)
    await provider.syncWithPendant(selectedTemplate, audioPath: pendingAudioPath);

    // 3. LAPORKAN KE DASHBOARD BAHWA 1 AUDIO SUDAH SELESAI
    onSyncComplete();

    // 4. MENGAMBIL DATA HASIL AI
    final newRecord = provider.recordings.last; // Karena kita menggunakan `.reversed` di UI, data terbaru ada di index pertama (atau sesuai urutan Isar Anda)

    // Tutup loading dan pindah layar
    navigator.pop(); 
    
    navigator.push(
      MaterialPageRoute(
        builder: (context) => WorkspaceScreen(recording: newRecord),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(color: const Color(0xFFC7C7CC), borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          // REVISI UX Teks agar lebih relevan dengan antrean
          const Text(
            'Process New Audio',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 22, fontWeight: FontWeight.w900, height: 1.2, letterSpacing: -0.5, color: Colors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select context for the oldest recording in queue.',
            style: TextStyle(fontFamily: 'SFPro', fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildTemplateOption(context: context, icon: CupertinoIcons.briefcase_fill, title: 'Business Meeting', subtitle: 'Outputs: Insights, Outcomes & Action Items', color: Colors.green.shade600, templateName: 'Business'),
                _buildDivider(),
                _buildTemplateOption(context: context, icon: CupertinoIcons.book_fill, title: 'Lecture/Seminar', subtitle: 'Outputs: Key Learnings & Mind-map', color: Colors.purple.shade600, templateName: 'Lecture'),
                _buildDivider(),
                _buildTemplateOption(context: context, icon: CupertinoIcons.lightbulb_fill, title: 'Personal Voice Note', subtitle: 'Outputs: Journal/Brainstorm style', color: Colors.orange.shade600, templateName: 'Idea'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(padding: EdgeInsets.only(left: 56.0), child: Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)));
  }

  Widget _buildTemplateOption({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required String templateName}) {
    return InkWell(
      onTap: () => _showProcessingDialog(context, templateName),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 20, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }
}