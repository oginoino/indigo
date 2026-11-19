import 'package:material_ui/material_ui.dart';

import '../../util/const/app/app_strings.dart';
import '../../util/const/ui/ui_constants.dart';
import 'avatar.dart';

class AvatarGroupMember {
  const AvatarGroupMember({this.imageProvider, this.label});

  final ImageProvider<Object>? imageProvider;
  final String? label;
}

class AvatarGroup extends StatelessWidget {
  const AvatarGroup({
    required this.members,
    this.size = AvatarSize.small,
    this.maxVisible = UIConstants.avatarGroupMaxVisible,
    this.emptyState,
    super.key,
  });

  final List<AvatarGroupMember> members;
  final AvatarSize size;
  final int maxVisible;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return emptyState ?? const SizedBox.shrink();

    final hasOverflow = members.length > maxVisible;
    final visibleMembers = hasOverflow
        ? members.take(maxVisible).toList(growable: false)
        : members;
    final overflowCount = members.length - visibleMembers.length;

    final diameter = size.diameter;
    final step = diameter * (1 - UIConstants.avatarGroupOverlapRatio);
    final itemCount = visibleMembers.length + (hasOverflow ? 1 : 0);
    final children = <Widget>[
      for (final member in visibleMembers)
        _buildMember(context, member, diameter),
      if (hasOverflow) _buildOverflow(context, diameter, overflowCount),
    ];

    return SizedBox(
      width: diameter + (itemCount - 1) * step,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < children.length; index++)
            Positioned(left: index * step, top: 0, child: children[index]),
        ],
      ),
    );
  }

  Widget _buildMember(
    BuildContext context,
    AvatarGroupMember member,
    double diameter,
  ) {
    final avatar = _ringed(
      context,
      diameter,
      Avatar(
        diameter: diameter - UIConstants.avatarGroupRingWidth * 2,
        imageProvider: member.imageProvider,
        useSavedImage: false,
      ),
    );

    final label = member.label;
    if (label == null || label.isEmpty) return avatar;
    return Tooltip(message: label, child: avatar);
  }

  Widget _buildOverflow(BuildContext context, double diameter, int count) {
    final theme = Theme.of(context);

    return _ringed(
      context,
      diameter,
      DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.secondaryContainer,
        ),
        child: Center(
          child: Text(
            AppStrings.avatarGroupOverflow.replaceAll('{count}', '$count'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ringed(BuildContext context, double diameter, Widget child) {
    final theme = Theme.of(context);
    final ringColor =
        theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(UIConstants.avatarGroupRingWidth),
      decoration: BoxDecoration(shape: BoxShape.circle, color: ringColor),
      child: child,
    );
  }
}
