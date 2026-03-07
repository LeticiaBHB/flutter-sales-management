import 'package:flutter/material.dart';

class ImageDisplayWidget extends StatelessWidget {
  final String imagePath;
  const ImageDisplayWidget({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context){

    if(imagePath.startsWith('http')){
      return Image.network(imagePath,width:50,height:50,fit:BoxFit.cover);
    }
    return Image.network(imagePath,width:50,height:50,fit:BoxFit.cover);
  }
}