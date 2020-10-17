/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import LocalAuthentication

enum BiometricType {
  case none
  case touchID
  case faceID
}

class BiometricIDAuth {
  let context = LAContext()
  let loginReason = "Logging in with Touch ID"
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func biometricType() -> BiometricType {
    let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    switch context.biometryType {
    case .touchID:
      return .touchID
    case .faceID:
      return .faceID
    default:
      return .none
    }
  }
  
  func authenticateUser(completion: @escaping (String?) -> Void) { // 1
    // 2
    guard canEvaluatePolicy() else {
      completion("Touch ID not available")
      return
    }
    
    // 3
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { success, evaluateError in
      // 4
      if success {
        DispatchQueue.main.async {
          // User authenticated successfully, take appropriate action
          completion(nil)
        }
      } else {
        // 1
        let message: String
                    
        // 2
        switch evaluateError {
        // 3
        case LAError.authenticationFailed?:
          message = "There was a problem verifying your identity."
        case LAError.userCancel?:
          message = "You pressed cancel."
        case LAError.userFallback?:
          message = "You pressed password."
        case LAError.biometryNotAvailable?:
          message = "Face ID/Touch ID is not available."
        case LAError.biometryNotEnrolled?:
          message = "Face ID/Touch ID is not set up."
        case LAError.biometryLockout?:
          message = "Face ID/Touch ID is locked."
        default:
          message = "Face ID/Touch ID may not be configured"
        }
        // 4
        completion(message)

      }
    }
  }
}
