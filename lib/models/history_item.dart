class HistoryItem {
  final String url;
  final String title;
  final DateTime timestamp;

  HistoryItem({
    required this.url,
    required this.title,
    required this.timestamp,
  });

  // Get favicon URL for the domain
  String get faviconUrl {
    try {
      final uri = Uri.parse(url);
      return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=64';
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      url: json['url'],
      title: json['title'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
