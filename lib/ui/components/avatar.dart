import 'package:material_ui/material_ui.dart';

import '../../util/const/ui/ui_constants.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    this.radius = UIConstants.avatarSize,
    this.iconSize = UIConstants.avatarSize,
    super.key,
  });

  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.person, size: iconSize),
    );
  }
}
