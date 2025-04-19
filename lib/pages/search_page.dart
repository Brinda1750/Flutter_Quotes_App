import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quotes_app/components/quote_card.dart';
import 'package:quotes_app/models/quote.dart';
import 'package:uuid/uuid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Quote> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyARoHf2nsle8kkSnH45QjI-3g4_xpF4dog', // <-- Replace with your Gemini API Key
  );

  Future<void> _searchQuotes(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults.clear();
      _hasSearched = true;
    });

    try {
      final prompt = '''
Generate 10 inspirational quotes about "$query". 
Respond in JSON format like:
[
  {"text": "Your quote here", "author": "Author Name"},
  ...
]
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) {
        throw Exception('Empty response from Gemini.');
      }

      // Parse the response into JSON
      final parsedJson = text.trim().replaceAll('```json', '').replaceAll('```', '');
      final List<dynamic> quotesJson = List.from(jsonDecode(parsedJson));

      final List<Quote> quotes = quotesJson.map((json) {
        return Quote(
          id: const Uuid().v4(),
          text: json['text'],
          author: json['author'] ?? 'Unknown',
          category: query,
          isCustom: false,
        );
      }).toList();

      setState(() {
        _searchResults.addAll(quotes);
      });
    } catch (e) {
      setState(() {
        _searchResults.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Quotes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by keyword (e.g., love, success, life)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _searchQuotes,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Search for quotes',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_dissatisfied,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No quotes found',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return QuoteCard(quote: _searchResults[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
