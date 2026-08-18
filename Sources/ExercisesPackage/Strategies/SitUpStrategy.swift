import Foundation
#if os(iOS) || os(watchOS)
import CoreMotion
#endif

public class SitUpStrategy: ExerciseStrategy {
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
    private var baselineGravity: CMAcceleration?
    #endif
    
    private var isUpPosition = false
    private var lastStateChangeTime: Date = Date()
    
    public init() {}
    
    public func startRecording() {
        #if os(iOS) || os(watchOS)
        guard motionManager.isDeviceMotionAvailable else { return }
        
        count = 0
        isRecording = true
        isUpPosition = false
        currentMetric = 0.0
        lastStateChangeTime = Date()
        baselineGravity = nil
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0 // 50 Hz
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let self = self, let motion = motion else { return }
            
            let gX = motion.gravity.x
            let gY = motion.gravity.y
            let gZ = motion.gravity.z
            
            if self.baselineGravity == nil {
                self.baselineGravity = motion.gravity
                return
            }
            
            guard let baseline = self.baselineGravity else { return }
            
            let dotProduct = gX * baseline.x + gY * baseline.y + gZ * baseline.z
            let clampedDot = max(-1.0, min(1.0, dotProduct))
            let angleRadians = acos(clampedDot)
            let angleDegrees = angleRadians * 180.0 / .pi
            
            self.currentMetric = angleDegrees
            
            let thresholdUp = 45.0
            let thresholdDown = 20.0
            let now = Date()
            
            if !self.isUpPosition && angleDegrees > thresholdUp {
                if now.timeIntervalSince(self.lastStateChangeTime) > 0.4 {
                    self.isUpPosition = true
                    self.lastStateChangeTime = now
                }
            } else if self.isUpPosition && angleDegrees < thresholdDown {
                if now.timeIntervalSince(self.lastStateChangeTime) > 0.4 {
                    self.count += 1
                    self.isUpPosition = false
                    self.lastStateChangeTime = now
                }
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
