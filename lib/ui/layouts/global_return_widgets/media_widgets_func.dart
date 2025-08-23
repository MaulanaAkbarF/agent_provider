import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../ui/layouts/styleconfig/themecolors.dart';
import '../../../core/constant_values/_setting_value/log_app_values.dart';
import '../../../core/constant_values/global_values.dart';
import '../../../core/utilities/functions/logger_func.dart';
import '../../../core/utilities/local_storage/sqflite/services/_setting_services/log_app_services.dart';

String getDefaultImageAssetPath() => 'assets/image/';

Image loadDefaultAppLogoPNG({double? sizeLogo}) {
  return Image.asset('assets/icon/logo.png', width: sizeLogo ?? 120, height: sizeLogo ?? 120,);
}

SvgPicture loadDefaultAppLogoSVG({double? sizeLogo}) {
  return SvgPicture.asset('assets/icon/logo.svg', width: sizeLogo ?? 120, height: sizeLogo ?? 120,);
}

/// Fungsi untuk load gambar PNG dari assets
Image loadImageAssetPNG({required String path, double? width, double? height, Color? color, double? opacity}) {
  return Image.asset(path, width: width ?? 20, height: height ?? 20, color: color?.withValues(alpha: opacity ?? 1.0), fit: BoxFit.cover,
    errorBuilder: (context, e, s) {
      clog('Terjadi masalah ketika loadImageAssetPNG: $e\n$s');
      addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: s.toString());
      return Container(height: 100, width: double.infinity, color: Colors.transparent, child: Center(child: loadDefaultAppLogoSVG(sizeLogo: 100)));
    },
  );
}

/// Fungsi untuk load gambar SVG dari assets
SvgPicture loadImageAssetSVG({required String path, double? width, double? height, Color? color, double? opacity}) {
  return SvgPicture.asset(path, width: width ?? 20, height: height ?? 20, color: color?.withValues(alpha: opacity ?? 1.0), fit: BoxFit.cover);
}

DecorationImage loadDecorationImage({required String path, double? width, double? height, Color? color, double? opacity}) {
  return DecorationImage(image: AssetImage(path), fit: BoxFit.cover,
    onError: (context, e) {
      clog('Terjadi masalah ketika loadImageAssetSVG: $e');
      addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: '');
    },
  );
}

/// Fungsi untuk load gambar XFile yang diambil dari kamera atau galeri ponsel
Image loadImageXFile({XFile? file, double? width, double? height, Color? color, double? opacity}) {
  return Image.file(File(file?.path ?? ''), width: width ?? 100, height: height ?? 100, color: color?.withValues(alpha: opacity ?? 1.0), fit: BoxFit.cover,
    errorBuilder: (context, e, s) {
      clog('Terjadi masalah ketika loadImageAssetXFile: $e\n$s');
      addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: s.toString());
      return Container(height: 100, width: double.infinity, color: Colors.transparent, child: Center(child: loadDefaultAppLogoSVG(sizeLogo: 100)));
    },
  );
}

/// Fungsi untuk load animasi dari Lottie
Widget loadLottieAsset({required String path, double? width, double? height}) {
  return loadDefaultAppLogoPNG();
}

/// Fungsi untuk load gambar dari internet
Image loadImageNetwork({required String imageUrl, double? width, double? height}) {
  return Image.network(imageUrl, width: width ?? 20, height: height ?? 20, fit: BoxFit.cover,
    errorBuilder: (context, e, s) {
      clog('Terjadi masalah ketika loadImageNetwork: $e\n$s');
      addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: s.toString());
      return Container(height: 100, width: double.infinity, color: Colors.transparent, child: Center(child: loadDefaultAppLogoSVG(sizeLogo: 100)));
    },
  );
}

/// Fungsi untuk load gambar profil dari internet (dan penanganan default profile kosong)
Widget loadCircleImage({
  required BuildContext context,
  String? imageUrl,
  String? imageAssetPath,
  File? fileImage,
  Color? backgroundColor,
  double radius = 20,
}) {
  return CircleAvatar(
    minRadius: radius,
    maxRadius: radius,
    backgroundColor: backgroundColor ?? ThemeColors.greyVeryLowContrast(context),
    backgroundImage: fileImage != null ? FileImage(fileImage) : (imageUrl != null ? NetworkImage(imageUrl) : null),
    foregroundImage: fileImage != null ? FileImage(fileImage) : (imageUrl != null ? NetworkImage(imageUrl) : null),
    // onForegroundImageError: (e, s) => clog('Terjadi masalah saat loadCircleImage Foreground: $e\n$s'),
    // onBackgroundImageError: (e, s) => clog('Terjadi masalah saat loadCircleImage Background: $e\n$s'),
    child: fileImage == null && imageUrl == null
      ? (imageAssetPath != null
      ? loadImageAssetPNG(path: imageAssetPath, width: radius * 1.8, height: radius * 1.8)
        : Icon(Icons.person, size: iconBtnMid, color: ThemeColors.surface(context)))
        : Icon(Icons.person_2, size: iconBtnMid, color: ThemeColors.surface(context)),
  );
}