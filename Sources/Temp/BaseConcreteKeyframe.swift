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
    PartialKeyPath<PartialKeyframe>,
    PartialKeyPath<Self>
  >;
  
  static var partialToConcreteKeyframePropertyMap: KeyframePropertyMap { get };
};

// MARK: - BaseConcreteKeyframe+interpolatablePropertiesMap
// ------------------------------------

public extension BaseConcreteKeyframe where InterpolatableValue == Self {
  
  static var interpolatablePropertiesMap: InterpolatableValuesMap {
    Self.partialToConcreteKeyframePropertyMap.reduce(into: [:]) {
      let concreteKeyframeKeyPath = $1.value;
      
      guard let uniformInterpolatableType = concreteKeyframeKeyPath.rootTypeAsType as? any UniformInterpolatable.Type else {
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
  
  typealias PartialKeyframeKeyPath<T> = WritableKeyPath<PartialKeyframe, T>;
  
  typealias ConcreteKeyframeKeypath<T> = WritableKeyPath<Self, T>;
  private typealias KeyframePairedApplyBlock = (
    applyToPartialKeyframeBlock: (
      _ target: inout PartialKeyframe,
      _ source: Self
    ) -> Void,
    applyToConcreteKeyframeBlock: (
      _ target: inout Self,
      _ source: PartialKeyframe,
      _ fallback: Self
    ) -> Void
  );
  
  // weird workaround for fully generic keyframes
  // keypaths with generics must be resolved to an actual type
  //
  private static func createPropertySetterBlocks() -> [KeyframePairedApplyBlock] {
    var pairedApplyBlocks: [KeyframePairedApplyBlock] = [];
    
    Self.partialToConcreteKeyframePropertyMap.forEach {
      switch ($0, $1) {
        case (
          let partialKeyframeKeyPath as PartialKeyframeKeyPath<CGFloat?>,
          let concreteKeyframeKeyPath as ConcreteKeyframeKeypath<CGFloat>
        ):
          pairedApplyBlocks.append((
            {
              $0[keyPath: partialKeyframeKeyPath] = $1[keyPath: concreteKeyframeKeyPath];
            },
            {
              $0[keyPath: concreteKeyframeKeyPath] =
                   $1[keyPath: partialKeyframeKeyPath]
                ?? $2[keyPath: concreteKeyframeKeyPath];
            }
          ));
        
        case (
          let partialKeyframeKeyPath as PartialKeyframeKeyPath<Double?>,
          let concreteKeyframeKeyPath as ConcreteKeyframeKeypath<Double>
        ):
          pairedApplyBlocks.append((
            {
              $0[keyPath: partialKeyframeKeyPath] = $1[keyPath: concreteKeyframeKeyPath];
            },
            {
              $0[keyPath: concreteKeyframeKeyPath] =
                   $1[keyPath: partialKeyframeKeyPath]
                ?? $2[keyPath: concreteKeyframeKeyPath];
            }
          ));
        
        default:
          break;
      };
    };
    
    return pairedApplyBlocks;
  };
  
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
    let applyBlocks = Self.createPropertySetterBlocks();
    
    applyBlocks.forEach {
      $0.applyToPartialKeyframeBlock(&partialKeyframe, self);
    };
  };
  
  mutating func apply(
    sourcePartialKeyframe partialKeyframe: PartialKeyframe,
    fallbackKeyframe: Self = .default
  ) {
    let applyBlocks = Self.createPropertySetterBlocks();
    
    applyBlocks.forEach {
      $0.applyToConcreteKeyframeBlock(&self, partialKeyframe, fallbackKeyframe);
    };
  };
};
