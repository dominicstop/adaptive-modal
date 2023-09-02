//
//  AdaptiveModalPageItemConfig.swift
//  
//
//  Created by Dominic Go on 9/2/23.
//

import UIKit


public struct AdaptiveModalPageItemConfig {
  public enum Identifier: Equatable {
    case key(AdaptiveModalSnapPointConfig.SnapPointKey);
    case index(Int);
  };

  public var associatedSnapPoints: [Identifier];
  public var viewController: UIViewController;
  
  public init(
    associatedSnapPoints: [Identifier],
    viewController: UIViewController
  ) {
  
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
