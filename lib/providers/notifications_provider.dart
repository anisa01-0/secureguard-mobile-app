import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/local_store.dart';
import '../models/app_notification.dart';

/// The in-app notification centre.
///
/// SecureGuard generates these entries locally whenever the user performs an
/// action (adds a contact, starts sharing a location, raises an alert...).
/// A production build would additionally deliver them as push notifications.
class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({LocalStore? store})
    : _store = store ?? LocalStore.instance {
    _load();
  }

  final LocalStore _store;

  List<AppNotification> _items = <AppNotification>[];

  /// Newest first.
  List<AppNotification> get items => _items;

  int get unreadCount => _items.where((AppNotification n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  void _load() {
    final List<Map<String, dynamic>>? saved = _store.readJsonList(
      StoreKeys.notifications,
    );
    if (saved == null) {
      _items = DemoData.notifications();
      _persist();
      return;
    }
    try {
      _items = saved.map(AppNotification.fromJson).toList();
      _sort();
    } catch (_) {
      _items = DemoData.notifications();
    }
  }

  void _sort() => _items.sort(
    (AppNotification a, AppNotification b) =>
        b.createdAt.compareTo(a.createdAt),
  );

  Future<void> _persist() => _store.writeJsonList(
    StoreKeys.notifications,
    _items.map((AppNotification n) => n.toJson()).toList(),
  );

  void _commit() {
    notifyListeners();
    _persist();
  }

  /// Adds a notification to the top of the list.
  void push({
    required NotificationType type,
    required String title,
    required String message,
  }) {
    _items = <AppNotification>[
      AppNotification(
        id: 'notif-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
      ..._items,
    ];
    // Keep the list a sensible length for a prototype.
    if (_items.length > 60) {
      _items = _items.sublist(0, 60);
    }
    _commit();
  }

  void markAsRead(String id) {
    final int index = _items.indexWhere((AppNotification n) => n.id == id);
    if (index == -1 || _items[index].isRead) return;
    _items = List<AppNotification>.from(_items);
    _items[index] = _items[index].copyWith(isRead: true);
    _commit();
  }

  void markAllAsRead() {
    if (!hasUnread) return;
    _items = _items
        .map((AppNotification n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    _commit();
  }

  void remove(String id) {
    _items = _items.where((AppNotification n) => n.id != id).toList();
    _commit();
  }

  void clearAll() {
    _items = <AppNotification>[];
    _commit();
  }

  void resetToDemoData() {
    _items = DemoData.notifications();
    _commit();
  }
}
