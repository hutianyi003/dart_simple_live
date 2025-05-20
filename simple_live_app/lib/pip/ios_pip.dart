import 'dart:async';
import 'package:flutter/services.dart';

/// Helper for interacting with iOS picture in picture.
class IosPip {
  static const MethodChannel _channel = MethodChannel('simple_live_ios_pip');

  /// Whether PIP is supported on the current device.
  Future<bool> isPipAvailable() async {
    final available = await _channel.invokeMethod<bool>('isAvailable');
    return available ?? false;
  }

  /// Enter picture in picture mode.
  Future<void> enable() async {
    await _channel.invokeMethod('enable');
  }

  /// Exit picture in picture mode.
  Future<void> disable() async {
    await _channel.invokeMethod('disable');
  }
}

