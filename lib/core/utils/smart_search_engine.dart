import 'dart:math';
import '../../domain/entities/product.dart';

class SmartSearchEngine {
  /// Arabic character normalization map and regex
  static final RegExp _tashkeelRegex = RegExp(r'[\u064B-\u0652\u0670\u0640]');
  static final RegExp _punctuationRegex = RegExp(r'[.,/#!$%\^&\*;:{}=\-_`~()|\[\]"\\?؟،]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Normalizes Arabic and English text for accurate multi-lingual search
  static String normalize(String text) {
    if (text.isEmpty) return '';

    String result = text.toLowerCase();

    // 1. Remove Tashkeel and Tatweel (Kashida)
    result = result.replaceAll(_tashkeelRegex, '');

    // 2. Normalize Arabic Alef variants (أ, إ, آ, ٱ -> ا)
    result = result
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        // 3. Normalize Taa Marbuta & Haa (ة -> ه)
        .replaceAll('ة', 'ه')
        // 4. Normalize Alef Maksura & Yaa (ى -> ي)
        .replaceAll('ى', 'ي')
        // 5. Normalize Persian/Urdu variants (ک -> ك, ی -> ي, ؤ -> و, ئ -> ي)
        .replaceAll('ک', 'ك')
        .replaceAll('ی', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');

    // 6. Replace punctuation and symbols with space
    result = result.replaceAll(_punctuationRegex, ' ');

    // 7. Collapse extra spaces
    result = result.replaceAll(_whitespaceRegex, ' ').trim();

    return result;
  }

  /// Remove common Arabic and English prefixes (like "الـ" or "the")
  static String stripPrefixes(String token) {
    if (token.startsWith('ال') && token.length > 3) {
      return token.substring(2);
    }
    if (token.startsWith('the ') && token.length > 4) {
      return token.substring(4);
    }
    return token;
  }

  /// Calculates Levenshtein Distance for typo tolerance
  static int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v0[j + 1] + 1, min(v1[j] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[s2.length];
  }

  /// Checks if two tokens match with typo tolerance
  static bool _fuzzyMatch(String a, String b) {
    if (a == b) return true;
    final cleanA = stripPrefixes(a);
    final cleanB = stripPrefixes(b);
    if (cleanA == cleanB) return true;

    final maxLen = max(cleanA.length, cleanB.length);
    if (maxLen <= 3) return cleanA == cleanB;

    // Allow 1 typo for words 4-7 chars, 2 typos for longer words
    final maxAllowedDist = maxLen >= 8 ? 2 : 1;
    return _levenshtein(cleanA, cleanB) <= maxAllowedDist;
  }

  /// Searches products using Weighted Multi-Token + Arabic Normalization algorithm
  static List<Product> search({
    required List<Product> products,
    required String query,
  }) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return products;

    final queryTokens = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();
    if (queryTokens.isEmpty) return products;

    final scoredProducts = <_ScoredProduct>[];

    for (final product in products) {
      final normTitle = normalize(product.title);
      final normDesc = normalize(product.description ?? '');
      final titleTokens = normTitle.split(' ').where((t) => t.isNotEmpty).toList();
      final descTokens = normDesc.split(' ').where((t) => t.isNotEmpty).toList();

      double score = 0.0;
      int matchedTokensCount = 0;

      // 1. Exact Full Phrase Match in Title (+150 pts)
      if (normTitle == normalizedQuery) {
        score += 200.0;
      } else if (normTitle.contains(normalizedQuery)) {
        score += 120.0;
        if (normTitle.startsWith(normalizedQuery)) {
          score += 50.0;
        }
      }

      // 2. Token-by-Token Weighted Scoring
      for (final qToken in queryTokens) {
        final strippedQToken = stripPrefixes(qToken);
        bool tokenMatchedInTitle = false;
        bool tokenMatchedInDesc = false;

        // A. Title Tokens Matching
        for (final tToken in titleTokens) {
          final strippedTToken = stripPrefixes(tToken);

          if (tToken == qToken || strippedTToken == strippedQToken) {
            // Exact Word Match in Title (+70 pts)
            score += 70.0;
            tokenMatchedInTitle = true;
            break;
          } else if (tToken.startsWith(qToken) || strippedTToken.startsWith(strippedQToken)) {
            // Prefix Match in Title (+45 pts, e.g. "تف" -> "تفاح")
            score += 45.0;
            tokenMatchedInTitle = true;
            break;
          } else if (tToken.contains(qToken) || strippedTToken.contains(strippedQToken)) {
            // Substring Match in Title (+30 pts)
            score += 30.0;
            tokenMatchedInTitle = true;
            break;
          } else if (_fuzzyMatch(tToken, qToken)) {
            // Typo Tolerant Fuzzy Match in Title (+25 pts)
            score += 25.0;
            tokenMatchedInTitle = true;
            break;
          }
        }

        // B. Description Tokens Matching (if not found in title)
        if (!tokenMatchedInTitle) {
          for (final dToken in descTokens) {
            final strippedDToken = stripPrefixes(dToken);
            if (dToken == qToken || strippedDToken == strippedQToken) {
              score += 15.0;
              tokenMatchedInDesc = true;
              break;
            } else if (dToken.startsWith(qToken) || strippedDToken.startsWith(strippedQToken)) {
              score += 10.0;
              tokenMatchedInDesc = true;
              break;
            } else if (_fuzzyMatch(dToken, qToken)) {
              score += 8.0;
              tokenMatchedInDesc = true;
              break;
            }
          }
        }

        if (tokenMatchedInTitle || tokenMatchedInDesc) {
          matchedTokensCount++;
        }
      }

      // 3. Multi-token Completeness Bonus (+60 pts if all words in query match)
      if (matchedTokensCount == queryTokens.length) {
        score += 60.0;
      } else if (matchedTokensCount > 0) {
        // Proportional score based on percentage of query words matched
        score += (matchedTokensCount / queryTokens.length) * 30.0;
      }

      if (score > 0) {
        scoredProducts.add(_ScoredProduct(product: product, score: score));
      }
    }

    // Sort descending by relevance score
    scoredProducts.sort((a, b) => b.score.compareTo(a.score));

    return scoredProducts.map((sp) => sp.product).toList();
  }
}

class _ScoredProduct {
  final Product product;
  final double score;

  const _ScoredProduct({required this.product, required this.score});
}
