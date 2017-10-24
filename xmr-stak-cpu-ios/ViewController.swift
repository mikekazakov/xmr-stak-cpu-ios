//
//  ViewController.swift
//  xmr-stak-cpu-ios
//
//  Created by Michael G. Kazakov on 10/22/17.
//  Copyright © 2017 Michael G. Kazakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var pipe: Pipe?
    var fileHandle: FileHandle?
    var source: DispatchSourceRead?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pipe = Pipe();
        fileHandle = pipe!.fileHandleForReading;
        fflush(stdout);
        if dup2(pipe!.fileHandleForWriting.fileDescriptor, fileno(stdout)) == -1 {
            abort();
        }
        setvbuf(stdout, nil, _IONBF, 0);
        
        source = DispatchSource.makeReadSource(fileDescriptor: fileHandle!.fileDescriptor,
                                               queue: DispatchQueue.global());
        source?.setEventHandler(handler: {
            let data = malloc(4096);
            var read_ret: Int = 0

            repeat {
                errno = 0;
                read_ret = read(self.fileHandle!.fileDescriptor, data, 4096)
            } while( read_ret == -1 && errno == EINTR )
            
            if read_ret > 0 {
                let d = UnsafeBufferPointer(start: data?.assumingMemoryBound(to: UInt8.self),
                                            count: read_ret)
                let s = String(bytes: d, encoding: String.Encoding.utf8)
                
                DispatchQueue.main.async {
                    self.acceptLog(str: s!);
                };
            }
            free(data);
        });
        source?.resume();
    }

    func acceptLog(str: String) {
        let attr_str = NSAttributedString(string: str)
        self.textView.textStorage.append(attr_str);


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onShowHashrate(_ sender: Any) {
        invoke_print_hash()
    }
    @IBOutlet var textView: UITextView!
    
}

