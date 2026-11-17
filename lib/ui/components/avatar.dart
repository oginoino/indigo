import 'package:material_ui/material_ui.dart';

class Avatar extends StatelessWidget {
  final double width;
  final double height;
  const Avatar({super.key,  this.width = 16, this.height = 16});

  @override
  Widget build(BuildContext context) {
    
    return SizedBox( child: Center(child: CircleAvatar(
      radius: width,
     child: Icon(Icons.person, size: width,),),));
  }
}