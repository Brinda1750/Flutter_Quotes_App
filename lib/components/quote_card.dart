import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quotes_app/models/quote.dart';
import 'package:quotes_app/services/quote_service.dart';
import 'package:quotes_app/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final Function(Quote, bool)? onBookmarkToggle;

  const QuoteCard({
    super.key,
    required this.quote,
    this.onBookmarkToggle,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  final QuoteService _quoteService = QuoteService();
  bool _isBookmarked = false;
  bool _isLoading = false;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.quote.imageUrl != null && widget.quote.imageUrl!.startsWith('image_')) {
      final imageData = await _quoteService.getImage(widget.quote.imageUrl!);
      if (mounted && imageData != null) {
        setState(() {
          _base64Image = imageData;
        });
      }
    }
  }

  Future<void> _checkIfBookmarked() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = authService.currentUser!.id;
      final isBookmarked = await _quoteService.isQuoteBookmarked(widget.quote.id, userId);
      
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleBookmark() async {
    final userId = authService.currentUser!.id;
    final newState = !_isBookmarked;
    
    setState(() {
      _isBookmarked = newState;
    });
    
    if (widget.onBookmarkToggle != null) {
      widget.onBookmarkToggle!(widget.quote, newState);
    }
  }

  void _shareQuote() {
    final text = '"${widget.quote.text}" - ${widget.quote.author}';
    Share.share(text);
  }

  void _copyToClipboard() {
    final text = '"${widget.quote.text}" - ${widget.quote.author}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.quote.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _base64Image != null
                    ? Image.memory(
                        base64Decode(_base64Image!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : widget.quote.imageUrl!.startsWith('image_')
                        ? Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          )
                        : Image.network(
                            widget.quote.imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, size: 50),
                              );
                            },
                          ),
              ),
            if (widget.quote.imageUrl != null) const SizedBox(height: 20),
            
            // Quote text
            Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(child: Container()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                widget.quote.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      height: 1.5,
                    ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.format_quote,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Author
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${widget.quote.author}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Category and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(widget.quote.category),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onPressed: _toggleBookmark,
                      tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyToClipboard,
                      tooltip: 'Copy quote',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _shareQuote,
                      tooltip: 'Share quote',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
