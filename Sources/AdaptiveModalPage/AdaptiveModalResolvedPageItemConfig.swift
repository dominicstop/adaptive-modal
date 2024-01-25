//
//  AdaptiveModalResolvedPageItemConfig.swift
//  
//
//  Created by Dominic Go on 9/2/23.
//

import UIKit

// TODO: Rename to AdaptiveModalPageItem
// * E.g. `AdaptiveModalPageItemConfig` -> `AdaptiveModalPageItem`
public struct AdaptiveModalResolvedPageItemConfig {
  
  public var pageKey: String?;
  
  /// The snap points associated to this page
  public var associatedSnapPoints: [(
    snapPointKey: String?,
    snapPointIndex: Int
  )];
  
  public weak var viewController: UIViewController?;
  
  public init?(
    pageConfig: AdaptiveModalPageItemConfig,
    interpolationPoints: [AdaptiveModalInterpolationPoint]
  ) {
  
    self.pageKey = pageConfig.pageKey;
  
    let matches = pageConfig.associatedSnapPoints.compactMap { id in
      interpolationPoints.first {
        switch id {
          case .undershoot:
            return $0.snapPoint.type == .undershootSnapPoint;
            
          case .overshoot:
            return $0.snapPoint.type == .overshootSnapPoint;
            
          case let .index(index):
            return $0.snapPoint.index == index;
            
          case let .key(key):
            return $0.snapPoint.key == key;
        };
      };
    };
    
    guard matches.count > 0 else { return nil };
    self.viewController = pageConfig.viewController;
    
    self.associatedSnapPoints = matches.map {(
      snapPointKey: $0.snapPoint.key,
      snapPointIndex: $0.snapPoint.index
    )};
  };
  
  public func contains(key: String) -> Bool {
    self.associatedSnapPoints.contains {
      $0.snapPointKey == key;
    };
  };
  
  public func contains(index: Int) -> Bool {
    self.associatedSnapPoints.contains {
      $0.snapPointIndex == index;
    };
  };
};
