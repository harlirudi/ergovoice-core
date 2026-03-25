import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/template_bottom_sheet.dart';
import '../providers/recording_provider.dart';
import '../screens/workspace_screen.dart'; // WAJIB untuk navigasi klik

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'ErgoVoice',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.bluetooth, color: Colors.blue, size: 16), 
                SizedBox(width: 4),
                Text(
                  '85%', 
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    color: Colors.blue, 
                    fontWeight: FontWeight.w700, 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  style: TextStyle(fontFamily: 'SFPro'),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 16),
                    prefixIcon: Icon(CupertinoIcons.search, color: Color(0xFF8E8E93), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'RECENT MEETINGS',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              
              // AREA DAFTAR RAPAT
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<RecordingProvider>(
                  builder: (context, provider, child) {
                    if (provider.recordings.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "Belum ada rekaman rapat.\nTekan Sync Pendant untuk memulai.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93)),
                          ),
                        ),
                      );
                    }

                    return Column(
                      // Membalik urutan agar yang terbaru muncul paling atas
                      children: provider.recordings.reversed.map((record) {
                        IconData icon = CupertinoIcons.doc_text_fill;
                        Color color = Colors.blue.shade600;
                        String type = record.templateType ?? 'General';

                        if (type == 'Business') { icon = CupertinoIcons.briefcase_fill; color = Colors.green.shade600; }
                        else if (type == 'Lecture') { icon = CupertinoIcons.book_fill; color = Colors.purple.shade600; }
                        else if (type == 'Idea') { icon = CupertinoIcons.lightbulb_fill; color = Colors.orange.shade600; }

                        return Column(
                          children: [
                            // DIBUNGKUS DISMISSIBLE UNTUK SWIPE-TO-DELETE IOS
                            Dismissible(
                              key: Key(record.id.toString()),
                              direction: DismissDirection.endToStart,
                              // REVISI: Mengikuti lengkungan kartu (12pt) dan warna Destructive Red Apple
                              background: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  color: CupertinoColors.destructiveRed,
                                  child: const Icon(CupertinoIcons.trash_fill, color: Colors.white),
                                ),
                              ),
                              onDismissed: (direction) {
                                provider.deleteRecording(record.id);
                              },
                              child: _buildListItem(
                                context: context, 
                                record: record,   
                                title: record.title ?? "Tanpa Judul",
                                date: record.date != null ? "${record.date!.day}/${record.date!.month}/${record.date!.year}" : "Hari ini",
                                duration: record.duration ?? "00:00",
                                tagText: type,
                                tagIcon: icon,
                                tagColor: color,
                              ),
                            ),
                            if (record != provider.recordings.first) _buildDivider(),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 120), 
            ],
          ),
          
          // TOMBOL SYNC PENDANT (LIQUID GLASS)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), 
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const TemplateBottomSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sync Pendant',
                            style: TextStyle(
                              fontFamily: 'SFPro',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Color(0xFFE5E5EA),
      ),
    );
  }

  // FUNGSI LIST ITEM YANG SUDAH DILENGKAPI NAVIGASI KLIK
  Widget _buildListItem({
    required BuildContext context,
    required dynamic record,
    required String title,
    required String date,
    required String duration,
    required String tagText,
    required IconData tagIcon,
    required Color tagColor,
  }) {
    return InkWell(
      onTap: () {
        // Navigasi masuk kembali ke WorkspaceScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceScreen(recording: record),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontFamily: 'SFPro',
                          color: Color(0xFF8E8E93),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontFamily: 'SFPro',
                          color: Color(0xFF8E8E93),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16, 
                    child: Center(
                      child: Icon(tagIcon, color: tagColor, size: 14),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tagText,
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      color: tagColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Color(0xFFC7C7CC), 
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}