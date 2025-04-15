import 'package:flutter/material.dart';

Size getIDFrameSize(BuildContext context) {
  final double frameWidth = MediaQuery.of(context).size.width * 0.95;
  final double frameHeight = frameWidth / (16 / 10);
  return Size(frameWidth, frameHeight);
}
