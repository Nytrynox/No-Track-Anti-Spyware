import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/detection_result.dart';

/// Real AI Detection using TFLite MobileNet SSD
/// Detects 80+ COCO classes including cars, people, bikes, trucks, buses
class DetectionService {
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  Interpreter? _interpreter;
  List<String> _labels = [];
  
  CameraController? _cameraController;
  Timer? _detectionTimer;
  
  // MobileNet SSD specs
  static const int inputSize = 300;
  static const int numResults = 20;
  
  final StreamController<List<DetectionResult>> _detectionController =
      StreamController<List<DetectionResult>>.broadcast();
  
  final StreamController<LaneDetection?> _laneController =
      StreamController<LaneDetection?>.broadcast();
  
  double _threshold = 0.30; // Very low threshold to detect ALL objects
  int _detectionCount = 0;
  
  Stream<List<DetectionResult>> get detectionStream => _detectionController.stream;
  Stream<LaneDetection?> get laneStream => _laneController.stream;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  
  Future<bool> initialize() async {
    try {
      debugPrint('🚀 Loading MobileNet SSD model...');
      
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_ssd.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      
      // Log model info
      final input = _interpreter!.getInputTensor(0);
      final outputs = _interpreter!.getOutputTensors();
      debugPrint('📊 Input: ${input.shape} (${input.type})');
      for (int i = 0; i < outputs.length; i++) {
        debugPrint('📊 Output[$i]: ${outputs[i].shape} (${outputs[i].type})');
      }
      
      await _loadLabels();
      
      _isInitialized = true;
      debugPrint('✅ Model loaded successfully!');
      return true;
    } catch (e) {
      debugPrint('❌ Model load error: $e');
      return false;
    }
  }
  
  Future<void> _loadLabels() async {
    try {
      final data = await rootBundle.loadString('assets/models/coco_labels.txt');
      _labels = data.split('\n').where((s) => s.trim().isNotEmpty).toList();
      debugPrint('📋 Loaded ${_labels.length} labels');
    } catch (e) {
      // Fallback
      _labels = [
        'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck',
        'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench',
        'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe',
      ];
    }
  }
  
  void setConfidenceThreshold(double threshold) {
    _threshold = threshold.clamp(0.1, 0.9);
  }
  
  void startDetection(CameraController controller) {
    if (_detectionTimer != null) return;
    
    _cameraController = controller;
    
    // Run every 600ms for faster, more responsive detection
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _runDetection();
    });
    
    debugPrint('🎥 Detection started');
  }
  
  void stopDetection() {
    _stopTimer();
    _cameraController = null;
    debugPrint('⏹️ Detection stopped');
  }
  
  void _stopTimer() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
  }
  
  Future<void> _runDetection() async {
    if (!_isInitialized || _isProcessing || _interpreter == null) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    // Can't take picture while streaming (if relevant)
    if (_cameraController!.value.isStreamingImages) {
      return;
    }
    
    _isProcessing = true;
    
    try {
      // Capture image
      final XFile photo = await _cameraController!.takePicture();
      final bytes = await File(photo.path).readAsBytes();
      
      // Decode image
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        _isProcessing = false;
        return;
      }
      
      // Resize to 300x300
      final resized = img.copyResize(decoded, width: inputSize, height: inputSize);
      
      // Prepare input (uint8)
      final input = Uint8List(inputSize * inputSize * 3);
      int idx = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          input[idx++] = pixel.r.toInt();
          input[idx++] = pixel.g.toInt();
          input[idx++] = pixel.b.toInt();
        }
      }
      
      // Reshape for model
      final inputReshaped = input.reshape([1, inputSize, inputSize, 3]);
      
      // Prepare outputs
      final boxes = List.generate(1, (_) => List.generate(numResults, (_) => List.filled(4, 0.0)));
      final classes = List.generate(1, (_) => List.filled(numResults, 0.0));
      final scores = List.generate(1, (_) => List.filled(numResults, 0.0));
      final count = List.filled(1, 0.0);
      
      // Run inference
      _interpreter!.runForMultipleInputs(
        [inputReshaped],
        {0: boxes, 1: classes, 2: scores, 3: count},
      );
      
      _detectionCount++;
      
      // Parse results
      final rawDetections = <DetectionResult>[];
      final numDetected = min(count[0].toInt(), numResults);
      
      for (int i = 0; i < numDetected; i++) {
        final score = scores[0][i];
        if (score < _threshold) continue;
        
        final classId = classes[0][i].toInt();
        final label = classId < _labels.length ? _labels[classId] : 'object';
        
        // ALLOW EVERYTHING - User wants "everything detected"
        // But still filter complete noise if needed, but for now we trust the model.
        // if (!_isRoadRelevant(label)) continue;
        
        final top = boxes[0][i][0].clamp(0.0, 1.0);
        final left = boxes[0][i][1].clamp(0.0, 1.0);
        final bottom = boxes[0][i][2].clamp(0.0, 1.0);
        final right = boxes[0][i][3].clamp(0.0, 1.0);
        
        final boxHeight = (bottom - top).abs();
        final distance = _estimateDistance(boxHeight, label);
        
        rawDetections.add(DetectionResult(
          label: label,
          confidence: score,
          boundingBox: Rect.fromLTRB(left, top, right, bottom),
          distance: distance,
        ));
      }
      
      // Emit results ONLY if still running
      if (_detectionTimer != null && !_detectionController.isClosed) {
        _detectionController.add(rawDetections);
      }
      
      // Cleanup
      try { await File(photo.path).delete(); } catch (_) {}
      
    } catch (e) {
      debugPrint('❌ Detection error: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  double _estimateDistance(double boxHeight, String label) {
    if (boxHeight <= 0.05) return 100.0;
    if (boxHeight >= 0.8) return 2.0;
    
    // Reference heights at 10m distance
    final refs = {
      'person': 0.35,
      'car': 0.18,
      'truck': 0.25,
      'bus': 0.30,
      'motorcycle': 0.22,
      'bicycle': 0.28,
      'stop sign': 0.40,
      'traffic light': 0.30,
    };
    final ref = refs[label] ?? 0.20;
    return ((ref / boxHeight) * 10.0).clamp(2.0, 100.0);
  }
  
  void dispose() {
    _stopTimer();
    _interpreter?.close();
    _detectionController.close();
    _laneController.close();
  }
}

// Placeholder services to satisfy other dependencies if any
class TrafficSignService {
  bool _isInitialized = false;
  final StreamController<List<String>> _ctrl = StreamController.broadcast();
  Stream<List<String>> get signStream => _ctrl.stream;
  Future<bool> initialize() async { _isInitialized = true; return true; }
  void dispose() => _ctrl.close();
}

class TrafficLightService {
  bool _isInitialized = false;
  final StreamController<String?> _ctrl = StreamController.broadcast();
  Stream<String?> get lightStream => _ctrl.stream;
  Future<bool> initialize() async { _isInitialized = true; return true; }
  void dispose() => _ctrl.close();
}
