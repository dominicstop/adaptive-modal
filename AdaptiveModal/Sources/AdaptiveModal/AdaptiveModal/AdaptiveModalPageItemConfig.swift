//
//  AdaptiveModalPageItemConfig.swift
//  
//
//  Created by Dominic Go on 9/2/23.
//

import UIKit


public struct AdaptiveModalPageItemConfig {
  public enum Identifier {
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
