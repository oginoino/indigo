import 'package:material_ui/material_ui.dart';

import '../../../util/const/ui/ui_constants.dart';

class NavBarSkeleton extends StatelessWidget {
  const NavBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey.withValues(alpha: 0.13);

    return SizedBox(
      height: UIConstants.navBarHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.navBarHorizontalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: UIConstants.navBarItemSpacing,
          children: [
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            const SizedBox(width: 8),
            Icon(Icons.add, size: 28, color: color),
          ],
        ),
      ),
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  final double width;
  final Color color;

  const _SkeletonItem({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: UIConstants.navBarHeight,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: width * 0.72,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
