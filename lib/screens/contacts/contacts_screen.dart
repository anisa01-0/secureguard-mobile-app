import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../models/emergency_contact.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/dialer_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/contact_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sg_card.dart';
import 'contact_editor_sheet.dart';

/// Trusted-contacts manager: add, edit, delete and choose the primary contact.
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add contact',
          ),
          SizedBox(width: padding - 12),
        ],
      ),
      floatingActionButton: contacts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(context),
              backgroundColor: AppColors.adaptive(context, AppColors.navy),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add contact'),
            ),
      body: SafeArea(
        child: ResponsiveBody(
          child: contacts.isEmpty
              ? EmptyState(
                  icon: Icons.group_add_rounded,
                  title: 'No trusted contacts yet',
                  message:
                      'SecureGuard alerts these people the moment you press '
                      'SOS. Add at least one person you trust.',
                  actionLabel: 'Add your first contact',
                  iconColor: AppColors.amber,
                  onAction: () => _openEditor(context),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(padding, 6, padding, 96),
                  children: <Widget>[
                    _ContactsSummary(count: contacts.count),
                    const SizedBox(height: 18),
                    Text('Alert order', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Your primary contact is always alerted first.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    ...contacts.contacts.map(
                      (EmergencyContact contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ContactTile(
                          contact: contact,
                          onTap: () => _openEditor(context, contact: contact),
                          onCall: () => _call(context, contact),
                          onEdit: () => _openEditor(context, contact: contact),
                          onSetPrimary: () => _setPrimary(context, contact),
                          onDelete: () => _confirmDelete(context, contact),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _PrivacyNote(),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    EmergencyContact? contact,
  }) async {
    final ContactEditorResult? result =
        await showModalBottomSheet<ContactEditorResult>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => ContactEditorSheet(contact: contact),
        );

    if (result == null || !context.mounted) return;

    final ContactsProvider contacts = context.read<ContactsProvider>();
    final NotificationsProvider notifications = context
        .read<NotificationsProvider>();

    if (contact == null) {
      contacts.add(
        name: result.name,
        relationship: result.relationship,
        phone: result.phone,
        isPrimary: result.isPrimary,
      );
      notifications.push(
        type: NotificationType.contact,
        title: 'Trusted contact added',
        message: '${result.name} will now be alerted when you press SOS.',
      );
      AppFeedback.success(context, '${result.name} added to your contacts.');
    } else {
      contacts.update(
        contact.id,
        name: result.name,
        relationship: result.relationship,
        phone: result.phone,
        isPrimary: result.isPrimary,
      );
      notifications.push(
        type: NotificationType.contact,
        title: 'Trusted contact updated',
        message: 'The details for ${result.name} were changed.',
      );
      AppFeedback.success(context, '${result.name} updated.');
    }
  }

  Future<void> _call(BuildContext context, EmergencyContact contact) async {
    final DialResult result = await const DialerService().call(contact.phone);
    if (!context.mounted) return;

    switch (result) {
      case DialResult.launched:
        AppFeedback.info(context, 'Calling ${contact.name}…');
      case DialResult.unsupported:
        await AppFeedback.notice(
          context,
          title: 'Demo call',
          message:
              'This device cannot make phone calls, so nothing was dialled. '
              'On a phone SecureGuard would open the dialler with '
              '${contact.phone}.',
          icon: Icons.phone_rounded,
        );
      case DialResult.failed:
        AppFeedback.error(context, 'The call could not be started.');
    }
  }

  void _setPrimary(BuildContext context, EmergencyContact contact) {
    context.read<ContactsProvider>().setPrimary(contact.id);
    AppFeedback.success(
      context,
      '${contact.name} is now your primary contact.',
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Delete ${contact.name}?',
      message:
          'They will no longer be alerted when you press SOS. You can add '
          'them again at any time.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.person_remove_rounded,
    );
    if (!confirmed || !context.mounted) return;

    context.read<ContactsProvider>().remove(contact.id);
    context.read<NotificationsProvider>().push(
      type: NotificationType.contact,
      title: 'Trusted contact removed',
      message: '${contact.name} was removed from your trusted contacts.',
    );
    AppFeedback.info(context, '${contact.name} was removed.');
  }
}

class _ContactsSummary extends StatelessWidget {
  const _ContactsSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SgCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AppColors.green.withValues(alpha: 0.13),
          AppColors.green.withValues(alpha: 0.04),
        ],
      ),
      borderColor: AppColors.green.withValues(alpha: 0.30),
      child: Row(
        children: <Widget>[
          const SgIconBadge(
            icon: Icons.verified_user_rounded,
            color: AppColors.green,
            size: 48,
            filled: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$count trusted ${count == 1 ? 'contact' : 'contacts'}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Everyone on this list receives your alert, your name and '
                  'your live location when you press SOS.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return const InlineBanner(
      title: 'Your contacts stay on this device',
      message:
          'SecureGuard stores trusted contacts in local storage on your phone. '
          'They are never uploaded to a server in this prototype.',
      icon: Icons.lock_outline_rounded,
      color: AppColors.blue,
    );
  }
}
