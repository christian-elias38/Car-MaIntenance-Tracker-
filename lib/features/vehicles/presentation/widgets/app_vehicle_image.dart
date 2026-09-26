import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppVehicleImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppVehicleImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    final trimmedPath = imagePath.trim();

    if (trimmedPath.startsWith('data:image') || _isBase64(trimmedPath)) {
      try {
        final String cleanBase64 = trimmedPath.contains(',') 
            ? trimmedPath.split(',').last 
            : trimmedPath;
        final bytes = base64Decode(cleanBase64);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildFallback(context),
        );
      } catch (_) {
        imageWidget = _buildFallback(context);
      }
    } else if (trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://')) {
      imageWidget = Image.network(
        trimmedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildFallback(context),
      );
    } else if (trimmedPath.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildFallback(context),
      );
    } else if (trimmedPath.isNotEmpty) {
      if (!kIsWeb) {
        final file = File(trimmedPath);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (ctx, err, stack) => _buildFallback(context),
          );
        } else {
          imageWidget = _buildFallback(context);
        }
      } else {
        imageWidget = _buildFallback(context);
      }
    } else {
      imageWidget = _buildFallback(context);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  bool _isBase64(String str) {
    if (str.length < 100) return false;
    final clean = str.contains(',') ? str.split(',').last : str;
    return RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(clean.replaceAll(RegExp(r'\s+'), ''));
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.darkSurface : AppColors.mintBackground,
      child: Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: (height != null && height! < 60) ? 24 : 38,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}
