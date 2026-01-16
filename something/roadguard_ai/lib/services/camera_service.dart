import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Camera service for managing camera operations
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isStreaming = false;
  
  // Stream controller for frame updates
  final StreamController<CameraImage> _frameController = 
      StreamController<CameraImage>.broadcast();
  
  /// Stream of camera frames for AI processing
  Stream<CameraImage> get frameStream => _frameController.stream;
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if streaming
  bool get isStreaming => _isStreaming;
  
  /// Get current camera controller
  CameraController? get controller => _controller;
  
  /// Initialize camera
  Future<bool> initialize({bool frontCamera = false}) async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return false;
      }
      
      // Select camera (back by default for road detection)
      final cameraIndex = frontCamera ? 1 : 0;
      final camera = _cameras!.length > cameraIndex 
          ? _cameras![cameraIndex] 
          : _cameras!.first;
      
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _controller!.initialize();
      _isInitialized = true;
      
      debugPrint('Camera initialized: ${camera.name}');
      return true;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      return false;
    }
  }
  
  /// Start streaming frames for AI processing
  Future<void> startStreaming() async {
    if (!_isInitialized || _isStreaming) return;
    
    try {
      await _controller!.startImageStream((CameraImage image) {
        if (!_frameController.isClosed) {
          _frameController.add(image);
        }
      });
      _isStreaming = true;
      debugPrint('Camera streaming started');
    } catch (e) {
      debugPrint('Stream start error: $e');
    }
  }
  
  /// Stop streaming
  Future<void> stopStreaming() async {
    if (!_isStreaming) return;
    
    try {
      await _controller!.stopImageStream();
      _isStreaming = false;
      debugPrint('Camera streaming stopped');
    } catch (e) {
      debugPrint('Stream stop error: $e');
    }
  }
  
  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    final currentLens = _controller?.description.lensDirection;
    final newLens = currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    
    await dispose();
    await initialize(frontCamera: newLens == CameraLensDirection.front);
    if (_isStreaming) {
      await startStreaming();
    }
  }
  
  /// Take a snapshot
  Future<XFile?> takePhoto() async {
    if (!_isInitialized) return null;
    
    try {
      final file = await _controller!.takePicture();
      debugPrint('Photo taken: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('Photo error: $e');
      return null;
    }
  }
  
  /// Start video recording
  Future<void> startRecording() async {
    if (!_isInitialized) return;
    
    try {
      await _controller!.startVideoRecording();
      debugPrint('Recording started');
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }
  
  /// Stop video recording
  Future<XFile?> stopRecording() async {
    try {
      final file = await _controller!.stopVideoRecording();
      debugPrint('Recording stopped: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('Recording stop error: $e');
      return null;
    }
  }
  
  /// Set zoom level (1.0 - 8.0)
  Future<void> setZoom(double zoom) async {
    if (!_isInitialized) return;
    
    final minZoom = await _controller!.getMinZoomLevel();
    final maxZoom = await _controller!.getMaxZoomLevel();
    final clampedZoom = zoom.clamp(minZoom, maxZoom);
    
    await _controller!.setZoomLevel(clampedZoom);
  }
  
  /// Toggle flash
  Future<void> toggleFlash() async {
    if (!_isInitialized) return;
    
    final currentMode = _controller!.value.flashMode;
    final newMode = currentMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    
    await _controller!.setFlashMode(newMode);
  }
  
  /// Dispose camera resources
  Future<void> dispose() async {
    await stopStreaming();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    debugPrint('Camera disposed');
  }
  
  /// Cleanup
  void close() {
    _frameController.close();
    dispose();
  }
}
