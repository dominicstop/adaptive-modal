//
//  Array+AdaptiveModalResolvedInterpolationPoint.swift
//  
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation

extension Array where Element == AdaptiveModalResolvedInterpolationPoint {

  var snapPoints: [AdaptiveModalSnapPointConfig] {
    self.map {
      $0.snapPoint;
    };
  };
  
  var interpolationPoints: [AdaptiveModalInterpolationPoint] {
    self.map {
      $0.interpolationPoint;
    };
  };
  
  var hasOvershootPoint: Bool {
    self.snapPoints.contains {
      $0.key == .overshootPoint;
    };
  };
  
  var overshootIndex: Index? {
    self.lastIndex {
      $0.snapPoint.key == .overshootPoint;
    };
  };
};
