import 'dart:convert';
import 'dart:math';  // Import random for selecting random quotes
import 'package:http/http.dart' as http;
import 'package:quotes_app/models/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GeminiService {
  static const String _generatedQuotesKey = 'generated_quotes';
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  static const String apiKey = 'AIzaSyARoHf2nsle8kkSnH45QjI-3g4_xpF4dog';

  // Generate 10 random quotes using Gemini API
  Future<List<Quote>> generateQuotes(String category) async {
    try {
      await Future.delayed(const Duration(seconds: 2));  // Simulate API delay
      
      final List<Quote> generatedQuotes = [];

      // Generate 10 random quotes based on category
      for (int i = 0; i < 10; i++) {
        final quote = _getRandomQuoteFromCategory(category);
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

  // Helper method to get a random quote from the specified category
  Quote _getRandomQuoteFromCategory(String category) {
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
  'wisdom': [
    {'text': 'Knowing others is intelligence; knowing yourself is true wisdom.', 'author': 'Lao Tzu'},
    {'text': 'The only true wisdom is in knowing you know nothing.', 'author': 'Socrates'},
    {'text': 'Wisdom begins in wonder.', 'author': 'Socrates'},
    {'text': 'A fool thinks himself to be wise, but a wise man knows himself to be a fool.', 'author': 'William Shakespeare'},
    {'text': 'Wisdom is not a product of schooling but of the lifelong attempt to acquire it.', 'author': 'Albert Einstein'},
    {'text': 'The wise man does at once what the fool does finally.', 'author': 'Niccolò Machiavelli'},
    {'text': 'An investment in knowledge pays the best interest.', 'author': 'Benjamin Franklin'},
    {'text': 'Do not go where the path may lead, go instead where there is no path and leave a trail.', 'author': 'Ralph Waldo Emerson'},
    {'text': 'The more that you read, the more things you will know. The more that you learn, the more places you\'ll go.', 'author': 'Dr. Seuss'},
    {'text': 'There is no remedy for love but to love more.', 'author': 'Henry David Thoreau'},
    {'text': 'In seeking wisdom, the key is to be open, curious, and fearless in questioning everything.', 'author': 'Unknown'},
  ],
  'happiness': [
    {'text': 'Happiness is not something ready made. It comes from your own actions.', 'author': 'Dalai Lama'},
    {'text': 'For every minute you are angry you lose sixty seconds of happiness.', 'author': 'Ralph Waldo Emerson'},
    {'text': 'Happiness depends upon ourselves.', 'author': 'Aristotle'},
    {'text': 'The most important thing is to enjoy your life—to be happy—it’s all that matters.', 'author': 'Audrey Hepburn'},
    {'text': 'Happiness is not a goal...it’s a by-product of a life well lived.', 'author': 'Eleanor Roosevelt'},
    {'text': 'Happiness is a warm puppy.', 'author': 'Charles M. Schulz'},
    {'text': 'The purpose of life is not to be happy. It is to be useful, to be honorable, to be compassionate, to have it make some difference that you have lived and lived well.', 'author': 'Ralph Waldo Emerson'},
    {'text': 'A happy life is a life in balance.', 'author': 'Mahatma Gandhi'},
    {'text': 'Happiness is not a station you arrive at, but a manner of traveling.', 'author': 'Margaret Lee Runbeck'},
    {'text': 'Success is not the key to happiness. Happiness is the key to success.', 'author': 'Albert Schweitzer'},
    {'text': 'Happiness is an inside job.', 'author': 'Unknown'},
  ],
  'friendship': [
    {'text': 'Friendship is born at that moment when one person says to another, "What! You too? I thought I was the only one."', 'author': 'C.S. Lewis'},
    {'text': 'True friends stab you in the front.', 'author': 'Oscar Wilde'},
    {'text': 'A friend is someone who knows all about you and still loves you.', 'author': 'Elbert Hubbard'},
    {'text': 'A real friend is one who walks in when the rest of the world walks out.', 'author': 'Walter Winchell'},
    {'text': 'Friendship is a single soul dwelling in two bodies.', 'author': 'Aristotle'},
    {'text': 'There are no strangers here; Only friends you haven’t yet met.', 'author': 'William Butler Yeats'},
    {'text': 'A true friend is somebody who can make us feel better no matter how bad things may be.', 'author': 'Ralph Waldo Emerson'},
    {'text': 'Friendship is not about whom you have known the longest, it’s about who came and never left your side.', 'author': 'Unknown'},
    {'text': 'A good friend is like a four-leaf clover: hard to find and lucky to have.', 'author': 'Irish Proverb'},
    {'text': 'A friend to all is a friend to none.', 'author': 'Aristotle'},
  ],
  'leadership': [
    {'text': 'Leadership is not about being in charge. It’s about taking care of those in your charge.', 'author': 'Simon Sinek'},
    {'text': 'The function of leadership is to produce more leaders, not more followers.', 'author': 'Ralph Nader'},
    {'text': 'Leadership is the capacity to translate vision into reality.', 'author': 'Warren Bennis'},
    {'text': 'The best way to predict the future is to create it.', 'author': 'Abraham Lincoln'},
    {'text': 'A leader is one who knows the way, goes the way, and shows the way.', 'author': 'John C. Maxwell'},
    {'text': 'Leadership is not about being the best. It’s about making everyone else better.', 'author': 'Unknown'},
    {'text': 'A great leader’s courage to fulfill his vision comes from passion, not position.', 'author': 'John C. Maxwell'},
    {'text': 'To lead people, walk behind them.', 'author': 'Lao Tzu'},
    {'text': 'Leadership is not about being the best, but about helping others be their best.', 'author': 'Unknown'},
    {'text': 'A leader is someone who demonstrates what’s possible.', 'author': 'Mark Yarnell'},
  ],
  'growth': [
    {'text': 'Growth is the only evidence of life.', 'author': 'John Henry Newman'},
    {'text': 'Growth begins when we begin to accept our own weakness.', 'author': 'Jean Vanier'},
    {'text': 'The greatest glory in living lies not in never falling, but in rising every time we fall.', 'author': 'Nelson Mandela'},
    {'text': 'The secret of getting ahead is getting started.', 'author': 'Mark Twain'},
    {'text': 'Growth and comfort do not coexist.', 'author': 'Ginni Rometty'},
    {'text': 'The only way to grow is to be willing to be uncomfortable.', 'author': 'Unknown'},
    {'text': 'Don’t be afraid to give up the good to go for the great.', 'author': 'John D. Rockefeller'},
    {'text': 'If you’re not growing, you’re dying.', 'author': 'Tony Robbins'},
    {'text': 'In the middle of difficulty lies opportunity.', 'author': 'Albert Einstein'},
    {'text': 'The greatest gift in life is not to be afraid of change.', 'author': 'Unknown'},
  ],
  'courage': [
    {'text': 'Courage is not the absence of fear, but the triumph over it.', 'author': 'Nelson Mandela'},
    {'text': 'It takes courage to grow up and become who you really are.', 'author': 'e.e. cummings'},
    {'text': 'Success is not final, failure is not fatal: It is the courage to continue that counts.', 'author': 'Winston Churchill'},
    {'text': 'Courage is grace under pressure.', 'author': 'Ernest Hemingway'},
    {'text': 'You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.', 'author': 'Eleanor Roosevelt'},
    {'text': 'Courage is being scared to death, but saddling up anyway.', 'author': 'John Wayne'},
    {'text': 'Courage is the first of human qualities because it is the quality which guarantees the others.', 'author': 'Aristotle'},
    {'text': 'Do one thing every day that scares you.', 'author': 'Eleanor Roosevelt'},
    {'text': 'Fortune favors the brave.', 'author': 'Virgil'},
    {'text': 'Courage is the commitment to begin without any guarantee of success.', 'author': 'Johann Wolfgang von Goethe'},
  ],
};

    // Default to 'motivation' category if the category is not found
    final categoryQuotes = quotes[category.toLowerCase()] ?? quotes['motivation']!;

    // Select a random quote from the category
    final random = Random();
    final randomQuote = categoryQuotes[random.nextInt(categoryQuotes.length)];

    return Quote(
      id: const Uuid().v4(),
      text: randomQuote['text']!,
      author: randomQuote['author']!,
      category: category,
      isCustom: false,
    );
  }
}
