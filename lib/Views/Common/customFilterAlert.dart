// lib/Commands/custom_filter_alert.dart
import 'package:flutter/material.dart';
import '../../Services/firestore_service.dart'; // for QuickRange & SortOption

/// What the dialog returns to the caller.
class FilterResult {
  final QuickRange range;
  final SortOption sort;
  const FilterResult({required this.range, required this.sort});
}

class CustomFilterAlert extends StatefulWidget {
  const CustomFilterAlert({super.key});

  @override
  State<CustomFilterAlert> createState() => _CustomFilterAlertState();
}

class _CustomFilterAlertState extends State<CustomFilterAlert> {
  QuickRange range = QuickRange.today; // default (matches your mock)
  SortOption sort = SortOption.nameAsc;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Container(
        width: 562,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(
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

            // Quick ranges
            Wrap(
              spacing: 10,
              children: [
                _chip('Today',
                    active: range == QuickRange.today,
                    onTap: () => setState(() => range = QuickRange.today)),
                _chip('Last 7 days',
                    active: range == QuickRange.last7,
                    onTap: () => setState(() => range = QuickRange.last7)),
                _chip('All',
                    active: range == QuickRange.all,
                    onTap: () => setState(() => range = QuickRange.all)),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Sort by',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: [
                _chip('Name (A-Z)',
                    active: sort == SortOption.nameAsc,
                    onTap: () => setState(() => sort = SortOption.nameAsc)),
                _chip('Last Visit (new > old)',
                    active: sort == SortOption.lastVisitDesc,
                    onTap: () => setState(() => sort = SortOption.lastVisitDesc)),
              ],
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5661),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(
                    FilterResult(range: range, sort: sort),
                  );
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, {required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          color: active ? const Color(0xFF2D5661) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: active ? Colors.transparent : const Color(0xFFBBD1D7)),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
