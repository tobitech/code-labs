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

class DocumentBrowserDelegate: NSObject, UIDocumentBrowserViewControllerDelegate {
  var presentationHandler: ((URL?, Error?) -> Void)?
  
  func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
    //1.
    let cacheurl = createNewDocumentURL()
    let newdoc = MarkupDocument(fileURL: cacheurl)
    
    //2.
    newdoc.save(to: cacheurl, for: .forCreating) { saveSuccess in
      
      //3.
      guard saveSuccess else {
        importHandler(nil, .none)
        return
      }
      
      //4.
      newdoc.close { (closeSuccess) in
        guard closeSuccess else {
          importHandler(nil, .none)
          return
        }
        
        importHandler(cacheurl, .move)
      }
    }
  }
  
  func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
    guard let pickedurl = documentURLs.first else {
      return
    }
    presentationHandler?(pickedurl, nil)
  }
  
  func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
    presentationHandler?(destinationURL, nil)
  }
  
  func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
    presentationHandler?(documentURL, error)
  }
  
}

extension DocumentBrowserDelegate {
  
  static let newDocNumberKey = "newDocNumber"
  
  private func getDocumentName() -> String {
    let newDocNumber = UserDefaults.standard.integer(forKey: DocumentBrowserDelegate.newDocNumberKey)
    return "Untitled \(newDocNumber)"
  }
  
  private func incrementNameCount() {
    let newDocNumber = UserDefaults.standard.integer(forKey: DocumentBrowserDelegate.newDocNumberKey) + 1
    UserDefaults.standard.set(newDocNumber, forKey: DocumentBrowserDelegate.newDocNumberKey)
  }
  
  func createNewDocumentURL() -> URL {
    let docspath = UIApplication.cacheDirectory()
    let newName = getDocumentName()
    let stuburl = docspath.appendingPathComponent(newName).appendingPathExtension(MarkupDocument.filenameExtension)
    incrementNameCount()
    return stuburl
  }
  
}
