//
//  AdaptiveModalInterpolationStepMode.swift
//  
//
//  Created by Dominic Go on 12/6/23.
//

import Foundation
import ComputableLayout


typealias AdaptiveModalInterpolationStepMode =
  AdaptiveModalInterpolationMode<[AdaptiveModalInterpolationStep]>;
  
extension AdaptiveModalInterpolationMode {

  init(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext
  ) where T == [AdaptiveModalInterpolationStep] {
    
    self = .config(
      .Element.compute(
        usingConfig: modalConfig,
        usingContext: context
      )
    );
  };
};

extension AdaptiveModalInterpolationMode
  where T == [AdaptiveModalInterpolationStep] {

  mutating func computeInterpolationPoints(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    usingContext context: ComputableLayoutValueContext,
    snapPoints: [AdaptiveModalSnapPointConfig]? = nil
  ) {
    
    let oldCopy = self;
    let snapPoints = snapPoints ?? oldCopy.associatedValue.snapPoints;
    
    self.associatedValue = .Element.compute(
      usingConfig: modalConfig,
      usingContext: context,
      snapPoints: snapPoints
    );
  };
  
  func getMatchingItem(
    forInterpolationStepItem stepItem: AdaptiveModalInterpolationStepItem
  ) -> AdaptiveModalInterpolationStepItem? {
  
    guard self.memberName != stepItem.memberName else { return nil };
    
    let match = self.associatedValue.first {
      $0.snapPointIndex == stepItem.associatedValue.snapPointIndex;
    };
    
    guard let match = match else { return nil };
    return self.copy(newAssociatedValue: match);
  };
  
  func contains(
    interpolationStepItem stepItem: AdaptiveModalInterpolationStepItem
  ) -> Bool {
    
    let match = self.getMatchingItem(forInterpolationStepItem: stepItem);
    return match != nil;
  };
  
  func getMatchingItem(
    forIndex index: Int
  ) -> AdaptiveModalInterpolationStepItem? {
  
    let match = self.associatedValue[safeIndex: index];
    guard let match = match else { return nil };
    
    return self.copy(newAssociatedValue: match);
  };
  
  func getMatchingItem(
    forInterpolationPoint interpolationPoint: AdaptiveModalInterpolationPoint
  ) -> AdaptiveModalInterpolationStepItem? {
  
    let match = self.associatedValue.first {
         $0.interpolationPoint.key == interpolationPoint.key
      && $0.interpolationPoint.snapPointIndex == interpolationPoint.snapPointIndex;
    };
    
    guard let match = match else { return nil };
    return self.copy(newAssociatedValue: match);
  };
};

