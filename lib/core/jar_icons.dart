import 'package:flutter/material.dart';

/// Icon for every category offered on the Create Jar screen.
const Map<String, IconData> kJarIcons = {
  'piggy': Icons.savings_outlined,
  'plane': Icons.flight,
  'home': Icons.home_outlined,
  'car': Icons.directions_car_outlined,
  'tech': Icons.computer_outlined,
  'health': Icons.favorite_outline,
  'education': Icons.school_outlined,
  'gift': Icons.card_giftcard_outlined,
  'emergency': Icons.local_hospital_outlined,
  'luxury': Icons.diamond_outlined,
  'shopping': Icons.shopping_bag_outlined,
  'food': Icons.restaurant_outlined,
  'sports': Icons.sports_soccer,
  'music': Icons.music_note_outlined,
  'pet': Icons.pets_outlined,
  'wedding': Icons.favorite,
  'baby': Icons.child_care_outlined,
  'business': Icons.business_center_outlined,
};

/// Bundled illustration for a category (Fluent Emoji 3D, MIT licensed).
String jarImagePath(String iconStyle) => 'lib/images/$iconStyle.png';

Widget buildJarIcon(String iconStyle,
    {required double imageSize, required Color iconColor}) {
  final fallback =
      Icon(kJarIcons[iconStyle] ?? Icons.savings_outlined, size: 80, color: iconColor);
  if (!kJarIcons.containsKey(iconStyle)) return fallback;
  return Image.asset(jarImagePath(iconStyle),
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback);
}
