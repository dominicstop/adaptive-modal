//
//  AdaptiveModalConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit

public struct AdaptiveModalConfig: Equatable {

  // MARK: - Types
  // -------------
  
  public enum Direction: Equatable {
    case vertical;
    case horizontal;
  };

  public enum SnapDirection: Equatable {
    case bottomToTop;
    case topToBottom;
    case leftToRight;
    case rightToLeft;
    
    public var direction: Direction {
      switch self {
        case .bottomToTop, .topToBottom: return .vertical;
        case .leftToRight, .rightToLeft: return .horizontal;
      };
    };
    
    public var isVertical: Bool {
      self.direction == .vertical;
    };
    
    public var isHorizontal: Bool {
      !self.isVertical;
    };
  };
  
  public enum SnapPercentStrategy: Equatable {
    case index;
    case position;
  };
  
  public enum DragHandlePosition: Equatable {
    case automatic, none;
    case top, bottom, left, right;
  };
  
  // MARK: - Properties - Config
  // ---------------------------
  
  public let baseSnapPoints: [AdaptiveModalSnapPointConfig];
  public let snapDirection: SnapDirection;
  
  public let snapPercentStrategy: SnapPercentStrategy;
  
  public let snapAnimationConfig: AdaptiveModalSnapAnimationConfig;
  public let interpolationClampingConfig: AdaptiveModalClampingConfig;
  
  public let undershootSnapPoint: AdaptiveModalSnapPointPreset;
  public let overshootSnapPoint: AdaptiveModalSnapPointPreset?;
  
  // the first snap point to snap to when the modal is first shown
  public let initialSnapPointIndex: Int;
  
  public let dragHandlePosition: DragHandlePosition;
  public let dragHandleHitSlop: CGPoint;
  
  public let modalSwipeGestureEdgeHeight: CGFloat;
  
  public let shouldSetModalScrollViewContentInsets: Bool;
  public let shouldSetModalScrollViewVerticalScrollIndicatorInsets: Bool;
  public let shouldSetModalScrollViewHorizontalScrollIndicatorInsets: Bool;
  
  // let entranceConfig: AdaptiveModalEntranceConfig;
  // let snapSwipeVelocityThreshold: CGFloat = 0;

  // MARK: - Computed Properties
  // ---------------------------
  
  public var snapPointLastIndex: Int {
    var count = 0;
    
    // undershoot snap point
    count += 1;
    
    // in-between snap points
    count += (self.baseSnapPoints.count - 1);
    
    // overshoot snap point
    if self.overshootSnapPoint != nil {
      count += 1;
    };
    
    return count;
  };
  
  public var snapPoints: [AdaptiveModalSnapPointConfig] {
    .Element.deriveSnapPoints(
      undershootSnapPoint: self.undershootSnapPoint,
      inBetweenSnapPoints: self.baseSnapPoints,
      overshootSnapPoint: self.overshootSnapPoint
    );
  };
  
  var didSetModalScrollViewContentInsets: Bool {
    self.snapPoints.allSatisfy {
      $0.keyframeConfig?.modalScrollViewContentInsets != nil;
    };
  };
  
  var didSetModalScrollViewVerticalScrollIndicatorInsets: Bool {
    self.snapPoints.allSatisfy {
      $0.keyframeConfig?.modalScrollViewVerticalScrollIndicatorInsets != nil;
    };
  };
  
  var didSetModalScrollViewHorizontalScrollIndicatorInsets: Bool {
    self.snapPoints.allSatisfy {
      $0.keyframeConfig?.modalScrollViewHorizontalScrollIndicatorInsets != nil;
    };
  };
  
  public var overshootSnapPointIndex: Int? {
    self.overshootSnapPoint != nil
      ? self.snapPoints.count - 1
      : nil;
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
  
  // MARK: - Init
  // ------------
  
  public init(
    snapPoints: [AdaptiveModalSnapPointConfig],
    snapDirection: SnapDirection,
    snapPercentStrategy: SnapPercentStrategy = .position,
    snapAnimationConfig: AdaptiveModalSnapAnimationConfig = .default,
    interpolationClampingConfig: AdaptiveModalClampingConfig = .default,
    initialSnapPointIndex: Int = 1,
    undershootSnapPoint: AdaptiveModalSnapPointPreset = .automatic,
    overshootSnapPoint: AdaptiveModalSnapPointPreset? = .automatic,
    dragHandlePosition: DragHandlePosition = .automatic,
    dragHandleHitSlop: CGPoint? = nil,
    dragHandleCornerRadius: CGFloat? = nil,
    modalSwipeGestureEdgeHeight: CGFloat? = nil,
    shouldSetModalScrollViewContentInsets: Bool = false,
    shouldSetModalScrollViewVerticalScrollIndicatorInsets: Bool = true,
    shouldSetModalScrollViewHorizontalScrollIndicatorInsets: Bool = true
  ) {
  
    self.baseSnapPoints = {
      var snapPointsNew = snapPoints;
    
      if let firstSnapPoint = snapPoints.first {
      
        var firstKeyframe = firstSnapPoint.keyframeConfig;
        firstKeyframe?.setNonNilValues(using: .defaultFirstKeyframe);
         
        snapPointsNew[0] = .init(
          fromBase: firstSnapPoint,
          newAnimationKeyframe: firstKeyframe ?? .defaultFirstKeyframe
        );
      };
      
      return snapPointsNew;
    }();
    
    self.snapDirection = snapDirection;
    self.snapPercentStrategy = snapPercentStrategy;
    
    self.snapAnimationConfig = snapAnimationConfig;
    self.interpolationClampingConfig = interpolationClampingConfig;
    
    self.initialSnapPointIndex = initialSnapPointIndex;
    
    self.undershootSnapPoint = {
      switch undershootSnapPoint.layoutPreset {
        case .automatic:
          return .getDefaultUnderShootSnapPoint(
            forDirection: snapDirection,
            keyframeConfig: undershootSnapPoint.keyframeConfig
          );
          
        default:
          return undershootSnapPoint;
      };
    }();
    
    self.overshootSnapPoint = {
      guard let overshootSnapPoint = overshootSnapPoint else { return nil };
    
      switch overshootSnapPoint.layoutPreset {
        case .automatic:
          return .getDefaultOvershootSnapPoint(
            forDirection: snapDirection,
            keyframeConfig: overshootSnapPoint.keyframeConfig
          );
        
        default:
          return overshootSnapPoint;
      };
    }();
      
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
    
    self.dragHandleHitSlop = dragHandleHitSlop ?? .init(x: 15, y: 15);
    
    self.modalSwipeGestureEdgeHeight = modalSwipeGestureEdgeHeight ?? 20;
    
    self.shouldSetModalScrollViewContentInsets =
      shouldSetModalScrollViewContentInsets;
    
    self.shouldSetModalScrollViewVerticalScrollIndicatorInsets =
      shouldSetModalScrollViewVerticalScrollIndicatorInsets;
      
    self.shouldSetModalScrollViewHorizontalScrollIndicatorInsets =
      shouldSetModalScrollViewHorizontalScrollIndicatorInsets;
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
