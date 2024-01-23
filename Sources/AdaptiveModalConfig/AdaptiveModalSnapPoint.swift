//
//  AdaptiveModalSnapPoint.swift
//  
//
//  Created by Dominic Go on 1/21/24.
//

import Foundation
import ComputableLayout


public struct AdaptiveModalSnapPoint: Equatable {
  
  public var index: Int;
  public var key: String?;
  
  public var mode: AdaptiveModalSnapPointMode;
  public var type: AdaptiveModalSnapPointType;
  
  public var layoutConfig: ComputableLayout;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  // MARK: - Init
  // ------------
  
  public init(
    index: Int,
    key: String?,
    mode: AdaptiveModalSnapPointMode,
    type: AdaptiveModalSnapPointType,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig?
  ) {
  
    self.index = index;
    self.key = key;
    self.mode = mode;
    self.type = type;
    self.layoutConfig = layoutConfig;
    self.keyframeConfig = keyframeConfig;
  };
  
  public init(
    fromSnapPointConfig snapPointConfig: AdaptiveModalSnapPointConfig,
    index: Int,
    type: AdaptiveModalSnapPointType
  ){
    
    self.index = index;
    self.key = snapPointConfig.key;
    
    self.mode = snapPointConfig.mode;
    self.type = type;
    
    self.layoutConfig = snapPointConfig.layoutConfig;
    self.keyframeConfig = snapPointConfig.keyframeConfig;
  };
};

// MARK: Helpers
// -------------

extension AdaptiveModalSnapPoint {

  static func deriveSnapPoints(
    undershootSnapPoint: AdaptiveModalSnapPointPreset,
    inBetweenSnapPoints: [AdaptiveModalSnapPointConfig],
    overshootSnapPoint: AdaptiveModalSnapPointPreset?
  ) -> [AdaptiveModalSnapPoint] {

    var items: [AdaptiveModalSnapPoint] = [];
    
    if let snapPointFirst = inBetweenSnapPoints.first {
      var initialSnapPointConfig = AdaptiveModalSnapPointConfig(
        fromSnapPointPreset: undershootSnapPoint,
        fromBaseLayoutConfig: snapPointFirst.layoutConfig
      );
      
      if var initialSnapPointKeyframe = initialSnapPointConfig.keyframeConfig {
        initialSnapPointKeyframe.setNonNilValues(
          using: .defaultUndershootKeyframe
        );
      
        initialSnapPointConfig = .init(
          fromBase: initialSnapPointConfig,
          newAnimationKeyframe: initialSnapPointKeyframe
        );
      };
      
      let undershootSnapPoint = AdaptiveModalSnapPoint(
        fromSnapPointConfig: initialSnapPointConfig,
        index: 0,
        type: .undershootSnapPoint
      );
      
      items.append(undershootSnapPoint);
    };
    
    items += inBetweenSnapPoints.enumerated().map {
      .init(
        fromSnapPointConfig: $0.element,
        index: $0.offset + 1,
        type: .snapPoint
      );
    };
    
    if let overshootSnapPoint = overshootSnapPoint,
       let snapPointLast = inBetweenSnapPoints.last {
       
      let overshootSnapPointConfig = AdaptiveModalSnapPointConfig(
        fromSnapPointPreset: overshootSnapPoint,
        fromBaseLayoutConfig: snapPointLast.layoutConfig
      );
      
      let lastIndex = items.count - 1;
      
      let overshootSnapPoint = AdaptiveModalSnapPoint(
        fromSnapPointConfig: overshootSnapPointConfig,
        index: lastIndex,
        type: .overshootSnapPoint
      );
      
      items.append(overshootSnapPoint);
    };
    
    return items;
  };
};
