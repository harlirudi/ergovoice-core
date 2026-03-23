import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Wajib untuk ikon & spinner Apple
import '../screens/workspace_screen.dart'; 

class TemplateBottomSheet extends StatelessWidget {
  const TemplateBottomSheet({super.key});

  void _showProcessingDialog(BuildContext context) {
    final navigator = Navigator.of(context);

    // 1. Tutup Bottom Sheet
    navigator.pop();

    // 2. Munculkan Pop-up Loading ala iOS (HUD Style)
    showDialog(
      context: context,
      barrierDismissible: false, 
      barrierColor: Colors.black.withValues(alpha: 0.2), // Latar belakang redup elegan
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), // Sudut melengkung iOS
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SPINNER KHAS APPLE
                CupertinoActivityIndicator(radius: 14), 
                SizedBox(height: 20),
                Text(
                  'Extracting Intelligence...',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 16, 
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    decoration: TextDecoration.none, // Wajib di dialog agar tidak ada garis bawah kuning
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gemini AI is analyzing your audio',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    color: Color(0xFF8E8E93), 
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    // 3. Simulasi jeda AI (3 detik)
    Future.delayed(const Duration(seconds: 3), () {
      navigator.pop(); // Tutup dialog loading
      
      // Buka Workspace Screen (Screen 3)
      navigator.push(
        MaterialPageRoute(builder: (context) => const WorkspaceScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // Latar Abu-abu sistem Apple
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle (Pil penarik khas iOS)
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFC7C7CC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'New Audio Detected.\nWhat is the context?',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              height: 1.2,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          // INSET GROUPED LIST: Satu blok putih besar menyatukan 3 opsi
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildTemplateOption(
                  context: context,
                  icon: CupertinoIcons.briefcase_fill,
                  title: 'Business Meeting',
                  subtitle: 'Outputs: Exec Summary & To-Do List',
                  color: Colors.green.shade600,
                ),
                _buildDivider(),
                _buildTemplateOption(
                  context: context,
                  icon: CupertinoIcons.book_fill,
                  title: 'Lecture/Seminar',
                  subtitle: 'Outputs: Key Learnings & Mind-map',
                  color: Colors.purple.shade600,
                ),
                _buildDivider(),
                _buildTemplateOption(
                  context: context,
                  icon: CupertinoIcons.lightbulb_fill,
                  title: 'Personal Voice Note',
                  subtitle: 'Outputs: Journal/Brainstorm style',
                  color: Colors.orange.shade600,
                ),
              ],
            ),
          ),
          // Ruang kosong ekstra di bawah (Safe Area)
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget Pemisah (Hairline Divider)
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 56.0), // Garis dimulai setelah ikon
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Color(0xFFE5E5EA),
      ),
    );
  }

  // Desain Opsi Template
  Widget _buildTemplateOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _showProcessingDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Ikon dikurung dalam kotak berukuran tetap
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(
                      fontFamily: 'SFPro',
                      fontWeight: FontWeight.w600, 
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: const TextStyle(
                      fontFamily: 'SFPro',
                      color: Color(0xFF8E8E93), 
                      fontSize: 13,
                    )
                  ),
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