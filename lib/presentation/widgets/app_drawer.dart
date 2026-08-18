import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../pages/sign_in_page.dart';
import 'animated_drawing_text_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.brandDarkGreen,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.brandDarkGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedDrawingTextLogo(
                  height: 32.0,
                  strokeColor: AppColors.brandGold,
                  fillColor: AppColors.brandGold,
                  duration: Duration(seconds: 3),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.brandGold),
            title: const Text(
              'Sign In / Account',
              style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignInPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.brandGold),
            title: const Text(
              'Order History',
              style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignInPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer, color: AppColors.brandGold),
            title: const Text(
              'Offers & Promos',
              style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          const Divider(color: AppColors.brandGold),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.brandGold),
            title: const Text(
              'Help & Support',
              style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.brandGold),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}
