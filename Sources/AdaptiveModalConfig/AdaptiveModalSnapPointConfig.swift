//
//  AdaptiveModalSnapPointConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit
import ComputableLayout


public struct AdaptiveModalSnapPointConfig: Equatable {
  
  public var mode: AdaptiveModalSnapPointMode;
  public var layoutConfig: ComputableLayout;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  public var key: String?;
  
  // MARK: Init
  // ----------
  
  public init(
    key: String? = nil,
    mode: AdaptiveModalSnapPointMode = .standard,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    self.key = key;
    self.mode = mode;
    self.layoutConfig = layoutConfig;
    self.keyframeConfig = keyframeConfig;
  };
  
  public init(
    key: String? = nil,
    mode: AdaptiveModalSnapPointMode = .standard,
    fromSnapPointPreset snapPointPreset: AdaptiveModalSnapPointPreset,
    fromBaseLayoutConfig baseLayoutConfig: ComputableLayout
  ) {
  
    let snapPointLayoutPreset = snapPointPreset.layoutPreset;
    
    let snapPointLayout = snapPointLayoutPreset.getLayoutConfig(
      fromBaseLayoutConfig: baseLayoutConfig
    );
    
    self.init(
      key: key,
      mode: mode,
      layoutConfig: snapPointLayout,
      keyframeConfig: snapPointPreset.keyframeConfig
    );
  };
  
  public init(
    fromBase base: Self,
    newSnapPoint: ComputableLayout? = nil,
    newAnimationKeyframe: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    let layoutConfig = newSnapPoint ?? base.layoutConfig;
    let keyframeConfig = newAnimationKeyframe ?? base.keyframeConfig;
    
    self.init(
      key: base.key,
      mode: base.mode,
      layoutConfig: layoutConfig,
      keyframeConfig: keyframeConfig
    );
  };
};


// MARK: Helpers
// -------------

extension AdaptiveModalSnapPointConfig {

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
