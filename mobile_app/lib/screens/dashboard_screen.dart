import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/template_bottom_sheet.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key}); // <-- INI ADALAH KELAS YANG DICARI MAIN.DART

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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildListItem(
                      title: 'Q1 Marketing Strategy Alignment',
                      date: 'Oct 24 • 14:30',
                      duration: '00:45:12',
                      tagText: 'Business',
                      tagIcon: CupertinoIcons.briefcase_fill,
                      tagColor: Colors.green.shade600, 
                    ),
                    _buildDivider(),
                    _buildListItem(
                      title: 'Stanford CS224N - Lecture 1',
                      date: 'Oct 23 • 09:00',
                      duration: '01:15:30',
                      tagText: 'Lecture',
                      tagIcon: CupertinoIcons.book_fill,
                      tagColor: Colors.purple.shade600,
                    ),
                    _buildDivider(),
                    _buildListItem(
                      title: 'App Architecture Brainstorm',
                      date: 'Oct 22 • 21:15',
                      duration: '00:08:45',
                      tagText: 'Idea',
                      tagIcon: CupertinoIcons.lightbulb_fill,
                      tagColor: Colors.orange.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120), 
            ],
          ),
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

  Widget _buildListItem({
    required String title,
    required String date,
    required String duration,
    required String tagText,
    required IconData tagIcon,
    required Color tagColor,
  }) {
    return InkWell(
      onTap: () {},
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