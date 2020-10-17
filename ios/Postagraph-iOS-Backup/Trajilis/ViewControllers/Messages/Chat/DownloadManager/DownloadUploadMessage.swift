
import Foundation

// Download service creates Download objects
class Download {
    
    var message: Message
    init(message: Message) {
        self.message = message
    }
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    // Download delegate sets this value:
    var progress: Float = 0
    
}
// Download service creates Download objects
class MessageUpload {
    
    var message: Message
    init(message: Message) {
        self.message = message
    }
    
    // Download service sets these values:
    var isUploading = true
    var resumeData: Data?
    // Download delegate sets this value:
    var progress: Float = 0
    
    var updateProgressBlock:((Message,Int64,Int64)->Void)?
    var uploadCompletionBlock:((Message,String?,Error?)->Void)?

    func upload() {
        let fileManager = FileManager.default
        
        if let localPath = message.localFilePath(),fileManager.fileExists(atPath: localPath.path) {
            let filename = localPath.deletingPathExtension().lastPathComponent
            do {
                let data = try Data(contentsOf: localPath)
                
                let group = DispatchGroup()
                
                var finalFilePath:String?
                var eror:Error?
                
                group.enter()
                Helpers.uploadFileForMsgToS3(data: data, fileName: filename, msgType: message.msgType, prgressBlock: { (_, totalByteSent, totalBytes) in
                    self.isUploading = false
                    self.updateProgressBlock?(self.message,totalByteSent,totalBytes)
                }) { (filePath, error) in
                    finalFilePath = filePath
                    eror = error
                    group.leave()
                }
                
                if message.msgType == ChatType.video.rawValue {

                    var thumnURL = localPath.deletingPathExtension().path
                    thumnURL.append("_thumb.png")
                    let thumPathLocal = URL(fileURLWithPath: thumnURL)
                    if fileManager.fileExists(atPath: thumPathLocal.path) {
                        let dataThumb = try Data(contentsOf: thumPathLocal)
                        group.enter()
                        Helpers.uploadFileForMsgToS3(data: dataThumb, fileName: "\(filename)_thumb", msgType: ChatType.image.rawValue, prgressBlock: { (_, totalByteSent, totalBytes) in
                            // do nothing
                            
                        }) { (filePath, error) in
                            group.leave()
                        }
                    }
                    
                }
                group.notify(queue: .main) {
                    self.isUploading = false
                    self.uploadCompletionBlock?(self.message,finalFilePath,eror)
                }
            } catch {
                print("got error")
                print(error)
            }
        }
    }
}
