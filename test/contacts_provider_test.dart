import 'package:flutter_test/flutter_test.dart';
import 'package:secureguard/data/local_store.dart';
import 'package:secureguard/models/emergency_contact.dart';
import 'package:secureguard/providers/contacts_provider.dart';

/// Unit tests for adding, editing, deleting and prioritising contacts.
void main() {
  late ContactsProvider contacts;

  setUp(() async {
    // No platform storage in a unit test, so LocalStore falls back to its
    // in-memory map. Clearing it gives every test a clean start.
    await LocalStore.instance.clearAll();
    contacts = ContactsProvider();
  });

  tearDown(() => contacts.dispose());

  test('starts with the demo contacts and one primary contact', () {
    expect(contacts.count, 3);
    expect(contacts.hasContacts, isTrue);
    expect(
      contacts.contacts.where((EmergencyContact c) => c.isPrimary).length,
      1,
    );
  });

  test('the primary contact is always listed first', () {
    expect(contacts.contacts.first.isPrimary, isTrue);
    expect(contacts.primaryContact?.name, 'Halima Abdi');
  });

  test('adds a new contact', () {
    final int before = contacts.count;
    contacts.add(
      name: 'Amina Ali',
      relationship: 'Friend',
      phone: '+252 61 000 0009',
    );
    expect(contacts.count, before + 1);
    expect(
      contacts.contacts.any((EmergencyContact c) => c.name == 'Amina Ali'),
      isTrue,
    );
  });

  test('the first contact added to an empty list becomes primary', () {
    for (final EmergencyContact contact in List<EmergencyContact>.from(
      contacts.contacts,
    )) {
      contacts.remove(contact.id);
    }
    expect(contacts.isEmpty, isTrue);

    final EmergencyContact added = contacts.add(
      name: 'Amina Ali',
      relationship: 'Friend',
      phone: '+252 61 000 0009',
    );
    expect(added.isPrimary, isTrue);
    expect(contacts.primaryContact?.id, added.id);
  });

  test('editing a contact keeps its identity', () {
    final EmergencyContact target = contacts.contacts.last;
    contacts.update(
      target.id,
      name: 'Sagal M. Mohamed',
      relationship: 'Roommate',
      phone: '+252 61 000 0033',
      isPrimary: false,
    );

    final EmergencyContact updated = contacts.contacts.firstWhere(
      (EmergencyContact c) => c.id == target.id,
    );
    expect(updated.name, 'Sagal M. Mohamed');
    expect(updated.relationship, 'Roommate');
    expect(updated.phone, '+252 61 000 0033');
    expect(contacts.count, 3);
  });

  test('setting a new primary contact clears the previous one', () {
    final EmergencyContact target = contacts.contacts.last;
    contacts.setPrimary(target.id);

    expect(contacts.primaryContact?.id, target.id);
    expect(
      contacts.contacts.where((EmergencyContact c) => c.isPrimary).length,
      1,
    );
  });

  test('deleting the primary contact promotes another one', () {
    final EmergencyContact primary = contacts.primaryContact!;
    contacts.remove(primary.id);

    expect(contacts.count, 2);
    expect(contacts.primaryContact, isNotNull);
    expect(contacts.primaryContact!.isPrimary, isTrue);
    expect(contacts.primaryContact!.id, isNot(primary.id));
  });

  test('deleting every contact leaves an empty list', () {
    for (final EmergencyContact contact in List<EmergencyContact>.from(
      contacts.contacts,
    )) {
      contacts.remove(contact.id);
    }
    expect(contacts.isEmpty, isTrue);
    expect(contacts.primaryContact, isNull);
  });

  test('detects a duplicate phone number, ignoring formatting', () {
    expect(contacts.isDuplicatePhone('+252610000001'), isTrue);
    expect(contacts.isDuplicatePhone('+252 61 000 0001'), isTrue);
    expect(contacts.isDuplicatePhone('+252 61 000 9999'), isFalse);
  });

  test('a contact is not a duplicate of itself while being edited', () {
    final EmergencyContact target = contacts.contacts.first;
    expect(
      contacts.isDuplicatePhone(target.phone, ignoreId: target.id),
      isFalse,
    );
  });

  test('resetting restores the demo contacts', () {
    contacts.remove(contacts.contacts.first.id);
    expect(contacts.count, 2);
    contacts.resetToDemoData();
    expect(contacts.count, 3);
  });
}
