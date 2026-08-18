import Foundation

public class ExerciseFactory {
    public static func createStrategy(for type: ExerciseType) -> ExerciseStrategy {
        switch type {
        case .pullUp:
            return PullUpStrategy()
        case .sitUp:
            return SitUpStrategy()
        case .squat:
            return SquatStrategy()
        case .pushUp:
            return PushUpStrategy()
        }
    }
}
