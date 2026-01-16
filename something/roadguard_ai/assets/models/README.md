# TFLite Models

Place your TensorFlow Lite models here:

- `yolov8_detect.tflite` - Object detection model
- `lane_detect.tflite` - Lane detection model
- `traffic_signs.tflite` - Traffic sign recognition model

## Downloading Pre-trained Models

You can download pre-trained models from:

1. **TensorFlow Hub**: https://tfhub.dev/
2. **Kaggle**: Search for "YOLOv8 TFLite" or "Object Detection TFLite"
3. **Ultralytics**: Convert YOLOv8 to TFLite format

## Converting Your Own Model

```python
# Convert YOLOv8 to TFLite
from ultralytics import YOLO
model = YOLO('yolov8n.pt')
model.export(format='tflite')
```

## Model Requirements

- Input: 640x640 RGB image (or resize in app)
- Output: Detection boxes, classes, confidence scores
- Optimized for mobile (quantized if possible)
