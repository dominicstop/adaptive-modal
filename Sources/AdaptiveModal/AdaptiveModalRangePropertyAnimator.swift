//
//  AdaptiveModalPropertyAnimator.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/31/23.
//

import UIKit
import DGSwiftUtilities

public struct AdaptiveModalRangePropertyAnimator {

  // MARK: - Properties
  // ------------------
  
  public var interpolationRangeStart: AdaptiveModalInterpolationPoint;
  public var interpolationRangeEnd: AdaptiveModalInterpolationPoint;
  
  public let interpolationOutputKey:
    KeyPath<AdaptiveModalInterpolationPoint, CGFloat>?;
  
  public var animator: UIViewPropertyAnimator;
  
  private weak var component: AnyObject?;
  
  private(set) var rangeInput : [CGFloat]!;
  private(set) var rangeOutput: [CGFloat]!;
  
  // MARK: - Init
  // ------------
  
  public init<T: UIView>(
    interpolationRangeStart: AdaptiveModalInterpolationPoint,
    interpolationRangeEnd: AdaptiveModalInterpolationPoint,
    forComponent component: T,
    interpolationOutputKey:
      KeyPath<AdaptiveModalInterpolationPoint, CGFloat>? = nil,
    animation: @escaping (
      _ component: T,
      _ interpolationPoint: AdaptiveModalInterpolationPoint
    ) -> Void
  ) {
    self.interpolationRangeStart = interpolationRangeStart;
    self.interpolationRangeEnd = interpolationRangeEnd;
    
    self.interpolationOutputKey = interpolationOutputKey;
    self.component = component;
    
    let animator = UIViewPropertyAnimator(
      duration: 0,
      curve: .linear
    );
    
    animator.addAnimations {
      animation(component, interpolationRangeEnd);
    };
    
    self.animator = animator;
    self.computeRanges();
  };
  
  // MARK: - Functions
  // -----------------
  
  private mutating func computeRanges(){
    let range = [
      self.interpolationRangeStart,
      self.interpolationRangeEnd
    ];
    
    self.rangeOutput = {
      if let interpolationOutputKey = self.interpolationOutputKey {
        return range.map {
          $0[keyPath: interpolationOutputKey]
        }
      };
      
      return [0, 1];
    }();
    
    self.rangeInput = range.map {
      $0.percent
    };
  };
  
  public func didRangeChange(
    interpolationRangeStart: AdaptiveModalInterpolationPoint,
    interpolationRangeEnd: AdaptiveModalInterpolationPoint
  ) -> Bool {
    let didChange =
      interpolationRangeStart != self.interpolationRangeStart ||
      interpolationRangeEnd   != self.interpolationRangeEnd;
  
    return didChange;
  };
  
  public mutating func update(
    interpolationRangeStart: AdaptiveModalInterpolationPoint,
    interpolationRangeEnd: AdaptiveModalInterpolationPoint
  ){
    self.interpolationRangeStart = interpolationRangeStart;
    self.interpolationRangeEnd = interpolationRangeEnd;
    
    self.computeRanges();
  };
  
  public func setFractionComplete(forPercent percent: CGFloat) {
    guard self.animator.fractionComplete != percent else { return };
    self.animator.fractionComplete = percent;
  };
  
  public func setFractionComplete(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
  
    let percent = InterpolationHelpers.interpolate(
      inputValue: inputPercentValue,
      rangeInput: self.rangeInput,
      rangeOutput: self.rangeOutput
    );
    
    guard let percent = percent else { return };
    self.setFractionComplete(forPercent: percent);
  };
  
  public func clear(){
    self.animator.stopAnimation(true);
  };
};
