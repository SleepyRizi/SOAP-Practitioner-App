import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormDetailView extends StatelessWidget {
  const FormDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final referral = Get.arguments['referral'];
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Form')),
      body: Center(
        child: Text(
          'Form details for referral: $referral\n\n'
              '🚧  Build out completion UI here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
