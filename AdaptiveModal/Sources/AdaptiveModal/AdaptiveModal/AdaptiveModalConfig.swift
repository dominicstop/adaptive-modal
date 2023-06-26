//
//  AdaptiveModalConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit

public struct AdaptiveModalConfig {

  // MARK: - Types
  // -------------

  public enum Direction {
    case bottomToTop;
    case topToBottom;
    case leftToRight;
    case rightToLeft;
    
    public var isVertical: Bool {
      switch self {
        case .bottomToTop, .topToBottom: return true;
        case .leftToRight, .rightToLeft: return false;
      };
    };
  };
  
  public enum SnapPercentStrategy {
    case index;
    case position;
  };
  
  public enum DragHandlePosition: Equatable {
    case automatic, none;
    case top, bottom, left, right;
  };
  
  // MARK: - Properties
  // ------------------
  
  public let baseSnapPoints: [AdaptiveModalSnapPointConfig];
  public let snapDirection: Direction;
  
  public let snapPercentStrategy: SnapPercentStrategy;
  
  public let snapAnimationConfig: AdaptiveModalSnapAnimationConfig;
  public let interpolationClampingConfig: AdaptiveModalClampingConfig;
  
  public let undershootSnapPoint: AdaptiveModalSnapPointPreset;
  public let overshootSnapPoint: AdaptiveModalSnapPointPreset;
  
  // the first snap point to snap to when the modal is first shown
  public let initialSnapPointIndex: Int;
  
  public let dragHandlePosition: DragHandlePosition;
  public let dragHandleSize: CGSize;
  public let dragHandleColor: UIColor;
  public let dragHandleOpacity: CGFloat;
  public let dragHandleOffset: CGFloat;
  public let dragHandleCornerRadius: CGFloat;
  
  // let entranceConfig: AdaptiveModalEntranceConfig;
  // let snapSwipeVelocityThreshold: CGFloat = 0;
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var snapPoints: [AdaptiveModalSnapPointConfig] {
    .Element.deriveSnapPoints(
      undershootSnapPoint: self.undershootSnapPoint,
      inBetweenSnapPoints: self.baseSnapPoints,
      overshootSnapPoint: self.overshootSnapPoint
    );
  };
  
  public var overshootSnapPointIndex: Int {
    self.snapPoints.count - 1;
  };
  
  /// Defines which axis of the gesture point to use to drive the interpolation
  /// of the modal snap points
  ///
  public var inputValueKeyForPoint: KeyPath<CGPoint, CGFloat> {
    switch self.snapDirection {
      case .topToBottom, .bottomToTop: return \.y;
      case .leftToRight, .rightToLeft: return \.x;
    };
  };
  
  public var inputValueKeyForRect: KeyPath<CGRect, CGFloat> {
    switch self.snapDirection {
      case .bottomToTop: return \.minY;
      case .topToBottom: return \.maxY;
      case .leftToRight: return \.maxX;
      case .rightToLeft: return \.minX;
    };
  };
  
  public var maxInputRangeKeyForRect: KeyPath<CGRect, CGFloat> {
    switch self.snapDirection {
      case .bottomToTop, .topToBottom: return \.height;
      case .leftToRight, .rightToLeft: return \.width;
    };
  };
  
  public var shouldInvertPercent: Bool {
    switch self.snapDirection {
      case .bottomToTop, .rightToLeft: return true;
      default: return false;
    };
  };
  
  public var secondarySwipeAxis: KeyPath<CGPoint, CGFloat> {
    switch self.snapDirection {
      case .bottomToTop, .topToBottom: return \.x;
      case .leftToRight, .rightToLeft: return \.y;
    };
  };
  
  public var dragHandleSizeAdj: CGSize {
    switch self.snapDirection {
      case .bottomToTop, .topToBottom:
        return self.dragHandleSize;
      
      case .leftToRight, .rightToLeft:
        return CGSize(
          width : self.dragHandleSize.height,
          height: self.dragHandleSize.width
        );
    };
  };
  
  // MARK: - Init
  // ------------
  
  public init(
    snapPoints: [AdaptiveModalSnapPointConfig],
    snapDirection: Direction,
    snapPercentStrategy: SnapPercentStrategy = .position,
    snapAnimationConfig: AdaptiveModalSnapAnimationConfig = .default,
    interpolationClampingConfig: AdaptiveModalClampingConfig = .default,
    initialSnapPointIndex: Int = 1,
    undershootSnapPoint: AdaptiveModalSnapPointPreset? = nil,
    overshootSnapPoint: AdaptiveModalSnapPointPreset? = nil,
    dragHandlePosition: DragHandlePosition = .automatic,
    dragHandleSize: CGSize? = nil,
    dragHandleColor: UIColor? = nil,
    dragHandleOpacity: CGFloat? = nil,
    dragHandleOffset: CGFloat? = nil,
    dragHandleCornerRadius: CGFloat? = nil
  ) {
    self.baseSnapPoints = snapPoints;
    
    self.snapDirection = snapDirection;
    self.snapPercentStrategy = snapPercentStrategy;
    
    self.snapAnimationConfig = snapAnimationConfig;
    self.interpolationClampingConfig = interpolationClampingConfig;
    
    self.initialSnapPointIndex = initialSnapPointIndex;
    
    self.undershootSnapPoint = undershootSnapPoint
      ?? .getDefaultUnderShootSnapPoint(forDirection: snapDirection);
    
    self.overshootSnapPoint = overshootSnapPoint
      ?? .getDefaultOvershootSnapPoint(forDirection: snapDirection);
      
    self.dragHandlePosition = {
      if dragHandlePosition != .automatic {
        return dragHandlePosition;
      };
      
      switch snapDirection {
        case .bottomToTop: return .top;
        case .topToBottom: return .bottom;
        case .leftToRight: return .right;
        case .rightToLeft: return .left;
      };
    }();
    
    self.dragHandleSize = dragHandleSize ?? CGSize(width: 40, height: 6);
    
    self.dragHandleColor   = dragHandleColor   ?? .systemGray;
    self.dragHandleOpacity = dragHandleOpacity ?? 0.8;
    self.dragHandleOffset  = dragHandleOffset  ?? 8;
    
    self.dragHandleCornerRadius = dragHandleCornerRadius ?? 3;
  };
  
  // MARK: - Functions
  // -----------------
  
  public func sortInterpolationSteps<T>(_ array: [T]) -> [T] {
    switch self.snapDirection {
      case .bottomToTop, .leftToRight:
        return array;
        
      case .topToBottom, .rightToLeft:
        return array.reversed();
    };
  };
};
