import '../services/gemini_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart'; 
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; 
import '../models/recording.dart'; 
import '../providers/recording_provider.dart'; 
import 'package:flutter_markdown/flutter_markdown.dart'; 

class WorkspaceScreen extends StatefulWidget {
  final Recording recording; 

  const WorkspaceScreen({super.key, required this.recording});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _selectedTab = 0;
  bool _isShowingActionSheet = false; 

  // --- MULAI: MESIN AUDIO PLAYER ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackRate = 1.0;

  // VARIABEL BARU: Untuk melacak status mengetik
  bool _isUserTyping = false;
  
  
  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    
    // --- MULAI: CHAT UX LISTENERBergaya iMessage ala liquid-glass-philosophy.md Interaction ---
    _chatController.addListener(() {
      setState(() {
        _isUserTyping = _chatController.text.isNotEmpty;
      });
    });
    // --- SELESAI: CHAT UX LISTENER ---
  }

  Future<void> _setupAudioPlayer() async {
    // 1. Dengarkan status Play/Pause
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    
    // 2. Dapatkan total durasi audio
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() => _duration = newDuration);
      }
    });
    
    // 3. Dengarkan pergerakan waktu (Progress Bar)
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() => _position = newPosition);
      }
    });
    
    // 4. Jika audio selesai, kembalikan ke awal
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    // 5. Masukkan "Kaset" Audio (Untuk MVP kita pakai file simulasi)
    // Pastikan Anda memiliki file testing_rapat.mp3 di folder assets Anda.
    if (widget.recording.filePath != null && widget.recording.filePath!.isNotEmpty) {
      await _audioPlayer.setSource(DeviceFileSource(widget.recording.filePath!));
    } else {
      await _audioPlayer.setSource(AssetSource('audio/testing_rapat.mp3'));
    }
  }

  // FUNGSI BARU: Siklus Kecepatan Audio
  void _togglePlaybackRate() {
    setState(() {
      if (_playbackRate == 1.0) {
        _playbackRate = 1.5;
      } else if (_playbackRate == 1.5) {
        _playbackRate = 2.0;
      } else if (_playbackRate == 2.0) {
        _playbackRate = 0.5;
      } else {
        _playbackRate = 1.0;
      }
    });
    _audioPlayer.setPlaybackRate(_playbackRate);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // WAJIB: Matikan mesin saat keluar layar agar tidak bocor memori
    super.dispose();
  }

  // Fungsi pengubah angka milidetik menjadi format Apple "00:00"
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  // --- SELESAI: MESIN AUDIO PLAYER ---

  // --- MULAI: MEMORI ASK ERGO CHAT ---
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isErgoTyping = false;

  Future<void> _handleSendMessage(String contextData) async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    // 1. Masukkan pesan user ke layar
    setState(() {
      _chatMessages.add({'role': 'user', 'text': text});
      _isErgoTyping = true;
    });
    _chatController.clear();
    _scrollToBottom();

    // 2. Kirim ke Gemini
    final gemini = GeminiService();
    final response = await gemini.askErgo(text, contextData);

    // 3. Tampilkan balasan Ergo
    if (mounted) {
      setState(() {
        _chatMessages.add({'role': 'ai', 'text': response});
        _isErgoTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  // --- SELESAI: MEMORI ASK ERGO CHAT ---

  // FUNGSI BARU: Dynamic Share - Membedakan apa yang dishare berdasarkan tab yang aktif (Interaction mastery ala design-awards.md)
  void _executeSmartShare(BuildContext context, Recording record) {
    String shareTitle = "Share";
    String shareContent = "";
    String shareMessagePrompt = "Share your meeting insights.";

    // 1. Tentukan konten berdasarkan Tab Aktif
    if (_selectedTab == 0) {
      shareTitle = "Share Summary";
      shareMessagePrompt = "Share ErgoVoice insights directly.";
      // Template teks profesional dengan branding ala liquid-glass-philosophy.md Emotion
      shareContent = '''
ErgoVoice Sync Summary 
"${record.title ?? 'Meeting Notes'}"
Date: ${record.date != null ? "${record.date!.day}/${record.date!.month}/${record.date!.year}" : "Today"}

Summary:
--------------------------------
${record.summary ?? 'AI gagal membuat ringkasan...'}
--------------------------------

"I hope you can be productive!"
Powered by ErgoVoice - Focus on human connection, let Ergo do the work.
''';
    } else {
      shareTitle = "Share Transcript";
      shareMessagePrompt = "Share ErgoVoice raw dialogue.";
      // Template transkrip murni
      shareContent = '''
ErgoVoice Raw Transcript 
"${record.title ?? 'Meeting Notes'}"
Date: ${record.date != null ? "${record.date!.day}/${record.date!.month}/${record.date!.year}" : "Today"}

Transcript:
--------------------------------
${record.transcript ?? 'Tidak ada data transkrip.'}
--------------------------------

"Hope you find this detailed context useful!"
Powered by ErgoVoice.
''';
    }

    // APPLE PARADIGM: Tetap gunakan Action Sheet untuk menu pilihandari HIG
    setState(() => _isShowingActionSheet = true); 
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(shareTitle, style: const TextStyle(fontFamily: 'SFPro')),
        message: Text(shareMessagePrompt, style: const TextStyle(fontFamily: 'SFPro')),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              if(mounted) setState(() => _isShowingActionSheet = false);
              Navigator.pop(context);
              // ignore: deprecated_member_use
              Share.share(shareContent);
            },
            // MENGGUNAKAN HEX COLOR APPLE SYSTEM BLUE MURNI
            child: const Text('Share Text', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF007AFF))),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            if(mounted) setState(() => _isShowingActionSheet = false);
            Navigator.pop(context);
          },
          // MENGGUNAKAN HEX COLOR APPLE SYSTEM BLUE MURNI
          child: const Text('Cancel', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF007AFF), fontWeight: FontWeight.w600)),
        ),
      ),
    ).then((_) {
      if (mounted && _isShowingActionSheet) {
        setState(() => _isShowingActionSheet = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData tagIcon = CupertinoIcons.doc_text_fill;
    Color tagColor = Colors.blue.shade600;
    String type = widget.recording.templateType ?? 'General';

    if (type == 'Business') { tagIcon = CupertinoIcons.briefcase_fill; tagColor = Colors.green.shade600; }
    else if (type == 'Lecture') { tagIcon = CupertinoIcons.book_fill; tagColor = Colors.purple.shade600; }
    else if (type == 'Idea') { tagIcon = CupertinoIcons.lightbulb_fill; tagColor = Colors.orange.shade600; }

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9), elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(icon: const Icon(CupertinoIcons.chevron_back, color: Colors.black, size: 24), onPressed: () => Navigator.pop(context)),
        // REVISI APP BAR: Duo Ikon Share Dinamis & Ellipsis (HIG Layout ala hig-layout.md Element Positioning)
        actions: [
          // 1. TOMBOL SHARE (HANYA SHARE TEXT)
          IconButton(
            icon: const Icon(CupertinoIcons.share, color: Colors.black, size: 22),
            onPressed: () {
              final provider = context.read<RecordingProvider>();
              final currentRecord = provider.recordings.firstWhere(
                (r) => r.id == widget.recording.id, 
                orElse: () => widget.recording
              );
              _executeSmartShare(context, currentRecord);
            },
          ),
          
          // 2. TOMBOL ELLIPSIS (DELETE)
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis_circle, color: Colors.black, size: 22),
            onPressed: () {
              setState(() => _isShowingActionSheet = true); 

              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  title: const Text('Meeting Options', style: TextStyle(fontFamily: 'SFPro')),
                  actions: <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                      isDestructiveAction: true, 
                      onPressed: () {
                        if(mounted) setState(() => _isShowingActionSheet = false);
                        Navigator.pop(context); 
                        context.read<RecordingProvider>().deleteRecording(widget.recording.id);
                        Navigator.pop(context); 
                      },
                      child: const Text('Delete Recording', style: TextStyle(fontFamily: 'SFPro')),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    isDefaultAction: true,
                    onPressed: () {
                      if(mounted) setState(() => _isShowingActionSheet = false);
                      Navigator.pop(context);
                    },
                    // MENGGUNAKAN HEX COLOR APPLE SYSTEM BLUE MURNI
                    child: const Text('Cancel', style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF007AFF), fontWeight: FontWeight.w600)),
                  ),
                ),
              ).then((_) {
                if (mounted && _isShowingActionSheet) {
                  setState(() => _isShowingActionSheet = false);
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: Consumer<RecordingProvider>(
        builder: (context, provider, child) {
          final currentRecord = provider.recordings.firstWhere(
            (r) => r.id == widget.recording.id, 
            orElse: () => widget.recording
          );

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER METADATA ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // INLINE EDITING: Ketuk judul untuk mengubah nama
                        GestureDetector(
                          onTap: () {
                            final TextEditingController titleController = TextEditingController(text: currentRecord.title);
                            showCupertinoDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text('Rename Meeting', style: TextStyle(fontFamily: 'SFPro')),
                                  content: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: CupertinoTextField(
                                      controller: titleController,
                                      style: const TextStyle(fontFamily: 'SFPro'),
                                      autofocus: true,
                                      textCapitalization: TextCapitalization.words,
                                    ),
                                  ),
                                  actions: [
                                    CupertinoDialogAction(child: const Text('Cancel', style: TextStyle(fontFamily: 'SFPro', color: CupertinoColors.activeBlue)), onPressed: () => Navigator.pop(context)),
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: const Text('Save', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue)),
                                      onPressed: () {
                                        provider.updateRecordingTitle(currentRecord.id, titleController.text);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            currentRecord.title ?? 'Meeting Notes', 
                            style: const TextStyle(fontFamily: 'SFPro', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5, height: 1.2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.calendar, size: 14, color: Color(0xFF8E8E93)), const SizedBox(width: 4), Text(currentRecord.date != null ? "${currentRecord.date!.day}/${currentRecord.date!.month}/${currentRecord.date!.year}" : "Hari ini", style: const TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13)),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("•", style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 14))),
                            const Icon(CupertinoIcons.location_solid, size: 14, color: Color(0xFF8E8E93)), const SizedBox(width: 4), const Text("Bandung", style: TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93), fontSize: 13)),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("•", style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 14))),
                            Icon(tagIcon, size: 14, color: tagColor), const SizedBox(width: 4), Text(type, style: TextStyle(fontFamily: 'SFPro', color: tagColor, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        // Participants (Tampilkan inisial saja ala request UX - but editable name)
                        if (currentRecord.participantNames != null && currentRecord.participantNames!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.person_3_fill, size: 16, color: Color(0xFF8E8E93)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  spacing: 8.0, runSpacing: 8.0,
                                  children: List.generate(currentRecord.participantNames!.length, (index) {
                                    final name = currentRecord.participantNames![index];
                                    // Membuat inventasi nama singkat (HW)
                                    String shortName = "S${index + 1}";
                                    if (!name.toLowerCase().startsWith("speaker")) {
                                    shortName = name; 
                                    }
                                    // INLINE EDITING: Ketuk Chip untuk ubah nama
                                    return InkWell(
                                      onTap: () {
                                        final TextEditingController editController = TextEditingController(text: name);
                                        showCupertinoDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              title: const Text('Rename Participant', style: TextStyle(fontFamily: 'SFPro')),
                                              content: Padding(
                                                padding: const EdgeInsets.only(top: 12.0),
                                                child: CupertinoTextField(
                                                  controller: editController,
                                                  placeholder: 'Enter actual name...',
                                                  style: const TextStyle(fontFamily: 'SFPro'),
                                                  autofocus: true,
                                                  clearButtonMode: OverlayVisibilityMode.editing,
                                                  textCapitalization: TextCapitalization.words,
                                                ),
                                              ),
                                              actions: [
                                                CupertinoDialogAction(child: const Text('Cancel', style: TextStyle(fontFamily: 'SFPro', color: CupertinoColors.activeBlue)), onPressed: () => Navigator.pop(context)),
                                                CupertinoDialogAction(
                                                  isDefaultAction: true,
                                                  child: const Text('Save', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue)),
                                                  onPressed: () {
                                                    provider.updateParticipantName(currentRecord.id, index, editController.text);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5EA))),
                                        child: Text(shortName, style: TextStyle(fontFamily: 'SFPro', color: Colors.blue.shade700, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5),),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- SEGMENTED CONTROL ---
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedTab, thumbColor: Colors.white, backgroundColor: const Color(0xFFE5E5EA), 
                        children: const {
                          0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Summary', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 14))),
                          1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Transcript', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 14))),
                          2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Ask Ergo', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, fontSize: 14))),
                        },
                        onValueChanged: (value) { if (value != null) setState(() => _selectedTab = value); },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: IndexedStack(
                      index: _selectedTab, 
                      children: [
                        // REVISI: Tambahkan context di sini agar To-Do bisa diklik
                        _buildSummaryTab(context, currentRecord), 
                        _buildTranscriptTab(currentRecord), 
                        _buildAskErgoTab(currentRecord)
                      ],
                    ),
                  ),
                ],
              ),

              // Mini Player Bawah (Liquid Glass ala request UX)
              // REVISI LOGIKA: Sembunyikan mini player jika Action Sheet sedang terbuka (Aesthetic polish ala hig-materials.md materials thickness)
              if (!_isShowingActionSheet && MediaQuery.of(context).viewInsets.bottom == 0)
                Positioned(
                  bottom: 32, left: 16, right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5)),
                        // UI MINI PLAYER YANG SUDAH HIDUP
                        child: Row(
                          children: [
                            // 1. TOMBOL PLAY/PAUSE INTERAKTIF
                            GestureDetector(
                              onTap: () {
                                if (_isPlaying) {
                                  _audioPlayer.pause();
                                } else {
                                  _audioPlayer.resume();
                                }
                              },
                              child: Icon(
                                _isPlaying ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill, 
                                color: Colors.white, 
                                size: 36
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // 2. PROGRESS BAR & WAKTU (SCRUBBING)
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 16, 
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        overlayShape: SliderComponentShape.noOverlay,
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                                        thumbColor: Colors.white,
                                      ),
                                      child: Slider(
                                        value: (_duration.inMilliseconds > 0 && _position.inMilliseconds <= _duration.inMilliseconds)
                                            ? _position.inMilliseconds.toDouble()
                                            : 0.0,
                                        min: 0.0,
                                        max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                                        onChanged: (value) {
                                          final newPosition = Duration(milliseconds: value.toInt());
                                          _audioPlayer.seek(newPosition);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                    children: [
                                      Text(_formatDuration(_position), style: TextStyle(fontFamily: 'SFPro', fontSize: 11, color: Colors.white.withValues(alpha: 0.7))), 
                                      Text("-${_formatDuration(_duration - _position)}", style: TextStyle(fontFamily: 'SFPro', fontSize: 11, color: Colors.white.withValues(alpha: 0.7)))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // 3. TOMBOL KECEPATAN (TUNGGAL & INTERAKTIF)
                            GestureDetector(
                              onTap: _togglePlaybackRate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), 
                                child: Text('${_playbackRate.toStringAsFixed(_playbackRate == 1.0 ? 0 : 1)}x', style: const TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13))
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  // REVISI: Menambahkan BuildContext dan MENGEMBALIKAN UI CHECKBOX TO-DO
  Widget _buildSummaryTab(BuildContext context, Recording currentRecord) {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
      children: [
        MarkdownBody(
          data: currentRecord.summary ?? 'AI gagal membuat ringkasan...',
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontFamily: 'SFPro', fontSize: 16, height: 1.6, fontWeight: FontWeight.w400, color: Color(0xFF1C1C1E)),
            strong: const TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w800, color: Colors.black),
            blockSpacing: 16,
            listBullet: const TextStyle(fontSize: 16, color: Colors.black, height: 1.6),
            h3: const TextStyle(fontFamily: 'SFPro', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black), 
            h4: const TextStyle(fontFamily: 'SFPro', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black, height: 1.6), 
          ),
        ),

        // --- TEMBOK BESI UI: HANYA RENDER JIKA TEMPLATE = BUSINESS ---
        if (currentRecord.templateType == 'Business' && currentRecord.actionItems != null && currentRecord.actionItems!.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Action Items', style: TextStyle(fontFamily: 'SFPro', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 16),
          ...List.generate(currentRecord.actionItems!.length, (index) {
            final item = currentRecord.actionItems![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: InkWell(
                onTap: () {
                  // Memanggil fungsi centang ke Provider
                  context.read<RecordingProvider>().toggleTodo(currentRecord.id, index, !item.isDone);
                },
                splashColor: Colors.transparent, highlightColor: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.isDone ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, 
                      color: item.isDone ? const Color(0xFFC7C7CC) : Colors.blue.shade600, 
                      size: 24
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          item.text ?? '',
                          style: TextStyle(
                            fontFamily: 'SFPro', fontSize: 16, height: 1.4,
                            color: item.isDone ? const Color(0xFF8E8E93) : Colors.black,
                            decoration: item.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ]
      ],
    );
  }

  Widget _buildTranscriptTab(Recording currentRecord) {
    String displayTranscript = currentRecord.transcript ?? 'Tidak ada data transkrip.';
    if (currentRecord.participantNames != null) {
      for (int i = 0; i < currentRecord.participantNames!.length; i++) {
        String originalLabel = "Speaker ${i + 1}";
        String newName = currentRecord.participantNames![i];
        displayTranscript = displayTranscript.replaceAll('[$originalLabel]', '**$newName**');
        displayTranscript = displayTranscript.replaceAll(originalLabel, '**$newName**'); 
      }
    }
    return ListView(padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120), children: [MarkdownBody(data: displayTranscript, styleSheet: MarkdownStyleSheet(p: const TextStyle(fontFamily: 'SFPro', fontSize: 16, height: 1.6, fontWeight: FontWeight.w400, color: Color(0xFF1C1C1E)), strong: const TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w800, color: Colors.blue), blockSpacing: 16),)],);
  }

 // REVISI Master: UI Chatbot iMessage Natural, Dinamis, & Profesional Bergaya Master HIG
  Widget _buildAskErgoTab(Recording currentRecord) {
    String displayTranscript = currentRecord.transcript ?? 'Tidak ada data transkrip.';
    if (currentRecord.participantNames != null) {
      for (int i = 0; i < currentRecord.participantNames!.length; i++) {
        displayTranscript = displayTranscript.replaceAll('[Speaker ${i + 1}]', currentRecord.participantNames![i]);
        displayTranscript = displayTranscript.replaceAll('Speaker ${i + 1}', currentRecord.participantNames![i]); 
      }
    }
    String contextData = "Judul: ${currentRecord.title}\nRingkasan:\n${currentRecord.summary}\nTranskrip dengan Nama Asli:\n$displayTranscript";

    // REVISI UX 1: Tap-to-Dismiss
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent, 
      child: Column(
        children: [
          // 1. AREA PESAN CHAT (Natural & Spacing Alami)
          Expanded(
            child: _chatMessages.isEmpty
                ? const SizedBox.shrink() 
                // REVISI UX 2: Pengganti 'keyboardDismissMode' yang kebal Error
                : NotificationListener<UserScrollNotification>(
                    onNotification: (notification) {
                      // Menutup keyboard seketika saat pengguna mulai menggulir obrolan
                      FocusScope.of(context).unfocus();
                      return false; // Biarkan scroll tetap berjalan natural
                    },
                    child: ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
                      itemCount: _chatMessages.length + (_isErgoTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        final isErgoTypingPlaceholder = (index == _chatMessages.length);
                        final msg = isErgoTypingPlaceholder ? {'role': 'ai', 'text': 'Ergo is typing...'} : _chatMessages[index];
                        
                        final isUser = msg['role'] == 'user' || msg['sender'] == 'user'; 
                        final color = isUser ? CupertinoColors.activeBlue : const Color(0xFFE9E9EB); 

                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                            
                            // Implementasi Asymmetrical Radius (CONCAVE STYLE)
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              msg['text'] ?? msg['message'] ?? '',
                              style: TextStyle(fontFamily: 'SFPro', fontSize: 16, height: 1.3, fontWeight: FontWeight.w400, color: isUser ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // 2. KOLOM INPUT CHAT Master Bergaya iOS Sempurna
          Container(
            margin: EdgeInsets.only(
              left: 20, 
              right: 20, 
              bottom: 85 + MediaQuery.of(context).padding.bottom, 
            ), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Container(
                  height: 38, width: 38,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey5, shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.plus, color: Color(0xFF8E8E93), size: 24), 
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E5EA))),
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(fontFamily: 'SFPro', fontSize: 16),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSendMessage(contextData), 
                      decoration: InputDecoration(
                        hintText: 'Ask Ergo', 
                        hintStyle: const TextStyle(fontFamily: 'SFPro', color: Color(0xFF8E8E93)),
                        border: InputBorder.none, 
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), 
                        
                        suffixIcon: GestureDetector(
                          onTap: _isUserTyping ? () => _handleSendMessage(contextData) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Icon(
                              _isUserTyping ? CupertinoIcons.arrow_up_circle_fill : CupertinoIcons.mic, 
                              color: _isUserTyping ? CupertinoColors.activeBlue : CupertinoColors.systemGrey, 
                              size: _isUserTyping ? 30 : 26,
                            ),
                          ),
                        )
                      )
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

