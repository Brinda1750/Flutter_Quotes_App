import 'package:flutter/material.dart';
import 'package:quotes_app/components/category_list.dart';
import 'package:quotes_app/components/quote_card.dart';
import 'package:quotes_app/main.dart';
import 'package:quotes_app/models/quote.dart';
import 'package:quotes_app/pages/create_quote_page.dart';
import 'package:quotes_app/services/gemini_service.dart';
import 'package:quotes_app/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GeminiService _geminiService = GeminiService();
  List<Quote> _quotes = [];
  List<String> _categories = ['Motivation', 'Success', 'Life', 'Love'];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialQuotes();
  }

  Future<void> _loadInitialQuotes() async {
    setState(() => _isLoading = true);

    try {
      final quotes = await _geminiService.generateQuotes('motivation');

      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to load quotes: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadQuotesByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    try {
      List<Quote> quotes = await _geminiService.generateQuotes(
        category == 'All' ? 'motivation' : category.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to load quotes: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadQuotesByCategory(_selectedCategory),
        child: Column(
          children: [
            // Category Selector
            CategoryList(
              categories: ['All', ..._categories],
              selectedCategory: _selectedCategory,
              onCategorySelected: _loadQuotesByCategory,
            ),

            // Display Quotes
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _quotes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.format_quote, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No quotes found',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _quotes.length,
                          itemBuilder: (context, index) {
                            return QuoteCard(
                              quote: _quotes[index],
                              // No bookmark toggle
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQuotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
