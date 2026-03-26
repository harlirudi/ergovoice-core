// lib/screens/dashboard_screen.dart

import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/recording.dart';
import '../providers/recording_provider.dart';
import '../widgets/template_bottom_sheet.dart';
import 'workspace_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  final List<String> pendingRecordings = [];
  
  // 1. TAMBAHAN MESIN PENCARI
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose(); // Wajib dibuang agar tidak memory leak
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleHardwareSimulator() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          pendingRecordings.add(path); 
        });
      }
    } else {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/ergo_sim_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: filePath);
        setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin mikrofon dibutuhkan untuk simulasi hardware.', style: TextStyle(fontFamily: 'SFPro'))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      // MENGHILANGKAN FOKUS KEYBOARD JIKA LAYAR DISENTUH (iOS Standard)
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // APP BAR BISA IKUT TERSCROLL ATAU TETAP
                SliverAppBar(
                  backgroundColor: const Color(0xFFF2F2F7),
                  elevation: 0,
                  pinned: true,
                  title: const Text('ErgoVoice', style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black, letterSpacing: -0.5)),
                  actions: [
                    HardwareSimulatorButton(isRecording: _isRecording, onTap: _toggleHardwareSimulator),
                    const SizedBox(width: 4), 
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.bluetooth, color: Color(0xFF8E8E93), size: 16),
                          SizedBox(width: 4),
                          Text('85%', style: TextStyle(fontFamily: 'SFPro', color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. REVISI SEARCH BAR (Vertical Alignment & rational lookup)
                        Container(
                          height: 36, // Native iOS UISearchBar height
                          decoration: BoxDecoration(
                            color: const Color(0xFF767680).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10), // Native iOS radius (Bukan Pill)
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: const TextStyle(fontFamily: 'SFPro', fontSize: 17),
                            decoration: const InputDecoration(
                              hintText: 'Search', 
                              hintStyle: TextStyle(fontFamily: 'SFPro', color: Color(0xFF3C3C43), fontSize: 17),
                              prefixIcon: Icon(CupertinoIcons.search, color: Color(0xFF3C3C43), size: 20),
                              border: InputBorder.none, 
                              // REVISI UX: contentPadding vertikal diseimbangkan agar teks sejajar di tengah
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Consumer<RecordingProvider>(
                          builder: (context, provider, child) {
                            // 3. LOGIKA FILTERING (MESIN PENCARI)
                            List<Recording> displayedRecordings = provider.recordings;
                            
                            if (_searchQuery.isNotEmpty) {
                              displayedRecordings = displayedRecordings.where((record) {
                                return (record.title ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                              }).toList();
                            }

                            // KONDISI KOSONG (REVISI: Centered horizontally untuk empty state)
                            if (displayedRecordings.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 60.0),
                                child: Center( // REVISI: Menggunakan Center untuk mengpusatkan empty state
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_searchQuery.isNotEmpty ? CupertinoIcons.search : CupertinoIcons.mic, size: 56, color: const Color(0xFFC7C7CC)),
                                      const SizedBox(height: 16),
                                      Text(_searchQuery.isNotEmpty ? 'No Results Found' : 'No Recordings', style: const TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                                      const SizedBox(height: 8),
                                      Text(_searchQuery.isNotEmpty ? 'Coba kata kunci pencarian lain.' : 'Tekan ikon Mic di atas\nuntuk merekam rapat Anda.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'SFPro', color: const Color(0xFF8E8E93), fontSize: 15)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // JIKA ADA ISI: Tampilkan Teks Recent Meetings dan Kotak Daftar Rapat
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, bottom: 8),
                                  child: Text('RECENT MEETINGS', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
                                ),
                                Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    // Gunakan list yang sudah di-filter
                                    children: displayedRecordings.reversed.map((record) {
                                      String type = record.templateType ?? 'General';
                                      IconData icon = type == 'Business' ? CupertinoIcons.briefcase_fill : (type == 'Lecture' ? CupertinoIcons.book_fill : CupertinoIcons.lightbulb_fill);
                                      Color color = type == 'Business' ? Colors.green.shade600 : (type == 'Lecture' ? Colors.purple.shade600 : Colors.orange.shade600);

                                      return Column(
                                        children: [
                                          Dismissible(
                                            key: Key(record.id.toString()),
                                            direction: DismissDirection.endToStart,
                                            background: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20.0),
                                                color: CupertinoColors.destructiveRed,
                                                child: const Icon(CupertinoIcons.trash_fill, color: Colors.white),
                                              ),
                                            ),
                                            onDismissed: (direction) => provider.deleteRecording(record.id),
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
                                          // Jangan beri garis pada item terakhir dari list
                                          if (record != displayedRecordings.first) _buildDivider(),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 120), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // TOMBOL PROCESS AUDIO (DENGAN BADGE NOTIFIKASI)
            Positioned(
              bottom: 32, left: 0, right: 0,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), 
                        child: InkWell(
                          onTap: () {
                            if (pendingRecordings.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada audio baru di Hardware.', style: TextStyle(fontFamily: 'SFPro'))));
                              return;
                            }
                            showModalBottomSheet(
                              context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
                              builder: (context) => TemplateBottomSheet(
                                pendingAudioPath: pendingRecordings.first, 
                                onSyncComplete: () {
                                  if (mounted) {
                                    setState(() => pendingRecordings.removeAt(0));
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white, size: 20), SizedBox(width: 8),
                                Text('Process Audio', style: TextStyle(fontFamily: 'SFPro', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.3)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    if (pendingRecordings.isNotEmpty)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: CupertinoColors.destructiveRed, shape: BoxShape.circle),
                          child: Text('${pendingRecordings.length}', style: const TextStyle(fontFamily: 'SFPro', color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(padding: EdgeInsets.only(left: 16.0), child: Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)));
  }

  Widget _buildListItem({required BuildContext context, required Recording record, required String title, required String date, required String duration, required String tagText, required IconData tagIcon, required Color tagColor}) {
    return InkWell(
      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => WorkspaceScreen(recording: record))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: -0.3), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(date, style: const TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w400)), const SizedBox(width: 8),
                      Text(duration, style: const TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 16, child: Center(child: Icon(tagIcon, color: tagColor, size: 14))), const SizedBox(width: 4),
                  Text(tagText, style: TextStyle(fontFamily: 'SFPro', color: tagColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.chevron_right, color: Color(0xFFC7C7CC), size: 20),
          ],
        ),
      ),
    );
  }
}

class HardwareSimulatorButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  const HardwareSimulatorButton({super.key, required this.isRecording, required this.onTap});
  @override
  State<HardwareSimulatorButton> createState() => _HardwareSimulatorButtonState();
}

class _HardwareSimulatorButtonState extends State<HardwareSimulatorButton> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HardwareSimulatorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _recordDuration = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (mounted) setState(() => _recordDuration++);
      });
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: widget.isRecording ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6) : const EdgeInsets.symmetric(horizontal: 8, vertical: 6), 
        decoration: BoxDecoration(
          color: widget.isRecording ? CupertinoColors.destructiveRed.withValues(alpha: 0.1) : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.isRecording ? CupertinoColors.destructiveRed.withValues(alpha: 0.4) : Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isRecording && _pulseController != null)
              FadeTransition(opacity: _pulseController!, child: const Icon(CupertinoIcons.mic_fill, color: CupertinoColors.destructiveRed, size: 16))
            else
              const Icon(CupertinoIcons.mic, color: Color(0xFF8E8E93), size: 16),
            
            if (widget.isRecording) ...[
              const SizedBox(width: 4),
              Text(_formatDuration(_recordDuration), style: const TextStyle(fontFamily: 'SFPro', color: CupertinoColors.destructiveRed, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}