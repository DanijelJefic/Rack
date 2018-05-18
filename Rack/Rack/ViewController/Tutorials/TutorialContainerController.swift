

import UIKit

class TutorialContainerController: UIViewController {
  
  @IBOutlet weak var bottomBGView: UIView!
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var skipButton: UIButton!
  @IBOutlet weak var pageControl: UIPageControl!
  
  var pageViewController: UIPageViewController?
  var pageViewModel: PageViewModel?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var viewControllers: [UIViewController] = []
    
    let titles = [TutorialData(title: "Page: 1"),
                  TutorialData(title: "Page: 2"),
                  TutorialData(title: "Page: 3"),
                  TutorialData(title: "Page: 4")]
    
    for data in titles {
//      if let controller: TutorialPageContentController = R.storyboard.main.tutorialPageContentController() {
//        controller.data = data
//        viewControllers.append(controller)
//      }
    }
    
    pageViewModel = PageViewModel(viewControllers: viewControllers)
    pageViewModel?.enableAutoScroll = true
    pageViewModel?.pageNumberChanged(callBack: { (index: Int) in
      self.pageNumberChanged(index: index)
    })
    
    pageViewModel?.scrollToNextPage(callBack: { (index: Int) in
      self.setNextPage(index: index)
      
    })
    
    self.pageControl.currentPageIndicatorTintColor = UIColor.gray
    self.pageControl.numberOfPages = viewControllers.count
    //self.pageControl.pageIndicatorTintColor = AppColor.themeSecondaryColor
    self.setupPageViewController()
  }
  
  // MAKR: -
  func setNextPage(index: Int) {
    if let firstViewController = pageViewModel?.viewControllers[index] {
      pageViewController?.setViewControllers([firstViewController],
                                             direction: .forward,
                                             animated: true,
                                             completion: nil)
    }
  }
  
  // MAKR: -
  private func setupPageViewController() {
    
    let pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    pageViewController.dataSource = pageViewModel
    pageViewController.delegate = pageViewModel
    if let firstViewController = pageViewModel?.viewControllers.first {
      pageViewController.setViewControllers([firstViewController],
                                            direction: .forward,
                                            animated: true,
                                            completion: nil)
    }
    
    
    self.addChildViewController(pageViewController)
    self.containerView.addSubview(pageViewController.view)
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    var pageViewRect = self.containerView.bounds
    if UIDevice.current.userInterfaceIdiom == .pad {
      pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
    }
    pageViewController.view.frame = pageViewRect
    pageViewController.didMove(toParentViewController: self)
    self.pageViewController = pageViewController
    
  }
  
  func newVc(viewController: String) -> UIViewController {
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
  }
  
  
  func pageNumberChanged(index: Int) {
    
    self.pageControl.currentPage = index
    
    if let totalCount = self.pageViewModel?.viewControllers.count {
      if index == totalCount - 1 {
        self.skipButton.setTitle("Next", for: .normal)
      } else {
        self.skipButton.setTitle("Skip", for: .normal)
      }
    }
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    
    self.pageViewModel?.enableAutoScroll = false
//    if let rootViewControllerNav = R.storyboard.main.rootViewControllerNav() {
//     // appDelegate.window?.rootViewController = rootViewControllerNav
//    }
  }
  
}
