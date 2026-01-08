import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../logic/face_detector_service.dart';
import '../enums.dart';

class SmileSnap extends StatefulWidget {
  final SnapTrigger trigger;
  final Function(File) onCapture;
  final bool showPreview;
  final CameraLensDirection cameraDirection;

  const SmileSnap({
    super.key,
    this.trigger = SnapTrigger.smile,
    required this.onCapture,
    this.showPreview = true,
    this.cameraDirection = CameraLensDirection.front,
  });

  @override
  State<SmileSnap> createState() => _SmileSnapState();
}

class _SmileSnapState extends State<SmileSnap> with WidgetsBindingObserver {
  CameraController? _controller;
  final FaceDetectorService _aiService = FaceDetectorService();
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  CameraDescription? _activeCamera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FIX: Handle lifecycle changes safely to prevent "Disposed CameraController" error
    final CameraController? cameraController = _controller;

    // App is going to the background (or screen turned off)
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (cameraController != null && cameraController.value.isInitialized) {
        // 1. Dispose the controller to free resources
        cameraController.dispose();

        // 2. CRITICAL: Update UI state immediately so we don't try to render a dead camera
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
            _controller = null; // Nuke the reference
          });
        }
      }
    }
    // App is coming back to the foreground
    else if (state == AppLifecycleState.resumed) {
      if (_controller == null) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _activeCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == widget.cameraDirection,
        orElse: () => cameras.first,
      );

      // Create new controller
      final controller = CameraController(
        _activeCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      // Store local reference first
      _controller = controller;

      await controller.initialize();

      if (!mounted) return;

      // Start AI Stream
      _startAIStream();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _startAIStream() {
    // Safety check before starting stream
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller?.startImageStream((CameraImage image) {
      if (_isTakingPicture) return;

      _aiService.processFrame(
        cameraImage: image,
        camera: _activeCamera!,
        triggerType: widget.trigger,
        onTrigger: _takePicture,
      );
    });
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture || _controller == null || !_controller!.value.isInitialized) return;
    _isTakingPicture = true;

    try {
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();

      widget.onCapture(File(file.path));

      await Future.delayed(const Duration(seconds: 2));

      // Restart stream only if controller is still valid
      if (mounted && _controller != null && _controller!.value.isInitialized) {
        _startAIStream();
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
    } finally {
      _isTakingPicture = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Extra safety check. If controller is null or disposed, show loader.
    if (!_isCameraInitialized || _controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.showPreview) {
      return const SizedBox.shrink();
    }

    return CameraPreview(_controller!);
  }
}