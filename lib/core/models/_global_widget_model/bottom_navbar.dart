import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavbarModel{
  final Widget page;
  final String title;
  final String? route;
  final IconData? iconData;
  final SvgPicture? iconImage;

  BottomNavbarModel({
    required this.page,
    required this.title,
    this.route,
    this.iconData,
    this.iconImage,
  });
}