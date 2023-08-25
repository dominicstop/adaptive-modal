//
//  TestRoutes.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/22/23.
//

import UIKit

enum TestRoutes {
  static let rootRouteKey: Self = .AdaptiveModalPresentationTest;

  case RNIDraggableTest;
  case BlurEffectTest;
  case RoundedViewTest;
  case AdaptiveModalPresentationTest;
  
  case BasicUsage01;
  
  var viewController: UIViewController {
    switch self {
      case .RNIDraggableTest:
        return RNIDraggableTestViewController();
        
      case .BlurEffectTest:
        return BlurEffectTestViewController();
        
      case .RoundedViewTest:
        return RoundedViewTestViewController();
        
      case .AdaptiveModalPresentationTest:
        return AdaptiveModalPresentationTestViewController();
        
      case .BasicUsage01:
        return AdaptiveModalBasicUsage01();
    };
  };
};
