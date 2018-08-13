//
//  InstagramWebViewController.swift
//  Authentification-Demo
//
//  Created by Mirzhan Gumarov on 11/15/17.
//  Copyright © 2017 Mirzhan Gumarov. All rights reserved.
//

import UIKit
import SnapKit

protocol InstagramWebViewDelegate {
    func didPickInstagramToken(_ token:String)
}

struct InstagramAPI {
    static let authorizationURL: String = "https://api.instagram.com/oauth/authorize/"
    static let clientId: String = "4e00d94d0acb40bbbc63dac736dbfdbc"
    static let clientSecret: String = "fcd3c3ed8a304d1aa6b574a3a82458c8"
    static let redirectURL: String = "http://pillowz.kz/"
    static let scope: String = "basic"
}

class InstagramWebViewController: PillowzViewController, UIWebViewDelegate {
    let webView = UIWebView()
    
    var delegate:InstagramWebViewDelegate?
    
    override func viewDidLoad() {
        title = "Instagram"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        
        webView.delegate = self
        
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [InstagramAPI.authorizationURL, InstagramAPI.clientId, InstagramAPI.redirectURL, InstagramAPI.scope])
        
        webView.loadRequest(URLRequest(url: URL(string: authURL)!))
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkResultForCallback(request)
    }
    
    func checkResultForCallback(_ request: URLRequest) -> Bool {
        let requestURL: String = (request.url?.absoluteString)! as String
        
        if requestURL.hasPrefix(InstagramAPI.redirectURL) {
            let range: Range<String.Index> = requestURL.range(of: "#access_token=")!
            self.handle(token: String(requestURL[range.upperBound...]))
            
            return false
        }
        return true
    }
    
    func handle(token: String){
        delegate?.didPickInstagramToken(token)
        
        dismissViewController()
    }
    
    @objc func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
}
