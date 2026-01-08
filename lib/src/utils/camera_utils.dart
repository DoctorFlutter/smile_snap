import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart'; 
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraUtils {
  
  
  static InputImage? convertCameraImageToInputImage(
      CameraImage cameraImage,
      CameraDescription camera,
      ) {
    final allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final InputImageRotation? imageRotation =
    _inputImageRotation(camera.sensorOrientation);

    if (imageRotation == null) return null;

    final inputImageFormat = _inputImageFormat(cameraImage.format.group);

    
    if (inputImageFormat == null) return null;

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetadata,
    );
  }

  
  static InputImageRotation? _inputImageRotation(int sensorOrientation) {
    
    
    if (Platform.isAndroid) {
      switch (sensorOrientation) {
        case 0:
          return InputImageRotation.rotation0deg;
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          return InputImageRotation.rotation0deg;
      }
    } else if (Platform.isIOS) {
      
      
      return InputImageRotation.rotation0deg;
    }
    return null;
  }

  
  static InputImageFormat? _inputImageFormat(ImageFormatGroup formatGroup) {
    switch (formatGroup) {
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
    
      case ImageFormatGroup.unknown:
      case ImageFormatGroup.jpeg:
        return null;
    }
  }
}