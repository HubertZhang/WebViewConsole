//
//  ConsoleViewController.swift
//  WebViewConsoleView
//
//  Created by Hubert Zhang on 2019/10/17.
//

import UIKit

let viewControllerBundle = Bundle(url: Bundle(for: ConsoleViewController.self).url(forResource: "ConsoleView", withExtension: "bundle")!)!

public class ConsoleViewController: UIViewController {
    @IBOutlet weak var messageTableView: UITableView!

    convenience init() {
        self.init(nibName: "ConsoleViewController", bundle: viewControllerBundle)
    }

    var consoleObserver: Any?
    public var console: Console! {
        didSet {
            console.set(delegate: self)
        }
    }
    var consoleInputViewController: ConsoleInputViewController!

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        messageTableView.register(UINib(nibName: "ConsoleMessageCell", bundle: viewControllerBundle), forCellReuseIdentifier: "consoleMessage")
        messageTableView.allowsSelection = false
        messageTableView.estimatedRowHeight = 52.0
        messageTableView.rowHeight = UITableView.automaticDimension

        constructInputView()
    }

    deinit {
        if self.consoleObserver != nil {
            self.consoleObserver = nil
        }
    }

    func setupNavigationBar() {
        self.title = "Debug Console"
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearClicked))
        }

    }

    @objc public func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    func constructInputView() {
        let consoleInputViewController = ConsoleInputViewController(nibName: "ConsoleInputViewController", bundle: viewControllerBundle)
        consoleInputViewController.console = self.console
        consoleInputViewController.uiDelegate = self
        self.consoleInputViewController = consoleInputViewController
        self.addChild(consoleInputViewController)
        consoleInputViewController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(consoleInputViewController.view)
        NSLayoutConstraint.activate([
            consoleInputViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            consoleInputViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            consoleInputViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.view.bringSubviewToFront(consoleInputViewController.view)
        consoleInputViewController.didMove(toParent: self)
    }

    @objc public func clearClicked(_ sender: Any) {
        self.console.clearMessages()
    }
}

extension ConsoleViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return console.count()
    }

    // Provide a cell object for each row.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "consoleMessage", for: indexPath) as? ConsoleMessageCell else {
            return UITableViewCell()
        }

        let message = self.console.messages(at: indexPath.row)
        cell.message.text = message.getMessage()
        cell.location.text = message.getLocation()

        cell.setStyle(message: message)

       return cell
    }
}

extension ConsoleViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return false
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let message = self.console.messages(at: indexPath.row)
            UIPasteboard.general.string = message.getMessage()
        }
    }
}

extension ConsoleViewController: ConsoleInputUIDelegate {
    func viewHeightDidChange(_ height: CGFloat) {
        if #available(iOS 11.0, *) {
            self.messageTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height-self.view.safeAreaInsets.bottom, right: 0)
        } else {
            // Fallback on earlier versions
        }
    }
}

extension ConsoleViewController: WebViewConsoleDataDelegate {
    public func messagesUpdated() {
        let shouldScroll = self.messageTableView.isBottomVisible()
        self.messageTableView.reloadData()
        if shouldScroll && self.console.count() > 0 {
            self.messageTableView.scrollToRow(at: IndexPath(row: self.console.count()-1, section: 0), at: .bottom, animated: true)
        }
    }

    public func messageArrived() {

    }
}

extension ConsoleMessageCell {
    func setStyle(message: ConsoleMessageProtocol) {
        let source = message.getSource()
        let level = message.getLevel()

        if #available(iOS 13.0, *) {
            self.message.textColor = UIColor.label
            self.contentView.backgroundColor = UIColor.systemBackground
        } else {
            self.message.textColor = UIColor.black
            self.contentView.backgroundColor = UIColor.white
        }
        if source == .js {
            let level = message.getLevel()
            self.levelImage.image = level.image()?.withRenderingMode(.alwaysTemplate)
            self.levelImage.tintColor = level.labelColor()
            self.message.textColor = level.labelColor()
            self.contentView.backgroundColor = level.backgroundColor()
        } else if source == .navigation {
            self.levelImage.image = source.image()?.withRenderingMode(.alwaysTemplate)
            if level == .warning {
                self.levelImage.tintColor = level.labelColor()
            } else {
                self.levelImage.tintColor = source.labelColor()
            }
        } else {
            self.levelImage.image = source.image()?.withRenderingMode(.alwaysTemplate)
            self.levelImage.tintColor = source.labelColor()
            self.message.textColor = source.labelColor()
        }
    }

}
