import Foundation
import Combine

public class ExerciseTracker: ObservableObject, @unchecked Sendable {
    @Published public private(set) var count: Int = 0
    @Published public private(set) var currentMetric: Double = 0.0
    @Published public private(set) var isRecording: Bool = false
    
    @Published public private(set) var currentType: ExerciseType
    private var strategy: ExerciseStrategy
    
    public init(type: ExerciseType) {
        self.currentType = type
        self.strategy = ExerciseFactory.createStrategy(for: type)
        setupCallbacks()
    }
    
    public func switchExercise(to type: ExerciseType) {
        if isRecording {
            stop()
        }
        self.currentType = type
        self.strategy = ExerciseFactory.createStrategy(for: type)
        self.count = 0
        self.currentMetric = 0.0
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        strategy.onCountChanged = { [weak self] newCount in
            self?.count = newCount
        }
        
        strategy.onMetricChanged = { [weak self] newMetric in
            self?.currentMetric = newMetric
        }
        
        strategy.onRecordingStateChanged = { [weak self] recordingState in
            self?.isRecording = recordingState
        }
    }
    
    public func start() {
        strategy.startRecording()
    }
    
    public func stop() {
        strategy.stopRecording()
    }
    
    // Support for manual exercises (like PullUp)
    public func increment() {
        strategy.manualIncrement()
    }
    
    public func decrement() {
        strategy.manualDecrement()
    }
}
