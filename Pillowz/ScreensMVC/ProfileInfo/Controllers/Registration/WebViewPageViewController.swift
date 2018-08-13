//
//  PrivacyViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 08.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class WebViewPageViewController: PillowzViewController {
    let privacyWebView: UIWebView = {
        let wv = UIWebView()
        wv.scalesPageToFit = false
        return wv
    }()
    
    var link:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(privacyWebView)
        privacyWebView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        privacyWebView.loadRequest(URLRequest(url: URL(string: link)!))
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }


}
