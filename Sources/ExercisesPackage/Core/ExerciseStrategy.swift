import Foundation

public protocol ExerciseStrategy: AnyObject {
    var count: Int { get }
    var currentMetric: Double { get }
    var isRecording: Bool { get }
    
    var onCountChanged: ((Int) -> Void)? { get set }
    var onMetricChanged: ((Double) -> Void)? { get set }
    var onRecordingStateChanged: ((Bool) -> Void)? { get set }
    
    func startRecording()
    func stopRecording()
    
    // Optional methods for manual exercises (like PullUp)
    func manualIncrement()
    func manualDecrement()
}

// Provide default implementations so strategies that don't need them don't have to implement them
public extension ExerciseStrategy {
    func manualIncrement() {}
    func manualDecrement() {}
}
