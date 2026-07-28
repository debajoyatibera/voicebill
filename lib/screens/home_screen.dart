import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/sale_entry.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../widgets/sale_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GeminiService _gemini;
  final SpeechService _speech = SpeechService();
  final StorageService _storage = StorageService();
  final FlutterTts _tts = FlutterTts();

  String _selectedLanguage = 'English (India)';
  bool _isListening = false;
  bool _isProcessing = false;
  String _liveTranscript = '';
  String? _errorMessage;

  List<SaleEntry> _sales = [];
  double _dailyTotal = 0;

  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _gemini = GeminiService();
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
      return;
    }

    setState(() {
      _errorMessage = null;
      _liveTranscript = '';
      _isListening = true;
    });

    final localeId = VoiceLocale.options[_selectedLanguage]!;

    await _speech.listen(
      localeId: localeId,
      onResult: (transcript, isFinal) async {
        setState(() => _liveTranscript = transcript);
        if (isFinal && transcript.trim().isNotEmpty) {
          setState(() => _isListening = false);
          await _handleTranscript(transcript);
        }
      },
    );
  }

  Future<void> _handleTranscript(String transcript) async {
    setState(() => _isProcessing = true);
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
            'internet connection and API key, then try again.';
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
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceBill'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              items: VoiceLocale.options.keys
                  .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedLanguage = v);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTotalCard(),
          if (_errorMessage != null) _buildErrorBanner(),
          if (_isListening || _liveTranscript.isNotEmpty) _buildLiveTranscript(),
          Expanded(
            child: _sales.isEmpty
                ? const Center(
                    child: Text(
                      'No sales yet today.\nTap the mic and speak a sale.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            heroTag: 'summary',
            onPressed: _speakSummary,
            label: const Text('Speak summary'),
            icon: const Icon(Icons.volume_up),
          ),
          FloatingActionButton.large(
            heroTag: 'mic',
            onPressed: _isProcessing ? null : _toggleListening,
            backgroundColor: _isListening ? Colors.red : null,
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(_isListening ? Icons.stop : Icons.mic),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          const Text("Today's Total", style: TextStyle(fontSize: 14)),
          Text(
            '₹${_dailyTotal.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          Text('${_sales.length} sale(s)', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 13))),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTranscript() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey.shade100,
      child: Text(
        _liveTranscript.isEmpty ? 'Listening...' : '"$_liveTranscript"',
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }
}
