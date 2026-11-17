import 'package:material_ui/material_ui.dart';

class NavBarSkeleton extends StatelessWidget {
  const NavBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey.withValues(alpha: 0.13);

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            _SkeletonItem(width: 80, color: color),
            const SizedBox(width: 8),
            Icon(
              Icons.add,
              size: 28,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  final double width;
  final Color color;

  const _SkeletonItem({
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 40,
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
