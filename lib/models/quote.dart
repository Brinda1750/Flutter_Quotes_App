class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  final String? imageUrl;
  final bool isCustom;
  final String? userId;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.imageUrl,
    this.isCustom = false,
    this.userId,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? '',
      text: json['content'] ?? json['text'] ?? '',
      author: json['author'] ?? 'Unknown',
      category: json['tags']?[0] ?? json['category'] ?? 'General',
      imageUrl: json['imageUrl'],
      isCustom: json['isCustom'] ?? false,
      userId: json['userId'],
    );
  }

  get quote => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'imageUrl': imageUrl,
      'isCustom': isCustom,
      'userId': userId,
    };
  }
}
