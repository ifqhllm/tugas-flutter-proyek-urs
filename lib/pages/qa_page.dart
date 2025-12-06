import 'package:flutter/material.dart';
import '../services/qa_service.dart';
import '../constants/colors.dart';
import '../widgets/background_widget.dart';

class QAPage extends StatefulWidget {
  const QAPage({super.key});

  @override
  State<QAPage> createState() => _QAPageState();
}

class _QAPageState extends State<QAPage> {
  final QAService _qaService = QAService();
  final TextEditingController _questionController = TextEditingController();
  String _answer = '';
  bool _isLoading = false;

  void _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final answer = await _qaService.getAnswer(question);
      setState(() {
        _answer = answer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _answer = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  void _useSuggestedQuestion(String question) {
    _questionController.text = question;
    _askQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tanya Jawab Fiqih Haid',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF69B4),
        elevation: 4,
        centerTitle: true,
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tanyakan tentang Haid, Nifas, dan Istihadah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Ketik pertanyaan Anda...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: secondaryColor, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: primaryColor),
                      onPressed: _askQuestion,
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _askQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Tanyakan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                else if (_answer.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jawaban:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _answer,
                          style: const TextStyle(
                            fontSize: 16,
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                const Text(
                  'Pertanyaan Populer:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                ..._qaService.getSuggestedQuestions().map((question) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        question,
                        style: const TextStyle(color: textColor),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: primaryColor),
                      onTap: () => _useSuggestedQuestion(question),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
