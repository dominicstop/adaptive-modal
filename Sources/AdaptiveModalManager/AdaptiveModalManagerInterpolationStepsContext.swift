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
  
  var currentMode: InterpolationMode<CurrentModeMetadata>;

  var interpolationPointMetadataPrev:
    InterpolationMode<InterpolationPointMetadata>?;
  
  var interpolationPointMetadataCurrent:
    InterpolationMode<InterpolationPointMetadata>;
    
  var interpolationPointMetadataNext:
    InterpolationMode<InterpolationPointMetadata>?;
    
  /// * Indicates the next potential snapping point.
  /// * As the modal is being dragged, this will be updated to the next closest
  ///   snapping point.
  ///
  /// * Note: This is a temp. variable that is set from:
  ///   `AdaptiveModalManager._notifyOnModalWillSnap`.
  ///
  var onModalWillSnapInterpolationPointMetadataNext:
    InterpolationMode<InterpolationPointMetadata>?;
    
  /// Owned by: `_notifyOnModalWillSnap`
  /// * The previous value of `onModalWillSnapInterpolationPointNext`
  /// * The previous potential snapping point
  ///
  /// * Note: This is a temp. variable that is set from:
  ///   `AdaptiveModalManager._notifyOnModalWillSnap`.
  ///
  var onModalWillSnapInterpolationPointMetadataPrev:
    InterpolationMode<InterpolationPointMetadata>?;
    
  // MARK: Computed Properties - Alias/Shortcuts
  // -------------------------------------------
  
  var currentModeMetadata: CurrentModeMetadata {
    self.currentMode.associatedValue;
  };
  
  public var snapPoints: [AdaptiveModalSnapPointConfig] {
    self.currentModeMetadata.snapPoints;
  };
  
  public var snapPointPrev: AdaptiveModalSnapPointConfig? {
    self.interpolationPointMetadataPrev?.associatedValue.snapPoint;
  };
  
  public var snapPointCurrent: AdaptiveModalSnapPointConfig {
    self.interpolationPointMetadataCurrent.associatedValue.snapPoint;
  };
  
  public var snapPointNext: AdaptiveModalSnapPointConfig? {
    self.interpolationPointMetadataNext?.associatedValue.snapPoint;
  };
  
  public var interpolationSteps: [AdaptiveModalInterpolationPoint] {
    self.currentModeMetadata.interpolationSteps;
  };
  
  public var interpolationPointPrev: AdaptiveModalInterpolationPoint? {
    self.interpolationPointMetadataPrev?.associatedValue.interpolationPoint;
  };
  
  public var interpolationPointCurrent: AdaptiveModalInterpolationPoint {
    self.interpolationPointMetadataCurrent.associatedValue.interpolationPoint;
  };
  
  public var interpolationPointNext: AdaptiveModalInterpolationPoint? {
    self.interpolationPointMetadataNext?.associatedValue.interpolationPoint;
  };
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var interpolationRangeInput: [CGFloat] {
    self.interpolationSteps.map { $0.percent };
  };
  
  public var isOverridingSnapPoints: Bool {
    !self.currentMode.isConfig;
  };
  
  // MARK: - Init
  // ------------
  
  init(
    currentMode:
      InterpolationMode<CurrentModeMetadata>,
      
    interpolationPointMetadataPrev:
      InterpolationMode<InterpolationPointMetadata>?,
      
    interpolationPointMetadataCurrent:
      InterpolationMode<InterpolationPointMetadata>,
      
    interpolationPointMetadataNext:
      InterpolationMode<InterpolationPointMetadata>,
      
    onModalWillSnapInterpolationPointMetadataNext:
      InterpolationMode<InterpolationPointMetadata>?,
      
    onModalWillSnapInterpolationPointMetadataPrev:
      InterpolationMode<InterpolationPointMetadata>?
  ) {
  
    self.currentMode = currentMode;
    
    self.interpolationPointMetadataPrev = interpolationPointMetadataPrev;
    self.interpolationPointMetadataCurrent = interpolationPointMetadataCurrent;
    self.interpolationPointMetadataNext = interpolationPointMetadataNext;
    
    self.onModalWillSnapInterpolationPointMetadataNext = onModalWillSnapInterpolationPointMetadataNext;
    self.onModalWillSnapInterpolationPointMetadataPrev = onModalWillSnapInterpolationPointMetadataPrev;
  };
  
  init?(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext
  ){
    
    let configMetadata = CurrentModeMetadata(
      usingModalConfig: modalConfig,
      usingContext: context
    );
    
    self.currentMode = .config(configMetadata);

    let startSnapPoint =
      configMetadata.snapPoints.first(forSnapPointKey: .undershootPoint);
    
    let startInterpolationPoint = configMetadata.interpolationSteps.first {
      $0.key == .undershootPoint;
    };
    
    guard let startSnapPoint = startSnapPoint,
          let startInterpolationPoint = startInterpolationPoint
    else { return nil };
    
    self.interpolationPointMetadataCurrent = .config(
      InterpolationPointMetadata(
        snapPoint: startSnapPoint,
        interpolationPoint: startInterpolationPoint
      )
    );
  };
  
  // MARK: - Functions
  // -----------------
  
  func shouldRevertCurrentModeToConfig(
    nextInterpolationPoint: AdaptiveModalInterpolationPoint
  ) -> Bool {
    switch self.currentMode {
      case .config:
        return false;
        
      case let .overrideSnapPoint(metadata):
        // guard adaptiveModalManager.presentationState == .none
        // else { return false };
        
        let hasOvershootPoint = metadata.hasOvershootSnapPoint;
        let interpolationPointsCount = metadata.interpolationSteps.count;
        
        // index of the override snap point
        let overrideIndex = hasOvershootPoint
          ? interpolationPointsCount - 2
          : interpolationPointsCount - 1;
        
        return nextInterpolationPoint.snapPointIndex <= overrideIndex;
    };
  };
};
