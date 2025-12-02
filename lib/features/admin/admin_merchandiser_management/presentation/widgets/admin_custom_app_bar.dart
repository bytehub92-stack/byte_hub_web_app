// lib/shared/widgets/custom_app_bar.dart
import 'package:admin_panel/core/constants/route_constants.dart';
import 'package:admin_panel/core/di/injection_container.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_bloc.dart';
import 'package:admin_panel/features/shared/auth/presentation/bloc/auth_event.dart';
import 'package:admin_panel/features/shared/profile/presentation/bloc/profile_bloc.dart';
import 'package:admin_panel/features/shared/profile/presentation/bloc/profile_event.dart';
import 'package:admin_panel/features/shared/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AdminCustomAppBar({super.key});

  @override
  State<AdminCustomAppBar> createState() => _AdminCustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdminCustomAppBarState extends State<AdminCustomAppBar> {
  String? profileId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        profileId = user.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return AppBar(
      title: const Text('Byte Hub'),
      leadingWidth: 300,
      leading: Row(
        children: [
          const SizedBox(width: 30),
          BlocProvider(
            create: (context) => sl<ProfileBloc>()..add(const LoadProfile()),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                Widget avatar;

                if (state is ProfileLoaded) {
                  final profile = state.profile;
                  avatar = profile.logoUrl != null
                      ? CircleAvatar(
                          backgroundColor: AppColors.grey100,
                          backgroundImage: NetworkImage(profile.logoUrl!),
                          onBackgroundImageError: (_, __) {},
                          child: Container(),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (user?.email?.substring(0, 1).toUpperCase() ?? 'A'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                } else {
                  avatar = CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.email?.substring(0, 1).toUpperCase() ?? 'A'),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return PopupMenuButton<String>(
                  icon: avatar,
                  onSelected: (value) {
                    if (value == 'logout') {
                      _signOut(context);
                    } else if (value == 'profile') {
                      context.push(RouteConstants.merchandiserProfile);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Profile'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              user?.email ?? '',
              style: AppTextStyles.getBodyMedium(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    context.read<AuthBloc>().add(LogoutRequested());
    context.go(RouteConstants.login);
  }
}
