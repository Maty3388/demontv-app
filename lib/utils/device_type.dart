import "package:flutter/material.dart";

enum DeviceType { phone, tv }

DeviceType getDeviceType(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final width = size.width;
  final height = size.height;
  // Detectar TV por orientacion landscape y aspect ratio
  final isLandscape = width > height;
  final aspectRatio = width / height;
  // TV boxes siempre en landscape con aspect ratio ~1.77 (16:9)
  if (isLandscape && aspectRatio > 1.5) return DeviceType.tv;
  if (width >= 500) return DeviceType.tv;
  return DeviceType.phone;
}

bool isTV(BuildContext context) => getDeviceType(context) == DeviceType.tv;
