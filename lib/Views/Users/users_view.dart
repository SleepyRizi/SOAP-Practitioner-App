import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Common/bottom_bar.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final nowStr = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    final scrW   = MediaQuery.of(context).size.width;
    final isTab  = scrW > 600;
    final titleSz= isTab ? 42.5 : 34.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFF),
      appBar: AppBar(
        toolbarHeight: isTab ? 100 : 86,
        backgroundColor: const Color(0xFFFAFDFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 32,
        title: Text(
          'Patients',
          style: TextStyle(
            fontFamily : 'Cormorant Garamond',
            fontSize   : titleSz,
            fontWeight : FontWeight.w600,
            color      : Colors.black,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Text(
                nowStr,
                style: TextStyle(
                  fontFamily : 'Avenir',
                  fontSize   : isTab ? 20 : 16,
                  fontWeight : FontWeight.w300,
                  color      : const Color(0xFF696969),
                ),
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Build out patient management here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(current: BottomTab.users),
    );
  }
}
