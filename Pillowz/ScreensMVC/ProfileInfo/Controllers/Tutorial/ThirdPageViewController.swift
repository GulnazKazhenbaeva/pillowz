////
////  ThirdPageViewController.swift
////  Pillowz
////
////  Created by Dias Ermekbaev on 09.12.17.
////  Copyright © 2017 Samat. All rights reserved.
////
//
//import UIKit
//
//class ThirdPageViewController: UIViewController {
//
//    let tutorialView = TutorialView()
//
//    override func loadView() {
//        super.loadView()
//        UIApplication.shared.statusBarView?.backgroundColor = DesignHelpers.currentMainColor()
//        view.backgroundColor = .white
//        view.addSubview(tutorialView)
//        tutorialView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//
//        tutorialView.imageView.image = UIImage.init(named: "Intro3")
//        tutorialView.titleLabel.text = "Есть недвижимость?\nЗарабатывай вместе с нами!"
//        tutorialView.titleLabel.numberOfLines = 2
//        tutorialView.subTitleLabel.text = "Активируй «Режим риелтора», выбирай\nзаявки и зарабатывай!"
//        tutorialView.subTitleLabel.numberOfLines = 2
//        tutorialView.stepImageView.image = UIImage.init(named: "Step3")
//        let skipTutorialGesture = UITapGestureRecognizer(target: self, action: #selector(skipTutorial))
//        tutorialView.skipLabel.addGestureRecognizer(skipTutorialGesture)
//        tutorialView.nextButton.addTarget(self, action: #selector(skipTutorial), for: .touchUpInside)
//    }
//
//    @objc func skipTutorial() {
//        //skipTutorial
//        UserDefaults.standard.set(true, forKey: "tutorialLooked")
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let tabBarController = appDelegate.tabbarController
//        present(tabBarController!, animated: false, completion: nil)
//    }
//}
