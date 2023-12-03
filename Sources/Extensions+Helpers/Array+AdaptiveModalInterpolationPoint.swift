//
//  Array+AdaptiveModalInterpolationPoint.swift
//
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation

extension Array where Element == AdaptiveModalInterpolationPoint {
  
  func first(
    forSnapPointKey snapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey
  ) -> Element? {
    
    self.first {
      $0.key == snapPointKey;
    };
  };
};
