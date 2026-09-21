import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../theme/app_colors.dart';
import 'sg_card.dart';
import 'status_pill.dart';

/// A circular avatar showing a person's initials.
class SgAvatar extends StatelessWidget {
  const SgAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.color = AppColors.navy,
    this.borderColor,
  });

  final String initials;
  final double size;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.adaptive(context, color);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.14),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// A trusted-contact row used on the contacts screen and the dashboard.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onCall,
    this.onEdit,
    this.onDelete,
    this.onSetPrimary,
    this.showActions = true,
  });

  final EmergencyContact contact;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetPrimary;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SgCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      borderColor: contact.isPrimary
          ? AppColors.green.withValues(alpha: 0.45)
          : theme.colorScheme.outline,
      semanticLabel:
          '${contact.name}, ${contact.relationship}, '
          '${contact.phone}'
          '${contact.isPrimary ? ', primary contact' : ''}',
      child: Row(
        children: <Widget>[
          SgAvatar(
            initials: contact.initials,
            color: contact.isPrimary ? AppColors.green : AppColors.navy,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        contact.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 15.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isPrimary) ...<Widget>[
                      const SizedBox(width: 8),
                      const StatusPill(
                        label: 'Primary',
                        color: AppColors.green,
                        icon: Icons.star_rounded,
                        dense: true,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  contact.relationship,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.phone_rounded,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        contact.phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showActions) ...<Widget>[
            if (onCall != null)
              IconButton(
                onPressed: onCall,
                tooltip: 'Call ${contact.name}',
                icon: const Icon(Icons.phone_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.green,
                  backgroundColor: AppColors.green.withValues(alpha: 0.10),
                ),
              ),
            PopupMenuButton<String>(
              tooltip: 'More options for ${contact.name}',
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (String value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                  case 'primary':
                    onSetPrimary?.call();
                  case 'delete':
                    onDelete?.call();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (onEdit != null)
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined, size: 20),
                      title: Text('Edit contact'),
                    ),
                  ),
                if (onSetPrimary != null && !contact.isPrimary)
                  const PopupMenuItem<String>(
                    value: 'primary',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.star_outline_rounded, size: 20),
                      title: Text('Set as primary'),
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.red,
                      ),
                      title: Text(
                        'Delete contact',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
