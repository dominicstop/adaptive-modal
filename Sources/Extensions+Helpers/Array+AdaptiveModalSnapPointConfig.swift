//
//  Array+AdaptiveModalSnapPointConfig.swift
//
//
//  Created by Dominic Go on 12/2/23.
//

import Foundation


extension Array where Element == AdaptiveModalSnapPointConfig {

  func first(
    forSnapPointKey snapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey
  ) -> Element? {
    
    self.first {
      $0.key == snapPointKey;
    };
  };
  
  func first(
    forInterpolationPoint interpolationPoint: AdaptiveModalInterpolationPoint
  ) -> Element? {
    
    let match = self.enumerated().first {
      $0.offset == interpolationPoint.snapPointIndex;
    };
    
    return match?.element;
  };
};
