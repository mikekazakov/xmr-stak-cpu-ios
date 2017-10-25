//
//  ViewController.swift
//  xmr-stak-cpu-ios
//
//  Created by Michael G. Kazakov on 10/22/17.
//  Copyright © 2017 Michael G. Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let textFont = UIFont(name: "Menlo-Regular", size: 15)!
    
    let pipe = Pipe()
    var fileHandle: FileHandle?
    var source: DispatchSourceRead?

    var backgroundTask = BackgroundTask()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupStdout()
      
        backgroundTask.startBackgroundTask()
        
        let config_path = Bundle.main.path(forResource: "config", ofType: "txt");
        run_main_miner( config_path )
    }

    func setupStdout () {
        fileHandle = pipe.fileHandleForReading;
        fflush(stdout);
        if dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout)) == -1 {
            abort();
        }
        setvbuf(stdout, nil, _IONBF, 0);
        
        source = DispatchSource.makeReadSource(fileDescriptor: fileHandle!.fileDescriptor,
                                               queue: DispatchQueue.global());
        source?.setEventHandler(handler: {
            self.readStdout();
        });
        source?.resume();
    }

    func readStdout() {
        let data = malloc(4096);
        var read_ret: Int = 0
        
        repeat {
            errno = 0;
            read_ret = read(self.fileHandle!.fileDescriptor, data, 4096)
        } while( read_ret == -1 && errno == EINTR )
        
        if read_ret > 0 {
            let d = UnsafeBufferPointer(start: data?.assumingMemoryBound(to: UInt8.self),
                                        count: read_ret)
            if let s = String(bytes: d, encoding: String.Encoding.utf8) {
                DispatchQueue.main.async {
                    self.acceptLog(str: s);
                };
            }
        }
        free(data);
    }

    func acceptLog(str: String) {
        let attr_str = NSAttributedString(string: str,
                                          attributes:[NSAttributedStringKey.font: self.textFont])
        self.textView.textStorage.append(attr_str);
    }

    @IBAction func onShowHashrate(_ sender: Any) {
        invoke_print_hash()
    }
    @IBOutlet var textView: UITextView!
    
}

