//
//  AdaptiveModalResolvedInterpolationPoint.swift
//  
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation

/// An indexed snap point paired with it's corresponding interpolation point
struct AdaptiveModalResolvedInterpolationPoint {
  let index: Int;
  
  var snapPoint: AdaptiveModalSnapPointConfig;
  var interpolationPoint: AdaptiveModalInterpolationPoint;
};
