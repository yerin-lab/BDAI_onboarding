import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Knock Knock',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단바
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          tooltip: '검색',
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.forum),
            tooltip: '채팅',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
            tooltip: '필터',
          ),
        ],
      ),

      body: const Center(child: Text('Knock Knock')),
    );
  }
}
