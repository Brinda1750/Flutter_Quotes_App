import 'package:flutter/material.dart';
import 'package:quotes_app/components/category_list.dart';
import 'package:quotes_app/components/quote_card.dart';
import 'package:quotes_app/main.dart';
import 'package:quotes_app/models/quote.dart';
import 'package:quotes_app/pages/create_quote_page.dart';
import 'package:quotes_app/services/quote_service.dart';
import 'package:quotes_app/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QuoteService _quoteService = QuoteService();
  List<Quote> _quotes = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _quoteService.getCategories();
      final quotes = await _quoteService.getRandomQuotes();

      if (mounted) {
        setState(() {
          _categories = categories;
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to load quotes: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadQuotesByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    try {
      final quotes = category == 'All'
          ? await _quoteService.getRandomQuotes()
          : await _quoteService.getQuotesByCategory(category);

      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to load quotes: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
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
            // Categories
            CategoryList(
              categories: ['All', ..._categories],
              selectedCategory: _selectedCategory,
              onCategorySelected: _loadQuotesByCategory,
            ),
            
            // Quotes
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _quotes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_quote,
                                size: 80,
                                color: Colors.grey[400],
                              ),
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
                          itemCount: _quotes.length,
                          itemBuilder: (context, index) {
                            return QuoteCard(
                              quote: _quotes[index],
                              onBookmarkToggle: (quote, isBookmarked) async {
                                final userId = authService.currentUser!.id;
                                if (isBookmarked) {
                                  await _quoteService.bookmarkQuote(quote, userId);
                                  context.showSnackBar('Quote bookmarked');
                                } else {
                                  await _quoteService.removeBookmark(quote.id, userId);
                                  context.showSnackBar('Bookmark removed');
                                }
                              },
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
