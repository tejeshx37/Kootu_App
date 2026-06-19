import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/categories.dart';

/// Classifies a free-text item name into one of [Categories.all] ids using the
/// Gemini API, falling back to the local keyword matcher whenever the key is
/// missing or the network call fails. Categorization must never block adding an
/// item, so every failure path degrades gracefully to the keyword guess.
class AiCategorizer {
  AiCategorizer({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ??
            const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '') {
    // One-time visibility into whether the build picked up the key. Never
    // prints the key itself — only whether it's present and its length.
    debugPrint('[Gemini] isConfigured=${_apiKey.isNotEmpty}, '
        'keyLen=${_apiKey.length}');
  }

  final http.Client _client;
  final String _apiKey;

  static const _model = 'gemini-2.0-flash';
  static const _timeout = Duration(seconds: 6);

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Returns a valid category id. Never throws.
  Future<String> categorize(String itemName) async {
    final fallback = Categories.categorizeByKeyword(itemName).id;
    if (itemName.trim().isEmpty) return fallback;
    if (!isConfigured) {
      debugPrint('[Gemini] no key — keyword fallback "$itemName" → $fallback');
      return fallback;
    }

    try {
      final ids = Categories.all.map((c) => c.id).join(', ');
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$_model:generateContent?key=$_apiKey',
      );
      final prompt =
          'You categorize Indian grocery/household shopping list items. '
          'Item names may be in English, Hindi, Tamil, Telugu, Kannada or '
          'transliterated/Tanglish (e.g. "vengayam"=onion=>vegetables, '
          '"paruppu"=dal=>grains_dal, "thayir"=curd=>dairy, "meen"=fish=>'
          'meat_fish, "manjal"=turmeric=>spices). Reply with EXACTLY ONE '
          'category id from this list and nothing else: $ids. '
          'Item: "$itemName"';

      final resp = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {'temperature': 0, 'maxOutputTokens': 10},
            }),
          )
          .timeout(_timeout);

      if (resp.statusCode != 200) {
        debugPrint('[Gemini] HTTP ${resp.statusCode} for "$itemName" — '
            'fallback $fallback. Body: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}');
        return fallback;
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = body['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return fallback;
      final parts = (candidates.first as Map?)?['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) return fallback;
      final text = (parts.first as Map?)?['text'] as String?;
      if (text == null) return fallback;
      debugPrint('[Gemini] "$itemName" → raw reply: ${text.trim()}');

      final guess = text.trim().toLowerCase();
      // Match by exact id, id contained, or the human label — so replies like
      // "vegetables", "grains_dal", or "Grains & Dal" all resolve. Non-'other'
      // categories are checked first so a stray word doesn't fall to 'other'.
      for (final c in Categories.all) {
        if (c.id == 'other') continue;
        if (guess == c.id ||
            guess.contains(c.id) ||
            guess.contains(c.label.toLowerCase())) {
          return c.id;
        }
      }
      return guess.contains('other') ? 'other' : fallback;
    } on TimeoutException {
      debugPrint('[Gemini] timeout for "$itemName" — fallback $fallback');
      return fallback;
    } catch (e) {
      debugPrint('[Gemini] error for "$itemName": $e — fallback $fallback');
      return fallback;
    }
  }
}
