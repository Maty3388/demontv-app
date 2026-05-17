import "package:flutter/material.dart";

enum DeviceType { phone, tv }

const bool kIsTV = true;

DeviceType getDeviceType(BuildContext context) {
  if (kIsTV) return DeviceType.tv;
  return DeviceType.phone;
}

bool isTV(BuildContext context) => getDeviceType(context) == DeviceType.tv;
