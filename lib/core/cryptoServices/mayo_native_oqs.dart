import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:oqs/oqs.dart';

class MayoKeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;

  MayoKeyPair({required this.publicKey, required this.privateKey});
}

class MayoNative {
  static final MayoNative instance = MayoNative._();

  static const String _preferredAlgorithm = 'MAYO-1';

  String? _resolvedAlgorithm;
  bool _pathsConfigured = false;

  MayoNative._();

  FutureOr<MayoKeyPair> generateKeyPair() {
    final signature = _createSignature();
    try {
      final keyPair = signature.generateKeyPair();
      return MayoKeyPair(
        publicKey: keyPair.publicKey,
        privateKey: keyPair.secretKey,
      );
    } finally {
      signature.dispose();
    }
  }

  FutureOr<Uint8List> sign({
    required Uint8List message,
    required Uint8List privateKey,
  }) {
    final signature = _createSignature();
    try {
      return signature.sign(message, privateKey);
    } finally {
      signature.dispose();
    }
  }

  FutureOr<bool> verify({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    final verifier = _createSignature();
    try {
      return verifier.verify(message, signature, publicKey);
    } finally {
      verifier.dispose();
    }
  }

  Signature _createSignature() {
    _configureLibraryPaths();
    return Signature.create(_resolveAlgorithmName());
  }

  String _resolveAlgorithmName() {
    final cached = _resolvedAlgorithm;
    if (cached != null) {
      return cached;
    }

    _configureLibraryPaths();
    LibOQS.init();

    final supported = LibOQS.getSupportedSignatureAlgorithms();
    const candidates = <String>[_preferredAlgorithm, 'MAYO_1', 'MAYO1'];

    for (final candidate in candidates) {
      if (supported.contains(candidate)) {
        _resolvedAlgorithm = candidate;
        return candidate;
      }
    }

    for (final algorithm in supported) {
      final normalized = algorithm.toUpperCase().replaceAll('_', '-');
      if (normalized == _preferredAlgorithm || normalized.startsWith('MAYO')) {
        _resolvedAlgorithm = algorithm;
        return algorithm;
      }
    }

    throw StateError(
      'MAYO-1 is not enabled in the loaded liboqs library. '
      'Available signature algorithms: ${supported.join(', ')}',
    );
  }

  void _configureLibraryPaths() {
    if (_pathsConfigured) {
      return;
    }

    LibOQSLoader.customPaths = LibraryPaths(
      windows: _firstExisting([
        r'native\liboqs\bin\oqs.dll',
        r'build\windows\x64\runner\Debug\oqs.dll',
        r'build\windows\x64\runner\Release\oqs.dll',
        r'bin\oqs.dll',
      ]),
      linuxX64: _firstExisting([
        'native/liboqs/lib/x86_64/liboqs.so',
        'lib/liboqs.so',
      ]),
      linuxArm64: _firstExisting([
        'native/liboqs/lib/aarch64/liboqs.so',
        'lib/liboqs.so',
      ]),
      macOS: _firstExisting([
        'native/liboqs/lib/liboqs.dylib',
        'lib/liboqs.dylib',
      ]),
      androidArm64: 'liboqs.so',
      androidArm32: 'liboqs.so',
      androidX64: 'liboqs.so',
      androidX86: 'liboqs.so',
    );

    _pathsConfigured = true;
  }

  String? _firstExisting(List<String> candidates) {
    for (final candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }
}
