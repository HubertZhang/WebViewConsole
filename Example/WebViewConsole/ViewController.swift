//
//  ViewController.swift
//  WebViewConsole
//
//  Created by Hubertzhang on 11/11/2019.
//  Copyright (c) 2019 Hubertzhang. All rights reserved.
//

import UIKit
import WebKit
import WebViewConsole
import WebViewConsoleView

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    let console = WebViewConsole()
    override func viewDidLoad() {
        super.viewDidLoad()

        console.setup(webView: webView)
        console.setupUserScript(to: webView)
        webView.load(URLRequest(url: URL(string: "https://bing.com")!))
    }

    @IBAction func displayConsoleView(_ sender: UIBarButtonItem) {
        let vc = ConsoleViewController(with: console, notificationName: WebViewConsoleMessageUpdated)
        let vc1 = UINavigationController.init(rootViewController: vc)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: vc, action: #selector(ConsoleViewController.dismissSelf))
        vc1.modalPresentationStyle = UIModalPresentationStyle.popover
        vc1.popoverPresentationController?.barButtonItem = sender
        self.present(vc1, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ConsoleViewController {
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
}
