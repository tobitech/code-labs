/// Copyright (c) 2018 Razeware LLC
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

import UIKit
import MarkupFramework

enum DocumentError: Error {
  case unrecognizedContent
  case corruptDocument
  case archivingFailure
  
  var localizedDescription: String {
    switch self {
      
    case .unrecognizedContent:
      return NSLocalizedString("File is an unrecognised format", comment: "")
    case .corruptDocument:
      return NSLocalizedString("File could not be read", comment: "")
    case .archivingFailure:
      return NSLocalizedString("File could not be saved", comment: "")
    }
  }
  
}

class MarkupDocument: UIDocument {
  
  static let defaultTemplateName = BottomAlignedView.name
  static let filenameExtension = "rwmarkup"
  
  var markup: MarkupDescription = ContentDescription(template: defaultTemplateName) {
    didSet {
      updateChangeCount(.done)
    }
  }
  
  override func contents(forType typeName: String) throws -> Any {
    let data: Data
    do {
      data = try NSKeyedArchiver.archivedData(withRootObject: markup, requiringSecureCoding: false)
    } catch {
      throw DocumentError.archivingFailure
    }
    guard !data.isEmpty else {
      throw DocumentError.archivingFailure
    }
    return data
  }
  
  override func load(fromContents contents: Any, ofType typeName: String?) throws {
    // 1
    guard let data = contents as? Data else {
      throw DocumentError.unrecognizedContent
    }
    
    // 2
    let unarchiver: NSKeyedUnarchiver
    do {
      unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
    } catch {
      throw DocumentError.corruptDocument
    }
    unarchiver.requiresSecureCoding = false
    let decodedContent = unarchiver.decodeObject(of: ContentDescription.self,
                                                 forKey: NSKeyedArchiveRootObjectKey)
    guard let content = decodedContent else {
      throw DocumentError.corruptDocument
    }
    
    // 3
    markup = content
  }

}
