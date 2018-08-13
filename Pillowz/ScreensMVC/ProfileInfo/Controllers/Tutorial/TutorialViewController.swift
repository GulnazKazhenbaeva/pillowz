//
//  TutorialViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 11.12.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {

    let skipButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 16)!
        button.setTitleColor(UIColor.black.withAlphaComponent(0.87), for: .normal)
        button.setTitle("Пропустить", for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    let scrollView = UIScrollView()
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var pageControl : UIPageControl = UIPageControl()
    let nextButton = PillowzButton()

    var tutorialViews: [TutorialView] = []
    
    override func loadView() {
        super.loadView()
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.scrollView.isPagingEnabled = true
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 3, height: self.scrollView.frame.size.height)
    
        let pageControlBottomSpace = view.frame.height * 0.2555 - 109
        
        view.addSubview(skipButton)
        skipButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-30)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.032)
        }
        
        view.addSubview(pageControl)
        configurePageControl()
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(view.frame.height * 0.0625 + 25 + pageControlBottomSpace/2))
            make.height.equalTo(5)
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        for index in 0..<3 {
            tutorialViews.append(TutorialView())
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            tutorialViews[index].frame = frame
            tutorialViews[index].backgroundColor = .white
            
            self.scrollView.addSubview(tutorialViews[index])
        }
        setupAnimations()
        
        view.addSubview(nextButton)
        nextButton.setTitle("Далее", for: .normal)
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalToSuperview().multipliedBy(0.0625)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.centerX.equalToSuperview()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        nextButton.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTutorial), for: .touchUpInside)
        setupInfo(pageNumber: 0)
    }
    func configurePageControl() {
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = .white
        self.pageControl.pageIndicatorTintColor = .lightGray
        self.pageControl.currentPageIndicatorTintColor = Constants.paletteVioletColor
    }
    
    @objc func skipTutorial() {
        UserDefaults.standard.set(true, forKey: "tutorialLooked")
        
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        
        let tabbarNavigationController = UINavigationController(rootViewController: appDelegate.tabbarController)
        tabbarNavigationController.setNavigationBarHidden(true, animated: false)

        UIApplication.shared.keyWindow?.rootViewController = tabbarNavigationController
    }
    
    @objc func changePage() {
        if pageControl.currentPage != 2 {
            pageControl.currentPage += 1
            setupInfo(pageNumber: pageControl.currentPage)
            let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
            scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
            setupAnimations()
        } else {
            skipTutorial()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        setupInfo(pageNumber: Int(pageNumber))
        setupAnimations()
    }
    func setupInfo(pageNumber: Int) {
        if Int(pageNumber) == 0 {
            tutorialViews[0].imageView.image = UIImage.init(named: "Intro1")
            tutorialViews[0].titleLabel.text = "Создайте заявку"
            tutorialViews[0].subTitleLabel.text = "В Pillowz размещено жилье от реальных владельцев. Найдите подходящее и отправьте персональную заявку, либо создайте общую заявку по нужным критериям."
        } else if Int(pageNumber) == 1 {
            tutorialViews[1].imageView.image = UIImage.init(named: "Intro2")
            tutorialViews[1].titleLabel.text = "Получите ответ"
            tutorialViews[1].subTitleLabel.text = "Владелец жилья получит уведомление о персональной заявке и свяжется с вами. Общая заявка видна всем владельцам, и они сами предложат свободное жилье."
        } else if Int(pageNumber) == 2 {
            tutorialViews[2].imageView.image = UIImage.init(named: "Intro3")
            tutorialViews[2].titleLabel.text = "Заключите сделку"
            tutorialViews[2].subTitleLabel.text = "Если вас не устраивает цена, предложите владельцу свою. Торговаться можно до 5 раз. Как только вы достигнете согласия, заключите сделку."
        }
    }
    func setupAnimations() {
//        let imageView = tutorialViews[pageControl.currentPage].imageView
//        let titleLabel = tutorialViews[pageControl.currentPage].titleLabel
//        let subtitleLabel = tutorialViews[pageControl.currentPage].subTitleLabel
//
//        imageView.animation = "pop"
//        imageView.curve = "spring"
//        imageView.duration = 4.0
//        imageView.force = 1.2
//        titleLabel.animation = "squeezeLeft"
//        titleLabel.curve = "spring"
//        titleLabel.duration = 1.5
//        subtitleLabel.animation = "squeezeRight"
//        subtitleLabel.curve = "spring"
//        subtitleLabel.duration = 1.5
//        imageView.animate()
//        titleLabel.animate()
//        subtitleLabel.animate()
    }
}

