//
//  AdaptiveModalSnapPoint.swift
//  
//
//  Created by Dominic Go on 1/24/24.
//

import Foundation
import ComputableLayout


public struct AdaptiveModalSnapPoint: Equatable {
  
  public var key: String?;
  public var index: Int;
  public var mode: AdaptiveModalSnapPointMode;
  
  public var type: AdaptiveModalSnapPointType;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  // MARK: Computed Properties
  // -------------------------
  
  public var layoutConfig: ComputableLayout {
    get {
      self.mode.layoutConfig ?? .zero;
    }
    set {
      switch self.mode {
        case .standard:
          self.mode = .standard(layoutConfig: newValue);
          
        case .inBetween:
          self.mode = .inBetween(layoutConfig: newValue);
      };
    }
  };
  
  // MARK: Init
  // ----------
  
  public init(
    key: String?,
    index: Int,
    mode: AdaptiveModalSnapPointMode,
    type: AdaptiveModalSnapPointType,
    keyframeConfig: AdaptiveModalKeyframeConfig?
  ) {
    
    self.key = key;
    self.index = index;
    self.mode = mode;
    self.type = type;
    self.keyframeConfig = keyframeConfig;
  };
  
  public init(
    fromSnapPointConfig snapPointConfig: AdaptiveModalSnapPointConfig,
    type: AdaptiveModalSnapPointType,
    index: Int
  ) {
    
    self.key = snapPointConfig.key;
    self.mode = snapPointConfig.mode;
    self.keyframeConfig = snapPointConfig.keyframeConfig;
    
    self.type = type;
    self.index = index;
  };
};

// MARK: Helpers
// -------------

extension AdaptiveModalSnapPoint {

  static func deriveSnapPoints(
    undershootSnapPoint: AdaptiveModalSnapPointPreset,
    inBetweenSnapPoints: [AdaptiveModalSnapPointConfig],
    overshootSnapPoint: AdaptiveModalSnapPointPreset?
  ) -> [Self] {

    var items: [AdaptiveModalSnapPoint] = [];
    
    if let snapPointFirst = inBetweenSnapPoints.first {
      var initialSnapPointConfig = AdaptiveModalSnapPointConfig(
        key: nil,
        fromSnapPointPreset: undershootSnapPoint,
        fromBaseLayoutConfig: snapPointFirst.layoutConfig
      );
      
      if var initialSnapPointKeyframe = initialSnapPointConfig.keyframeConfig {
        initialSnapPointKeyframe.setNonNilValues(
          using: .defaultUndershootKeyframe
        );
        
        initialSnapPointConfig.keyframeConfig = initialSnapPointKeyframe;
      };
      
      let undershootSnapPoint = AdaptiveModalSnapPoint(
        fromSnapPointConfig: initialSnapPointConfig,
        type: .undershootSnapPoint,
        index: 0
      );
      
      items.append(undershootSnapPoint);
    };
    
    items += inBetweenSnapPoints.enumerated().map {
      .init(
        fromSnapPointConfig: $0.element,
        type: .snapPoint,
        index: $0.offset + 1
      );
    };
    
    if let overshootSnapPoint = overshootSnapPoint,
       let snapPointLast = inBetweenSnapPoints.last {
      
      let lastIndex = items.count - 1;
      
      let overshootSnapPointConfig = AdaptiveModalSnapPointConfig(
        key: nil,
        fromSnapPointPreset: overshootSnapPoint,
        fromBaseLayoutConfig: snapPointLast.layoutConfig
      );
      
      let overshootSnapPoint = AdaptiveModalSnapPoint(
        fromSnapPointConfig: overshootSnapPointConfig,
        type: .overshootSnapPoint,
        index: lastIndex
      );
      
      items.append(overshootSnapPoint);
    };
    
    return items;
  };
};

