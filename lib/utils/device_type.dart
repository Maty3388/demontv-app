import "package:flutter/material.dart";

enum DeviceType { phone, tv }

// TRUE = APK para Android TV/TV Box
// FALSE = APK para celular
const bool kIsAndroidTV = true;

DeviceType getDeviceType(BuildContext context) => kIsAndroidTV ? DeviceType.tv : DeviceType.phone;

bool isTV(BuildContext context) => kIsAndroidTV;
