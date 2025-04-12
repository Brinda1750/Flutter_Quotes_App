import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quotes_app/models/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class QuoteService {
  static const String _apiKey = 'ErHnnMv99Bg/6hK0R1eXbA==3qWcKVwCRyR6Cv3z';
  static const String apiUrl = 'https://api.api-ninjas.com/v1/quotes';
  static const String bookmarksKey = 'bookmarked_quotes';
  static const String customQuotesKey = 'custom_quotes';
  
  // Fetch random quotes
  Future<List<Quote>> getRandomQuotes({int count = 10}) async {
    final response = await http.get(Uri.parse('$apiUrl/quotes/random?limit=$count'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quotes');
    }
  }
  
  // Fetch quotes by category
  Future<List<Quote>> getQuotesByCategory(String category, {int count = 10}) async {
    final response = await http.get(
      Uri.parse('$apiUrl/quotes/random?tags=$category&limit=$count')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quotes for category: $category');
    }
  }
  
  // Search quotes
  Future<List<Quote>> searchQuotes(String query) async {
    final response = await http.get(
      Uri.parse('$apiUrl/search/quotes?query=$query')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search quotes');
    }
  }
  
  // Get available categories
  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$apiUrl/tags'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<String>((tag) => tag['name'] as String).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
  
  // Save a custom quote
  Future<Quote> saveCustomQuote({
    required String text,
    required String author,
    required String category,
    String? imageUrl,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customQuotesJson = prefs.getStringList(customQuotesKey) ?? [];
    
    final quote = Quote(
      id: const Uuid().v4(),
      text: text,
      author: author,
      category: category,
      imageUrl: imageUrl,
      isCustom: true,
      userId: userId,
    );
    
    customQuotesJson.add(jsonEncode(quote.toJson()));
    await prefs.setStringList(customQuotesKey, customQuotesJson);
    
    return quote;
  }
  
  // Get all custom quotes for a user
  Future<List<Quote>> getCustomQuotes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final customQuotesJson = prefs.getStringList(customQuotesKey) ?? [];
    
    return customQuotesJson
        .map((json) => Quote.fromJson(jsonDecode(json)))
        .where((quote) => quote.userId == userId)
        .toList();
  }
  
  // Bookmark a quote
  Future<void> bookmarkQuote(Quote quote, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(bookmarksKey) ?? [];
    
    // Add userId to identify the bookmark owner
    final quoteWithUser = {
      ...quote.toJson(),
      'userId': userId,
    };
    
    bookmarksJson.add(jsonEncode(quoteWithUser));
    await prefs.setStringList(bookmarksKey, bookmarksJson);
  }
  
  // Remove bookmark
  Future<void> removeBookmark(String quoteId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(bookmarksKey) ?? [];
    
    final updatedBookmarks = bookmarksJson.where((json) {
      final quote = Quote.fromJson(jsonDecode(json));
      return !(quote.id == quoteId && quote.userId == userId);
    }).toList();
    
    await prefs.setStringList(bookmarksKey, updatedBookmarks);
  }
  
  // Get all bookmarked quotes for a user
  Future<List<Quote>> getBookmarkedQuotes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(bookmarksKey) ?? [];
    
    return bookmarksJson
        .map((json) => Quote.fromJson(jsonDecode(json)))
        .where((quote) => quote.userId == userId)
        .toList();
  }
  
  // Check if a quote is bookmarked
  Future<bool> isQuoteBookmarked(String quoteId, String userId) async {
    final bookmarks = await getBookmarkedQuotes(userId);
    return bookmarks.any((quote) => quote.id == quoteId);
  }
  
  // Save image to local storage (base64 encoded)
  Future<String?> saveImage(List<int> imageBytes, String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64Image = base64Encode(imageBytes);
      
      // Store image with filename as key
      final imageKey = 'image_$fileName';
      await prefs.setString(imageKey, base64Image);
      
      // Return the key as the "URL"
      return imageKey;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
  
  // Get image from local storage
  Future<String?> getImage(String imageKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(imageKey);
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  fetchQuotes() {}
}
