//
//  StepsViewController.swift
//  Pillowz
//
//  Created by Samat on 04.04.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class StepsViewController: PillowzViewController {
    var pageViewController: UIPageViewController!
    
    var numberOfPages = 4
    
    let nextButton = UIButton()
    let previousButton = UIButton()
    
    let bottomView = UIView()
    
    let progressView = UIProgressView()
    
    var currentPage = 0 {
        didSet {
            currentVC = getItemController(itemIndex: currentPage) as! StepViewController
            
            setTitleAndProgressForCurrentPage()
        }
    }
    
    var currentVC:StepViewController! {
        didSet {
            SpaceEditorManager.sharedInstance.currentStepVC = currentVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "close"), for: .normal)
        leftButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        leftButton.frame = CGRect(x:0, y:0, width:35, height:44)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        setupPageControl()
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addChildViewController(self.pageViewController)
        
        self.pageViewController.didMove(toParentViewController: self)
        
        
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        progressView.setProgress(0.1, animated: true)
        progressView.tintColor = Colors.strongVioletColor
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(59)
        }
        bottomView.backgroundColor = .white
        bottomView.dropShadow()
        
        bottomView.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-Constants.basicOffset)
            make.centerY.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(33)
        }
        nextButton.setTitle("продолжить", for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = Constants.paletteLightGrayColor //UIColor(hexString: "#FA533C")
        nextButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 13)
        nextButton.layer.cornerRadius = 5
        
        bottomView.addSubview(previousButton)
        previousButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(51)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        previousButton.setTitle("назад", for: .normal)
        previousButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        previousButton.setTitleColor(Constants.paletteLightGrayColor, for: .normal)
        previousButton.titleLabel?.font = UIFont.init(name: "OpenSans-Regular", size: 12)
        
        self.pageViewController.setViewControllers([self.getItemController(itemIndex: 0)!], direction: .forward, animated: true, completion: nil)
    }
    
    func setTitleAndProgressForCurrentPage() {
        self.title = "Заголовок не указан"
    }

    func getItemController(itemIndex: Int) -> UIViewController? {
        
        return nil
    }
    
    func lastStepTapped() {
        
    }
    
    @objc func closeTapped() {
        SpaceEditorManager.sharedInstance.spaceCRUDVC = nil
        SpaceEditorManager.sharedInstance.currentStepVC = nil
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 13)!]        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 18)!]
    }
    
    @objc func nextTapped() {
        if (!currentVC.checkIfAllFieldsAreFilled()) {
            return
        }
        
        if (currentVC.itemIndex == numberOfPages - 1) {
            lastStepTapped()
            return
        }
        
        if let vc = getItemController(itemIndex: currentPage + 1) {
            self.pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            
            currentPage = currentPage + 1
        }
    }
    
    @objc func prevTapped() {
        if let vc = getItemController(itemIndex: currentPage - 1) {
            self.pageViewController.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
            
            currentPage = currentPage - 1
        }
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = Constants.paletteLightGrayColor
        appearance.currentPageIndicatorTintColor = UIColor(hexString: "#FA533C")
    }
}

extension StepsViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil

        let itemController = viewController as! StepViewController
        
        if (!itemController.checkIfAllFieldsAreFilled()) {
            return nil
        }
        
        if itemController.itemIndex+1 < numberOfPages {
            return getItemController(itemIndex: itemController.itemIndex+1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil

        let itemController = viewController as! StepViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemIndex: itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            return
        }
        
        self.currentPage = (self.pageViewController.viewControllers!.first! as! StepViewController).itemIndex
    }
}

