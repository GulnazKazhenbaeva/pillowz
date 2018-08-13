////
////  PrivacyViewController.swift
////  Pillowz
////
////  Created by Dias Ermekbaev on 08.12.17.
////  Copyright © 2017 Samat. All rights reserved.
////
//
//import UIKit
//
//class WebViewPageViewController: UIViewController {
//    
//    let privacyWebView: UIWebView = {
//        let wv = UIWebView()
//        wv.scalesPageToFit = false
//        return wv
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let newBackButton = UIBarButtonItem(image: UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
//        navigationItem.title = "Политика конфиденциальности"
//        navigationItem.hidesBackButton = true
//        navigationItem.leftBarButtonItem = newBackButton
//        view.addSubview(privacyWebView)
//        privacyWebView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        
//        privacyWebView.loadRequest(NSURLRequest(URL: NSURL(string: "google.com")!))
//    }
//    
//    @objc func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//
//
//}
