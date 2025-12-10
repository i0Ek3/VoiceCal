import 'package:flutter/material.dart';
import '../utils/api_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _openAIController = TextEditingController();
  final TextEditingController _anthropicController = TextEditingController();
  
  bool _isTtsEnabled = true;
  String _selectedLanguage = 'auto';
  bool _isUsingDefaultKeys = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _openAIController.dispose();
    _anthropicController.dispose();
    super.dispose();
  }
  
  // Load settings
  void _loadSettings() {
    setState(() {
      _openAIController.text = ApiConfig.openAIKey;
      _anthropicController.text = ApiConfig.anthropicKey;
      _isTtsEnabled = ApiConfig.isTtsEnabled;
      _selectedLanguage = ApiConfig.language;
      _isUsingDefaultKeys = ApiConfig.isUsingDefaultKeys;
    });
  }
  
  // Save settings
  Future<void> _saveSettings() async {
    await ApiConfig.setOpenAIKey(_openAIController.text.trim());
    await ApiConfig.setAnthropicKey(_anthropicController.text.trim());
    await ApiConfig.setTtsEnabled(_isTtsEnabled);
    await ApiConfig.setLanguage(_selectedLanguage);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }
  
  // Reset to defaults
  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all settings to default values. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ApiConfig.clearAll();
      _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Keys Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.key),
                      const SizedBox(width: 8),
                      Text(
                        'API Keys',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isUsingDefaultKeys)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Using built-in demo keys (limited usage). Add your own keys below.',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // OpenAI API Key
                  TextField(
                    controller: _openAIController,
                    decoration: const InputDecoration(
                      labelText: 'OpenAI API Key',
                      hintText: 'sk-proj-...',
                      helperText: 'For speech recognition (Whisper)',
                      prefixIcon: Icon(Icons.mic),
                    ),
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Open URL in browser (you'd need url_launcher package)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Get key at: https://platform.openai.com/api-keys'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Get OpenAI API Key'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Anthropic API Key
                  TextField(
                    controller: _anthropicController,
                    decoration: const InputDecoration(
                      labelText: 'Anthropic API Key',
                      hintText: 'sk-ant-...',
                      helperText: 'For calculation understanding (Claude)',
                      prefixIcon: Icon(Icons.calculate),
                    ),
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Get key at: https://console.anthropic.com/'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Get Anthropic API Key'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_up),
                      const SizedBox(width: 8),
                      Text(
                        'Voice Settings',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Enable TTS
                  SwitchListTile(
                    title: const Text('Voice Output'),
                    subtitle: const Text('Speak calculation results aloud'),
                    value: _isTtsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isTtsEnabled = value;
                      });
                    },
                  ),
                  
                  const Divider(),
                  
                  // Language selection
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(_getLanguageName(_selectedLanguage)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => _showLanguageDialog(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'About',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  const ListTile(
                    title: Text('VoiceCal'),
                    subtitle: Text('Version 1.0.0'),
                  ),
                  
                  const ListTile(
                    title: Text('Powered By'),
                    subtitle: Text('OpenAI Whisper & Anthropic Claude'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reset button
          OutlinedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.all(16),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  // Show language selection dialog
  Future<void> _showLanguageDialog() async {
    final languages = {
      'auto': 'Auto Detect',
      'en': 'English',
      'zh': 'Chinese (中文)',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'ja': 'Japanese',
      'ko': 'Korean',
    };
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
      ),
    );
    
    if (selected != null) {
      setState(() {
        _selectedLanguage = selected;
      });
    }
  }
  
  // Get language display name
  String _getLanguageName(String code) {
    final names = {
      'auto': 'Auto Detect',
      'en': 'English',
      'zh': 'Chinese (中文)',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'ja': 'Japanese',
      'ko': 'Korean',
    };
    return names[code] ?? code;
  }
}