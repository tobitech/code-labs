import Foundation

public func delay(_ delay: TimeInterval, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

public func exampleOf(description: String, action: () -> Void) {
    
    print("\n--- Example of:", description, "---")
    action()
    
}

#if NOT_IN_PLAYGROUND

public func playgroundTimeLimit(seconds: TimeInterval) {
}

#else

import PlaygroundSupport
public func playgroundTimeLimit(seconds: TimeInterval) {
    PlaygroundPage.current.needsIndefiniteExecution = true
    delay(seconds) {
        PlaygroundPage.current.finishExecution()
    }
}

#endif
