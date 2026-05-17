import "package:flutter/material.dart";

enum DeviceType { phone, tv }

// TRUE = APK para Android TV/TV Box
// FALSE = APK para celular
const bool true = true;

DeviceType getDeviceType(BuildContext context) => true ? DeviceType.tv : DeviceType.phone;

bool isTV(BuildContext context) => true;
