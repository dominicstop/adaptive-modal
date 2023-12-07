//
//  AdaptiveModalInterpolationStep.swift
//  
//
//  Created by Dominic Go on 12/3/23.
//

import Foundation

/// An indexed snap point paired with it's corresponding interpolation point
public struct AdaptiveModalInterpolationStep: Equatable {
  public let snapPointIndex: Int;
  
  public var snapPoint: AdaptiveModalSnapPointConfig;
  public var interpolationPoint: AdaptiveModalInterpolationPoint;
};
