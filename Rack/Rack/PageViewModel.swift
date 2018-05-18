

import UIKit
import Foundation

class PageViewModel: NSObject {
  
  private var timer: Timer? = nil
  private var interval: Double = 1.3
  var enableAutoScroll: Bool = false {
    didSet {
      self.toggleTimer()
    }
  }
  var viewControllers: [UIViewController]
  var currentIndex: Int = 0
  var direction: UIPageViewControllerNavigationDirection = .forward
  
  init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    super.init()
  }
  
  override convenience init() {
    self.init(viewControllers: [])
  }
  
  private func stopTimer() {
    if let _ = self.timer {
      timer?.invalidate()
      timer = nil
      return
    }
  }
  
  private func startTimer() {
    
    if let _ = self.timer {
      return
    }
    
    if #available(iOS 10.0, *) {
      timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer: Timer) in
        self.timerFire()
      })
    } else {
      // Fallback on earlier versions
      timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(PageViewModel.timerFire), userInfo: nil, repeats: true)
    }
  }
  
  @objc private func timerFire() {
    
    if direction == .forward {
      
      var index = currentIndex
      if index < self.viewControllers.count - 1 {
        index += 1
      }else {
        index = 0
      }
      
      currentIndex = index
      scrollToNextPage?(currentIndex)
      pageNumberChangedObserver?(currentIndex)

    }else {
      
      var index = currentIndex
      if index <= 0 {
        index = (self.viewControllers.count - 1)
      }else {
        index -= 1
      }
      
      currentIndex = index
      scrollToNextPage?(index)
      pageNumberChangedObserver?(currentIndex)

    }
    
  }
  
  
  // MARK: - Timer
  func toggleTimer() {
    if enableAutoScroll == true {
      startTimer()
    }else {
      stopTimer()
    }
  }
  
  fileprivate var scrollToNextPage: ((_ index: Int) -> Void)?
  func scrollToNextPage(callBack: @escaping (_ index: Int) -> Void) {
    scrollToNextPage = callBack
  }
  
  // MARK: - PageNumberChangedObserver
  fileprivate var pageNumberChangedObserver: ((_ index: Int) -> Void)?
  func pageNumberChanged(callBack: @escaping (_ index: Int) -> Void) {
    pageNumberChangedObserver = callBack
  }
  
}

// MARK: - UIPageViewControllerDataSource
extension PageViewModel: UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = viewControllers.index(of: viewController) else {
      return nil
    }
    let previousIndex = viewControllerIndex - 1
    
    // User is on the first view controller and swiped left to loop to
    // the last view controller.
    guard previousIndex >= 0 else {
      //return orderedViewControllers.last
      // Uncommment the line below, remove the line above if you don't want the page control to loop.
      return nil
    }
    
    guard viewControllers.count > previousIndex else {
      return nil
    }
    
    return viewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = viewControllers.index(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = viewControllers.count
    
    // User is on the last view controller and swiped right to loop to
    // the first view controller.
    guard orderedViewControllersCount != nextIndex else {
      //return orderedViewControllers.first
      // Uncommment the line below, remove the line above if you don't want the page control to loop.
      return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return viewControllers[nextIndex]
  }
  
}

// MARK: - UIPageViewControllerDelegate
extension PageViewModel: UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    
    if let pageContentViewController = pageViewController.viewControllers?[0] {
      
      if let index = viewControllers.index(of: pageContentViewController) {
        currentIndex = index
        pageNumberChangedObserver?(currentIndex)
      }
      
    }
    
  }
  
}
