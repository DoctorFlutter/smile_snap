import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; 
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../utils/camera_utils.dart';
import '../enums.dart';

class FaceDetectorService {
  late FaceDetector _faceDetector;
  bool _isBusy = false;

  FaceDetectorService() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> processFrame({
    required CameraImage cameraImage,
    required CameraDescription camera,
    required SnapTrigger triggerType,
    required Function onTrigger,
  }) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final inputImage =
      CameraUtils.convertCameraImageToInputImage(cameraImage, camera);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);

      for (final face in faces) {
        if (_checkTrigger(face, triggerType)) {
          onTrigger();
          break;
        }
      }
    } catch (e) {
      debugPrint("FaceDetectorService Error: $e");
    } finally {
      _isBusy = false;
    }
  }

  bool _checkTrigger(Face face, SnapTrigger trigger) {
    
    final leftOpen = face.leftEyeOpenProbability ?? -1.0;
    final rightOpen = face.rightEyeOpenProbability ?? -1.0;
    final smileProb = face.smilingProbability ?? -1.0;

    
    
    if (trigger != SnapTrigger.smile) {
      debugPrint("👀 Eyes -> Left: ${leftOpen.toStringAsFixed(2)} | Right: ${rightOpen.toStringAsFixed(2)}");
    }

    switch (trigger) {
      case SnapTrigger.smile:
        return smileProb > 0.8;

      case SnapTrigger.doubleBlink:
      
      
        return leftOpen < 0.4 && rightOpen < 0.4 && leftOpen != -1;

      case SnapTrigger.blinkLeft:
      
        return leftOpen < 0.4 && rightOpen > 0.5;

      case SnapTrigger.blinkRight:
      
        return rightOpen < 0.4 && leftOpen > 0.5;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}