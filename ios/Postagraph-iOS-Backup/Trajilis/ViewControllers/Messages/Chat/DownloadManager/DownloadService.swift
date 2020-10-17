/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

// Downloads song snippets, and stores in local file.
// Allows cancel, pause, resume download.
class DownloadService {

    
  // SearchViewController creates downloadsSession
  var downloadsSession: URLSession!
  var activeDownloads: [URL: Download] = [:]

  // MARK: - Download methods called by TrackCell delegate methods

    func startDownload(_ message: Message) {
        // 1
        guard let strurl = message.mediaURL,let url = URL(string: strurl) else {return}
        if !self.activeDownloads.keys.contains(url) {
            let download = Download(message: message)            
            // 2
            download.task = downloadsSession.downloadTask(with: url)
            // 3
            download.task!.resume()
            // 4
            download.isDownloading = true
            // 5
            activeDownloads[url] = download
        }
    }

  func pauseDownload(_ message: Message) {
    guard let strurl = message.mediaURL,let url = URL(string: strurl) else {return}
    
    guard let download = activeDownloads[url] else { return }
    if download.isDownloading {
      download.task?.cancel(byProducingResumeData: { data in
        download.resumeData = data
      })
      download.isDownloading = false
    }
  }

  func cancelDownload(_ message: Message) {
    guard let strurl = message.mediaURL,let url = URL(string: strurl) else {return}
    
    if let download = activeDownloads[url] {
      download.task?.cancel()
      activeDownloads[url] = nil
    }
  }

  func resumeDownload(_ message: Message) {
    guard let strurl = message.mediaURL,let url = URL(string: strurl) else {return}
    guard let download = activeDownloads[url] else { return }
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
    } else {
      download.task = downloadsSession.downloadTask(with: url)
    }
    download.task!.resume()
    download.isDownloading = true
  }

}
