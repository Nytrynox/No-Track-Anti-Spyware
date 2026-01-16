/// App settings model
class AppSettings {
  // Detection settings
  bool objectDetectionEnabled;
  bool laneDetectionEnabled;
  bool trafficSignEnabled;
  bool trafficLightEnabled;
  double confidenceThreshold;
  
  // Alert settings
  bool voiceAlertsEnabled;
  bool vibrationAlertsEnabled;
  bool soundAlertsEnabled;
  String voiceLanguage;
  double voiceSpeed;
  double alertVolume;
  
  // Speed settings
  bool speedMonitoringEnabled;
  double speedLimitWarning;
  bool autoSpeedLimitDetection;
  
  // Recording settings
  bool dashCamEnabled;
  bool autoRecordOnStart;
  int maxRecordingMinutes;
  
  // Display settings
  bool showBoundingBoxes;
  bool showConfidence;
  bool showDistance;
  bool showLaneLines;
  bool hudModeEnabled;
  
  // Safety settings
  bool crashDetectionEnabled;
  bool sosEnabled;
  String? emergencyContact;
  
  // Advanced settings
  bool nightModeAuto;
  bool weatherIntegrationEnabled;
  bool offlineModeEnabled;
  bool cloudBackupEnabled;
  
  AppSettings({
    this.objectDetectionEnabled = true,
    this.laneDetectionEnabled = true,
    this.trafficSignEnabled = true,
    this.trafficLightEnabled = true,
    this.confidenceThreshold = 0.5,
    this.voiceAlertsEnabled = true,
    this.vibrationAlertsEnabled = true,
    this.soundAlertsEnabled = true,
    this.voiceLanguage = 'en-US',
    this.voiceSpeed = 1.0,
    this.alertVolume = 0.8,
    this.speedMonitoringEnabled = true,
    this.speedLimitWarning = 80.0,
    this.autoSpeedLimitDetection = true,
    this.dashCamEnabled = false,
    this.autoRecordOnStart = false,
    this.maxRecordingMinutes = 30,
    this.showBoundingBoxes = true,
    this.showConfidence = true,
    this.showDistance = true,
    this.showLaneLines = true,
    this.hudModeEnabled = false,
    this.crashDetectionEnabled = true,
    this.sosEnabled = true,
    this.emergencyContact,
    this.nightModeAuto = true,
    this.weatherIntegrationEnabled = true,
    this.offlineModeEnabled = true,
    this.cloudBackupEnabled = false,
  });
  
  AppSettings copyWith({
    bool? objectDetectionEnabled,
    bool? laneDetectionEnabled,
    bool? trafficSignEnabled,
    bool? trafficLightEnabled,
    double? confidenceThreshold,
    bool? voiceAlertsEnabled,
    bool? vibrationAlertsEnabled,
    bool? soundAlertsEnabled,
    String? voiceLanguage,
    double? voiceSpeed,
    double? alertVolume,
    bool? speedMonitoringEnabled,
    double? speedLimitWarning,
    bool? autoSpeedLimitDetection,
    bool? dashCamEnabled,
    bool? autoRecordOnStart,
    int? maxRecordingMinutes,
    bool? showBoundingBoxes,
    bool? showConfidence,
    bool? showDistance,
    bool? showLaneLines,
    bool? hudModeEnabled,
    bool? crashDetectionEnabled,
    bool? sosEnabled,
    String? emergencyContact,
    bool? nightModeAuto,
    bool? weatherIntegrationEnabled,
    bool? offlineModeEnabled,
    bool? cloudBackupEnabled,
  }) {
    return AppSettings(
      objectDetectionEnabled: objectDetectionEnabled ?? this.objectDetectionEnabled,
      laneDetectionEnabled: laneDetectionEnabled ?? this.laneDetectionEnabled,
      trafficSignEnabled: trafficSignEnabled ?? this.trafficSignEnabled,
      trafficLightEnabled: trafficLightEnabled ?? this.trafficLightEnabled,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      voiceAlertsEnabled: voiceAlertsEnabled ?? this.voiceAlertsEnabled,
      vibrationAlertsEnabled: vibrationAlertsEnabled ?? this.vibrationAlertsEnabled,
      soundAlertsEnabled: soundAlertsEnabled ?? this.soundAlertsEnabled,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      alertVolume: alertVolume ?? this.alertVolume,
      speedMonitoringEnabled: speedMonitoringEnabled ?? this.speedMonitoringEnabled,
      speedLimitWarning: speedLimitWarning ?? this.speedLimitWarning,
      autoSpeedLimitDetection: autoSpeedLimitDetection ?? this.autoSpeedLimitDetection,
      dashCamEnabled: dashCamEnabled ?? this.dashCamEnabled,
      autoRecordOnStart: autoRecordOnStart ?? this.autoRecordOnStart,
      maxRecordingMinutes: maxRecordingMinutes ?? this.maxRecordingMinutes,
      showBoundingBoxes: showBoundingBoxes ?? this.showBoundingBoxes,
      showConfidence: showConfidence ?? this.showConfidence,
      showDistance: showDistance ?? this.showDistance,
      showLaneLines: showLaneLines ?? this.showLaneLines,
      hudModeEnabled: hudModeEnabled ?? this.hudModeEnabled,
      crashDetectionEnabled: crashDetectionEnabled ?? this.crashDetectionEnabled,
      sosEnabled: sosEnabled ?? this.sosEnabled,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      nightModeAuto: nightModeAuto ?? this.nightModeAuto,
      weatherIntegrationEnabled: weatherIntegrationEnabled ?? this.weatherIntegrationEnabled,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'objectDetectionEnabled': objectDetectionEnabled,
    'laneDetectionEnabled': laneDetectionEnabled,
    'trafficSignEnabled': trafficSignEnabled,
    'trafficLightEnabled': trafficLightEnabled,
    'confidenceThreshold': confidenceThreshold,
    'voiceAlertsEnabled': voiceAlertsEnabled,
    'vibrationAlertsEnabled': vibrationAlertsEnabled,
    'soundAlertsEnabled': soundAlertsEnabled,
    'voiceLanguage': voiceLanguage,
    'voiceSpeed': voiceSpeed,
    'alertVolume': alertVolume,
    'speedMonitoringEnabled': speedMonitoringEnabled,
    'speedLimitWarning': speedLimitWarning,
    'autoSpeedLimitDetection': autoSpeedLimitDetection,
    'dashCamEnabled': dashCamEnabled,
    'autoRecordOnStart': autoRecordOnStart,
    'maxRecordingMinutes': maxRecordingMinutes,
    'showBoundingBoxes': showBoundingBoxes,
    'showConfidence': showConfidence,
    'showDistance': showDistance,
    'showLaneLines': showLaneLines,
    'hudModeEnabled': hudModeEnabled,
    'crashDetectionEnabled': crashDetectionEnabled,
    'sosEnabled': sosEnabled,
    'emergencyContact': emergencyContact,
    'nightModeAuto': nightModeAuto,
    'weatherIntegrationEnabled': weatherIntegrationEnabled,
    'offlineModeEnabled': offlineModeEnabled,
    'cloudBackupEnabled': cloudBackupEnabled,
  };
  
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    objectDetectionEnabled: json['objectDetectionEnabled'] as bool? ?? true,
    laneDetectionEnabled: json['laneDetectionEnabled'] as bool? ?? true,
    trafficSignEnabled: json['trafficSignEnabled'] as bool? ?? true,
    trafficLightEnabled: json['trafficLightEnabled'] as bool? ?? true,
    confidenceThreshold: json['confidenceThreshold'] as double? ?? 0.5,
    voiceAlertsEnabled: json['voiceAlertsEnabled'] as bool? ?? true,
    vibrationAlertsEnabled: json['vibrationAlertsEnabled'] as bool? ?? true,
    soundAlertsEnabled: json['soundAlertsEnabled'] as bool? ?? true,
    voiceLanguage: json['voiceLanguage'] as String? ?? 'en-US',
    voiceSpeed: json['voiceSpeed'] as double? ?? 1.0,
    alertVolume: json['alertVolume'] as double? ?? 0.8,
    speedMonitoringEnabled: json['speedMonitoringEnabled'] as bool? ?? true,
    speedLimitWarning: json['speedLimitWarning'] as double? ?? 80.0,
    autoSpeedLimitDetection: json['autoSpeedLimitDetection'] as bool? ?? true,
    dashCamEnabled: json['dashCamEnabled'] as bool? ?? false,
    autoRecordOnStart: json['autoRecordOnStart'] as bool? ?? false,
    maxRecordingMinutes: json['maxRecordingMinutes'] as int? ?? 30,
    showBoundingBoxes: json['showBoundingBoxes'] as bool? ?? true,
    showConfidence: json['showConfidence'] as bool? ?? true,
    showDistance: json['showDistance'] as bool? ?? true,
    showLaneLines: json['showLaneLines'] as bool? ?? true,
    hudModeEnabled: json['hudModeEnabled'] as bool? ?? false,
    crashDetectionEnabled: json['crashDetectionEnabled'] as bool? ?? true,
    sosEnabled: json['sosEnabled'] as bool? ?? true,
    emergencyContact: json['emergencyContact'] as String?,
    nightModeAuto: json['nightModeAuto'] as bool? ?? true,
    weatherIntegrationEnabled: json['weatherIntegrationEnabled'] as bool? ?? true,
    offlineModeEnabled: json['offlineModeEnabled'] as bool? ?? true,
    cloudBackupEnabled: json['cloudBackupEnabled'] as bool? ?? false,
  );
}
