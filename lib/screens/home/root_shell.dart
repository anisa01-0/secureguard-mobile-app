import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/emergency_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../contacts/contacts_screen.dart';
import '../history/history_screen.dart';
import '../location/location_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// The signed-in container: five tabs plus a persistent emergency banner.
///
/// Using an [IndexedStack] keeps each tab's scroll position and state alive
/// while the user moves between them, which makes the demonstration feel
/// like a real application.
class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  /// Lets any screen switch tabs, e.g. "View all contacts" on the dashboard.
  ///
  /// The shell registers itself in [_current] while it is mounted, so this
  /// works even from a screen that is about to be popped (Settings, for
  /// example), where walking up the widget tree would no longer find it.
  static void goToTab(BuildContext context, int index) {
    final _RootShellState? shell =
        context.findAncestorStateOfType<_RootShellState>() ?? _current;
    shell?.selectTab(index);
  }

  static _RootShellState? _current;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    RootShell._current = this;
  }

  @override
  void dispose() {
    if (identical(RootShell._current, this)) RootShell._current = null;
    super.dispose();
  }

  static const List<_ShellTab> _tabs = <_ShellTab>[
    _ShellTab('Home', Icons.home_outlined, Icons.home_rounded),
    _ShellTab('Contacts', Icons.group_outlined, Icons.group_rounded),
    _ShellTab(
      'Location',
      Icons.location_on_outlined,
      Icons.location_on_rounded,
    ),
    _ShellTab('History', Icons.history_outlined, Icons.history_rounded),
    _ShellTab('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  void selectTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final bool emergencyRunning = context.select<EmergencyProvider, bool>(
      (EmergencyProvider e) => e.isEmergencyInProgress,
    );

    return Scaffold(
      body: Column(
        children: <Widget>[
          // A live emergency stays visible no matter which tab is open.
          if (emergencyRunning) const _ActiveEmergencyBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const <Widget>[
                HomeScreen(),
                ContactsScreen(),
                LocationScreen(),
                HistoryScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: selectTab,
          destinations: _tabs
              .map(
                (_ShellTab tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
                  tooltip: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Persistent red strip shown while an emergency is running.
class _ActiveEmergencyBanner extends StatelessWidget {
  const _ActiveEmergencyBanner();

  @override
  Widget build(BuildContext context) {
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();

    final String message = switch (emergency.phase) {
      SosPhase.countdown =>
        'Emergency alert activating in ${emergency.countdownRemaining}s',
      SosPhase.dispatching => 'Notifying your trusted contacts…',
      SosPhase.active => 'Emergency active • contacts notified',
      SosPhase.idle => '',
    };

    return Material(
      color: AppColors.red,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.sos),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const Text(
                  'OPEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
