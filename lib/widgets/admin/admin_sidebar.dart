import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onLogout,
    this.isCollapsed = false,
  });

  final AdminTab activeTab;
  final ValueChanged<AdminTab> onTabSelected;
  final VoidCallback onLogout;
  final bool isCollapsed;

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
      _SidebarItemData(
        tab: AdminTab.feedback,
        icon: Icons.rate_review_rounded,
        label: 'Feedback',
      ),
    ];

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.emerald,
        border: Border(
          right: BorderSide(
            color: isDark 
                ? const Color(0xFF1E293B) 
                : AppColors.emeraldDark.withOpacity(0.2),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Logo / Brand Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            height: 74,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 13 : 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: isCollapsed
                  ? Center(
                      key: const ValueKey<bool>(true),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x3310B981) : Colors.white.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(14)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: isDark ? AppColors.emerald : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey<bool>(false),
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x3310B981) : Colors.white.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: isDark ? AppColors.emerald : Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'My',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Mbg',
                                  style: TextStyle(
                                    color: isDark ? AppColors.emerald : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Section Label or Divider
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: isCollapsed
                ? Padding(
                    key: const ValueKey<bool>(true),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Divider(
                      color: isDark ? AppColors.slate700 : Colors.white.withOpacity(0.15),
                      height: 1,
                    ),
                  )
                : Padding(
                    key: const ValueKey<bool>(false),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'MENU UTAMA',
                        style: TextStyle(
                          color: isDark ? AppColors.slate500 : Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
          ),
          // Menu Items
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 10 : 18),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (BuildContext context, int index) {
                final _SidebarItemData item = items[index];
                final bool isActive = item.tab == activeTab;

                return _SidebarItem(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  isDark: isDark,
                  onTap: () => onTabSelected(item.tab),
                );
              },
            ),
          ),
          // Logout Button
          Padding(
            padding: EdgeInsets.all(isCollapsed ? 10 : 18),
            child: _LogoutButton(
              onTap: onLogout,
              isCollapsed: isCollapsed,
              isDark: isDark,
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

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.isDark,
    required this.onTap,
  });

  final _SidebarItemData item;
  final bool isActive;
  final bool isCollapsed;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final bool isActive = widget.isActive;
    final bool isCollapsed = widget.isCollapsed;
    final _SidebarItemData item = widget.item;

    // Background color based on active & hover state
    Color getBgColor() {
      if (isActive) {
        return isDark ? AppColors.emerald : Colors.white;
      }
      if (_isHovered) {
        return isDark 
            ? Colors.white.withOpacity(0.08) 
            : Colors.white.withOpacity(0.15);
      }
      return Colors.transparent;
    }

    // Text & icon color based on active & hover state
    Color getTextColor() {
      if (isActive) {
        return isDark ? Colors.white : AppColors.emeraldDark;
      }
      if (_isHovered) {
        return Colors.white;
      }
      return isDark ? AppColors.slate300 : Colors.white.withOpacity(0.8);
    }

    final Widget itemContent = InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      hoverColor: Colors.transparent, // Use custom stateful hover
      splashColor: isDark 
          ? AppColors.emerald.withOpacity(0.2) 
          : AppColors.emeraldDark.withOpacity(0.15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 0 : 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive && !isDark
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isCollapsed
            ? Center(
                child: Icon(
                  item.icon,
                  color: getTextColor(),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: <Widget>[
                    Icon(
                      item.icon,
                      color: getTextColor(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered && !isActive ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        child: isCollapsed
            ? Tooltip(
                message: item.label,
                preferBelow: false,
                verticalOffset: 0,
                child: itemContent,
              )
            : itemContent,
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton({
    required this.onTap,
    required this.isCollapsed,
    required this.isDark,
  });

  final VoidCallback onTap;
  final bool isCollapsed;
  final bool isDark;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final bool isCollapsed = widget.isCollapsed;

    Color getBgColor() {
      if (isDark) {
        return _isHovered 
            ? const Color(0x33F87171) 
            : const Color(0x1AF87171);
      } else {
        return _isHovered 
            ? Colors.white.withOpacity(0.25) 
            : Colors.white.withOpacity(0.15);
      }
    }

    Color getTextColor() {
      if (isDark) {
        return const Color(0xFFF87171);
      } else {
        return Colors.white;
      }
    }

    final Widget buttonContent = InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      hoverColor: Colors.transparent, // Disable default hover
      splashColor: isDark 
          ? const Color(0x33F87171) 
          : Colors.white.withOpacity(0.2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 0 : 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(18),
        ),
        child: isCollapsed
            ? Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: getTextColor(),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.logout_rounded,
                      color: getTextColor(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Logout Admin',
                      style: TextStyle(
                        color: getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        child: isCollapsed
            ? Tooltip(
                message: 'Logout Admin',
                child: buttonContent,
              )
            : buttonContent,
      ),
    );
  }
}
