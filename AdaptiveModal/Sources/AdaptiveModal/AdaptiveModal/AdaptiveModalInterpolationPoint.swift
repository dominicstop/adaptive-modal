//
//  AdaptiveModalInterpolationPoint.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/29/23.
//

import UIKit

public struct AdaptiveModalInterpolationPoint: Equatable {

  public typealias BackgroundInteractionMode =
    AdaptiveModalKeyframeConfig.BackgroundInteractionMode;
    
  static let defaultModalBackground: UIColor = {
    if #available(iOS 13.0, *) {
      return .systemBackground
    };
    
    return .white;
  }();
  
  // MARK: - Properties - Config
  // ---------------------------
  
  public var key: AdaptiveModalSnapPointConfig.SnapPointKey;
  public var percent: CGFloat;
  public var snapPointIndex: Int;

  public var computedRect: CGRect;
  public var modalPadding: UIEdgeInsets;
  
  public var backgroundTapInteraction: BackgroundInteractionMode;
  public var secondaryGestureAxisDampingPercent: CGFloat;
  
  public var modalScrollViewContentInsets: UIEdgeInsets;
  public var modalScrollViewVerticalScrollIndicatorInsets: UIEdgeInsets;
  public var modalScrollViewHorizontalScrollIndicatorInsets: UIEdgeInsets;
  
  // MARK: - Properties - Keyframes
  // ------------------------------
  
  public var modalTransform: Transform3D;
  
  public var modalBorderWidth: CGFloat;
  public var modalBorderColor: UIColor;
  
  public var modalShadowColor: UIColor;
  public var modalShadowOffset: CGSize;
  public var modalShadowOpacity: CGFloat;
  public var modalShadowRadius: CGFloat;
  
  public var modalCornerRadius: CGFloat;
  public var modalMaskedCorners: CACornerMask;
  
  public var modalOpacity: CGFloat;
  public var modalContentOpacity: CGFloat;
  public var modalBackgroundColor: UIColor;
  public var modalBackgroundOpacity: CGFloat;
  
  public var modalBackgroundVisualEffect: UIVisualEffect?;
  public var modalBackgroundVisualEffectOpacity: CGFloat;
  public var modalBackgroundVisualEffectIntensity: CGFloat;
  public var modalDragHandleCornerRadius: CGFloat;
  
  public var modalDragHandleSize: CGSize;
  public var modalDragHandleOffset: CGFloat;
  public var modalDragHandleColor: UIColor;
  public var modalDragHandleOpacity: CGFloat;
  
  public var backgroundColor: UIColor;
  public var backgroundOpacity: CGFloat;
  
  public var backgroundVisualEffect: UIVisualEffect?;
  public var backgroundVisualEffectOpacity: CGFloat;
  public var backgroundVisualEffectIntensity: CGFloat;
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var modalPaddingAdjusted: UIEdgeInsets {
    .init(
      top   :  self.modalPadding.top,
      left  :  self.modalPadding.left,
      bottom: -self.modalPadding.bottom,
      right : -self.modalPadding.right
    );
  };
  
  public var isBgVisualEffectSeeThrough: Bool {
       self.backgroundVisualEffect == nil
    || self.backgroundVisualEffectOpacity == 0
    || self.backgroundVisualEffectIntensity == 0;
  };
  
  public var isBgDimmingViewSeeThrough: Bool {
       self.backgroundColor == .clear
    || self.backgroundColor.rgba.a == 0
    || self.backgroundOpacity == 0;
  };
  
  public var isBgSeeThrough: Bool {
       self.isBgVisualEffectSeeThrough
    && self.isBgDimmingViewSeeThrough;
  };
  
  public var derivedBackgroundTapInteraction: BackgroundInteractionMode {
    switch self.backgroundTapInteraction {
      case .automatic:
        return self.isBgSeeThrough ? .passthrough : .ignore;
        
      default:
        return self.backgroundTapInteraction;
    };
  };
  
  // MARK: - Functions
  // -----------------
  
  func applyAnimation(
    toModalManager modalManager: AdaptiveModalManager
  ){
    let modalConfig = modalManager.currentModalConfig;
    
    if let modalView = modalManager.modalView {
      modalView.alpha = self.modalContentOpacity;
    };
    
    if let modalWrapperLayoutView = modalManager.modalWrapperLayoutView {
      if modalWrapperLayoutView.frame != self.computedRect {
        modalWrapperLayoutView.frame = self.computedRect;
        
        modalWrapperLayoutView.setNeedsLayout();
      };
      
      modalWrapperLayoutView.alpha = self.modalOpacity;
    };
    
    if let modalWrapperTransformView = modalManager.modalWrapperTransformView {
      modalWrapperTransformView.layer.transform = self.modalTransform.transform;
    };
    
    if let modalWrapperShadowView = modalManager.modalWrapperShadowView {
      // border
      modalWrapperShadowView.layer.borderWidth = self.modalBorderWidth;
      modalWrapperShadowView.layer.borderColor = self.modalBorderColor.cgColor;

      // shadow
      modalWrapperShadowView.layer.shadowColor = self.modalShadowColor.cgColor;
      modalWrapperShadowView.layer.shadowOffset = self.modalShadowOffset;
      modalWrapperShadowView.layer.shadowOpacity = Float(self.modalShadowOpacity);
      modalWrapperShadowView.layer.shadowRadius = self.modalShadowRadius;
    };
    
    if let modalContentWrapperView = modalManager.modalContentWrapperView {
      modalContentWrapperView.layer.cornerRadius = self.modalCornerRadius;
      modalContentWrapperView.layer.maskedCorners = self.modalMaskedCorners;
    };
    
    if let dummyModalView = modalManager.dummyModalView {
      dummyModalView.frame = self.computedRect;
    };
    
    if let modalBgView = modalManager.modalBackgroundView {
      modalBgView.alpha = self.modalBackgroundOpacity;
      modalBgView.backgroundColor = self.modalBackgroundColor;
    };
    
    if let bgView = modalManager.backgroundDimmingView {
      bgView.alpha = self.backgroundOpacity;
      bgView.backgroundColor = self.backgroundColor;
    };
    
    if let modalBgEffectView = modalManager.modalBackgroundVisualEffectView {
      modalBgEffectView.alpha = self.modalBackgroundVisualEffectOpacity;
    };
    
    if let bgVisualEffectView = modalManager.backgroundVisualEffectView {
      bgVisualEffectView.alpha = self.backgroundVisualEffectOpacity;
    };
    
    var shouldUpdateConstraints = false;
    
    if let constraintLeft = modalManager.modalConstraintLeft,
       constraintLeft.constant != self.modalPaddingAdjusted.left {
      
      constraintLeft.constant = self.modalPaddingAdjusted.left;
      shouldUpdateConstraints = true;
    };
    
    if let constraintRight = modalManager.modalConstraintRight,
       constraintRight.constant != self.modalPaddingAdjusted.right {
      
      constraintRight.constant = self.modalPaddingAdjusted.right;
      shouldUpdateConstraints = true;
    };
    
    if let constraintTop = modalManager.modalConstraintTop,
       constraintTop.constant != self.modalPaddingAdjusted.top {
      
      constraintTop.constant = self.modalPaddingAdjusted.top;
      shouldUpdateConstraints = true;
    };
    
    if let constraintBottom = modalManager.modalConstraintBottom,
       constraintBottom.constant != self.modalPaddingAdjusted.bottom {
      
      constraintBottom.constant = self.modalPaddingAdjusted.bottom;
      shouldUpdateConstraints = true;
    };
    
    if shouldUpdateConstraints,
       let modalView = modalManager.modalView {
       
      modalView.updateConstraints();
      modalView.setNeedsLayout();
    };
    
    block:
    if let modalDragHandleView = modalManager.modalDragHandleView {
    
      modalDragHandleView.backgroundColor = self.modalDragHandleColor;
      modalDragHandleView.alpha = self.modalDragHandleOpacity;
      modalDragHandleView.layer.cornerRadius = self.modalDragHandleCornerRadius;
      
      var didUpdateConstraints = false;
      
      if let constraintOffset = modalManager.modalDragHandleConstraintOffset,
         constraintOffset.constant != self.modalDragHandleOffset {
         
        constraintOffset.constant = self.modalDragHandleOffset;
        didUpdateConstraints = true;
      };
      
      if let constraintWidth = modalManager.modalDragHandleConstraintWidth,
         constraintWidth.constant != self.modalDragHandleSize.width {
         
        constraintWidth.constant = self.modalDragHandleSize.width;
        didUpdateConstraints = true;
      };
      
      if let constraintHeight = modalManager.modalDragHandleConstraintHeight,
         constraintHeight.constant != self.modalDragHandleSize.height {
         
        constraintHeight.constant = self.modalDragHandleSize.height;
        didUpdateConstraints = true;
      };
      
      guard didUpdateConstraints else { break block };
      
      modalDragHandleView.updateConstraints()
      modalDragHandleView.setNeedsLayout();
    };
    
    block:
    if let modalContentScrollView = modalManager.modalContentScrollView {
      if modalConfig.shouldSetModalScrollViewContentInsets {
        modalContentScrollView.contentInset = self.modalScrollViewContentInsets;
        modalContentScrollView.adjustedContentInsetDidChange();
      };
      
      guard #available(iOS 11.1, *) else { break block };
      
      if modalConfig.shouldSetModalScrollViewVerticalScrollIndicatorInsets {
        modalContentScrollView.verticalScrollIndicatorInsets =
          self.modalScrollViewVerticalScrollIndicatorInsets;
      };
      
      if modalConfig.shouldSetModalScrollViewHorizontalScrollIndicatorInsets {
        modalContentScrollView.horizontalScrollIndicatorInsets =
          self.modalScrollViewHorizontalScrollIndicatorInsets;
      };
    };
    
    modalManager.modalWrapperLayoutView?.layoutIfNeeded();
    modalManager.modalDragHandleView?.layoutIfNeeded();
  };
  
  func applyAnimation(
    toModalBackgroundEffectView modalBgEffectView: UIVisualEffectView?,
    toBackgroundVisualEffectView bgVisualEffectView: UIVisualEffectView?
  ){
    modalBgEffectView?.effect = self.modalBackgroundVisualEffect;
    bgVisualEffectView?.effect = self.backgroundVisualEffect;
  };
  
  func applyConfig(toModalManager modalManager: AdaptiveModalManager){
    let bgTapInteraction = self.derivedBackgroundTapInteraction;
    let shouldAllowUserInteraction = !bgTapInteraction.isPassThrough;
  
    if let bgVisualEffectView = modalManager.backgroundVisualEffectView {
      bgVisualEffectView.isUserInteractionEnabled = shouldAllowUserInteraction;
    };
    
    if let bgDimmingView = modalManager.backgroundDimmingView {
      bgDimmingView.isUserInteractionEnabled = shouldAllowUserInteraction;
    };
    
    if let bgTapGesture = modalManager.backgroundTapGesture {
      bgTapGesture.isEnabled = shouldAllowUserInteraction;
    };
  };
};

// MARK: - Init
// ------------

public extension AdaptiveModalInterpolationPoint {

  init(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    snapPointIndex: Int,
    percent: CGFloat? = nil,
    layoutValueContext baseContext: RNILayoutValueContext,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint keyframePrev: Self? = nil
  ) {
    self.key = snapPointConfig.key;
    self.snapPointIndex = snapPointIndex;
    
    let computedRect = snapPointConfig.layoutConfig.computeRect(
      usingLayoutValueContext: baseContext
    );
    
    let context = RNILayoutValueContext(
      derivedFrom: baseContext,
      currentSize: computedRect.size
    );
    
    self.computedRect = computedRect;
    
    self.modalPadding = snapPointConfig.layoutConfig.computePadding(
      usingLayoutValueContext: context
    );
    
    self.percent = percent ?? {
      switch modalConfig.snapPercentStrategy {
        case .position:
          let maxRangeInput =
            context.targetRect[keyPath: modalConfig.maxInputRangeKeyForRect];
          
          let inputValue =
            computedRect[keyPath: modalConfig.inputValueKeyForRect];
            
          let percent = inputValue / maxRangeInput;
          
          return modalConfig.shouldInvertPercent
            ? AdaptiveModalUtilities.invertPercent(percent)
            : percent;
            
        case .index:
          let current = CGFloat(snapPointIndex + 1);
          let max = CGFloat(modalConfig.snapPoints.count);
          
          return current / max;
      };
    }();
    
    let isFirstSnapPoint = snapPointIndex == 0;
    let keyframeCurrent = snapPointConfig.keyframeConfig;
    
    self.backgroundTapInteraction = keyframeCurrent?.backgroundTapInteraction
      ?? keyframePrev?.backgroundTapInteraction
      ?? .default;
    
    self.secondaryGestureAxisDampingPercent = keyframeCurrent?.secondaryGestureAxisDampingPercent
      ?? keyframePrev?.secondaryGestureAxisDampingPercent
      ?? 1;
      
    self.modalTransform = {
      let prevTransform = keyframePrev?.modalTransform ?? .init();
    
      guard var nextTransform = keyframeCurrent?.modalTransform else {
        return prevTransform;
      };
      
      nextTransform.setNonNilValues(with: prevTransform);
      return nextTransform;
    }();
      
    self.modalBorderWidth = keyframeCurrent?.modalBorderWidth
      ?? keyframePrev?.modalBorderWidth
      ?? 0;
    
    self.modalBorderColor = keyframeCurrent?.modalBorderColor
      ?? keyframePrev?.modalBorderColor
      ?? .black;
    
    self.modalShadowColor = keyframeCurrent?.modalShadowColor
      ?? keyframePrev?.modalShadowColor
      ?? .black;
    
    self.modalShadowOffset = keyframeCurrent?.modalShadowOffset
      ?? keyframePrev?.modalShadowOffset
      ?? .zero;
    
    self.modalShadowOpacity = keyframeCurrent?.modalShadowOpacity
      ?? keyframePrev?.modalShadowOpacity
      ?? 0;
    
    self.modalShadowRadius = keyframeCurrent?.modalShadowRadius
      ?? keyframePrev?.modalShadowRadius
      ?? 0;
    
    let modalCornerRadius = keyframeCurrent?.modalCornerRadius
      ?? keyframePrev?.modalCornerRadius
      ?? 0;
      
    self.modalCornerRadius = modalCornerRadius;
      
    let modalMaskedCorners = keyframeCurrent?.modalMaskedCorners
      ?? keyframePrev?.modalMaskedCorners
      ?? .allCorners;
      
    self.modalMaskedCorners = modalMaskedCorners;
      
    self.modalOpacity = keyframeCurrent?.modalOpacity
      ?? keyframePrev?.modalOpacity
      ?? 1;
      
    self.modalContentOpacity = keyframeCurrent?.modalContentOpacity
      ?? keyframePrev?.modalContentOpacity
      ?? 1;
      
    self.modalBackgroundColor = keyframeCurrent?.modalBackgroundColor
      ?? keyframePrev?.modalBackgroundColor
      ?? Self.defaultModalBackground;
      
    self.modalBackgroundOpacity = keyframeCurrent?.modalBackgroundOpacity
      ?? keyframePrev?.modalBackgroundOpacity
      ?? 1;
      
    self.modalBackgroundVisualEffect = keyframeCurrent?.modalBackgroundVisualEffect
      ?? keyframePrev?.modalBackgroundVisualEffect;
      
    self.modalBackgroundVisualEffectOpacity = keyframeCurrent?.modalBackgroundVisualEffectOpacity
      ?? keyframePrev?.modalBackgroundVisualEffectOpacity
      ?? 1;
      
    self.modalBackgroundVisualEffectIntensity = keyframeCurrent?.modalBackgroundVisualEffectIntensity
      ?? keyframePrev?.modalBackgroundVisualEffectIntensity
      ?? (isFirstSnapPoint ? 0 : 1);
      
    self.modalDragHandleSize = {
      let currentSizeRaw = keyframeCurrent?.modalDragHandleSize;
      
      if currentSizeRaw == nil,
         let modalDragHandleSize = keyframePrev?.modalDragHandleSize {
         
        return modalDragHandleSize;
      };
      
      let nextSize = currentSizeRaw ?? CGSize(width: 40, height: 6);
      
      switch modalConfig.snapDirection {
        case .bottomToTop, .topToBottom:
          return nextSize;
        
        case .leftToRight, .rightToLeft:
          return CGSize(
            width : nextSize.height,
            height: nextSize.width
          );
      };
    }();
      
    self.modalDragHandleOffset = {
      let currentOffsetRaw = keyframeCurrent?.modalDragHandleOffset;
    
      if currentOffsetRaw == nil,
         let modalDragHandleOffset = keyframePrev?.modalDragHandleOffset {
         
        return modalDragHandleOffset;
      };
      
      let nextOffset = currentOffsetRaw ?? 8;
      
      switch modalConfig.dragHandlePosition {
        case .top, .left:
          return nextOffset;
          
        case .bottom, .right:
          return -nextOffset;
          
        default:
          return 0;
      };
    }();
      
    self.modalDragHandleColor = keyframeCurrent?.modalDragHandleColor
      ?? keyframePrev?.modalDragHandleColor
      ?? .systemGray;
      
    self.modalDragHandleOpacity = keyframeCurrent?.modalDragHandleOpacity
      ?? keyframePrev?.modalDragHandleOpacity
      ?? 0.8;
      
    self.modalDragHandleCornerRadius = keyframeCurrent?.modalDragHandleCornerRadius
      ?? keyframePrev?.modalDragHandleCornerRadius
      ?? 3;
      
    self.backgroundColor = keyframeCurrent?.backgroundColor
      ?? keyframePrev?.backgroundColor
      ?? .black;
      
    self.backgroundOpacity = keyframeCurrent?.backgroundOpacity
      ?? keyframePrev?.backgroundOpacity
      ?? 0;
      
    self.backgroundVisualEffect = keyframeCurrent?.backgroundVisualEffect
      ?? keyframePrev?.backgroundVisualEffect;
      
    self.backgroundVisualEffectOpacity = keyframeCurrent?.backgroundVisualEffectOpacity
      ?? keyframePrev?.backgroundVisualEffectOpacity
      ?? 1;
      
    self.backgroundVisualEffectIntensity = keyframeCurrent?.backgroundVisualEffectIntensity
      ?? keyframePrev?.backgroundVisualEffectIntensity
      ?? (isFirstSnapPoint ? 0 : 1);
      
    self.modalScrollViewContentInsets = {
      if let insets = keyframeCurrent?.modalScrollViewContentInsets {
        return insets.compute(usingLayoutValueContext: context);
      };
      
      if let insets = keyframePrev?.modalScrollViewContentInsets {
        return insets;
      };
      
      return UIEdgeInsets(
        top   : modalMaskedCorners.isMaskingTopCorners    ? modalCornerRadius : 0,
        left  : modalMaskedCorners.isMaskingLeftCorners   ? modalCornerRadius : 0,
        bottom: modalMaskedCorners.isMaskingBottomCorners ? modalCornerRadius : 0,
        right : modalMaskedCorners.isMaskingRightCorners  ? modalCornerRadius : 0
      );
    }();
    
    self.modalScrollViewVerticalScrollIndicatorInsets = {
      let didSetModalScrollViewVerticalScrollIndicatorInsets =
        modalConfig.didSetModalScrollViewVerticalScrollIndicatorInsets;
      
      if didSetModalScrollViewVerticalScrollIndicatorInsets,
         let insets = keyframeCurrent?.modalScrollViewVerticalScrollIndicatorInsets {
         
        return insets.compute(usingLayoutValueContext: context);
      };
      
      if didSetModalScrollViewVerticalScrollIndicatorInsets,
         let insets = keyframePrev?.modalScrollViewVerticalScrollIndicatorInsets {
         
        return insets;
      };
      
      if modalConfig.snapDirection.isVertical {
        return UIEdgeInsets(
          top   : modalMaskedCorners.isMaskingTopCorners    ? modalCornerRadius : 0,
          left  : 0,
          bottom: modalMaskedCorners.isMaskingBottomCorners ? modalCornerRadius : 0,
          right : 0
        );
      };
      
      return .zero;
    }();
    
    self.modalScrollViewHorizontalScrollIndicatorInsets = {
      let didSetModalScrollViewHorizontalScrollIndicatorInsets =
        modalConfig.didSetModalScrollViewHorizontalScrollIndicatorInsets;
      
      if didSetModalScrollViewHorizontalScrollIndicatorInsets,
         let insets = keyframeCurrent?.modalScrollViewVerticalScrollIndicatorInsets {
         
        return insets.compute(usingLayoutValueContext: context);
      };
      
      if didSetModalScrollViewHorizontalScrollIndicatorInsets,
         let insets = keyframePrev?.modalScrollViewVerticalScrollIndicatorInsets {
         
        return insets;
      };
      
      if modalConfig.snapDirection.isHorizontal {
        return UIEdgeInsets(
          top   : 0,
          left  : modalMaskedCorners.isMaskingLeftCorners  ? modalCornerRadius : 0,
          bottom: 0,
          right : modalMaskedCorners.isMaskingRightCorners ? modalCornerRadius : 0
        );
      };
      
      return .zero;
    }();
  };
};

// MARK: - Helpers
// ---------------

public extension AdaptiveModalInterpolationPoint {

  static func itemsWithPercentCollision(interpolationPoints: [Self]) -> [Self] {
    interpolationPoints.filter { interpolationPoint in
      interpolationPoints.contains {
        $0 != interpolationPoint && $0.percent == interpolationPoint.percent;
      };
    };
  };

  static func compute(
    usingModalConfig modalConfig: AdaptiveModalConfig,
    snapPoints: [AdaptiveModalSnapPointConfig]? = nil,
    layoutValueContext context: RNILayoutValueContext
  ) -> [Self] {
  
    let snapPoints = snapPoints ?? modalConfig.snapPoints;
    var items: [AdaptiveModalInterpolationPoint] = [];
    
    for (index, snapConfig) in snapPoints.enumerated() {
      items.append(
        AdaptiveModalInterpolationPoint(
          usingModalConfig: modalConfig,
          snapPointIndex: index,
          layoutValueContext: context,
          snapPointConfig: snapConfig,
          prevInterpolationPoint: items.last
        )
      );
    };
    
    if let firstSnapPoint = snapPoints.first,
       let secondInterpolationPoint = items[safeIndex: 1] {
       
      items[0] = AdaptiveModalInterpolationPoint(
        usingModalConfig: modalConfig,
        snapPointIndex: 0,
        layoutValueContext: context,
        snapPointConfig: firstSnapPoint,
        prevInterpolationPoint: secondInterpolationPoint
      );
    };
    
    #if DEBUG
    let collisions = Self.itemsWithPercentCollision(interpolationPoints: items);
      
    collisions.forEach {
      print(
        "Warning: Snap point collision",
        "\n - snapPointIndex: \($0.snapPointIndex)",
        "\n - key: \($0.key)",
        "\n - percent: \($0.percent)",
        "\n - computedRect: \($0.computedRect)",
        "\n"
      );
    };
    #endif
    
    return items;
  };
};

