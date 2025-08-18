import 'package:flutter/material.dart';

class LiveGiftModel {
  final String id;
  final String name;
  final String icon;
  final int price;
  final String currency;
  final bool isAnimated;
  final String? animationUrl;
  final String? soundUrl;
  final int duration; // in milliseconds
  final String category;
  final bool isLimited;
  final DateTime? availableUntil;
  final int maxQuantity;
  final String? description;
  final Map<String, dynamic> effects;
  final bool isSpecial;
  final String? rarity; // 'common', 'rare', 'epic', 'legendary'
  final int? experiencePoints;
  final Map<String, dynamic> metadata;

  LiveGiftModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    this.currency = 'coins',
    this.isAnimated = false,
    this.animationUrl,
    this.soundUrl,
    this.duration = 3000,
    this.category = 'general',
    this.isLimited = false,
    this.availableUntil,
    this.maxQuantity = 99,
    this.description,
    this.effects = const {},
    this.isSpecial = false,
    this.rarity,
    this.experiencePoints,
    this.metadata = const {},
  });

  factory LiveGiftModel.fromJson(Map<String, dynamic> json) {
    return LiveGiftModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'coins',
      isAnimated: json['isAnimated'] ?? false,
      animationUrl: json['animationUrl'],
      soundUrl: json['soundUrl'],
      duration: json['duration'] ?? 3000,
      category: json['category'] ?? 'general',
      isLimited: json['isLimited'] ?? false,
      availableUntil: json['availableUntil'] != null 
          ? DateTime.parse(json['availableUntil']) 
          : null,
      maxQuantity: json['maxQuantity'] ?? 99,
      description: json['description'],
      effects: Map<String, dynamic>.from(json['effects'] ?? {}),
      isSpecial: json['isSpecial'] ?? false,
      rarity: json['rarity'],
      experiencePoints: json['experiencePoints'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'price': price,
      'currency': currency,
      'isAnimated': isAnimated,
      'animationUrl': animationUrl,
      'soundUrl': soundUrl,
      'duration': duration,
      'category': category,
      'isLimited': isLimited,
      'availableUntil': availableUntil?.toIso8601String(),
      'maxQuantity': maxQuantity,
      'description': description,
      'effects': effects,
      'isSpecial': isSpecial,
      'rarity': rarity,
      'experiencePoints': experiencePoints,
      'metadata': metadata,
    };
  }

  LiveGiftModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? price,
    String? currency,
    bool? isAnimated,
    String? animationUrl,
    String? soundUrl,
    int? duration,
    String? category,
    bool? isLimited,
    DateTime? availableUntil,
    int? maxQuantity,
    String? description,
    Map<String, dynamic>? effects,
    bool? isSpecial,
    String? rarity,
    int? experiencePoints,
    Map<String, dynamic>? metadata,
  }) {
    return LiveGiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isAnimated: isAnimated ?? this.isAnimated,
      animationUrl: animationUrl ?? this.animationUrl,
      soundUrl: soundUrl ?? this.soundUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      isLimited: isLimited ?? this.isLimited,
      availableUntil: availableUntil ?? this.availableUntil,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      description: description ?? this.description,
      effects: effects ?? this.effects,
      isSpecial: isSpecial ?? this.isSpecial,
      rarity: rarity ?? this.rarity,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedPrice {
    if (currency == 'coins') {
      return '$price 🪙';
    } else if (currency == 'diamonds') {
      return '$price 💎';
    } else if (currency == 'dollars') {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '$price $currency';
    }
  }

  String get displayName {
    if (isSpecial) {
      return '$name ⭐';
    } else if (rarity == 'legendary') {
      return '$name 🔥';
    } else if (rarity == 'epic') {
      return '$name ✨';
    } else if (rarity == 'rare') {
      return '$name 💫';
    } else {
      return name;
    }
  }

  bool get isAvailable {
    if (!isLimited) return true;
    if (availableUntil == null) return true;
    return DateTime.now().isBefore(availableUntil!);
  }

  Color get rarityColor {
    switch (rarity) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'common':
      default:
        return Colors.grey;
    }
  }

  bool get hasEffects => effects.isNotEmpty;
  bool get hasSound => soundUrl != null;
  bool get hasAnimation => animationUrl != null;
}

// Gift Categories
class GiftCategories {
  static const String general = 'general';
  static const String love = 'love';
  static const String celebration = 'celebration';
  static const String food = 'food';
  static const String animals = 'animals';
  static const String nature = 'nature';
  static const String technology = 'technology';
  static const String sports = 'sports';
  static const String music = 'music';
  static const String art = 'art';
  static const String fashion = 'fashion';
  static const String travel = 'travel';
  static const String gaming = 'gaming';
  static const String education = 'education';
  static const String health = 'health';
  static const String business = 'business';
  static const String seasonal = 'seasonal';
  static const String limited = 'limited';
  static const String special = 'special';
}

// Gift Rarities
class GiftRarities {
  static const String common = 'common';
  static const String rare = 'rare';
  static const String epic = 'epic';
  static const String legendary = 'legendary';
}

