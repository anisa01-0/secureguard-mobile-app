import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/local_store.dart';
import '../models/emergency_contact.dart';
import '../services/alert_service.dart';

/// Manages the user's trusted contacts (add / edit / delete / set primary).
class ContactsProvider extends ChangeNotifier {
  ContactsProvider({LocalStore? store})
    : _store = store ?? LocalStore.instance {
    _load();
  }

  final LocalStore _store;

  List<EmergencyContact> _contacts = <EmergencyContact>[];

  /// Contacts with the primary contact always first.
  List<EmergencyContact> get contacts => AlertService.sortByPriority(_contacts);

  int get count => _contacts.length;
  bool get isEmpty => _contacts.isEmpty;
  bool get hasContacts => _contacts.isNotEmpty;

  EmergencyContact? get primaryContact {
    for (final EmergencyContact contact in _contacts) {
      if (contact.isPrimary) return contact;
    }
    return _contacts.isEmpty ? null : _contacts.first;
  }

  void _load() {
    final List<Map<String, dynamic>>? saved = _store.readJsonList(
      StoreKeys.contacts,
    );
    if (saved == null) {
      _contacts = List<EmergencyContact>.from(DemoData.contacts);
      _persist();
      return;
    }
    try {
      _contacts = saved.map(EmergencyContact.fromJson).toList();
    } catch (_) {
      _contacts = List<EmergencyContact>.from(DemoData.contacts);
    }
  }

  Future<void> _persist() => _store.writeJsonList(
    StoreKeys.contacts,
    _contacts.map((EmergencyContact c) => c.toJson()).toList(),
  );

  void _commit() {
    notifyListeners();
    _persist();
  }

  /// Returns `true` when another contact already uses this phone number.
  bool isDuplicatePhone(String phone, {String? ignoreId}) {
    final String cleaned = _normalise(phone);
    return _contacts.any(
      (EmergencyContact c) =>
          c.id != ignoreId && _normalise(c.phone) == cleaned,
    );
  }

  String _normalise(String phone) => phone.replaceAll(RegExp(r'[\s\-()]'), '');

  EmergencyContact add({
    required String name,
    required String relationship,
    required String phone,
    bool isPrimary = false,
  }) {
    // The very first contact automatically becomes the primary one.
    final bool makePrimary = isPrimary || _contacts.isEmpty;

    final EmergencyContact contact = EmergencyContact(
      id: 'contact-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      relationship: relationship,
      phone: phone.trim(),
      isPrimary: makePrimary,
    );

    if (makePrimary) _clearPrimaryFlags();
    _contacts = <EmergencyContact>[..._contacts, contact];
    _commit();
    return contact;
  }

  void update(
    String id, {
    required String name,
    required String relationship,
    required String phone,
    required bool isPrimary,
  }) {
    final int index = _contacts.indexWhere((EmergencyContact c) => c.id == id);
    if (index == -1) return;

    if (isPrimary) _clearPrimaryFlags();

    // If this was the only primary contact and the flag is being removed,
    // keep it primary - the app always needs one contact to call first.
    final bool keepPrimary = !isPrimary && _contacts.length == 1
        ? true
        : isPrimary;

    _contacts[index] = _contacts[index].copyWith(
      name: name.trim(),
      relationship: relationship,
      phone: phone.trim(),
      isPrimary: keepPrimary,
    );
    _contacts = List<EmergencyContact>.from(_contacts);
    _commit();
  }

  void remove(String id) {
    final int index = _contacts.indexWhere((EmergencyContact c) => c.id == id);
    if (index == -1) return;
    final bool removedPrimary = _contacts[index].isPrimary;

    _contacts = List<EmergencyContact>.from(_contacts)..removeAt(index);

    // Promote the next contact so there is always a primary contact.
    if (removedPrimary && _contacts.isNotEmpty) {
      _contacts[0] = _contacts[0].copyWith(isPrimary: true);
    }
    _commit();
  }

  void setPrimary(String id) {
    _clearPrimaryFlags();
    final int index = _contacts.indexWhere((EmergencyContact c) => c.id == id);
    if (index == -1) return;
    _contacts[index] = _contacts[index].copyWith(isPrimary: true);
    _contacts = List<EmergencyContact>.from(_contacts);
    _commit();
  }

  void _clearPrimaryFlags() {
    _contacts = _contacts
        .map(
          (EmergencyContact c) =>
              c.isPrimary ? c.copyWith(isPrimary: false) : c,
        )
        .toList();
  }

  /// Restores the demo contacts (used by "Reset demo data" in Settings).
  void resetToDemoData() {
    _contacts = List<EmergencyContact>.from(DemoData.contacts);
    _commit();
  }
}
