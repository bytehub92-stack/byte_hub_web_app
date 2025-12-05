// Create this file at: lib/core/debug/env_debug_page.dart
// Temporary page to debug environment variables
// Remove this after confirming everything works

import 'package:admin_panel/core/constants/api_constants.dart';
import 'package:flutter/material.dart';

class EnvDebugPage extends StatelessWidget {
  const EnvDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseUrl = ApiConstants.supabaseUrl;
    final supabaseKey = ApiConstants.supabaseAnonKey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Variables Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environment Variables Status:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatusRow(
              'SUPABASE_URL',
              supabaseUrl.isNotEmpty,
              supabaseUrl.isNotEmpty
                  ? '${supabaseUrl.substring(0, 20)}...'
                  : 'NOT SET',
            ),
            const SizedBox(height: 10),
            _buildStatusRow(
              'SUPABASE_ANON_KEY',
              supabaseKey.isNotEmpty,
              supabaseKey.isNotEmpty
                  ? '${supabaseKey.substring(0, 20)}...'
                  : 'NOT SET',
            ),
            const SizedBox(height: 30),
            if (supabaseUrl.isEmpty || supabaseKey.isEmpty) ...[
              const Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '❌ Missing Environment Variables',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check your GitHub secrets and deploy.yml configuration',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Card(
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ All Environment Variables Loaded',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Configuration is correct!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String name, bool isSet, String value) {
    return Row(
      children: [
        Icon(
          isSet ? Icons.check_circle : Icons.error,
          color: isSet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
