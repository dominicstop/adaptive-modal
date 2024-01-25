//
//  AdaptiveModalPageViewController+AdaptiveModalPresentationEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 9/7/23.
//

import UIKit


extension AdaptiveModalPageViewController: AdaptiveModalPresentationEventsNotifiable {

  public func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    nextInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    
    let prevSnapPointIndex = prevInterpolationPoint?.snapPoint.index;
    let nextSnapPointIndex = nextInterpolationPoint.snapPoint.index;
    
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
    
    if prevPage?.viewController !== nextPage.viewController,
       let delegate = prevPage?.viewController as? AdaptiveModalPageFocusEventsNotifiable {
    
      delegate.notifyOnModalPageWillBlur(
        sender: self,
        pageToBlur: prevPage,
        pageToFocus: nextPage
      );
    };
    
    if let delegate = nextPage.viewController as? AdaptiveModalPageFocusEventsNotifiable {
      delegate.notifyOnModalPageWillFocus(
        sender: self,
        pageToBlur: prevPage,
        pageToFocus: nextPage
      );
    };
  };
  
  public func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    currentInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    
    let prevSnapPointIndex = prevInterpolationPoint?.snapPoint.index;
    let currentSnapPointIndex = currentInterpolationPoint.snapPoint.index;
    
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
    
    if prevPage?.viewController !== currentPage.viewController,
       let delegate = prevPage?.viewController as? AdaptiveModalPageFocusEventsNotifiable {
       
      delegate.notifyOnModalPageDidBlur(
        sender: self,
        blurredPage: prevPage,
        focusedPage: currentPage
      );
    };
    
    if let delegate = currentPage.viewController as? AdaptiveModalPageFocusEventsNotifiable {
      delegate.notifyOnModalPageDidFocus(
        sender: self,
        blurredPage: prevPage,
        focusedPage: currentPage
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
