//
//  AdaptiveModalInterpolationContext.swift
//
//
//  Created by Dominic Go on 12/2/23.
//

import Foundation
import ComputableLayout


public class AdaptiveModalInterpolationContext {

  // MARK: - Properties
  // ------------------
  
  var mode: AdaptiveModalInterpolationStepMode;
  var interpolationStepItemCurrent: AdaptiveModalInterpolationStepItem;
  
  var interpolationStepItemPrev: AdaptiveModalInterpolationStepItem?;
  var interpolationStepItemNext: AdaptiveModalInterpolationStepItem?;
    
  /// * Indicates the next potential snapping point.
  /// * As the modal is being dragged, this will be updated to the next closest
  ///   snapping point.
  ///
  /// * Note: This is a temp. variable that is set from:
  ///   `AdaptiveModalManager._notifyOnModalWillSnap`.
  ///
  var onModalWillSnapNextModeItem: AdaptiveModalInterpolationStepItem?;
    
  /// Owned by: `_notifyOnModalWillSnap`
  /// * The previous value of `onModalWillSnapInterpolationPointNext`
  /// * The previous potential snapping point
  ///
  /// * Note: This is a temp. variable that is set from:
  ///   `AdaptiveModalManager._notifyOnModalWillSnap`.
  ///
  var onModalWillSnapPrevModeItem: AdaptiveModalInterpolationStepItem?;
    
  // MARK: Computed Properties - Alias/Shortcuts
  // -------------------------------------------
  
  public var interpolationSteps: [AdaptiveModalInterpolationStep] {
    self.mode.associatedValue;
  };
  
  public var interpolationStepPrev: AdaptiveModalInterpolationStep? {
    self.interpolationStepItemPrev?.associatedValue;
  };
  
  public var interpolationStepCurrent: AdaptiveModalInterpolationStep {
    self.interpolationStepItemCurrent.associatedValue;
  };
  
  public var interpolationStepNext: AdaptiveModalInterpolationStep? {
    self.interpolationStepItemNext?.associatedValue;
  };
  
  public var snapPointIndexPrev: Int? {
    self.interpolationStepPrev?.snapPointIndex;
  };
  
  public var snapPointIndexCurrent: Int {
    self.interpolationStepCurrent.snapPointIndex;
  };
  
  public var snapPointIndexNext: Int? {
    self.interpolationStepNext?.snapPointIndex;
  };
  
  public var snapPoints: [AdaptiveModalSnapPointConfig] {
    self.mode.associatedValue.snapPoints;
  };
  
  public var snapPointPrev: AdaptiveModalSnapPointConfig? {
    self.interpolationStepPrev?.snapPoint;
  };
  
  public var snapPointCurrent: AdaptiveModalSnapPointConfig {
    self.interpolationStepCurrent.snapPoint;
  };
  
  public var snapPointNext: AdaptiveModalSnapPointConfig? {
    self.interpolationStepNext?.snapPoint;
  };
  
  public var interpolationPoints: [AdaptiveModalInterpolationPoint] {
    self.mode.associatedValue.interpolationPoints;
  };
  
  public var interpolationPointPrev: AdaptiveModalInterpolationPoint? {
    self.interpolationStepPrev?.interpolationPoint;
  };
  
  public var interpolationPointCurrent: AdaptiveModalInterpolationPoint {
    self.interpolationStepCurrent.interpolationPoint;
  };
  
  public var interpolationPointNext: AdaptiveModalInterpolationPoint? {
    self.interpolationStepNext?.interpolationPoint;
  };
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var interpolationRangeInput: [CGFloat] {
    self.interpolationPoints.map { $0.percent };
  };
  
  public var isOverridingSnapPoints: Bool {
    !self.mode.isConfig;
  };
  
  // MARK: - Init
  // ------------
  
  init(
    mode: AdaptiveModalInterpolationStepMode,
    interpolationStepItemCurrent: AdaptiveModalInterpolationStepItem,
    interpolationStepItemPrev: AdaptiveModalInterpolationStepItem? = nil,
    interpolationStepItemNext: AdaptiveModalInterpolationStepItem? = nil,
    onModalWillSnapNextModeItem: AdaptiveModalInterpolationStepItem? = nil,
    onModalWillSnapPrevModeItem: AdaptiveModalInterpolationStepItem? = nil
  ) {
  
    self.mode = mode;
    self.interpolationStepItemCurrent = interpolationStepItemCurrent;
    
    self.interpolationStepItemPrev = interpolationStepItemPrev;
    self.interpolationStepItemNext = interpolationStepItemNext;
    
    self.onModalWillSnapNextModeItem = onModalWillSnapNextModeItem;
    self.onModalWillSnapPrevModeItem = onModalWillSnapPrevModeItem;
  }
  
  init?(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext
  ) {
  
    self.mode = AdaptiveModalInterpolationMode(
      usingModalConfig: modalConfig,
      usingContext: context
    );

    let initialInterpolationStep = mode.associatedValue.first {
      $0.snapPoint.key == .undershootPoint
    };
    
    guard let initialInterpolationStep = initialInterpolationStep
    else { return nil };
    
    self.interpolationStepItemCurrent = .config(initialInterpolationStep);
  };
  
  // MARK: - Functions
  // -----------------
  
  func computeInterpolationPoints(
    usingModalConfig config: AdaptiveModalConfig,
    usingLayoutValueContext context: ComputableLayoutValueContext
  ){
  
    self.mode.computeInterpolationPoints(
      usingModalConfig: config,
      usingContext: context
    );
    
    self.interpolationStepCurrent =
  };
  
  func shouldRevertCurrentModeToConfig(
    nextModeItem nextResolvedInterpolationPoint: AdaptiveModalInterpolationStep
  ) -> Bool {
    switch self.mode {
      case .config:
        return false;
        
      case let .overrideSnapPoint(resolvedInterpolationPoints):
        // TODO:
        // guard adaptiveModalManager.presentationState == .none
        // else { return false };
        
        let lastIndex = resolvedInterpolationPoints.count - 1;
  
        // index of the override snap point
        let overrideIndex =
          resolvedInterpolationPoints.overshootIndex ?? lastIndex;
          
        return nextResolvedInterpolationPoint.snapPointIndex < overrideIndex;
    };
  };
};
