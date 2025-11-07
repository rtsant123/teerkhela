class TeerGame {
  final int id;
  final String name;
  final String displayName;
  final String? region;
  final String? scrapeUrl;
  final bool isActive;
  final bool scrapeEnabled;
  final String? frTime;
  final String? srTime;
  final int displayOrder;

  TeerGame({
    required this.id,
    required this.name,
    required this.displayName,
    this.region,
    this.scrapeUrl,
    required this.isActive,
    required this.scrapeEnabled,
    this.frTime,
    this.srTime,
    required this.displayOrder,
  });

  factory TeerGame.fromJson(Map<String, dynamic> json) {
    return TeerGame(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      region: json['region'],
      scrapeUrl: json['scrape_url'],
      isActive: json['is_active'] ?? true,
      scrapeEnabled: json['scrape_enabled'] ?? false,
      frTime: json['fr_time'],
      srTime: json['sr_time'],
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'region': region,
      'scrape_url': scrapeUrl,
      'is_active': isActive,
      'scrape_enabled': scrapeEnabled,
      'fr_time': frTime,
      'sr_time': srTime,
      'display_order': displayOrder,
    };
  }
}
