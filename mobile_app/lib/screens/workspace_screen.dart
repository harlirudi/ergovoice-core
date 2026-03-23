import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  // Variabel ini sekarang pasti terpanggil di bawah
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9), 
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.share, color: Colors.black, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Q1 Marketing Strategy Alignment',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.calendar, size: 14, color: Color(0xFF8E8E93)),
                        const SizedBox(width: 4),
                        const Text(
                          'Oct 24, 2026',
                          style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Icon(CupertinoIcons.briefcase_fill, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Business',
                          style: TextStyle(fontFamily: 'SFPro', color: Colors.green.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _selectedTab, // <-- Di sini _selectedTab digunakan
                    thumbColor: Colors.white,
                    backgroundColor: const Color(0xFFE5E5EA), 
                    children: const {
                      0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Summary', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 14))),
                      1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Transcript', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 14))),
                      2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Ask Ergo', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 14))),
                    },
                    onValueChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTab = value); // <-- Di sini _selectedTab diubah
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: IndexedStack(
                  index: _selectedTab, // <-- Di sini _selectedTab digunakan lagi
                  children: [
                    _buildSummaryTab(),
                    _buildTranscriptTab(),
                    _buildAskErgoTab(),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.play_circle_fill, color: Colors.white, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.3, 
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('15:20', style: TextStyle(fontFamily: 'SFPro', fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                                Text('-29:52', style: TextStyle(fontFamily: 'SFPro', fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '1x', 
                          style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
      children: [
        const Text('Executive Summary', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
        const SizedBox(height: 12),
        const Text(
          'The Q1 marketing alignment meeting focused on redefining the target demographic for the new flagship product. The team agreed to shift budget allocation towards social media channels, specifically TikTok and Instagram Reels, to capture a younger audience.',
          style: TextStyle(fontFamily: 'SFPro', fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: Color(0xFF1C1C1E)),
        ),
        const SizedBox(height: 32),
        const Text('Action Items', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
        const SizedBox(height: 16),
        _buildChecklistItem('Draft new social media ad creatives (Sarah)', true),
        _buildChecklistItem('Re-allocate 20% of Google Ads budget to TikTok (John)', false),
        _buildChecklistItem('Schedule follow-up meeting with creative agency (Mark)', false),
      ],
    );
  }

  Widget _buildTranscriptTab() {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'SFPro', fontSize: 16, height: 1.6, fontWeight: FontWeight.w400, color: Color(0xFF1C1C1E)),
            children: [
              TextSpan(text: 'Sarah: ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
              TextSpan(text: 'Alright everyone, let\'s get started. The main agenda for today is our Q1 marketing alignment. John, do you want to kick things off?\n\n'),
              TextSpan(text: 'John: ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
              TextSpan(text: 'Sure. So, looking at the preliminary data from the soft launch, it seems we\'re not hitting the target demographic we anticipated...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAskErgoTab() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 180),
          children: const [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Ask a question about this meeting.\n(e.g., "What did Sarah say about the budget?")',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 110,
          left: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: const TextField(
              style: TextStyle(fontFamily: 'SFPro'),
              decoration: InputDecoration(
                hintText: 'Ask Ergo...',
                hintStyle: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                suffixIcon: Icon(CupertinoIcons.arrow_up_circle_fill, color: Colors.black, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isChecked ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, 
            size: 22, 
            color: isChecked ? Colors.black : const Color(0xFFC7C7CC),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: isChecked ? const Color(0xFF8E8E93) : const Color(0xFF1C1C1E), 
                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}