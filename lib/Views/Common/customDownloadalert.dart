// lib/Commands/custom_download_alert.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/assessment_model.dart';
import '../../Services/firestore_service.dart';
import '../../Services/auth_service.dart';

class CustomDownloadAlert extends StatelessWidget {
  CustomDownloadAlert({
    super.key,
    required this.referral,
    required this.displayName,
    String? practitionerUid,
  }) : practitionerUid = practitionerUid ?? Get.find<AuthService>().currentUser?.uid ?? '';

  final String referral;
  final String displayName;
  final String practitionerUid;

  @override
  Widget build(BuildContext context) {
    final fs = Get.find<FirestoreService>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Available Forms – $displayName',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // List of completed files (this practitioner only)
            StreamBuilder<List<AssessmentModel>>(
              stream: fs.streamPatientCompletedAssessments(
                referral: referral,
                practitionerUid: practitionerUid.isEmpty ? null : practitionerUid,
              ),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snap.data!;
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No completed assessments yet.', style: TextStyle(color: Colors.black54)),
                  );
                }

                return Column(
                  children: [
                    ...items.map((a) => _FileRow(
                      assessment: a,
                      practitionerUid: practitionerUid,
                      onDownload: () async {
                        await _generateAndDownloadPdf(a); // ⬅️ replace with real export
                        await fs.markAssessmentDownloaded(
                          referral: referral,
                          assessmentId: a.id,
                          practitionerUid: practitionerUid,
                        );
                      },
                    )),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5661),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        onPressed: () async {
                          for (final a in items) {
                            await _generateAndDownloadPdf(a); // ⬅️ replace with real export
                            await fs.markAssessmentDownloaded(
                              referral: referral,
                              assessmentId: a.id,
                              practitionerUid: practitionerUid,
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download All'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.assessment,
    required this.practitionerUid,
    required this.onDownload,
  });

  final AssessmentModel assessment;
  final String practitionerUid;
  final Future<void> Function() onDownload;

  @override
  Widget build(BuildContext context) {
    final already = assessment.downloadedBy[practitionerUid] == true;
    final btnColor = already ? const Color(0xFFBBD1D7) : const Color(0xFF2D5661);

    // Safer local filename (avoid relying on a non-existent getter)
    final when = assessment.completedAt ?? assessment.updatedAt;
    final dateStr = DateFormat('yyyyMMdd').format(when);
    final fileName =
    '${assessment.lastName}_${assessment.firstName}_$dateStr.pdf'.replaceAll(' ', '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined, size: 20, color: Colors.black54),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            onPressed: onDownload,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }
}

// TODO: connect to your real PDF-generation + file saver
Future<void> _generateAndDownloadPdf(AssessmentModel a) async {
  await Future.delayed(const Duration(milliseconds: 350));
}
