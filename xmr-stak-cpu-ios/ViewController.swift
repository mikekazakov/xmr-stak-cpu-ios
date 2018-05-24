//
//  ViewController.swift
//  xmr-stak-cpu-ios
//
//  Created by Michael G. Kazakov on 10/22/17.
//  Copyright © 2017 Michael G. Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let textFont = UIFont(name: "Menlo-Regular", size: 13)!
    
    let pipe = Pipe()
    var fileHandle: FileHandle!
    var source: DispatchSourceRead!

    var backgroundTask = BackgroundTask()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupStdout()
      
        backgroundTask.startBackgroundTask()
        
        let config_path = Bundle.main.path(forResource: "config", ofType: "txt")
        let pools_path = Bundle.main.path(forResource: "pools", ofType: "txt")
        let cpu_path = Bundle.main.path(forResource: "cpu", ofType: "txt")
        run_main_miner( config_path, pools_path, cpu_path )
    }

    func setupStdout() {
        fileHandle = pipe.fileHandleForReading
        fflush(stdout)
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))
        setvbuf(stdout, nil, _IONBF, 0)
        source = DispatchSource.makeReadSource(fileDescriptor: fileHandle.fileDescriptor,
                                               queue: DispatchQueue.global())
        source.setEventHandler {
            self.readStdout()
        };
        source.resume()
    }

    func readStdout() {
        let buffer = malloc(4096)!
        let read_ret = read(fileHandle.fileDescriptor, buffer, 4096)
        if read_ret > 0 {
            let data = UnsafeBufferPointer(start: buffer.assumingMemoryBound(to: UInt8.self),
                                           count: read_ret)
            if let str = String(bytes: data, encoding: String.Encoding.utf8) {
                DispatchQueue.main.async {
                    self.acceptLog(str: str)
                }
            }
        }
        free(buffer)
    }

    func acceptLog(str: String) {
        let attr_str = NSAttributedString(string: str,
                                          attributes:[NSAttributedStringKey.font: self.textFont])
        self.textView.textStorage.append(attr_str);
    }

    @IBAction func onShowHashrate(_ sender: Any) {
        invoke_print_hash()
    }
    
    @IBAction func onShowResults(_ sender: Any) {
        invoke_print_results()
    }
    
    @IBAction func onShowConnection(_ sender: Any) {
        invoke_print_connection()
    }

    @IBOutlet var textView: UITextView!
}

