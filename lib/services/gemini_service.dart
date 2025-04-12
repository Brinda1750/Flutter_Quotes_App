import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quotes_app/models/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GeminiService {
  static const String _generatedQuotesKey = 'generated_quotes';
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // Your API key would go here - for demo purposes we'll simulate the API
  // In a real app, you would store this securely and not hardcode it
  static const String apiKey = 'AIzaSyARoHf2nsle8kkSnH45QjI-3g4_xpF4dog';
  
  // Generate quotes using Gemini API
  Future<List<Quote>> generateQuotes(String category, {int count = 10}) async {
    try {
      // In a real implementation, this would make an actual API call
      // For demo purposes, we'll simulate the API response
      
      // This is how you would make the actual API call:
      /*
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'Generate $count inspirational quotes about $category. Format the response as a JSON array with each quote having text and author fields.'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        // Parse the JSON from the text response
        final List<dynamic> quotesJson = jsonDecode(text);
        final quotes = quotesJson.map((json) => Quote(
          id: const Uuid().v4(),
          text: json['text'],
          author: json['author'] ?? 'Unknown',
          category: category,
        )).toList();
        
        // Save generated quotes
        await _saveGeneratedQuotes(quotes);
        return quotes;
      } else {
        throw Exception('Failed to generate quotes: ${response.statusCode}');
      }
      */
      
      // Simulated response for demo purposes
      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
      
      final List<Quote> generatedQuotes = [];
      
      // Generate simulated quotes based on category
      for (int i = 0; i < count; i++) {
        final quote = _createSimulatedQuote(category, i);
        generatedQuotes.add(quote);
      }
      
      // Save generated quotes
      await _saveGeneratedQuotes(generatedQuotes);
      
      return generatedQuotes;
    } catch (e) {
      throw Exception('Failed to generate quotes: $e');
    }
  }
  
  // Save generated quotes to localStorage
  Future<void> _saveGeneratedQuotes(List<Quote> quotes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingQuotesJson = prefs.getStringList(_generatedQuotesKey) ?? [];
      
      // Convert quotes to JSON strings
      final newQuotesJson = quotes.map((quote) => jsonEncode(quote.toJson())).toList();
      
      // Combine existing and new quotes
      final allQuotesJson = [...existingQuotesJson, ...newQuotesJson];
      
      // Save to localStorage
      await prefs.setStringList(_generatedQuotesKey, allQuotesJson);
    } catch (e) {
      print('Error saving generated quotes: $e');
    }
  }
  
  // Get all previously generated quotes
  Future<List<Quote>> getGeneratedQuotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quotesJson = prefs.getStringList(_generatedQuotesKey) ?? [];
      
      return quotesJson
          .map((json) => Quote.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting generated quotes: $e');
      return [];
    }
  }
  
  // Get generated quotes by category
  Future<List<Quote>> getGeneratedQuotesByCategory(String category) async {
    final allQuotes = await getGeneratedQuotes();
    return allQuotes.where((quote) => quote.category.toLowerCase() == category.toLowerCase()).toList();
  }
  
  // Helper method to create simulated quotes for demo purposes
  Quote _createSimulatedQuote(String category, int index) {
    final quotes = {
      'motivation': [
        {'text': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
        {'text': 'Believe you can and you\'re halfway there.', 'author': 'Theodore Roosevelt'},
        {'text': 'It does not matter how slowly you go as long as you do not stop.', 'author': 'Confucius'},
        {'text': 'Your time is limited, don\'t waste it living someone else\'s life.', 'author': 'Steve Jobs'},
        {'text': 'The future belongs to those who believe in the beauty of their dreams.', 'author': 'Eleanor Roosevelt'},
        {'text': 'Success is not final, failure is not fatal: It is the courage to continue that counts.', 'author': 'Winston Churchill'},
        {'text': 'Don\'t watch the clock; do what it does. Keep going.', 'author': 'Sam Levenson'},
        {'text': 'The only limit to our realization of tomorrow is our doubts of today.', 'author': 'Franklin D. Roosevelt'},
        {'text': 'The way to get started is to quit talking and begin doing.', 'author': 'Walt Disney'},
        {'text': 'If you are working on something that you really care about, you don\'t have to be pushed. The vision pulls you.', 'author': 'Steve Jobs'},
        {'text': 'Hardships often prepare ordinary people for an extraordinary destiny.', 'author': 'C.S. Lewis'},
        {'text': 'Start where you are. Use what you have. Do what you can.', 'author': 'Arthur Ashe'},
      ],
      'success': [
        {'text': 'Success is not the key to happiness. Happiness is the key to success.', 'author': 'Albert Schweitzer'},
        {'text': 'Success usually comes to those who are too busy to be looking for it.', 'author': 'Henry David Thoreau'},
        {'text': 'The road to success and the road to failure are almost exactly the same.', 'author': 'Colin R. Davis'},
        {'text': 'Success is walking from failure to failure with no loss of enthusiasm.', 'author': 'Winston Churchill'},
        {'text': 'The successful warrior is the average man, with laser-like focus.', 'author': 'Bruce Lee'},
        {'text': 'Success is not how high you have climbed, but how you make a positive difference to the world.', 'author': 'Roy T. Bennett'},
        {'text': 'Success is liking yourself, liking what you do, and liking how you do it.', 'author': 'Maya Angelou'},
        {'text': 'The secret of success is to do the common thing uncommonly well.', 'author': 'John D. Rockefeller Jr.'},
        {'text': 'Success is stumbling from failure to failure with no loss of enthusiasm.', 'author': 'Winston S. Churchill'},
        {'text': 'The only place where success comes before work is in the dictionary.', 'author': 'Vidal Sassoon'},
        {'text': 'Success is not in what you have, but who you are.', 'author': 'Bo Bennett'},
        {'text': 'The difference between successful people and very successful people is that very successful people say no to almost everything.', 'author': 'Warren Buffett'},
      ],
      'life': [
        {'text': 'Life is what happens when you\'re busy making other plans.', 'author': 'John Lennon'},
        {'text': 'The purpose of our lives is to be happy.', 'author': 'Dalai Lama'},
        {'text': 'Life is really simple, but we insist on making it complicated.', 'author': 'Confucius'},
        {'text': 'Life is 10% what happens to us and 90% how we react to it.', 'author': 'Charles R. Swindoll'},
        {'text': 'In the end, it\'s not the years in your life that count. It\'s the life in your years.', 'author': 'Abraham Lincoln'},
        {'text': 'Life is either a daring adventure or nothing at all.', 'author': 'Helen Keller'},
        {'text': 'Life isn\'t about finding yourself. Life is about creating yourself.', 'author': 'George Bernard Shaw'},
        {'text': 'Life is short, and it\'s up to you to make it sweet.', 'author': 'Sarah Louise Delany'},
        {'text': 'Life is like riding a bicycle. To keep your balance, you must keep moving.', 'author': 'Albert Einstein'},
        {'text': 'The biggest adventure you can take is to live the life of your dreams.', 'author': 'Oprah Winfrey'},
        {'text': 'Life is a journey that must be traveled no matter how bad the roads and accommodations.', 'author': 'Oliver Goldsmith'},
        {'text': 'Life is made of ever so many partings welded together.', 'author': 'Charles Dickens'},
      ],
      'love': [
        {'text': 'The best thing to hold onto in life is each other.', 'author': 'Audrey Hepburn'},
        {'text': 'Love is composed of a single soul inhabiting two bodies.', 'author': 'Aristotle'},
        {'text': 'Where there is love there is life.', 'author': 'Mahatma Gandhi'},
        {'text': 'The greatest happiness of life is the conviction that we are loved.', 'author': 'Victor Hugo'},
        {'text': 'Love is when the other person\'s happiness is more important than your own.', 'author': 'H. Jackson Brown Jr.'},
        {'text': 'Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.', 'author': 'Unknown'},
        {'text': 'To love and be loved is to feel the sun from both sides.', 'author': 'David Viscott'},
        {'text': 'Love is an untamed force. When we try to control it, it destroys us. When we try to imprison it, it enslaves us.', 'author': 'Paulo Coelho'},
        {'text': 'The giving of love is an education in itself.', 'author': 'Eleanor Roosevelt'},
        {'text': 'Love doesn\'t make the world go round. Love is what makes the ride worthwhile.', 'author': 'Franklin P. Jones'},
        {'text': 'Love is the only force capable of transforming an enemy into a friend.', 'author': 'Martin Luther King Jr.'},
        {'text': 'Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.', 'author': 'Lao Tzu'},
      ],
    };
    
    // Default to motivation if category not found
    final categoryQuotes = quotes[category.toLowerCase()] ?? quotes['motivation']!;
    final quoteIndex = index % categoryQuotes.length;
    final quoteData = categoryQuotes[quoteIndex];
    
    return Quote(
      id: const Uuid().v4(),
      text: quoteData['text']!,
      author: quoteData['author']!,
      category: category,
      isCustom: false,
    );
  }
}
