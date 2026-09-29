import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CryptoApp());
}

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Precios cripto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  const CryptoHomePage({super.key});

  @override
  State<CryptoHomePage> createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  List<dynamic> _coins = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.coingecko.com/api/v3/coins/markets'
          '?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('La API respondió con ${response.statusCode}');
      }

      setState(() {
        _coins = jsonDecode(response.body) as List<dynamic>;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'No se pudieron cargar los precios.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado cripto'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadCoins,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadCoins,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoins,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Las 10 criptomonedas principales',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text('Precios en dólares, proporcionados por CoinGecko.'),
          const SizedBox(height: 16),
          ..._coins.map((coin) => _CoinCard(coin: coin)),
        ],
      ),
    );
  }
}

class _CoinCard extends StatelessWidget {
  const _CoinCard({required this.coin});

  final dynamic coin;

  @override
  Widget build(BuildContext context) {
    final change =
        (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0;
    final isPositive = change >= 0;
    final symbol = '${coin['symbol']}'.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(symbol.substring(0, 1))),
        title: Text('${coin['name']}'),
        subtitle: Text('#${coin['market_cap_rank']}  $symbol'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${(coin['current_price'] as num).toStringAsFixed(2)}'),
            Text(
              '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
              style: TextStyle(color: isPositive ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
