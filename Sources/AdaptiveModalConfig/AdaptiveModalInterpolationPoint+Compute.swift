//
//  AdaptiveModalInterpolationPoint+Compute.swift
//  
//
//  Created by Dominic Go on 8/9/23.
//

import UIKit
import ComputableLayout
import DGSwiftUtilities

extension AdaptiveModalInterpolationPoint {

  static func itemsWithPercentCollision(interpolationPoints: [Self]) -> [Self] {
    interpolationPoints.filter { interpolationPoint in
      interpolationPoints.contains {
        $0 != interpolationPoint && $0.percent == interpolationPoint.percent;
      };
    };
  };
  
  /// `KeyframeMode.standard` snap points
  static private func computeStandard(
    usingConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPointsIndexed snapPoints: [AdaptiveModalSnapPoint]
  ) -> [Self] {

    var items: [AdaptiveModalInterpolationPoint] = [];
    
    for snapPoint in snapPoints {
      items.append(
        AdaptiveModalInterpolationPoint(
          usingModalConfig: modalConfig,
          layoutValueContext: context,
          snapPoint: snapPoint,
          prevInterpolationPoint: items.last
        )
      );
    };
    
    let firstSnapPoint = snapPoints.first {
      $0.index == 0;
    };
    
    let secondInterpolationPoint = items.first {
      $0.snapPoint.index == 1;
    };
    
    if let firstSnapPoint = firstSnapPoint,
       let secondInterpolationPoint = secondInterpolationPoint {
       
      items[0] = AdaptiveModalInterpolationPoint(
        usingModalConfig: modalConfig,
        layoutValueContext: context,
        snapPoint: firstSnapPoint,
        prevInterpolationPoint: secondInterpolationPoint
      );
    };

    return items;
  };
  
  static private func computeInBetween(
    usingConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPoints: [AdaptiveModalSnapPoint],
    standardInterpolationPoints: [Self],
    startPoint: Self,
    endPoint: Self?,
    inBetweenPoints: [AdaptiveModalSnapPoint]
  ) -> [Self] {
  
    let snapPointPercentList: [CGFloat] = {
      let rangeInput = standardInterpolationPoints.map {
        CGFloat($0.snapPoint.index);
      };
      
      let rangeOutput = standardInterpolationPoints.map {
        $0.percent;
      };
      
      return snapPoints.map {
        InterpolationHelpers.interpolate(
          inputValue: CGFloat($0.index),
          rangeInput: rangeInput,
          rangeOutput: rangeOutput
        )!;
      };
    }();
    
    var inBetweenKeyframes = inBetweenPoints.map {(
      offset: $0.index,
      element: $0.keyframeConfig ?? .init()
    )};
    
    func getRangeInputOutput<T>(
      keyframeKey: WritableKeyPath<AdaptiveModalKeyframeConfig, T?>,
      interpolationPointKey: KeyPath<Self, T>
    ) -> (
      rangeInput: [CGFloat],
      rangeOutput: [T]
    ) {
      var rangeInputOutput: [(input: CGFloat, output: T)] = [];
      
      rangeInputOutput.append((
        input: startPoint.percent,
        output: startPoint[keyPath: interpolationPointKey]
      ));
      
      rangeInputOutput += inBetweenPoints.compactMap {
        guard let keyframeConfig = $0.keyframeConfig,
              let rangeInput = snapPointPercentList[safeIndex: $0.index],
              let rangeOutput = keyframeConfig[keyPath: keyframeKey]
        else {
          return nil;
        };
        
        return (rangeInput, rangeOutput);
      };
      
      if let endPoint = endPoint {
        rangeInputOutput.append((
          input: endPoint.percent,
          output: endPoint[keyPath: interpolationPointKey]
        ));
      };
      
      return {
        var rangeInput: [CGFloat] = [];
        var rangeOutput: [T] = [];
        
        rangeInputOutput.forEach {
          rangeInput.append($0.input);
          rangeOutput.append($0.output);
        };
        
        return (rangeInput, rangeOutput);
      }();
    };
    
    func setKeyframeValue<T>(
      keyframeKey: WritableKeyPath<AdaptiveModalKeyframeConfig, T?>,
      interpolationPointKey: KeyPath<Self, T>,
      interpolator: (
        _ inputValue    : CGFloat,
        _ rangeInput    : [CGFloat],
        _ rangeOutput   : [T],
        _ shouldClampMin: Bool,
        _ shouldClampMax: Bool
      ) -> T?
    ) {
    
      let range = getRangeInputOutput(
        keyframeKey: keyframeKey,
        interpolationPointKey: interpolationPointKey
      );
      
      for index in 0 ..< inBetweenKeyframes.count {
        let currentItem = inBetweenKeyframes[index];
        let currentKeyframe = currentItem.element;
      
        guard currentKeyframe[keyPath: keyframeKey] == nil else { continue };
        let percent = snapPointPercentList[currentItem.offset];
        
        let interpolatedValue = interpolator(
          percent,
          range.rangeInput,
          range.rangeOutput,
          false,
          false
        );
        
        inBetweenKeyframes[index].element[keyPath: keyframeKey] = interpolatedValue!;
      };
    };
    
    for index in 0 ..< inBetweenKeyframes.count {
      inBetweenKeyframes[index].element.setIfNilValue(
        forKey: \.allowSnapping,
        value: false
      );
    };
    
    AdaptiveModalKeyframeConfig.keyMap.forEach {
      switch ($0.keyframeKey, $0.interpolationPointKey) {
        case (
          let keyframeKey as WritableKeyPath<AdaptiveModalKeyframeConfig, CGRect?>,
          let interpolationPointKey as WritableKeyPath<Self, CGRect>
        ):
          setKeyframeValue(
            keyframeKey: keyframeKey,
            interpolationPointKey: interpolationPointKey,
            interpolator: {
              InterpolationHelpers.interpolateRect(
                inputValue: $0,
                rangeInput: $1,
                rangeOutput: $2,
                shouldClampMinHeight: $3,
                shouldClampMaxHeight: $4,
                shouldClampMinWidth: $3,
                shouldClampMaxWidth: $4,
                shouldClampMinX: $3,
                shouldClampMaxX: $4,
                shouldClampMinY: $3,
                shouldClampMaxY: $4
              );
            }
          );
          
        case (
          let keyframeKey as WritableKeyPath<AdaptiveModalKeyframeConfig, UIEdgeInsets?>,
          let interpolationPointKey as WritableKeyPath<Self, UIEdgeInsets>
        ):
          setKeyframeValue(
            keyframeKey: keyframeKey,
            interpolationPointKey: interpolationPointKey,
            interpolator: InterpolationHelpers.interpolateEdgeInsets
          );
          
        case (
          let keyframeKey as WritableKeyPath<AdaptiveModalKeyframeConfig, CGFloat?>,
          let interpolationPointKey as WritableKeyPath<Self, CGFloat>
        ):
          setKeyframeValue(
            keyframeKey: keyframeKey,
            interpolationPointKey: interpolationPointKey,
            interpolator: InterpolationHelpers.interpolate
          );
          
        case (
          let keyframeKey as WritableKeyPath<AdaptiveModalKeyframeConfig, Transform3D?>,
          let interpolationPointKey as WritableKeyPath<Self, Transform3D>
        ):
          setKeyframeValue(
            keyframeKey: keyframeKey,
            interpolationPointKey: interpolationPointKey,
            interpolator: {
              InterpolationHelpers.interpolateTransform3D(
                inputValue: $0,
                rangeInput: $1,
                rangeOutput: $2,
                shouldClampMinTranslateX: $3,
                shouldClampMaxTranslateX: $4,
                shouldClampMinTranslateY: $3,
                shouldClampMaxTranslateY: $4,
                shouldClampMinTranslateZ: $3,
                shouldClampMaxTranslateZ: $4,
                shouldClampMinScaleX: $3,
                shouldClampMaxScaleX: $4,
                shouldClampMinScaleY: $3,
                shouldClampMaxScaleY: $4,
                shouldClampMinRotationX: $3,
                shouldClampMaxRotationX: $4,
                shouldClampMinRotationY: $3,
                shouldClampMaxRotationY: $4,
                shouldClampMinRotationZ: $3,
                shouldClampMaxRotationZ: $4,
                shouldClampMinPerspective: $3,
                shouldClampMaxPerspective: $4,
                shouldClampMinSkewX: $3,
                shouldClampMaxSkewX: $4,
                shouldClampMinSkewY: $3,
                shouldClampMaxSkewY: $4
              );
            }
          );
          
        case (
          let keyframeKey as WritableKeyPath<AdaptiveModalKeyframeConfig, UIColor?>,
          let interpolationPointKey as WritableKeyPath<Self, UIColor>
        ):
          setKeyframeValue(
            keyframeKey: keyframeKey,
            interpolationPointKey: interpolationPointKey,
            interpolator: InterpolationHelpers.interpolateColor
          );
        
        case (
          let keyframeKey as WritableKeyPath<AdaptiveModalKeyframeConfig, CGSize?>,
          let interpolationPointKey as WritableKeyPath<Self, CGSize>
        ):
          setKeyframeValue(
            keyframeKey: keyframeKey,
            interpolationPointKey: interpolationPointKey,
            interpolator: InterpolationHelpers.interpolateSize
          );
        
        default:
          break;
      };
    };
    
    if inBetweenPoints.count > 0 {
      let startPointKeyframe = AdaptiveModalKeyframeConfig(
        fromInterpolationPoint: startPoint
      );
      
      inBetweenKeyframes[0].element.setNonNilValues(
        using: startPointKeyframe
      );
    };
    
    let inBetweenPointsMerged: [AdaptiveModalSnapPoint] = {
      var items: [AdaptiveModalSnapPoint] = [];
      
      for index in 0 ..< inBetweenPoints.count {
        let prevSnapPoint = inBetweenPoints[index];
        let nextKeyframe = inBetweenKeyframes[index];
        
        let newSnapPoint = AdaptiveModalSnapPoint(
          key: prevSnapPoint.key,
          index: prevSnapPoint.index,
          mode: .inBetween(layoutConfig: prevSnapPoint.layoutConfig),
          type: .snapPoint,
          keyframeConfig: nextKeyframe.element
        );
        
        items.append(newSnapPoint);
      };
      
      return items;
    }();
    
    return Self.computeStandard(
      usingConfig: modalConfig,
      usingContext: context,
      snapPointsIndexed: inBetweenPointsMerged
    );
  };

  public static func compute(
    usingConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPoints: [AdaptiveModalSnapPoint]? = nil,
    shouldCheckForPercentCollision: Bool = true
  ) -> [Self] {
  
    let snapPoints = snapPoints ?? modalConfig.snapPoints;

    var snapPointsStandard: [AdaptiveModalSnapPoint] = [];
    var snapPointsInBetween: [AdaptiveModalSnapPoint] = [];
    
    snapPoints.forEach {
      switch $0.mode {
        case .standard:
          snapPointsStandard.append($0);
          
        case let .inBetween(layoutConfig):
          var snapPoint = $0;
          
          let shouldComputedLayoutConfig =
            layoutConfig != nil && layoutConfig != .zero;
            
          let shouldComputeKeyframe: Bool = {
            guard let keyframeConfig = snapPoint.keyframeConfig else { return false };
            
            return
                 keyframeConfig.modalScrollViewContentInsets != nil
              || keyframeConfig.modalScrollViewVerticalScrollIndicatorInsets != nil
              || keyframeConfig.modalScrollViewHorizontalScrollIndicatorInsets != nil
          }();
        
          guard shouldComputedLayoutConfig || shouldComputeKeyframe else {
            snapPointsInBetween.append(snapPoint);
            break;
          };
        
          var nextKeyframeConfig = $0.keyframeConfig ?? .init();
          
          if let layoutConfig = layoutConfig {
            nextKeyframeConfig.computedRect =
              layoutConfig.computeRect(usingLayoutValueContext: context);
          };
          
          if let insets = nextKeyframeConfig.modalScrollViewContentInsets {
            nextKeyframeConfig.computedModalScrollViewContentInsets =
              insets.compute(usingLayoutValueContext: context);
          };
          
          if let insets = nextKeyframeConfig.modalScrollViewVerticalScrollIndicatorInsets {
            nextKeyframeConfig.computedModalScrollViewVerticalScrollIndicatorInsets =
              insets.compute(usingLayoutValueContext: context);
          };
          
          if let insets = nextKeyframeConfig.modalScrollViewHorizontalScrollIndicatorInsets {
            nextKeyframeConfig.computedModalScrollViewHorizontalScrollIndicatorInsets =
              insets.compute(usingLayoutValueContext: context);
          };
 
          snapPoint.keyframeConfig = nextKeyframeConfig;
          snapPointsInBetween.append(snapPoint);
      };
    };
    
    let interpolationPointsStandard = Self.computeStandard(
      usingConfig: modalConfig,
      usingContext: context,
      snapPointsIndexed: snapPointsStandard
    );
    
    #if DEBUG
    func checkForCollisions(
      _ interpolationPoints: [AdaptiveModalInterpolationPoint]
    ) {
      guard shouldCheckForPercentCollision else { return };
      
      let collisions = Self.itemsWithPercentCollision(
        interpolationPoints: interpolationPoints
      );
      
      if collisions.count > 0 {
        print(
          "Warning: AdaptiveModalInterpolationPoint - Snap point collision",
          "\n - collisions count:", collisions.count,
          "\n"
        );
        
        collisions.enumerated().forEach {
          print(
            "Snap point collision - \($0.offset + 1)/\(collisions.count)",
            "\n - snapPointIndex: \($0.element.snapPoint.index)",
            "\n - key: \($0.element.snapPoint.key ?? "N/A")",
            "\n - percent: \($0.element.percent)",
            "\n - computedRect: \($0.element.computedRect)",
            "\n"
          );
        };
      };
    };
    #endif
    
    guard snapPointsInBetween.count > 0 else {
      #if DEBUG
      checkForCollisions(interpolationPointsStandard);
      #endif
      
      return interpolationPointsStandard;
    };
    
    typealias QueueItem = (
      startPoint: Self,
      endPoint: Self?,
      inBetweenSnapPoints: [AdaptiveModalSnapPoint]
    );
    
    let queue: [QueueItem] = {
      var queue: [QueueItem] = [];
    
      var currentIndex = 0;
      let lastIndex = snapPoints.count - 1;
      
      while currentIndex < snapPoints.count {
        
        // standard snap point - start
        let snapPointStart = snapPoints.first {
          guard $0.index >= currentIndex else {
            return false;
          };
          
          let snapPointCurrent = snapPoints[$0.index];
          
          guard let snapPointNext = snapPoints[safeIndex: $0.index + 1]
          else { return false };

          return (
               snapPointCurrent.mode.isStandard
            && snapPointNext.mode.isInBetween
          );
        };
        
        // standard snap point - end
        let snapPointEnd = snapPoints.first {
          guard $0.index >= currentIndex else {
            return false;
          };
          
          let snapPointCurrent = snapPoints[$0.index];
          
          guard let snapPointPrev = snapPoints[safeIndex: $0.index - 1]
          else { return false };
          
          return (
               snapPointCurrent.mode.isStandard
            && snapPointPrev.mode.isInBetween
          );
        };
        
        guard let snapPointStart = snapPointStart else { break };
        
        let interpolationPointStart = interpolationPointsStandard.first {
          $0.snapPoint.index == snapPointStart.index;
        };
        
        let interpolationPointEnd: Self? = {
          guard let snapPointEnd = snapPointEnd else { return nil };
          
          return interpolationPointsStandard.first {
            $0.snapPoint.index == snapPointEnd.index;
          };
        }();
        
        guard let interpolationPointStart = interpolationPointStart
        else { break };
        
        /// "in-between snap point", i.e. snap points between
        /// `snapPointStart` (exclusive) and `snapPointEnd` (exclusive)
        ///
        let inBetweenSnapPoints: [AdaptiveModalSnapPoint] = snapPoints.compactMap {
          let minIndex = interpolationPointStart.snapPoint.index;
          
          let maxIndex =
               interpolationPointEnd?.snapPoint.index
            ?? lastIndex + 1;
          
          guard $0.index > minIndex && $0.index < maxIndex else { return nil };
          return $0;
        };
        
        queue.append((
          startPoint: interpolationPointStart,
          endPoint: interpolationPointEnd,
          inBetweenSnapPoints: inBetweenSnapPoints
        ));
        
        currentIndex = snapPointEnd?.index ?? lastIndex;
        currentIndex += 1;
      };
      
      return queue;
    }();
    
    guard queue.count > 0 else {
      #if DEBUG
      checkForCollisions(interpolationPointsStandard);
      #endif
      
      return interpolationPointsStandard;
    };
    
    let interpolationPointsInBetween: [Self] = {
      var items: [Self] = [];
      
      queue.forEach {
        let inBetweenPoints = Self.computeInBetween(
          usingConfig: modalConfig,
          usingContext: context,
          snapPoints: snapPoints,
          standardInterpolationPoints: interpolationPointsStandard,
          startPoint: $0.startPoint,
          endPoint: $0.endPoint,
          inBetweenPoints: $0.inBetweenSnapPoints
        );
        
        items += inBetweenPoints;
      };
      
      return items;
    }();
    
    let interpolationPointsCombined = snapPoints.compactMap {
      let currentIndex = $0.index;
      
      if $0.mode.isStandard {
        return interpolationPointsStandard.first {
          $0.snapPoint.index == currentIndex;
        };
      };
      
      return interpolationPointsInBetween.first {
        $0.snapPoint.index == currentIndex;
      };
    };
    
    #if DEBUG
    checkForCollisions(interpolationPointsCombined);
    #endif
    
    return interpolationPointsCombined;
  };
};
