import Foundation

public class PullUpStrategy: ExerciseStrategy {
    public var count: Int = 0 {
        didSet {
            onCountChanged?(count)
        }
    }
    
    public var currentMetric: Double = 0.0 {
        didSet {
            onMetricChanged?(currentMetric)
        }
    }
    
    public var isRecording: Bool = false {
        didSet {
            onRecordingStateChanged?(isRecording)
        }
    }
    
    public var onCountChanged: ((Int) -> Void)?
    public var onMetricChanged: ((Double) -> Void)?
    public var onRecordingStateChanged: ((Bool) -> Void)?
    
    public init() {}
    
    public func startRecording() {
        count = 0
        currentMetric = 0.0
        isRecording = true
    }
    
    public func stopRecording() {
        isRecording = false
    }
    
    public func manualIncrement() {
        guard isRecording else { return }
        count += 1
    }
    
    public func manualDecrement() {
        guard isRecording else { return }
        if count > 0 {
            count -= 1
        }
    }
}
