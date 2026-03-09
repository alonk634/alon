import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const VoiceKeyboardApp());
}

class VoiceKeyboardApp extends StatelessWidget {
  const VoiceKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Keyboard',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const VoiceKeyboardPage(),
    );
  }
}

class VoiceKeyboardPage extends StatefulWidget {
  const VoiceKeyboardPage({super.key});

  @override
  State<VoiceKeyboardPage> createState() => _VoiceKeyboardPageState();
}

class _VoiceKeyboardPageState extends State<VoiceKeyboardPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _controller = TextEditingController();

  bool _speechReady = false;
  bool _listening = false;
  String _status = 'Tap "Start Listening"';

  static const Map<String, String> _tokenMap = {
    // Letters
    'a': 'a',
    'b': 'b',
    'bee': 'b',
    'c': 'c',
    'cee': 'c',
    'd': 'd',
    'e': 'e',
    'f': 'f',
    'g': 'g',
    'h': 'h',
    'i': 'i',
    'j': 'j',
    'k': 'k',
    'l': 'l',
    'm': 'm',
    'n': 'n',
    'o': 'o',
    'p': 'p',
    'q': 'q',
    'r': 'r',
    's': 's',
    't': 't',
    'u': 'u',
    'v': 'v',
    'w': 'w',
    'x': 'x',
    'y': 'y',
    'z': 'z',

    // Digits
    'zero': '0',
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',

    // Punctuation
    'comma': ',',
    'period': '.',
    'dot': '.',
    'question': '?',
    'questionmark': '?',
    'exclamation': '!',
    'colon': ':',
    'semicolon': ';',
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ready = await _speech.initialize(
      onStatus: (value) => setState(() => _status = 'Status: $value'),
      onError: (error) => setState(() => _status = 'Error: ${error.errorMsg}'),
    );

    setState(() {
      _speechReady = ready;
      _status = ready ? 'Ready to listen' : 'Speech recognition unavailable';
    });
  }

  Future<void> _startListening() async {
    if (!_speechReady || _listening) return;

    setState(() {
      _listening = true;
      _status = 'Listening... speak commands one-by-one';
    });

    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isEmpty) return;
        _applyRecognizedText(result.recognizedWords);
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: false,
      cancelOnError: true,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _listening = false;
      _status = 'Stopped';
    });
  }

  void _applyRecognizedText(String recognized) {
    final normalized = recognized.toLowerCase().trim();
    if (normalized.isEmpty) return;

    final tokens = normalized
        .replaceAll('-', ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    var text = _controller.text;

    for (final rawToken in tokens) {
      final token = rawToken.replaceAll(RegExp(r'[^a-z0-9]'), '');

      if (token == 'space') {
        text += ' ';
        continue;
      }

      if (token == 'newline' || token == 'enter') {
        text += '\n';
        continue;
      }

      if (token == 'backspace') {
        if (text.isNotEmpty) {
          text = text.substring(0, text.length - 1);
        }
        continue;
      }

      final mapped = _tokenMap[token];
      if (mapped != null) {
        text += mapped;
      }
    }

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Keyboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_status),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Output',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _listening ? null : _startListening,
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Listening'),
                ),
                OutlinedButton.icon(
                  onPressed: _listening ? _stopListening : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                TextButton.icon(
                  onPressed: () => _controller.clear(),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
