import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quotes_app/components/quote_card.dart';
import 'package:quotes_app/models/quote.dart';
import 'package:quotes_app/services/auth_service.dart';
import 'package:quotes_app/services/gemini_service.dart';
import 'package:quotes_app/services/quote_service.dart';

class AIGeneratorPage extends StatefulWidget {
  const AIGeneratorPage({super.key});

  @override
  State<AIGeneratorPage> createState() => _AIGeneratorPageState();
}

class _AIGeneratorPageState extends State<AIGeneratorPage> {
  final GeminiService _geminiService = GeminiService();
  final QuoteService _quoteService = QuoteService();
  
  List<Quote> _generatedQuotes = [];
  String _selectedCategory = '';
  bool _isLoading = false;
  bool _hasGenerated = false;
  
  // List of available categories
  final List<String> _categories = [
    'Motivation',
    'Success',
    'Life',
    'Love',
    'Wisdom',
    'Happiness',
    'Friendship',
    'Leadership',
    'Growth',
    'Courage',
  ];

  Future<void> _generateQuotes() async {
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasGenerated = true;
    });

    try {
      final quotes = await _geminiService.generateQuotes(_selectedCategory);
      
      if (mounted) {
        setState(() {
          _generatedQuotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating quotes: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_categories[index]),
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _copyQuote(Quote quote) {
    final text = '"${quote.text}" - ${quote.author}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard')),
    );
  }

  Future<void> _bookmarkQuote(Quote quote) async {
    try {
      final userId = authService.currentUser!.id;
      await _quoteService.bookmarkQuote(quote, userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quote bookmarked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error bookmarking quote: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quote Generator'),
      ),
      body: Column(
        children: [
          // Category and Generate Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Category Selection
                OutlinedButton.icon(
                  onPressed: _showCategoryDialog,
                  icon: const Icon(Icons.category),
                  label: Text(
                    _selectedCategory.isEmpty
                        ? 'Choose Category'
                        : _selectedCategory,
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Generate Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateQuotes,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isLoading ? 'Generating...' : 'Generate Quotes',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          const Divider(),
          
          // Generated Quotes
          Expanded(
            child: !_hasGenerated
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a category and generate quotes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _generatedQuotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No quotes generated',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _generatedQuotes.length,
                            itemBuilder: (context, index) {
                              final quote = _generatedQuotes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '"${quote.text}"',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '- ${quote.author}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy),
                                            onPressed: () => _copyQuote(quote),
                                            tooltip: 'Copy Quote',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.bookmark_border),
                                            onPressed: () => _bookmarkQuote(quote),
                                            tooltip: 'Bookmark Quote',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
