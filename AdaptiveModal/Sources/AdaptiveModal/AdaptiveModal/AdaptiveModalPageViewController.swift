//
//  AdaptiveModalPaginatedViewController.swift
//  
//
//  Created by Dominic Go on 9/1/23.
//

import UIKit


public class AdaptiveModalPageViewController: UIViewController {

  public weak var modalManager: AdaptiveModalManager?;
  
  public var pages: [AdaptiveModalPageItemConfig] {
    didSet {
      let newValue = self.pages;
      
      let didValueChange: Bool = {
        if oldValue.count != newValue.count {
          return true;
        };
        
        return newValue.enumerated().contains {
          let newPage = $0.element;
          let oldPage = oldValue[$0.offset];
          
          return newPage != oldPage;
        };
      }();
      
      if didValueChange {
        self.notifyOnPagesDidChange();
      };
    }
  };
  
  public var resolvedPages: [AdaptiveModalResolvedPageItemConfig]?;
  
  public var pageChangeEventDelegate =
    MulticastDelegate<AdaptiveModalPageChangeEventsNotifiable>();
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var pageViewControllers: [UIViewController] {
    self.pages.map {
      $0.viewController;
    };
  };
  
  public var isAnyPageAttached: Bool {
    self.pages.contains {
      $0.viewController.parent === self;
    };
  };
  
  // MARK: - Init
  // ------------
  
  public init(pages: [AdaptiveModalPageItemConfig]){
    self.pages = pages;
    super.init(nibName: nil, bundle: nil);
  };
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  };
  
  // MARK: - Functions
  // -----------------
  
  func setup(modalManager: AdaptiveModalManager){
    self.modalManager = modalManager;
  
    modalManager.presentationEventsDelegate.add(self);
    modalManager.animationEventDelegate.add(self);
  };
  
  func resolvePages(interpolationPoints: [AdaptiveModalInterpolationPoint]){
    let pagesResolved = self.pages.compactMap {
      AdaptiveModalResolvedPageItemConfig(
        pageConfig: $0,
        interpolationPoints: interpolationPoints
      );
    };
    
    let pagesPartial = interpolationPoints.map { interpolationPoint in (
      offset: interpolationPoint.snapPointIndex,
      element: pagesResolved.first {
        $0.contains(index: interpolationPoint.snapPointIndex);
      }
    )};
    
    func getNextPage(startIndex: Int) -> AdaptiveModalResolvedPageItemConfig? {
      let match = pagesPartial.seekForwardAndBackwards(
        startIndex: startIndex,
        where: { item, isReversing in
        
          guard item.element != nil else { return false };
          
          if isReversing {
            return true;
          };
          
          return item.offset > startIndex;
        }
      );
     
      guard let match = match else { return nil };
      return match.element;
    };
    
    let pages = interpolationPoints.compactMap {
      if let page = pagesPartial[safeIndex: $0.snapPointIndex]?.element {
        return page;
      };
      
      return getNextPage(startIndex: $0.snapPointIndex);
    };
    
    guard pages.count == interpolationPoints.count else { return };
    self.resolvedPages = pages;
  };
  
  func notifyOnPagesDidChange(){
    self.refreshPages();
  };
  
  // MARK: - Public Functions
  // ------------------------
  
  public func resolvePages(){
    guard let modalManager = self.modalManager else { return };
    self.resolvePages(interpolationPoints: modalManager.interpolationSteps);
  };
  
  public func refreshPages(){
    self.resolvePages();
    
    let nextVC = self.pageViewControllers;
    let prevVC = self.children;
    
    let didPageControllersChange = !nextVC.elementsEqual(prevVC) { $0 !== $1 };
    guard didPageControllersChange else { return };
    
    self.detachPages();
    self.attachPages();
  };
  
  public func attachPages(){
    guard let modalManager = self.modalManager,
          let resolvedPages = self.resolvedPages
    else { return };

    resolvedPages.enumerated().forEach {
      guard let childVC = $0.element.viewController,
            childVC.parent !== self
      else { return };
      
      self.view.addSubview(childVC.view);
      self.addChild(childVC);
      childVC.didMove(toParent: self);
      
      childVC.view.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        childVC.view.topAnchor.constraint(
          equalTo: self.view.topAnchor
        ),
        childVC.view.bottomAnchor.constraint(
          equalTo: self.view.bottomAnchor
        ),
        childVC.view.leadingAnchor.constraint(
          equalTo: self.view.leadingAnchor
        ),
        childVC.view.trailingAnchor.constraint(
          equalTo: self.view.trailingAnchor
        ),
      ]);
      
      if $0.offset == modalManager.currentSnapPointIndex {
        childVC.view.alpha = 1;
        
      } else {
        childVC.view.alpha = 0;
      };
    };
  };
  
  public func detachPages(){
    self.children.forEach {
      $0.willMove(toParent: nil);
      $0.removeFromParent();
      $0.view.removeFromSuperview();
    };
  };
};

extension AdaptiveModalPageViewController: AdaptiveModalPresentationEventsNotifiable {

  public func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    prevSnapPointConfig: AdaptiveModalSnapPointConfig?,
    nextSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    nextInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
  
    guard let resolvedPages = self.resolvedPages,
          let nextPage = resolvedPages[safeIndex: nextSnapPointIndex]
    else { return };
    
    let prevPage: AdaptiveModalResolvedPageItemConfig? = {
      guard let prevSnapPointIndex = prevSnapPointIndex else { return nil };
      return resolvedPages[safeIndex: prevSnapPointIndex]
    }();
  
    self.pageChangeEventDelegate.invoke {
      $0.notifyOnModalPageWillChange(
        sender: self,
        prevPage: prevPage,
        nextPage: nextPage
      );
    };
  };
  
  public func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    prevSnapPointConfig: AdaptiveModalSnapPointConfig?,
    currentSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    currentInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    
    guard let resolvedPages = self.resolvedPages,
          let currentPage = resolvedPages[safeIndex: currentSnapPointIndex]
    else { return };
    
    let prevPage: AdaptiveModalResolvedPageItemConfig? = {
      guard let prevSnapPointIndex = prevSnapPointIndex else { return nil };
      return resolvedPages[safeIndex: prevSnapPointIndex]
    }();
    
    self.pageChangeEventDelegate.invoke {
      $0.notifyOnModalPageDidChange(
        sender: self,
        prevPage: prevPage,
        currentPage: currentPage
      );
    };
  };
  
  public func notifyOnAdaptiveModalWillShow(sender: AdaptiveModalManager) {
    self.resolvePages(interpolationPoints: sender.interpolationSteps);
    self.attachPages();
  };
  
  public func notifyOnAdaptiveModalDidShow(sender: AdaptiveModalManager) {
    // no-op
  };
  
  public func notifyOnAdaptiveModalWillHide(sender: AdaptiveModalManager) {
    // no-op
  };
  
  public func notifyOnAdaptiveModalDidHide(sender: AdaptiveModalManager) {
    // no-op
  };
  
  public func notifyOnModalPresentCancelled(sender: AdaptiveModalManager) {
    // no-op
  };
  
  public func notifyOnModalDismissCancelled(sender: AdaptiveModalManager) {
    // no-op
  };
  
  public func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  ) {
    self.refreshPages();
  };
};

extension AdaptiveModalPageViewController: AdaptiveModalAnimationEventsNotifiable {

  public func notifyOnModalAnimatorStart(
    sender: AdaptiveModalManager,
    animator: UIViewPropertyAnimator?,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool
  ) {
  
    let nextSnapPointIndex = interpolationPoint.snapPointIndex;
    
    guard let resolvedPages = self.resolvedPages,
          let nextPage = resolvedPages[safeIndex: nextSnapPointIndex]
    else { return };
    
    let animationBlock = {
      resolvedPages.enumerated().forEach {
        guard let pageVC = $0.element.viewController else { return };
        let shouldShowPage = pageVC ===  nextPage.viewController;
        pageVC.view.alpha = shouldShowPage ? 1 : 0;
      };
    };
    
    if isAnimated,
       let animator = animator {
      
      animator.addAnimations(animationBlock);
      
    } else {
      animationBlock();
    };
  };
  
  public func notifyOnModalAnimatorPercentChanged(
    sender: AdaptiveModalManager,
    percent: CGFloat
  ) {
  
    guard let resolvedPages = self.resolvedPages,
          let interpolationSteps = sender.interpolationSteps
    else { return };
    
    let rangeInput = interpolationSteps.map { $0.percent };
    
    resolvedPages.enumerated().forEach {
      guard let pageVC = $0.element.viewController else { return };

      let outputRangeOpacity = resolvedPages.map {
        let shouldShowPage = pageVC === $0.viewController;
        return CGFloat(shouldShowPage ? 1 : 0);
      };
      
      let opacityNext = AdaptiveModalUtilities.interpolate(
        inputValue: percent,
        rangeInput: rangeInput,
        rangeOutput: outputRangeOpacity
      );
      
      let prevOpacity = pageVC.view.alpha;
      
      guard let opacityNext = opacityNext,
            prevOpacity != opacityNext
      else { return };
      
      pageVC.view.alpha = opacityNext;
    };
  };
  
  public func notifyOnModalAnimatorStop(
    sender: AdaptiveModalManager
  ) {
    // no-op
  };
  
  public func notifyOnModalAnimatorCompletion(
    sender: AdaptiveModalManager,
    position: UIViewAnimatingPosition
  ) {
    // no-op
  };
};

