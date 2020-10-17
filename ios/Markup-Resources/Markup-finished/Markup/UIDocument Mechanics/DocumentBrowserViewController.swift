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

class DocumentBrowserViewController: UIViewController {
  
  var currentDocument: MarkupDocument?
  var editingDocument = false
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  var browserDelegate = DocumentBrowserDelegate()
  lazy var documentBrowser: UIDocumentBrowserViewController = {
    let browser = UIDocumentBrowserViewController()
    
    browser.allowsDocumentCreation = true
    browser.browserUserInterfaceStyle = .dark
    browser.view.tintColor = UIColor(named: "RazeGreen") ?? .white
    browser.delegate = browserDelegate
    
    return browser
  }()
  
  func installDocumentBrowser() {
    view.pinToInside(view: documentBrowser.view)
    browserDelegate.presentationHandler = { [weak self] url, error in
      
      guard error == nil else {
        //present error to user e.g UIAlertController
        return
      }
      
      if let url = url, let self = self {
        self.openDocument(url: url)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    installDocumentBrowser()
  }
  
}

extension DocumentBrowserViewController {
  
  func openDocument(url: URL) {
    
    //1.
    guard isDocumentCurrentlyOpen(url: url) == false else {
      return
    }
    
    
    closeMarkupController {
      //2.
      let document = MarkupDocument(fileURL: url)
      document.open { openSuccess in
        guard openSuccess else {
          return
        }
        self.currentDocument = document
        self.displayMarkupController()
      }
    }
  }
  
  //3.
  private func isDocumentCurrentlyOpen(url: URL) -> Bool {
    if let document = currentDocument {
      if document.fileURL == url && document.documentState != .closed  {
        return true
      }
    }
    return false
  }
  
  private func closeCurrentDocument()  {
    currentDocument?.close()
    currentDocument = nil
  }
  
}

extension DocumentBrowserViewController: MarkupViewControllerDelegate {
  
  //1.
  func displayMarkupController() {
    
    guard !editingDocument, let document = currentDocument else {
      return
    }
    
    editingDocument = true
    let controller = MarkupViewController.freshController(markup: document.markup, delegate: self)
    present(controller, animated: true)
  }
  
  //2.
  func closeMarkupController(completion: (() -> Void)? = nil) {
    
    let compositeClosure = {
      self.closeCurrentDocument()
      self.editingDocument = false
      completion?()
    }
    
    if editingDocument {
      dismiss(animated: true) {
        compositeClosure()
      }
    } else {
      compositeClosure()
    }
  }
  
  func markupEditorDidFinishEditing(_ controller: MarkupViewController, markup: MarkupDescription) {
    currentDocument?.markup = markup
    closeMarkupController()
  }
  
  func markupEditorDidUpdateContent(_ controller: MarkupViewController, markup: MarkupDescription) {
    currentDocument?.markup = markup
  }
  
}

extension DocumentBrowserViewController {
  func openRemoteDocument(_ inboundURL: URL, importIfNeeded: Bool) {
    documentBrowser.revealDocument(at: inboundURL, importIfNeeded: importIfNeeded) { (url, error) in
      if let error = error {
        print("import did fail - should be communicated to user - \(error)")
      } else if let url = url {
        self.openDocument(url: url)
      }
    }
  }
}
