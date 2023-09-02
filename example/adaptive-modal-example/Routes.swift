//
//  TestRoutes.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/22/23.
//

import UIKit

enum Routes {
  static let rootRoute: Self = .AdaptiveModalPageTest;

  case AdaptiveModalConfigTest;
  case AdaptiveModalConfigDemo;
  case AdaptiveModalPageTest;
  
  case BasicUsage01;
  
  var viewController: UIViewController {
    switch self {
      case .AdaptiveModalConfigTest:
        return AdaptiveModalConfigTestViewController();

      case .AdaptiveModalConfigDemo:
        return AdaptiveModalConfigDemoViewController();
        
      case .BasicUsage01:
        return AdaptiveModalBasicUsage01();
        
      case .AdaptiveModalPageTest:
        return AdaptiveModalPageTestViewController();
    };
  };
};
