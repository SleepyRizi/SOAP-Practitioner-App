import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Services/firestore_service.dart';
import '../../Models/patient_model.dart';

class PatientDetailView extends StatelessWidget {
  const PatientDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final referral = Get.arguments['referral'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Detail')),
      body: referral == null
          ? const Center(child: Text('No referral id passed'))
          : StreamBuilder<PatientModel?>(
        stream: Get.find<FirestoreService>()
            .streamPatient(referral), // implement if needed
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final patient = snap.data;
          if (patient == null) {
            return const Center(child: Text('Patient not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${patient.firstName} ${patient.lastName}\nDOB: ${patient.dob}',
            ),
          );
        },
      ),
    );
  }
}
