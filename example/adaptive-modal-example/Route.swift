//
//  TestRoutes.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/22/23.
//

import UIKit

enum Route: CaseIterable {
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

class RouteManager {
  static let sharedInstance = RouteManager();
  
  weak var window: UIWindow?;
  
  var routes: [Route] = [
    .AdaptiveModalConfigDemo,
    .AdaptiveModalPageTest
  ];
  
  var routeCounter = 0;
  
  var currentRouteIndex: Int {
    self.routeCounter % self.routes.count;
  };
  
  var currentRoute: Route {
    self.routes[self.currentRouteIndex];
  };
  
  func applyCurrentRoute(){
    guard let window = self.window else { return };
  
    let nextVC = self.currentRoute.viewController;
    window.rootViewController = nextVC;
  };
};
