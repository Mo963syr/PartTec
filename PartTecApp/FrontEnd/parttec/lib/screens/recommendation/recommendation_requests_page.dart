import 'package:flutter/material.dart';

class RecommendationRequestsPage extends StatelessWidget {
  const RecommendationRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التوصية'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'هنا سيتم عرض طلبات التوصية الواردة من الزبائن.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
