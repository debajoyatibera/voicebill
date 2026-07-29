import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/sale_entry.dart';
import '../services/export_service.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../widgets/sale_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final GeminiService _gemini;
  final SpeechService _speech = SpeechService();
  final StorageService _storage = StorageService();
  final FlutterTts _tts = FlutterTts();

  String _selectedLanguage = 'English (India)';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _hasSubmittedTranscript = false;
  String _liveTranscript = '';
  String? _errorMessage;

  List<SaleEntry> _sales = [];
  double _dailyTotal = 0;

  final DateTime _today = DateTime.now();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _gemini = GeminiService();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await _storage.getSalesForDate(_today);
    final total = await _storage.getDailyTotal(_today);
    setState(() {
      _sales = sales;
      _dailyTotal = total;
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_liveTranscript.trim().isNotEmpty && !_hasSubmittedTranscript) {
        await _handleTranscript(_liveTranscript);
      }
      return;
    }

    setState(() {
      _errorMessage = null;
      _liveTranscript = '';
      _isListening = true;
      _hasSubmittedTranscript = false;
    });

    final localeId = VoiceLocale.options[_selectedLanguage]!;

    await _speech.listen(
      localeId: localeId,
      onResult: (transcript, isFinal) async {
        setState(() => _liveTranscript = transcript);
        if (isFinal &&
            transcript.trim().isNotEmpty &&
            !_hasSubmittedTranscript) {
          _hasSubmittedTranscript = true;
          setState(() => _isListening = false);
          await _handleTranscript(transcript);
        }
      },
    );
  }

  Future<void> _showTypeSaleDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.keyboard_rounded, color: Color(0xFF0083B0)),
            SizedBox(width: 8),
            Text(
              'Type or Paste Sale',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. "do chai, panch panch rupaye"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (val) {
            Navigator.pop(ctx);
            if (val.trim().isNotEmpty) {
              _handleTranscript(val);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.trim().isNotEmpty) {
                _handleTranscript(controller.text);
              }
            },
            child: const Text('Add Sale'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final reportText =
        ExportService.generateSummaryText(_sales, _dailyTotal, _today);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.share_rounded, color: Color(0xFF0083B0)),
                    SizedBox(width: 10),
                    Text(
                      'Share / Export Daily Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                reportText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success =
                          await ExportService.shareOnWhatsApp(reportText);
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Could not open WhatsApp. Try copying the report text instead.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await ExportService.downloadCsv(
                          _sales, _dailyTotal, _today);
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Could not download CSV. Check browser permissions.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 20),
                    label: const Text(
                      'CSV Excel',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: reportText));
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text(
                  'Copy Report Text',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTranscript(String transcript) async {
    if (_isProcessing) return;
    _hasSubmittedTranscript = true;
    setState(() {
      _isProcessing = true;
      _isListening = false;
    });
    try {
      final sale = await _gemini.parseTranscript(transcript);
      if (sale == null) {
        setState(() {
          _errorMessage =
              'Could not understand that as a sale. Try again, e.g. '
              '"do chai, panch panch rupaye".';
        });
      } else {
        await _storage.addSale(sale);
        await _loadSales();
        if (sale.confidence < 0.6) {
          setState(() {
            _errorMessage =
                'Added "${sale.item}" but I wasn\'t fully sure — please check it.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong talking to Gemini. Check your '
            'internet connection and try again.';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteSale(SaleEntry sale) async {
    await _storage.deleteSale(sale.id, _today);
    await _loadSales();
  }

  Future<void> _speakSummary() async {
    if (_sales.isEmpty) {
      await _tts.speak('No sales recorded yet today.');
      return;
    }

    final localeId = VoiceLocale.options[_selectedLanguage]!;
    await _tts.setLanguage(localeId.replaceAll('_', '-'));
    await _tts.setSpeechRate(0.45);

    final itemCounts = <String, double>{};
    for (final s in _sales) {
      itemCounts[s.item] = (itemCounts[s.item] ?? 0) + s.quantity;
    }

    final itemsText = itemCounts.entries
        .map((e) => '${e.value.toStringAsFixed(0)} ${e.key}')
        .join(', ');

    final summary = 'Today you sold: $itemsText. '
        'Total collection: ${_dailyTotal.toStringAsFixed(0)} rupees.';

    await _tts.speak(summary);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'VoiceBill',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              icon: const Icon(Icons.language_rounded,
                  size: 18, color: Color(0xFF0083B0)),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                fontSize: 13,
              ),
              items: VoiceLocale.options.keys
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedLanguage = v);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded,
                  size: 20, color: Color(0xFF25D366)),
              tooltip: 'Share / Export Daily Report',
              onPressed: _showExportDialog,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTotalCard(),
          if (_errorMessage != null) _buildErrorBanner(),
          if (_isListening || _liveTranscript.isNotEmpty)
            _buildLiveTranscript(),
          Expanded(
            child: _sales.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0083B0).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 40,
                            color: Color(0xFF0083B0),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No sales recorded today yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap the glowing mic & speak a sale naturally\ne.g., "do chai, panch panch rupaye"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 110),
                    itemCount: _sales.length,
                    itemBuilder: (context, i) => SaleCard(
                      sale: _sales[i],
                      onDelete: () => _deleteSale(_sales[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FloatingActionButton.extended(
                  heroTag: 'summary',
                  onPressed: _speakSummary,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0083B0),
                  elevation: 4,
                  label: const Text(
                    'Speak Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 'keyboard',
                  onPressed: _showTypeSaleDialog,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0083B0),
                  elevation: 4,
                  tooltip: 'Type or paste sale',
                  child: const Icon(Icons.keyboard_rounded),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF416C).withValues(
                                  alpha: 0.3 + 0.3 * _pulseController.value),
                              blurRadius: 20,
                              spreadRadius: 8 * _pulseController.value,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color:
                                  const Color(0xFF0083B0).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: FloatingActionButton.large(
                    heroTag: 'mic',
                    onPressed: _isProcessing ? null : _toggleListening,
                    backgroundColor: _isListening
                        ? const Color(0xFFFF416C)
                        : const Color(0xFF0083B0),
                    child: _isProcessing
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3)
                        : Icon(
                            _isListening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF1A365D), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: Color(0xFF60A5FA), size: 16),
                    SizedBox(width: 6),
                    Text(
                      "TODAY'S COLLECTION",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_sales.length} sale(s)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '₹${_dailyTotal.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 22, color: Color(0xFFEA580C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF9A3412),
                  fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: Color(0xFFEA580C)),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTranscript() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.spatial_audio_rounded,
              color: Color(0xFF0083B0), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _liveTranscript.isEmpty
                  ? 'Listening for speech...'
                  : '"$_liveTranscript"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
