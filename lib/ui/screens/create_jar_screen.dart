import 'package:flutter/material.dart';
import '../../core/jar_icons.dart';
import '../../core/theme.dart';
import '../../providers/jar_provider.dart';
import '../../data/models/jar_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

const List<Map<String, dynamic>> _kIcons = [
  {'key': 'piggy',     'icon': Icons.savings_outlined,          'label': 'Piggy Bank'},
  {'key': 'plane',     'icon': Icons.flight,                    'label': 'Travel'},
  {'key': 'home',      'icon': Icons.home_outlined,             'label': 'Home'},
  {'key': 'car',       'icon': Icons.directions_car_outlined,   'label': 'Car'},
  {'key': 'tech',      'icon': Icons.computer_outlined,         'label': 'Tech'},
  {'key': 'health',    'icon': Icons.favorite_outline,          'label': 'Health'},
  {'key': 'education', 'icon': Icons.school_outlined,           'label': 'Education'},
  {'key': 'gift',      'icon': Icons.card_giftcard_outlined,    'label': 'Gifts'},
  {'key': 'emergency', 'icon': Icons.local_hospital_outlined,   'label': 'Emergency'},
  {'key': 'luxury',    'icon': Icons.diamond_outlined,          'label': 'Luxury'},
  {'key': 'shopping',  'icon': Icons.shopping_bag_outlined,     'label': 'Shopping'},
  {'key': 'food',      'icon': Icons.restaurant_outlined,       'label': 'Food'},
  {'key': 'sports',    'icon': Icons.sports_soccer,             'label': 'Sports'},
  {'key': 'music',     'icon': Icons.music_note_outlined,       'label': 'Music'},
  {'key': 'pet',       'icon': Icons.pets_outlined,             'label': 'Pets'},
  {'key': 'wedding',   'icon': Icons.favorite,                  'label': 'Wedding'},
  {'key': 'baby',      'icon': Icons.child_care_outlined,       'label': 'Baby'},
  {'key': 'business',  'icon': Icons.business_center_outlined,  'label': 'Business'},
];

const List<Color> _kColors = [
  Color(0xFF0047CC), Color(0xFF10B981), Color(0xFFF59E0B),
  Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899),
  Color(0xFF06B6D4), Color(0xFF84CC16), Color(0xFFFF6B35), Color(0xFF6366F1),
];

class CreateJarScreen extends StatefulWidget {
  final VoidCallback? onJarCreated;
  const CreateJarScreen({Key? key, this.onJarCreated}) : super(key: key);
  @override
  State<CreateJarScreen> createState() => _CreateJarScreenState();
}

class _CreateJarScreenState extends State<CreateJarScreen> {
  String _selectedIcon = 'piggy';
  Color _selectedColor = _kColors.first;
  bool _autoSave = false;
  bool _lockedJar = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createJar() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a jar name.')));
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Provider.of<JarProvider>(context, listen: false).addJar(JarModel(
        id: '',
        name: name,
        targetAmount: amount,
        savedAmount: 0.0,
        iconStyle: _selectedIcon,
        color: _selectedColor.value,
        autoSave: _autoSave,
        locked: _lockedJar,
        createdAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser?.uid,
      ));
      if (mounted) {
        // If used as a tab page, call callback; if pushed as a route, pop.
        if (widget.onJarCreated != null) {
          widget.onJarCreated!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('New Savings Jar',
            style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 16)],
              ),
              child: Column(children: [
                Icon(Icons.savings, size: 48, color: _selectedColor),
                const SizedBox(height: 10),
                Text('New Savings Jar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text('Give your goal a name.', style: theme.textTheme.bodyMedium),
              ]),
            ),
            const SizedBox(height: 24),

            // Name
            _label(context, Icons.edit, 'Jar Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: _dec(context, 'e.g., Summer Holiday 🏖️'),
            ),
            const SizedBox(height: 18),

            // Amount
            _label(context, Icons.flag_outlined, 'Target Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: _dec(context, '0.00', prefix: '\$'),
            ),
            const SizedBox(height: 22),

            // Icon Picker
            _label(context, Icons.palette_outlined, 'Category Icon'),
            const SizedBox(height: 10),
            SizedBox(
              height: 98,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kIcons.length,
                itemBuilder: (_, i) {
                  final item = _kIcons[i];
                  final isSelected = _selectedIcon == item['key'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = item['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 68,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withOpacity(0.12) : theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? _selectedColor : Colors.transparent, width: 2),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Image.asset(jarImagePath(item['key'] as String), width: 34, height: 34,
                            errorBuilder: (_, __, ___) => Icon(item['icon'] as IconData,
                                color: isSelected ? _selectedColor : AppTheme.textSecondary, size: 26)),
                        const SizedBox(height: 4),
                        Text(item['label'] as String,
                            style: TextStyle(fontSize: 9, color: isSelected ? _selectedColor : AppTheme.textSecondary),
                            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Color Picker
            _label(context, Icons.color_lens_outlined, 'Jar Color'),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kColors.length,
                itemBuilder: (_, i) {
                  final color = _kColors[i];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34, height: 34,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)] : [],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Row(children: [
              Expanded(child: _optCard(selected: _autoSave, bg: const Color(0xFFFFF7ED), border: Colors.orange,
                  icon: Icons.auto_awesome, iconColor: const Color(0xFFC05621), title: 'Auto-Save', subtitle: 'Round up changes',
                  onTap: () => setState(() => _autoSave = !_autoSave))),
              const SizedBox(width: 12),
              Expanded(child: _optCard(selected: _lockedJar, bg: const Color(0xFFF0FDF4), border: const Color(0xFF047857),
                  icon: Icons.lock_outline, iconColor: const Color(0xFF047857), title: 'Locked Jar', subtitle: 'Prevent early dips',
                  onTap: () => setState(() => _lockedJar = !_lockedJar))),
            ]),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createJar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: _selectedColor.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Create Jar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, IconData icon, String label) => Row(children: [
    Icon(icon, size: 15, color: AppTheme.textSecondary), const SizedBox(width: 6),
    Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
  ]);

  InputDecoration _dec(BuildContext ctx, String hint, {String? prefix}) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: AppTheme.textSecondary),
    filled: true, fillColor: Theme.of(ctx).cardColor, prefixText: prefix,
    prefixStyle: TextStyle(color: _selectedColor, fontSize: 18, fontWeight: FontWeight.bold),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  );

  Widget _optCard({required bool selected, required Color bg, required Color border, required IconData icon,
      required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? border : Colors.transparent, width: 2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 14),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: iconColor.withOpacity(0.7))),
          ]),
        ),
      );
}
