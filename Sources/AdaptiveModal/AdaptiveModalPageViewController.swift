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
