//
//  AdaptiveModalConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit
import ComputableLayout


public struct AdaptiveModalConfig: Equatable {

  // MARK: - Types
  // -------------
  
  public enum Orientation: Equatable {
    case vertical;
    case horizontal;
  };

  public enum SnapDirection: Equatable {
    case bottomToTop;
    case topToBottom;
    case leftToRight;
    case rightToLeft;
    
    public var orientation: Orientation {
      switch self {
        case .bottomToTop, .topToBottom: return .vertical;
        case .leftToRight, .rightToLeft: return .horizontal;
      };
    };
    
    public var isVertical: Bool {
      self.orientation == .vertical;
    };
    
    public var isHorizontal: Bool {
      !self.isVertical;
    };
    
    /// Where the top and right is increasing
    public var isDirectionIncreasing: Bool {
      switch self {
        case .bottomToTop, .leftToRight: return true;
        case .topToBottom, .rightToLeft: return false;
      };
    };
    
    public func getDirection<T: Numeric & Comparable>(next: T, prev: T) -> Self {
      switch self.orientation {
        case .horizontal:
          return next > prev
            ? .leftToRight
            : .rightToLeft;
          
        case .vertical:
          return next > prev
            ? .topToBottom
            : .bottomToTop;
        };
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
  
  public var snapDirection: SnapDirection;
  
  public var snapPercentStrategy: SnapPercentStrategy = .position;
  
  public var snapAnimationConfig: AdaptiveModalSnapAnimationConfig = .default;
  public var entranceAnimationConfig: AdaptiveModalSnapAnimationConfig = .default;
  public var exitAnimationConfig: AdaptiveModalSnapAnimationConfig = .default;
  
  public var interpolationClampingConfig = AdaptiveModalClampingConfig();
  
  // the first snap point to snap to when the modal is first shown
  public var initialSnapPointIndex = 1;
  
  public var dragHandleHitSlop = CGPoint(x: 15, y: 15);
  
  public var modalSwipeGestureEdgeHeight: CGFloat = 20;
  
  public var shouldSetModalScrollViewContentInsets = false;
  public var shouldSetModalScrollViewVerticalScrollIndicatorInsets = true;
  public var shouldSetModalScrollViewHorizontalScrollIndicatorInsets = true;
  
  // MARK: - Properties - Raw Config
  // -------------------------------
  
  public var baseUndershootSnapPoint: AdaptiveModalSnapPointPreset = .automatic;
  public var baseOvershootSnapPoint: AdaptiveModalSnapPointPreset?;
  
  public var baseSnapPoints: [AdaptiveModalSnapPointConfig];
  
  public var baseDragHandlePosition: DragHandlePosition = .automatic;
  
  // MARK: - Computed Properties - Derived Config
  // --------------------------------------------
  
  public var undershootSnapPoint: AdaptiveModalSnapPointPreset {
    let undershootSnapPoint = self.baseUndershootSnapPoint;
    
    switch undershootSnapPoint.layoutPreset {
      case .automatic:
        return .getDefaultUnderShootSnapPoint(
          forDirection: snapDirection,
          keyframeConfig: undershootSnapPoint.keyframeConfig
        );
        
      default:
        return undershootSnapPoint;
    };
  };
  
  public var overshootSnapPoint: AdaptiveModalSnapPointPreset? {
    guard let overshootSnapPoint = self.baseOvershootSnapPoint
    else { return nil };
    
    switch overshootSnapPoint.layoutPreset {
      case .automatic:
        return .getDefaultOvershootSnapPoint(
          forDirection: snapDirection,
          keyframeConfig: overshootSnapPoint.keyframeConfig
        );
      
      default:
        return overshootSnapPoint;
    };
  };
  
  public var snapPoints: [AdaptiveModalSnapPointConfig] {
    .Element.deriveSnapPoints(
      undershootSnapPoint: self.undershootSnapPoint,
      inBetweenSnapPoints: self.baseSnapPoints,
      overshootSnapPoint: self.overshootSnapPoint
    );
  };
  
  public var dragHandlePosition: DragHandlePosition {
    let dragHandlePosition = self.baseDragHandlePosition;
    
    if dragHandlePosition != .automatic {
      return dragHandlePosition;
    };
    
    switch self.snapDirection {
      case .bottomToTop: return .top;
      case .topToBottom: return .bottom;
      case .leftToRight: return .right;
      case .rightToLeft: return .left;
    };
  };
  
  // MARK: - Computed Properties - Public
  // ------------------------------------
  
  public var overshootSnapPointIndex: Int? {
    self.overshootSnapPoint != nil
      ? self.snapPoints.count - 1
      : nil;
  };
  
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
  
  // MARK: - Computed Properties
  // ---------------------------
  
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
  
  /// Defines which axis of the gesture point to use to drive the interpolation
  /// of the modal snap points
  ///
  var inputValueKeyForPoint: KeyPath<CGPoint, CGFloat> {
    switch self.snapDirection {
      case .topToBottom, .bottomToTop: return \.y;
      case .leftToRight, .rightToLeft: return \.x;
    };
  };
  
  var inputValueKeyForRect: KeyPath<CGRect, CGFloat> {
    switch self.snapDirection {
      case .bottomToTop: return \.minY;
      case .topToBottom: return \.maxY;
      case .leftToRight: return \.maxX;
      case .rightToLeft: return \.minX;
    };
  };
  
  var maxInputRangeKeyForRect: KeyPath<CGRect, CGFloat> {
    switch self.snapDirection {
      case .bottomToTop, .topToBottom: return \.height;
      case .leftToRight, .rightToLeft: return \.width;
    };
  };
  
  var shouldInvertPercent: Bool {
    switch self.snapDirection {
      case .bottomToTop, .rightToLeft: return true;
      default: return false;
    };
  };
  
  var secondarySwipeAxis: KeyPath<CGPoint, CGFloat> {
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
    snapPercentStrategy: SnapPercentStrategy? = nil,
    snapAnimationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    entranceAnimationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    exitAnimationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    interpolationClampingConfig: AdaptiveModalClampingConfig? = nil,
    initialSnapPointIndex: Int? = nil,
    undershootSnapPoint: AdaptiveModalSnapPointPreset? = nil,
    overshootSnapPoint: AdaptiveModalSnapPointPreset? = nil,
    dragHandlePosition: DragHandlePosition = .automatic,
    dragHandleHitSlop: CGPoint? = nil,
    modalSwipeGestureEdgeHeight: CGFloat? = nil,
    shouldSetModalScrollViewContentInsets: Bool? = nil,
    shouldSetModalScrollViewVerticalScrollIndicatorInsets: Bool? = nil,
    shouldSetModalScrollViewHorizontalScrollIndicatorInsets: Bool? = nil
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
    
    if let snapPercentStrategy = snapPercentStrategy {
      self.snapPercentStrategy = snapPercentStrategy;
    };
    
    if let snapAnimationConfig = snapAnimationConfig {
      self.snapAnimationConfig = snapAnimationConfig;
    };
    
    if let entranceAnimationConfig = entranceAnimationConfig {
      self.entranceAnimationConfig = entranceAnimationConfig;
    };
    
    if let exitAnimationConfig = exitAnimationConfig {
      self.exitAnimationConfig = exitAnimationConfig;
    };
    
    if let interpolationClampingConfig = interpolationClampingConfig {
      self.interpolationClampingConfig = interpolationClampingConfig;
    };
    
    if let initialSnapPointIndex = initialSnapPointIndex {
      self.initialSnapPointIndex = initialSnapPointIndex;
    };
    
    if let undershootSnapPoint = undershootSnapPoint {
      self.baseUndershootSnapPoint = undershootSnapPoint;
    };
    
    if let overshootSnapPoint = overshootSnapPoint {
      self.baseOvershootSnapPoint = overshootSnapPoint;
    };
    
    self.baseDragHandlePosition = dragHandlePosition
      
    if let dragHandleHitSlop = dragHandleHitSlop {
      self.dragHandleHitSlop = dragHandleHitSlop;
    };
    
    if let modalSwipeGestureEdgeHeight = modalSwipeGestureEdgeHeight {
      self.modalSwipeGestureEdgeHeight = modalSwipeGestureEdgeHeight;
    };
    
    if let flag = shouldSetModalScrollViewContentInsets {
      self.shouldSetModalScrollViewContentInsets = flag;
    };
    
    if let flag = shouldSetModalScrollViewVerticalScrollIndicatorInsets {
      self.shouldSetModalScrollViewVerticalScrollIndicatorInsets = flag;
    };
    
    if let flag = shouldSetModalScrollViewHorizontalScrollIndicatorInsets {
      self.shouldSetModalScrollViewHorizontalScrollIndicatorInsets = flag;
    };
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
