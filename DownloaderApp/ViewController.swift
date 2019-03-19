//
//  ViewController.swift
//  DownloaderApp
//
//  Created by Mohammed Altoobi on 3/19/19.
//  Copyright © 2019 Mohammed Altoobi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    
    var defaultSession: URLSession!
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    @IBOutlet weak var progress: UIProgressView!
    
    let VIDEO_URL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
    var videoPath = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDownloader()
    }
    
    func setupDownloader(){
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        defaultSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progress.setProgress(0.0, animated: false)
        
    }
    
    func startDownloading(FileURL: String) {
        
        let url = URL(string: FileURL)!
        downloadTask = defaultSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    @IBAction func downloadAction(_ sender: UIButton) {
        
        /*
         Checking if file is existing in File Manager, so it will not download it againg and just play it
         */
        
        if isExistingFile(fileName: "video-1.mp4") == true {
            
            print("File already exists..")
            
            let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
            let vc = AVPlayerViewController()
            vc.player = player
            
            self.present(vc, animated: true){ vc.player?.play()}
            
        }else{
            
            print("File is not exists..")
            showAlertWithMessage(message: "Downloading..")
            startDownloading(FileURL: VIDEO_URL)
        }
        
    }
    
    func isExistingFile(fileName: String) -> Bool {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent("/\(fileName)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            
            videoPath = filePath
            
            if fileManager.fileExists(atPath: filePath)
            {
                return true
            } else {
                return false
            }
            
        } else {
            return false
            
        }
    }
    
    func showFileWithPath(path: String){
        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
        if isFileFound == true{
            
            //Displaying PDF file
            /*
            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreview(animated: true)
            */

            
            //Displaying AVPlayerViewController after downloading Video
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            let vc = AVPlayerViewController()
            vc.player = player
            
            self.present(vc, animated: true) {
                vc.player?.play()
            }
        }
        
    }
    
    
    //Show Alert Message
    func showAlertWithMessage(message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        present(alert, animated: true) {
            sleep(3)
            alert.dismiss(animated: true)
        }
    }
    
}

extension ViewController : URLSessionDownloadDelegate {
    
    // MARK:- URLSessionDownloadDelegate
    
    //Saving file to file manager and getting file path
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print(downloadTask)
        print("File downloaded succesfully")
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/"+"video-1.mp4"))
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            showFileWithPath(path: destinationURLForFile.path)
            print(destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
                showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
        
    }
    
    //Set progress bar
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progress.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        downloadTask = nil
        progress.setProgress(0.0, animated: true)
        if (error != nil) {
            print("didCompleteWithError \(error?.localizedDescription ?? "no value")")
        }
        else {
            print("The task finished successfully")
        }
    }
}

extension ViewController : UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
    
}

