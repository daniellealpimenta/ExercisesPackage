import Foundation
#if os(iOS) || os(watchOS)
import CoreMotion
#endif

public class SquatStrategy: ExerciseStrategy {
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
    private var velocity: Double = 0.0
    private var filteredAcc: Double = 0.0
    
    public init() {}
    
    public func startRecording() {
        #if os(iOS) || os(watchOS)
        guard motionManager.isDeviceMotionAvailable else { return }
        
        count = 0
        isRecording = true
        isDownPosition = false
        velocity = 0.0
        filteredAcc = 0.0
        currentMetric = 0.0
        
        let dt = 1.0 / 50.0
        motionManager.deviceMotionUpdateInterval = dt
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let self = self, let motion = motion else { return }
            
            let downAcc = motion.userAcceleration.x * motion.gravity.x +
                          motion.userAcceleration.y * motion.gravity.y +
                          motion.userAcceleration.z * motion.gravity.z
            
            let upAcc = -downAcc
            
            self.filteredAcc = self.filteredAcc * 0.8 + upAcc * 0.2
            
            var activeAcc = self.filteredAcc
            if abs(activeAcc) < 0.03 { activeAcc = 0 }
            
            self.velocity += activeAcc * dt
            self.velocity *= 0.92
            
            self.currentMetric = self.velocity * 100
            
            let thresholdDown = -1.5
            let thresholdUp = 1.5
            
            if !self.isDownPosition && self.currentMetric < thresholdDown {
                self.isDownPosition = true
            } else if self.isDownPosition && self.currentMetric > thresholdUp {
                self.count += 1
                self.isDownPosition = false
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
