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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 추후 화면 변경을 위한 탭 번호

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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 눌린 탭 기억
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: '노크'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '집'),
          BottomNavigationBarItem(icon: Icon(Icons.room), label: '방'),
        ],
      ),
    );
  }
}
