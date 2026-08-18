import Foundation
#if os(iOS) || os(watchOS)
import CoreMotion
#endif

public class PushUpStrategy: ExerciseStrategy {
    public var count: Int = 0 {
        didSet { onCountChanged?(count) }
    }
    
    public var currentMetric: Double = 0.0 {
        didSet { onMetricChanged?(currentMetric) }
    }
    
    public var isRecording: Bool = false {
        didSet { onRecordingStateChanged?(isRecording) }
    }
    
    public var onCountChanged: ((Int) -> Void)?
    public var onMetricChanged: ((Double) -> Void)?
    public var onRecordingStateChanged: ((Bool) -> Void)?
    
    #if os(iOS) || os(watchOS)
    private let motionManager = CMMotionManager()
    #endif
    private var isDownPosition = false
    private var maxPitch: Double = -Double.greatestFiniteMagnitude
    private var minPitch: Double = Double.greatestFiniteMagnitude
    private var lastPushupTime: TimeInterval = 0
    
    public init() {}
    
    public func startRecording() {
        #if os(iOS) || os(watchOS)
        guard motionManager.isDeviceMotionAvailable else { return }
        
        count = 0
        isRecording = true
        isDownPosition = false
        maxPitch = -Double.greatestFiniteMagnitude
        minPitch = Double.greatestFiniteMagnitude
        currentMetric = 0.0
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0 // 50 Hz
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let self = self, let motion = motion else { return }
            
            let pitch = motion.attitude.pitch
            self.currentMetric = pitch
            
            if pitch > self.maxPitch { self.maxPitch = pitch }
            if pitch < self.minPitch { self.minPitch = pitch }
            
            let threshold = 0.24
            
            if !self.isDownPosition && (self.maxPitch - pitch) > threshold {
                self.isDownPosition = true
                self.minPitch = pitch
            } else if self.isDownPosition && (pitch - self.minPitch) > threshold {
                let currentTime = Date().timeIntervalSince1970
                if (currentTime - self.lastPushupTime) > 0.8 {
                    self.count += 1
                    self.lastPushupTime = currentTime
                }
                
                self.isDownPosition = false
                self.maxPitch = pitch
            }
        }
        #endif
    }
    
    public func stopRecording() {
        #if os(iOS) || os(watchOS)
        motionManager.stopDeviceMotionUpdates()
        #endif
        isRecording = false
    }
}
