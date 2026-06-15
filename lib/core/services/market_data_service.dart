import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TickerData {
  final String symbol;
  final String price;
  final double rawPrice;
  final String change;
  final bool isUp;
  final LinearGradient gradient;
  final String logoUrl;

  const TickerData(this.symbol, this.price, this.rawPrice, this.change,
      this.isUp, this.gradient, this.logoUrl);
}

class MarketDataService {
  // ─── CRYPTO ──────────────────────────────────────────────
  Stream<List<TickerData>> getCryptoTickersStream() async* {
    while (true) {
      try {
        yield await getCryptoTickers();
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<List<TickerData>> getCryptoTickers() async {
    try {
      return await _fetchCryptoBinance();
    } catch (e) {
      debugPrint('Binance fetch failed: $e');
      try {
        return await _fetchCryptoCoinGecko();
      } catch (e2) {
        debugPrint('CoinGecko fetch failed: $e2');
        try {
          return await _fetchCryptoKucoin();
        } catch (e3) {
          debugPrint('Kucoin fetch failed: $e3');
          throw Exception('Failed to fetch crypto from all sources');
        }
      }
    }
  }

  static const _cryptoSymbols = [
    'BTC',
    'ETH',
    'BNB',
    'SOL',
    'XRP',
    'ADA',
    'AVAX',
    'DOGE'
  ];
  static const _geckoIds =
      'bitcoin,ethereum,binancecoin,solana,ripple,cardano,avalanche-2,dogecoin';

  Future<List<TickerData>> _fetchCryptoBinance() async {
    final syms = _cryptoSymbols.map((s) => '"${s}USDT"').join(',');
    final url =
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbols=[$syms]');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, TickerData> results = {};
      for (var item in data) {
        final symbol = (item['symbol'] as String).replaceAll('USDT', '');
        final price = double.tryParse(item['lastPrice'] ?? '0') ?? 0;
        final change = double.tryParse(item['priceChangePercent'] ?? '0') ?? 0;
        results[symbol] = _createCryptoData(symbol, price, change);
      }
      return _cryptoSymbols
          .map((s) => results[s] ?? _createCryptoData(s, 0, 0))
          .toList();
    } else {
      throw Exception('Binance status: ${response.statusCode}');
    }
  }

  Future<List<TickerData>> _fetchCryptoCoinGecko() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=$_geckoIds&vs_currencies=usd&include_24hr_change=true');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      const idMap = {
        'BTC': 'bitcoin',
        'ETH': 'ethereum',
        'BNB': 'binancecoin',
        'SOL': 'solana',
        'XRP': 'ripple',
        'ADA': 'cardano',
        'AVAX': 'avalanche-2',
        'DOGE': 'dogecoin',
      };
      return _cryptoSymbols.map((s) {
        final id = idMap[s]!;
        return _createCryptoData(s, (data[id]?['usd'] as num?)?.toDouble() ?? 0,
            (data[id]?['usd_24h_change'] as num?)?.toDouble() ?? 0);
      }).toList();
    } else {
      throw Exception('CoinGecko status: ${response.statusCode}');
    }
  }

  Future<List<TickerData>> _fetchCryptoKucoin() async {
    final url = Uri.parse('https://api.kucoin.com/api/v1/market/allTickers');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List tickers = data['data']['ticker'] ?? [];
      final Map<String, TickerData> results = {};
      for (var item in tickers) {
        final symbolRaw = item['symbol'] as String;
        if (symbolRaw.endsWith('-USDT')) {
          final symbol = symbolRaw.replaceAll('-USDT', '');
          if (_cryptoSymbols.contains(symbol)) {
            final price = double.tryParse(item['last'] ?? '0') ?? 0;
            final changeRate = double.tryParse(item['changeRate'] ?? '0') ?? 0;
            results[symbol] =
                _createCryptoData(symbol, price, changeRate * 100);
          }
        }
      }
      return _cryptoSymbols
          .map((s) => results[s] ?? _createCryptoData(s, 0, 0))
          .toList();
    } else {
      throw Exception('Kucoin status: ${response.statusCode}');
    }
  }

  // ─── FOREX ───────────────────────────────────────────────
  Stream<List<TickerData>> getForexTickersStream() async* {
    while (true) {
      try {
        yield await getForexTickers();
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<List<TickerData>> getForexTickers() async {
    try {
      return await _fetchForexYahoo();
    } catch (e) {
      debugPrint('Yahoo Forex fetch failed: $e');
      try {
        return await _fetchForexFrankfurter();
      } catch (e2) {
        debugPrint('Frankfurter fetch failed: $e2');
        try {
          return await _fetchForexErApi();
        } catch (e3) {
          debugPrint('ER-API fetch failed: $e3');
          try {
            return await _fetchForexFloatRates();
          } catch (e4) {
            debugPrint('FloatRates API fetch failed: $e4');
            throw Exception('Failed to fetch forex from all sources');
          }
        }
      }
    }
  }

  // 9 Forex pairs: EUR/USD, GBP/USD, USD/JPY, AUD/USD, USD/CAD, USD/CHF, NZD/USD, USD/CNY, USD/SGD
  static const _forexPairs = [
    ['EURUSD=X', 'EUR/USD'],
    ['GBPUSD=X', 'GBP/USD'],
    ['JPY=X', 'USD/JPY'],
    ['AUDUSD=X', 'AUD/USD'],
    ['CAD=X', 'USD/CAD'],
    ['CHF=X', 'USD/CHF'],
    ['NZDUSD=X', 'NZD/USD'],
    ['CNY=X', 'USD/CNY'],
    ['SGD=X', 'USD/SGD'],
  ];

  Future<List<TickerData>> _fetchForexYahoo() async {
    final urls = _forexPairs
        .map((p) => 'https://query1.finance.yahoo.com/v8/finance/chart/${p[0]}')
        .toList();

    final responses = await Future.wait(urls.map(
        (u) => http.get(Uri.parse(u)).timeout(const Duration(seconds: 15))));

    TickerData parseYahooData(http.Response res, String symbol) {
      double price = 0.0;
      double changePercent = 0.0;
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final result = data['chart']?['result'];
        if (result != null && result.isNotEmpty) {
          final meta = result[0]['meta'];
          price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
          final prevClose =
              (meta['chartPreviousClose'] as num?)?.toDouble() ?? price;
          if (prevClose > 0) { changePercent = ((price - prevClose) / prevClose) * 100; }
        }
      }
      if (price == 0) throw Exception('Failed to parse $symbol from Yahoo');
      return _createForexData(symbol, price, changePercent);
    }

    return List.generate(_forexPairs.length,
        (i) => parseYahooData(responses[i], _forexPairs[i][1]));
  }

  Future<List<TickerData>> _fetchForexFrankfurter() async {
    final url = Uri.parse('https://api.frankfurter.app/latest?from=USD');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      double inv(String c) => 1.0 / ((rates[c] as num?)?.toDouble() ?? 1.0);
      double dir(String c) => (rates[c] as num?)?.toDouble() ?? 0.0;
      return [
        _createForexData('EUR/USD', inv('EUR'), 0.0),
        _createForexData('GBP/USD', inv('GBP'), 0.0),
        _createForexData('USD/JPY', dir('JPY'), 0.0),
        _createForexData('AUD/USD', inv('AUD'), 0.0),
        _createForexData('USD/CAD', dir('CAD'), 0.0),
        _createForexData('USD/CHF', dir('CHF'), 0.0),
        _createForexData('NZD/USD', inv('NZD'), 0.0),
        _createForexData('USD/CNY', dir('CNY'), 0.0),
        _createForexData('USD/SGD', dir('SGD'), 0.0),
      ];
    } else {
      throw Exception('Frankfurter status: ${response.statusCode}');
    }
  }

  Future<List<TickerData>> _fetchForexErApi() async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      double inv(String c) => 1.0 / ((rates[c] as num?)?.toDouble() ?? 1.0);
      double dir(String c) => (rates[c] as num?)?.toDouble() ?? 0.0;
      return [
        _createForexData('EUR/USD', inv('EUR'), 0.0),
        _createForexData('GBP/USD', inv('GBP'), 0.0),
        _createForexData('USD/JPY', dir('JPY'), 0.0),
        _createForexData('AUD/USD', inv('AUD'), 0.0),
        _createForexData('USD/CAD', dir('CAD'), 0.0),
        _createForexData('USD/CHF', dir('CHF'), 0.0),
        _createForexData('NZD/USD', inv('NZD'), 0.0),
        _createForexData('USD/CNY', dir('CNY'), 0.0),
        _createForexData('USD/SGD', dir('SGD'), 0.0),
      ];
    } else {
      throw Exception('ER-API status: ${response.statusCode}');
    }
  }

  Future<List<TickerData>> _fetchForexFloatRates() async {
    final url = Uri.parse('https://www.floatrates.com/daily/usd.json');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      double inv(String c) =>
          (data[c]?['inverseRate'] as num?)?.toDouble() ?? 0.0;
      double dir(String c) => (data[c]?['rate'] as num?)?.toDouble() ?? 0.0;
      return [
        _createForexData('EUR/USD', inv('eur'), 0.0),
        _createForexData('GBP/USD', inv('gbp'), 0.0),
        _createForexData('USD/JPY', dir('jpy'), 0.0),
        _createForexData('AUD/USD', inv('aud'), 0.0),
        _createForexData('USD/CAD', dir('cad'), 0.0),
        _createForexData('USD/CHF', dir('chf'), 0.0),
        _createForexData('NZD/USD', inv('nzd'), 0.0),
        _createForexData('USD/CNY', dir('cny'), 0.0),
        _createForexData('USD/SGD', dir('sgd'), 0.0),
      ];
    } else {
      throw Exception('FloatRates status: ${response.statusCode}');
    }
  }

  // ─── METALS ──────────────────────────────────────────────
  Stream<List<TickerData>> getMetalTickersStream() async* {
    while (true) {
      try {
        yield await getMetalTickers();
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 60));
    }
  }

  Future<List<TickerData>> getMetalTickers() async {
    try {
      return await _fetchMetalsYahoo();
    } catch (e) {
      debugPrint('Yahoo Metals fetch failed: $e');
      try {
        return await _fetchMetalsBinancePaxg();
      } catch (e2) {
        debugPrint('Binance Metals fallback failed: $e2');
        return _mockMetalsFallback();
      }
    }
  }

  // Yahoo tickers: GC=F Gold, SI=F Silver, HG=F Copper, TI=F Titanium (proxy)
  static const _metalYahooTickers = ['GC=F', 'SI=F', 'HG=F'];
  static const _metalSymbols = ['XAU/USD', 'XAG/USD', 'XCU/USD'];

  Future<List<TickerData>> _fetchMetalsYahoo() async {
    final urls = _metalYahooTickers.map((t) =>
        Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$t'));

    final responses = await Future.wait(
        urls.map((u) => http.get(u).timeout(const Duration(seconds: 15))));

    double parsePrice(http.Response res) {
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final result = data['chart']?['result'];
        if (result != null && result.isNotEmpty) {
          return (result[0]['meta']['regularMarketPrice'] as num?)
                  ?.toDouble() ??
              0.0;
        }
      }
      return 0.0;
    }

    double parseChange(http.Response res) {
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final result = data['chart']?['result'];
        if (result != null && result.isNotEmpty) {
          final meta = result[0]['meta'];
          final price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
          final prev =
              (meta['chartPreviousClose'] as num?)?.toDouble() ?? price;
          return prev > 0 ? ((price - prev) / prev) * 100 : 0.0;
        }
      }
      return 0.0;
    }

    final prices = responses.map(parsePrice).toList();
    final changes = responses.map(parseChange).toList();
    if (prices.any((p) => p == 0)) {
      throw Exception('Failed to parse Yahoo Metals');
    }

    // Add Titanium as static approximation (no free live feed)
    return [
      ..._metalSymbols.asMap().entries.map((e) =>
          _createMetalData(e.value, prices[e.key], changes[e.key], e.value)),
      _createMetalData('XTI/USD', 11.20, 0.0, 'Titanium'), // Approx spot USD/kg
    ];
  }

  Future<List<TickerData>> _fetchMetalsBinancePaxg() async {
    final url =
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=PAXGUSDT');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final goldPrice = double.tryParse(data['lastPrice'] ?? '0') ?? 0;
      final goldChange =
          double.tryParse(data['priceChangePercent'] ?? '0') ?? 0;
      return [
        _createMetalData('XAU/USD', goldPrice, goldChange, 'Gold'),
        _createMetalData('XAG/USD', 30.50, 0.0, 'Silver'),
        _createMetalData('XCU/USD', 4.20, 0.0, 'Copper'),
        _createMetalData('XTI/USD', 11.20, 0.0, 'Titanium'),
      ];
    } else {
      throw Exception('Binance PAXG status: ${response.statusCode}');
    }
  }

  List<TickerData> _mockMetalsFallback() {
    return [
      _createMetalData('XAU/USD', 2420.50, 0.40, 'Gold'),
      _createMetalData('XAG/USD', 31.10, -0.20, 'Silver'),
      _createMetalData('XCU/USD', 4.22, 0.10, 'Copper'),
      _createMetalData('XTI/USD', 11.20, 0.00, 'Titanium'),
    ];
  }

  // ─── HELPERS ─────────────────────────────────────────────
  TickerData _createCryptoData(
      String symbol, double price, double changePercent) {
    const gradientMap = <String, List<Color>>{
      'BTC': [Color(0xFFF7931A), Color(0xFFBF6F10)],
      'ETH': [Color(0xFF627EEA), Color(0xFF3D4FC4)],
      'BNB': [Color(0xFFF3BA2F), Color(0xFFC87F0A)],
      'SOL': [Color(0xFF9945FF), Color(0xFF14F195)],
      'XRP': [Color(0xFF006097), Color(0xFF003D5C)],
      'ADA': [Color(0xFF0033AD), Color(0xFF001F6B)],
      'AVAX': [Color(0xFFE84142), Color(0xFF9B1B1C)],
      'DOGE': [Color(0xFFC2A633), Color(0xFF8B7225)],
    };
    const logoMap = <String, String>{
      'BTC': 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
      'ETH': 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
      'BNB': 'https://cryptologos.cc/logos/bnb-bnb-logo.png',
      'SOL': 'https://cryptologos.cc/logos/solana-sol-logo.png',
      'XRP': 'https://cryptologos.cc/logos/xrp-xrp-logo.png',
      'ADA': 'https://cryptologos.cc/logos/cardano-ada-logo.png',
      'AVAX': 'https://cryptologos.cc/logos/avalanche-avax-logo.png',
      'DOGE': 'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
    };
    final colors = gradientMap[symbol] ??
        [const Color(0xFFF7931A), const Color(0xFFBF6F10)];
    return _buildData(symbol, price, changePercent,
        LinearGradient(colors: colors), logoMap[symbol] ?? '');
  }

  TickerData _createForexData(String pair, double price, double changePercent) {
    const flagMap = <String, String>{
      'EUR': 'https://cdn-icons-png.flaticon.com/512/330/330426.png',
      'GBP': 'https://cdn-icons-png.flaticon.com/512/330/330425.png',
      'JPY': 'https://cdn-icons-png.flaticon.com/512/330/330622.png',
      'AUD': 'https://cdn-icons-png.flaticon.com/512/330/330451.png',
      'CAD': 'https://cdn-icons-png.flaticon.com/512/330/330457.png',
      'CHF': 'https://cdn-icons-png.flaticon.com/512/330/330459.png',
      'NZD': 'https://cdn-icons-png.flaticon.com/512/330/330533.png',
      'CNY': 'https://cdn-icons-png.flaticon.com/512/330/330490.png',
      'SGD': 'https://cdn-icons-png.flaticon.com/512/330/330580.png',
    };
    String logoUrl = 'https://cdn-icons-png.flaticon.com/512/5111/5111166.png';
    for (final entry in flagMap.entries) {
      if (pair.contains(entry.key)) {
        logoUrl = entry.value;
        break;
      }
    }
    const gradient =
        LinearGradient(colors: [Color(0xFF1A6B3A), Color(0xFF0D3D20)]);
    return _buildData(pair, price, changePercent, gradient, logoUrl,
        precision: 4);
  }

  TickerData _createMetalData(
      String symbol, double price, double changePercent, String name) {
    const gradientMap = <String, List<Color>>{
      'XAU/USD': [Color(0xFFFFD700), Color(0xFFFFA000)],
      'XAG/USD': [Color(0xFFB0BEC5), Color(0xFF78909C)],
      'XCU/USD': [Color(0xFFB87333), Color(0xFF7D4F24)],
      'XTI/USD': [Color(0xFF90A4AE), Color(0xFF546E7A)],
    };
    const emojiMap = <String, String>{
      'XAU/USD': '🥇 ',
      'XAG/USD': '🥈 ',
      'XCU/USD': '🟤 ',
      'XTI/USD': '⚙️ ',
    };
    final colors = gradientMap[symbol] ??
        [const Color(0xFFFFD700), const Color(0xFFFFA000)];
    return _buildData(symbol, price, changePercent,
        LinearGradient(colors: colors), '', // no icon for metals
        prefix: emojiMap[symbol] ?? '');
  }

  TickerData _buildData(String symbol, double price, double changePercent,
      LinearGradient gradient, String logoUrl,
      {int precision = 2, String prefix = ''}) {
    String formattedPrice;
    if (price >= 1000) {
      formattedPrice =
          '\$${price.toStringAsFixed(precision).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } else {
      formattedPrice = '\$${price.toStringAsFixed(precision)}';
    }

    final isUp = changePercent >= 0;
    final formattedChange = changePercent == 0.0
        ? '0.0%'
        : '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

    return TickerData(prefix + symbol, formattedPrice, price, formattedChange,
        isUp, gradient, logoUrl);
  }
}
