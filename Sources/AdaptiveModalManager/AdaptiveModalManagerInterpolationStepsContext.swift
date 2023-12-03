//
//  AdaptiveModalManagerInterpolationStepsContext.swift
//
//
//  Created by Dominic Go on 12/2/23.
//

import Foundation
import ComputableLayout


class AdaptiveModalManagerInterpolationStepsContext {
  
  // MARK: - Properties
  // ------------------
  
  var interpolationMode:
    AdaptiveModalManagerInterpolationMode<[AdaptiveModalResolvedInterpolationPoint]>;

  var resolvedInterpolationPointPrev:
    AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>?;
  
  var resolvedInterpolationPointCurrent:
    AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>;
    
  var resolvedInterpolationPointNext:
    AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>?;
    
  /// * Indicates the next potential snapping point.
  /// * As the modal is being dragged, this will be updated to the next closest
  ///   snapping point.
  ///
  /// * Note: This is a temp. variable that is set from:
  ///   `AdaptiveModalManager._notifyOnModalWillSnap`.
  ///
  var onModalWillSnapResolvedInterpolationPointNext:
    AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>?;
    
  /// Owned by: `_notifyOnModalWillSnap`
  /// * The previous value of `onModalWillSnapInterpolationPointNext`
  /// * The previous potential snapping point
  ///
  /// * Note: This is a temp. variable that is set from:
  ///   `AdaptiveModalManager._notifyOnModalWillSnap`.
  ///
  var onModalWillSnapResolvedInterpolationPointPrev:
    AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>?;
    
  // MARK: Computed Properties - Alias/Shortcuts
  // -------------------------------------------
  
  var resolvedInterpolationPoints: [AdaptiveModalResolvedInterpolationPoint] {
    self.interpolationMode.associatedValue;
  };
  
  public var snapPoints: [AdaptiveModalSnapPointConfig] {
    self.interpolationMode.associatedValue.snapPoints;
  };
  
  public var snapPointPrev: AdaptiveModalSnapPointConfig? {
    self.resolvedInterpolationPointPrev?.associatedValue.snapPoint;
  };
  
  public var snapPointCurrent: AdaptiveModalSnapPointConfig {
    self.resolvedInterpolationPointCurrent.associatedValue.snapPoint;
  };
  
  public var snapPointNext: AdaptiveModalSnapPointConfig? {
    self.resolvedInterpolationPointNext?.associatedValue.snapPoint;
  };
  
  public var interpolationPoints: [AdaptiveModalInterpolationPoint] {
    self.interpolationMode.associatedValue.interpolationPoints;
  };
  
  public var interpolationPointPrev: AdaptiveModalInterpolationPoint? {
    self.resolvedInterpolationPointPrev?.associatedValue.interpolationPoint;
  };
  
  public var interpolationPointCurrent: AdaptiveModalInterpolationPoint {
    self.resolvedInterpolationPointCurrent.associatedValue.interpolationPoint;
  };
  
  public var interpolationPointNext: AdaptiveModalInterpolationPoint? {
    self.resolvedInterpolationPointNext?.associatedValue.interpolationPoint;
  };
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var interpolationRangeInput: [CGFloat] {
    self.interpolationPoints.map { $0.percent };
  };
  
  public var isOverridingSnapPoints: Bool {
    !self.interpolationMode.isConfig;
  };
  
  // MARK: - Init
  // ------------
  
  init(
    interpolationMode:
      AdaptiveModalManagerInterpolationMode<[AdaptiveModalResolvedInterpolationPoint]>,
      
    interpolationPointMetadataPrev:
      AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>? = nil,
      
    interpolationPointMetadataCurrent:
      AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>,
      
    interpolationPointMetadataNext:
      AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>? = nil,
      
    onModalWillSnapInterpolationPointMetadataNext:
      AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>? = nil,
      
    onModalWillSnapInterpolationPointMetadataPrev:
      AdaptiveModalManagerInterpolationMode<AdaptiveModalResolvedInterpolationPoint>? = nil
  ) {
  
    self.interpolationMode = interpolationMode;
    
    self.resolvedInterpolationPointPrev = interpolationPointMetadataPrev;
    self.resolvedInterpolationPointCurrent = interpolationPointMetadataCurrent;
    self.resolvedInterpolationPointNext = interpolationPointMetadataNext;
    
    self.onModalWillSnapResolvedInterpolationPointNext = onModalWillSnapInterpolationPointMetadataNext;
    self.onModalWillSnapResolvedInterpolationPointPrev = onModalWillSnapInterpolationPointMetadataPrev;
  };
  
  init?(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext
  ) {
  
    let interpolationMode = AdaptiveModalManagerInterpolationMode(
      usingModalConfig: modalConfig,
      usingContext: context
    );
    
    guard let interpolationMode = interpolationMode else { return nil };
    self.interpolationMode = interpolationMode;
  
    let initialResolvedInterpolationPoint = interpolationMode.associatedValue.first {
      $0.snapPoint.key == .undershootPoint
    };
    
    guard let initialResolvedInterpolationPoint = initialResolvedInterpolationPoint
    else { return nil };
    
    self.resolvedInterpolationPointCurrent =
      .config(initialResolvedInterpolationPoint);
  };
  
  // MARK: - Functions
  // -----------------
  
  func shouldRevertCurrentModeToConfig(
    nextResolvedInterpolationPoint: AdaptiveModalResolvedInterpolationPoint
  ) -> Bool {
    switch self.interpolationMode {
      case .config:
        return false;
        
      case let .overrideSnapPoint(resolvedInterpolationPoints):
        // guard adaptiveModalManager.presentationState == .none
        // else { return false };
        
        let hasOvershootPoint = resolvedInterpolationPoints.hasOvershootPoint;
        let lastIndex = resolvedInterpolationPoints.count - 1;
  
        // index of the override snap point
        let overrideIndex =
          resolvedInterpolationPoints.overshootIndex ?? lastIndex;
          
        return nextResolvedInterpolationPoint.index < overrideIndex;
    };
  };
};
