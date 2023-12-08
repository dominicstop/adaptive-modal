//
//  AdaptiveModalPageItemConfig.swift
//  
//
//  Created by Dominic Go on 9/2/23.
//

import UIKit


public struct AdaptiveModalPageItemConfig {

  public enum AssociatedSnapPoint: Equatable {
    case key(AdaptiveModalSnapPointConfig.SnapPointKey);
    case index(Int);
  };
  
  public var pageKey: String?;
  public var associatedSnapPoints: [AssociatedSnapPoint];
  public var viewController: UIViewController;
  
  public init(
    pageKey: String?,
    associatedSnapPoints: [AssociatedSnapPoint],
    viewController: UIViewController
  ) {
    
    self.pageKey = pageKey;
    self.associatedSnapPoints = associatedSnapPoints;
    self.viewController = viewController;
  };
};

extension AdaptiveModalPageItemConfig: Equatable {

  public static func == (
    lhs: AdaptiveModalPageItemConfig,
    rhs: AdaptiveModalPageItemConfig
  ) -> Bool {
    
    return
         lhs.viewController === rhs.viewController
      && lhs.associatedSnapPoints == rhs.associatedSnapPoints
  };
};
