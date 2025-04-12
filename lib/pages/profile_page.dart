import 'package:flutter/material.dart';
import 'package:quotes_app/components/quote_card.dart';
import 'package:quotes_app/services/auth_service.dart';
import 'package:quotes_app/models/quote.dart';
import 'package:quotes_app/pages/login_page.dart';
import 'package:quotes_app/services/quote_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  late TabController _tabController;
  List<Quote> _bookmarkedQuotes = [];
  List<Quote> _customQuotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = authService.currentUser!.id;
      final bookmarkedQuotes = await _quoteService.getBookmarkedQuotes(userId);
      final customQuotes = await _quoteService.getCustomQuotes(userId);

      if (mounted) {
        setState(() {
          _bookmarkedQuotes = bookmarkedQuotes;
          _customQuotes = customQuotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final email = user?.email ?? 'User';
    final name = user?.name ?? user?.userMetadata?['name'] ?? email.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Bookmarks'),
              Tab(text: 'My Quotes'),
            ],
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Bookmarks Tab
                      _bookmarkedQuotes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bookmark_border,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No bookmarked quotes yet',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadUserData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _bookmarkedQuotes.length,
                                itemBuilder: (context, index) {
                                  return QuoteCard(
                                    quote: _bookmarkedQuotes[index],
                                    onBookmarkToggle: (quote, isBookmarked) async {
                                      if (!isBookmarked) {
                                        final userId = authService.currentUser!.id;
                                        await _quoteService.removeBookmark(quote.id, userId);
                                        _loadUserData();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),

                      // My Quotes Tab
                      _customQuotes.isEmpty
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
                                    'No custom quotes yet',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadUserData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _customQuotes.length,
                                itemBuilder: (context, index) {
                                  return QuoteCard(
                                    quote: _customQuotes[index],
                                  );
                                },
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
