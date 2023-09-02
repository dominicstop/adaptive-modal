//
//  AdaptiveModalPaginatedViewController.swift
//  
//
//  Created by Dominic Go on 9/1/23.
//

import UIKit


public class AdaptiveModalPageViewController: UIViewController {

  weak var modalManager: AdaptiveModalManager?;
  
  var pages: [AdaptiveModalPageItemConfig];
  var resolvedPages: [AdaptiveModalResolvedPageItemConfig]?;
  
  var viewControllers: [UIViewController] {
    self.pages.map {
      $0.viewController;
    };
  };
  
  public init(pages: [AdaptiveModalPageItemConfig]){
    self.pages = pages;
    super.init(nibName: nil, bundle: nil);
  };
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  };
  
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
  
  func setupAttachPages(){
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
};

extension AdaptiveModalPageViewController: AdaptiveModalPresentationEventsNotifiable {

  public func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    // no-op
  };
  
  public func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    // no-op
  };
  
  public func notifyOnAdaptiveModalWillShow(sender: AdaptiveModalManager) {
    self.resolvePages(interpolationPoints: sender.interpolationSteps);
    self.setupAttachPages();
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
    // no-op
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

