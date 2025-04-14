//
//  BaseConcreteKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic on 4/9/25.
//

import UIKit
import DGSwiftUtilities


public protocol BaseConcreteKeyframe<PartialKeyframe>: CompositeInterpolatable {
  
  associatedtype PartialKeyframe: BasePartialKeyframe;
  
  static var `default`: Self { get };
  
  typealias KeyframePropertyMap = Dictionary<
    AnyWritableKeyPath<PartialKeyframe>,
    AnyWritableKeyPath<Self>
  >;
  
  static var partialToConcreteKeyframePropertyMap: KeyframePropertyMap { get };
};

// MARK: - BaseConcreteKeyframe+interpolatablePropertiesMap
// ------------------------------------

public extension BaseConcreteKeyframe where InterpolatableValue == Self {
  
  static var interpolatablePropertiesMap: InterpolatableValuesMap {
    Self.partialToConcreteKeyframePropertyMap.reduce(into: [:]) {
      let concreteKeyframeKeyPath = $1.value.partialKeyPath;
      
      guard let uniformInterpolatableType =
              concreteKeyframeKeyPath.rootTypeAsType as? any UniformInterpolatable.Type
      else {
        #if DEBUG
        print(
          "BaseConcreteKeyframe.interpolatablePropertiesMap",
          "\n - Error: Could not find uniform interpolatable type for keypath: \(concreteKeyframeKeyPath)",
          "\n - Total keyframes to map: \(Self.partialToConcreteKeyframePropertyMap.count)",
          "\n - Current map element count: \($0.count)",
          "\n - Note: Make sure that the concrete keyframe conforms to `UniformInterpolatable"
        );
        #endif
        return;
      };
      
      $0[concreteKeyframeKeyPath] = uniformInterpolatableType;
    }
  };
  
  init() {
    self = .default;
  }
};

// MARK: - BaseConcreteKeyframe+Helpers
// ------------------------------------

public extension BaseConcreteKeyframe {
  
  // MARK: - Computed Properties
  // ---------------------------
  
  var asPartialKeyframe: PartialKeyframe {
    var partialKeyframe: PartialKeyframe = .empty;
    self.apply(toPartialKeyframe: &partialKeyframe);
    return partialKeyframe;
  };
  
  // MARK: - Init
  // ------------
  
  init(
    from partialKeyframe: PartialKeyframe,
    fallbackKeyframe: Self = .default
  ){
    var concreteKeyframe: Self = .default;
    concreteKeyframe.apply(
      sourcePartialKeyframe: partialKeyframe,
      fallbackKeyframe: fallbackKeyframe
    );
    
    self = concreteKeyframe;
  };
  
  // MARK: - Functions
  // -----------------
  
  func apply(toPartialKeyframe partialKeyframe: inout PartialKeyframe){
    Self.partialToConcreteKeyframePropertyMap.forEach {
      let (partialKeyframePath, concreteKeyframePath) = $0;
      
      let newValue = self[keyPath: concreteKeyframePath.partialKeyPath];
      try? partialKeyframePath.setValue(
        target: &partialKeyframe,
        withValue: newValue
      );
    };
  };
  
  mutating func apply(
    sourcePartialKeyframe partialKeyframe: PartialKeyframe,
    fallbackKeyframe: Self = .default
  ) {
    Self.partialToConcreteKeyframePropertyMap.forEach {
      let (partialKeyframePath, concreteKeyframePath) = $0;
      
      let newValue = partialKeyframe[keyPath: partialKeyframePath.partialKeyPath];
      try? concreteKeyframePath.setValue(
        target: &self,
        withValue: newValue
      );
    };
  };
};
