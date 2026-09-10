class MarketplaceItem {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final String title;
  final double price;
  final String category; // 'Electronics', 'Vehicles', 'Property', 'Fashion', 'Home', 'Hobbies'
  final String condition; // 'New', 'Used - Like New', 'Used - Good', 'Used - Fair'
  final String location;
  final String imageUrl;
  final String description;
  final String createdAt;
  final bool isSaved;

  MarketplaceItem({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatar,
    required this.title,
    required this.price,
    required this.category,
    required this.condition,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    this.isSaved = false,
  });

  MarketplaceItem copyWith({bool? isSaved}) {
    return MarketplaceItem(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      title: title,
      price: price,
      category: category,
      condition: condition,
      location: location,
      imageUrl: imageUrl,
      description: description,
      createdAt: createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerAvatar': sellerAvatar,
        'title': title,
        'price': price,
        'category': category,
        'condition': condition,
        'location': location,
        'imageUrl': imageUrl,
        'description': description,
        'createdAt': createdAt,
        'isSaved': isSaved,
      };

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) => MarketplaceItem(
        id: json['id'] ?? '',
        sellerId: json['sellerId'] ?? '',
        sellerName: json['sellerName'] ?? '',
        sellerAvatar: json['sellerAvatar'] ?? '',
        title: json['title'] ?? '',
        price: (json['price'] as num? ?? 0.0).toDouble(),
        category: json['category'] ?? 'General',
        condition: json['condition'] ?? 'Used',
        location: json['location'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        description: json['description'] ?? '',
        createdAt: json['createdAt'] ?? '',
        isSaved: json['isSaved'] ?? false,
      );
}
