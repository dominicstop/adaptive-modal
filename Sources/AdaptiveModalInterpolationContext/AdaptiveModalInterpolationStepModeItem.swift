//
//  AdaptiveModalInterpolationStepItem.swift
//  
//
//  Created by Dominic Go on 12/6/23.
//

import Foundation


typealias AdaptiveModalInterpolationStepItem =
  AdaptiveModalInterpolationMode<AdaptiveModalInterpolationStep>;

extension AdaptiveModalInterpolationMode
  where T == AdaptiveModalInterpolationStep {
  
  var snapPointIndex: Int {
    self.associatedValue.snapPointIndex;
  };
  var snapPoint: AdaptiveModalSnapPointConfig {
    self.associatedValue.snapPoint;
  };
  var interpolationPoint: AdaptiveModalInterpolationPoint {
    self.associatedValue.interpolationPoint;
  };
};
