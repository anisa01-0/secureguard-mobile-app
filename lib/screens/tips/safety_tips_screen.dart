import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../models/safety_tip.dart';
import '../../utils/responsive.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sg_card.dart';

/// Safety advice, grouped into five categories and shown as cards.
class SafetyTipsScreen extends StatefulWidget {
  const SafetyTipsScreen({super.key});

  @override
  State<SafetyTipsScreen> createState() => _SafetyTipsScreenState();
}

class _SafetyTipsScreenState extends State<SafetyTipsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: SafetyTipCategory.values.length,
    vsync: this,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);
    final List<SafetyTip> tips = DemoData.safetyTips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: theme.colorScheme.outline,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          tabs: SafetyTipCategory.values
              .map(
                (SafetyTipCategory category) => Tab(
                  height: 50,
                  icon: Icon(category.icon, size: 19),
                  iconMargin: const EdgeInsets.only(bottom: 2),
                  text: category.label,
                ),
              )
              .toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: SafetyTipCategory.values.map((SafetyTipCategory category) {
            final List<SafetyTip> inCategory = tips
                .where((SafetyTip t) => t.category == category)
                .toList();

            if (inCategory.isEmpty) {
              return EmptyState(
                icon: category.icon,
                title: 'No tips in this category',
                message:
                    'Choose another category to read SecureGuard’s '
                    'safety advice.',
                compact: true,
              );
            }

            return ResponsiveBody(
              child: ListView(
                padding: EdgeInsets.fromLTRB(padding, 18, padding, 32),
                children: <Widget>[
                  _CategoryIntro(category: category, count: inCategory.length),
                  const SizedBox(height: 18),
                  ...inCategory.asMap().entries.map(
                    (MapEntry<int, SafetyTip> entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TipCard(tip: entry.value, number: entry.key + 1),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryIntro extends StatelessWidget {
  const _CategoryIntro({required this.category, required this.count});

  final SafetyTipCategory category;
  final int count;

  String get _intro => switch (category) {
    SafetyTipCategory.personal =>
      'Simple habits that lower your risk wherever you are.',
    SafetyTipCategory.travel =>
      'Stay protected on the road, in a taxi and on public transport.',
    SafetyTipCategory.night =>
      'Extra care for the hours when streets are quiet and dark.',
    SafetyTipCategory.online =>
      'Protect your accounts, your identity and your location online.',
    SafetyTipCategory.preparedness =>
      'Be ready before an emergency happens, not during one.',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SgCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          category.color.withValues(alpha: 0.13),
          category.color.withValues(alpha: 0.04),
        ],
      ),
      borderColor: category.color.withValues(alpha: 0.28),
      child: Row(
        children: <Widget>[
          SgIconBadge(
            icon: category.icon,
            color: category.color,
            size: 48,
            filled: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(category.label, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(_intro, style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                Text(
                  '$count tips in this category',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: category.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single expandable tip card.
class _TipCard extends StatefulWidget {
  const _TipCard({required this.tip, required this.number});

  final SafetyTip tip;
  final int number;

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SafetyTip tip = widget.tip;

    return SgCard(
      onTap: () => setState(() => _expanded = !_expanded),
      semanticLabel: '${tip.title}. ${tip.body}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tip.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.number}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: tip.color,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    tip.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 240),
                child: Icon(
                  Icons.expand_more_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8, left: 43),
              child: Text(
                tip.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8, left: 43),
              child: Text(tip.body, style: theme.textTheme.bodySmall),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 240),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}
