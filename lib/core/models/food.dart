class Food {
  final String name;
  final String imageUrl;
  final double price;

  const Food({
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  Food copyWith({
    String? name,
    String? imageUrl,
    double? price,
  }) {
    return Food(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imageUrl == other.imageUrl &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ imageUrl.hashCode ^ price.hashCode;
}
