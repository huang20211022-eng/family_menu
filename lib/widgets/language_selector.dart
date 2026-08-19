import 'package:flutter/material.dart';

/// A visible language switcher: `中文 | English`.
///
/// Language names are shown in their own language (endonyms) and are not
/// translated — this is intentional.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.locale,
    required this.onChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onChanged;

  bool get _isChinese => locale.languageCode == 'zh';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LanguageOption(
          label: '中文',
          active: _isChinese,
          onTap: () => onChanged(const Locale('zh', 'CN')),
        ),
        Text(
          '|',
          style: TextStyle(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        _LanguageOption(
          label: 'English',
          active: !_isChinese,
          onTap: () => onChanged(const Locale('en')),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = active
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final FontWeight weight = active ? FontWeight.w700 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: weight,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
