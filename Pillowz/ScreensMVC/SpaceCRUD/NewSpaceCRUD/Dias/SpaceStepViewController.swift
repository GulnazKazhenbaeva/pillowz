//
//  SpaceStepViewController.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 04.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpaceStepViewController: PillowzViewController {
    var pageViewController: UIPageViewController!
    var numberOfPages = 4
    
    let bottomView = SpaceBottomView()
    let progressView = UIProgressView()
    
    var currentPage = 0 {
        didSet {
            currentVC = getItemController(itemIndex: currentPage) as! StepViewController
            
            setTitleAndProgressForCurrentPage()
        }
    }
    
    var currentVC:StepViewController! {
        didSet {
            SpacesManager.shared.currentStepVC = currentVC
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupPageControl()
        addPageVC()
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        progressView.setProgress(0.1, animated: true)
        progressView.tintColor = Colors.strongVioletColor
        
        bottomView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 13)!]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 18)!]
    }
}

extension SpaceStepViewController {
    func setupNavigationBar() {
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: "close"), for: .normal)
        rightButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        rightButton.frame = CGRect(x:0, y:0, width:35, height:44)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = Constants.paletteLightGrayColor
        appearance.currentPageIndicatorTintColor = UIColor(hexString: "#FA533C")
    }
    
    func addPageVC() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        addChildViewController(pageViewController)
        
        pageViewController.didMove(toParentViewController: self)
    }
}

extension SpaceStepViewController {
    func setTitleAndProgressForCurrentPage() {
        self.title = "Заголовок не указан"
    }
    
    func getItemController(itemIndex: Int) -> UIViewController? {
        
        return nil
    }
    
    func lastStepTapped() {}
    
    @objc func closeTapped() {
        SpaceEditorManager.sharedInstance.spaceCRUDVC = nil
        SpaceEditorManager.sharedInstance.currentStepVC = nil
        
        self.navigationController?.dismiss(animated: true, completion: nil)
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
}

extension SpaceStepViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
        
        currentPage = (pageViewController.viewControllers!.first! as! StepViewController).itemIndex
    }
}

