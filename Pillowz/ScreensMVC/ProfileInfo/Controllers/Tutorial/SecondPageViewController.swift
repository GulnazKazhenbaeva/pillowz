////
////  SecondPageViewController.swift
////  Pillowz
////
////  Created by Dias Ermekbaev on 09.12.17.
////  Copyright © 2017 Samat. All rights reserved.
////
//
//import UIKit
//
//class SecondPageViewController: UIViewController {
//    let tutorialView = TutorialView()
//
//    override func loadView() {
//        super.loadView()
//        view.backgroundColor = .white
//        view.addSubview(tutorialView)
//        tutorialView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        
//        tutorialView.imageView.image = UIImage.init(named: "Intro2")
//        tutorialView.titleLabel.text = "Ответ на Ваши заявки\nот 5 минут"
//        tutorialView.titleLabel.numberOfLines = 2
//        tutorialView.subTitleLabel.text = "Заявка отправляется всем\nзарегистрированным риелторам."
//        tutorialView.subTitleLabel.numberOfLines = 2
//        tutorialView.stepImageView.image = UIImage.init(named: "Step2")
//        let skipTutorialGesture = UITapGestureRecognizer(target: self, action: #selector(skipTutorial))
//        tutorialView.skipLabel.addGestureRecognizer(skipTutorialGesture)
//        tutorialView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
//    }
//    
//    @objc func skipTutorial() {
//        //skipTutorial
//        UserDefaults.standard.set(true, forKey: "tutorialLooked")
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let tabBarController = appDelegate.tabbarController
//        present(tabBarController!, animated: false, completion: nil)
//    }
//    
//    @objc func nextButtonTapped() {
//        let dvc = ThirdPageViewController()
//        present(dvc, animated: false, completion: nil)
//    }
//
//}
