//
//  AdaptiveModalResolvedPageItemConfig.swift
//  
//
//  Created by Dominic Go on 9/2/23.
//

import UIKit


struct AdaptiveModalResolvedPageItemConfig {

  var associatedSnapPoints: [(
    snapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey,
    snapPointIndex: Int
  )];
  
  weak var viewController: UIViewController?;
  
  init?(
    pageConfig: AdaptiveModalPageItemConfig,
    interpolationPoints: [AdaptiveModalInterpolationPoint]
  ) {
  
    let matches = pageConfig.associatedSnapPoints.compactMap { id in
      interpolationPoints.first {
        switch id {
          case let .index(index):
            return $0.snapPointIndex == index;
            
          case let .key(key):
            return $0.key == key;
          };
      };
    };
    
    guard matches.count > 0 else { return nil };
    self.viewController = pageConfig.viewController;
    
    self.associatedSnapPoints = matches.map {(
      snapPointKey: $0.key,
      snapPointIndex: $0.snapPointIndex
    )};
  };
  
  func contains(key: AdaptiveModalSnapPointConfig.SnapPointKey) -> Bool {
    self.associatedSnapPoints.contains {
      $0.snapPointKey == key;
    };
  };
  
  func contains(index: Int) -> Bool {
    self.associatedSnapPoints.contains {
      $0.snapPointIndex == index;
    };
  };
};
