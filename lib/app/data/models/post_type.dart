import 'package:flutter/material.dart';

enum PostType {
  image("صورة", Icons.image),
  video("فيديو", Icons.videocam),
  text("نص", Icons.article);

  final String displayName;
  final IconData icon;

  const PostType(this.displayName, this.icon);
}


