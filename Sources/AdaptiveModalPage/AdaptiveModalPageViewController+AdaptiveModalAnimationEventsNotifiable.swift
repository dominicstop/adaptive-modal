//
//  AdaptiveModalPageViewController+AdaptiveModalAnimationEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 9/7/23.
//

import UIKit
import DGSwiftUtilities

extension AdaptiveModalPageViewController: AdaptiveModalAnimationEventsNotifiable {

  public func notifyOnModalAnimatorStart(
    sender: AdaptiveModalManager,
    animator: UIViewPropertyAnimator?,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool
  ) {
  
    let nextSnapPointIndex = interpolationPoint.snapPoint.index;
    
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
      
      let opacityNext = InterpolationHelpers.interpolate(
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

