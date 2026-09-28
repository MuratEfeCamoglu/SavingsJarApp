import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/security_provider.dart';

/// Shows [child] only after a successful unlock when Biometric Lock is on.
class BiometricGate extends StatefulWidget {
  final Widget child;
  const BiometricGate({Key? key, required this.child}) : super(key: key);

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {
  late bool _unlocked;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    _unlocked = !context.read<SecurityProvider>().biometricEnabled;
    if (!_unlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final security = context.read<SecurityProvider>();
    // If the device lost its screen lock, there is nothing to verify against.
    final ok = !await security.isSupported() ||
        await security.authenticate('Unlock your savings jars');
    if (mounted) {
      setState(() {
        _unlocked = ok;
        _authenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 72, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text('Savings Jar is locked',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            _authenticating
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _unlock,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Unlock'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
