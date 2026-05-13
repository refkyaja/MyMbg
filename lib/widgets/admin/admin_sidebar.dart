import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onLogout,
  });

  final AdminTab activeTab;
  final ValueChanged<AdminTab> onTabSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final List<_SidebarItemData> items = <_SidebarItemData>[
      _SidebarItemData(
        tab: AdminTab.dashboard,
        icon: Icons.dashboard_customize_rounded,
        label: 'Dashboard',
      ),
      _SidebarItemData(
        tab: AdminTab.menu,
        icon: Icons.restaurant_menu_rounded,
        label: 'Menu MBG',
      ),
      _SidebarItemData(
        tab: AdminTab.kelas,
        icon: Icons.menu_book_rounded,
        label: 'Data Kelas',
      ),
      _SidebarItemData(
        tab: AdminTab.monitoring,
        icon: Icons.visibility_rounded,
        label: 'Monitoring',
      ),
      _SidebarItemData(
        tab: AdminTab.riwayat,
        icon: Icons.history_rounded,
        label: 'Riwayat',
      ),
    ];

    return Container(
      color: AppColors.slate900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: const Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x3310B981),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.emerald,
                      size: 32,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text.rich(
                  TextSpan(
                    text: 'My',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Mbg',
                        style: TextStyle(color: AppColors.emerald),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Text(
              'MENU UTAMA',
              style: TextStyle(
                color: AppColors.slate500,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (BuildContext context, int index) {
                final _SidebarItemData item = items[index];
                final bool isActive = item.tab == activeTab;
                return InkWell(
                  onTap: () => onTabSelected(item.tab),
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.emerald : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          item.icon,
                          color: isActive ? Colors.white : AppColors.slate300,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.slate300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1AF87171),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
                    SizedBox(width: 12),
                    Text(
                      'Logout Admin',
                      style: TextStyle(
                        color: Color(0xFFF87171),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItemData {
  const _SidebarItemData({
    required this.tab,
    required this.icon,
    required this.label,
  });

  final AdminTab tab;
  final IconData icon;
  final String label;
}
