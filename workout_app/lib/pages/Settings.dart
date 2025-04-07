import 'package:flutter/material.dart';
import '../helpers/settings_helper.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class Settings extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final VoidCallback? onWeightChanged;

  const Settings({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    this.onWeightChanged,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final weight = await SettingsHelper.getWeight();
      final height = await SettingsHelper.getHeight();

      if (mounted) {
        setState(() {
          _weightController.text = weight.toString();
          _heightController.text = height.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final weight = double.tryParse(_weightController.text) ?? 70.0;
      final height = double.tryParse(_heightController.text) ?? 170.0;

      await SettingsHelper.setWeight(weight);
      await SettingsHelper.setHeight(height);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
        widget.onWeightChanged?.call();
      }
    } catch (e) {
      print('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving settings')),
        );
      }
    }
  }

  Future<void> _toggleTheme() async {
    if (!mounted) return;
    try {
      await SettingsHelper.setDarkMode(!widget.isDarkMode);
      if (mounted) {
        widget.toggleTheme();
      }
    } catch (e) {
      if (mounted) {
        print('Error toggling theme: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: widget.isDarkMode,
              onChanged: (value) => _toggleTheme(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Body Measurements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
