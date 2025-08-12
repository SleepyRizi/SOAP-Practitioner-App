import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

enum BottomTab { home, users, settings }

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, required this.current});
  final BottomTab current;

  @override
  Widget build(BuildContext context) {
    Widget usersIcon(bool active) => Image.asset(
      'assets/images/${active ? 'UsersColored.png' : 'Users_gray.png'}',
      width: 24,
      height: 24,
    );

    Widget settingsIcon(bool active) => Image.asset(
      'assets/images/${active ? 'NutColored.png' : 'NutBlack.png'}',
      width: 24,
      height: 24,
    );

    Widget item({required Widget icon, required VoidCallback onTap}) =>
        InkWell(onTap: onTap, child: icon);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        color: const Color(0xFFFAFDFF),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 59, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home (keeps the vector icon)
          item(
            icon: Icon(
              Icons.home,
              size: 24,
              color: current == BottomTab.home
                  ? const Color(0xFF2D5661)
                  : Colors.black54,
            ),
            onTap: () {
              if (current != BottomTab.home) Get.offAllNamed(Routes.home);
            },
          ),

          // Users (image swap)
          item(
            icon: usersIcon(current == BottomTab.users),
            onTap: () {
              if (current != BottomTab.users) Get.offAllNamed(Routes.users);
            },
          ),

          // Settings (image swap)
          item(
            icon: settingsIcon(current == BottomTab.settings),
            onTap: () {
              if (current != BottomTab.settings) {
                Get.offAllNamed(Routes.settings);
              }
            },
          ),
        ],
      ),
    );
  }
}
