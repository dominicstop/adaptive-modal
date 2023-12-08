//
//  AdaptiveModalManager+PublicFunctions.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import UIKit


public extension AdaptiveModalManager {

  func updateModalConfig(_ newConfig: AdaptiveModalConfigMode){
    self._cancelModalGesture();
    self._stopModalAnimator();
    
    self.modalConfig = newConfig;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };
  
  func prepareForPresentation(
    viewControllerToPresent presentedVC: UIViewController,
    presentingViewController presentingVC: UIViewController
  ) {
  
    if let paginatedVC = presentedVC as? AdaptiveModalPageViewController {
      paginatedVC.setup(modalManager: self);
      self.paginatedViewController = paginatedVC;
    };
  
    self.modalViewController = presentedVC;
    self.presentingViewController = presentingVC;
    
    let modalWrapperVC = AdaptiveModalRootViewController();
    self.modalWrapperViewController = modalWrapperVC;
    
    modalWrapperVC.addChild(presentedVC);
    modalWrapperVC.view.addSubview(presentedVC.view);
    presentedVC.didMove(toParent: presentedVC);
    
    self._setupViewControllers();
  };
  
  func setScreenEdgePanGestureRecognizer(
    edgePanGesture: UIScreenEdgePanGestureRecognizer,
    viewControllerProvider: @escaping () -> (
      viewControllerToPresent: UIViewController,
      presentingViewController: UIViewController
    )
  ) {
  
    if let prevEdgePanGesture = self.edgePanGesture {
      prevEdgePanGesture.removeTarget(
        self,
        action: #selector(self._onDragScreenEdge(_:))
      );
      
      self.edgePanGesture = nil;
    };
    
    edgePanGesture.addTarget(
      self,
      action: #selector(self._onDragScreenEdge(_:))
    );
    
    self.edgePanGesture = edgePanGesture;
    self.viewControllerProvider = viewControllerProvider;
  };
  
  func notifyDidLayoutSubviews() {
    guard let rootView = self.rootView,
          let modalFrame = self.modalFrame,
          let interpolationContext = self.interpolationContext
    else { return };
    
    let prevTargetFrame = self.prevTargetFrame;
    let nextTargetFrame = rootView.frame;
    
    guard prevTargetFrame != nextTargetFrame else { return };
    self.prevTargetFrame = nextTargetFrame;
    
    self._updateCurrentModalConfig();
    
    if self._pendingCurrentModalConfigUpdate {
    
      // config changes while a snap override is active is buggy...
      self._cleanupSnapPointOverride();
      self._computeSnapPoints();
      
      let closestSnapPoint = self._getClosestSnapPoint(
        forRect: modalFrame,
        shouldExcludeUndershootSnapPoint: true
      );
      
      if let closestSnapPoint = closestSnapPoint {
        interpolationContext.interpolationStepItemCurrent = closestSnapPoint.interpolationStepItem;
      };

      let shouldUpdateDragHandleConstraints: Bool = {
        guard let prevConfig = self.prevModalConfig else {
          return false;
        };
        
        let dragHandlePositionPrev = prevConfig.dragHandlePosition;
        let dragHandlePositionNext = self.currentModalConfig.dragHandlePosition;
        
        return dragHandlePositionPrev != dragHandlePositionNext;
      }();
      
      if shouldUpdateDragHandleConstraints {
        self._setupDragHandleConstraints(shouldDeactivateOldConstraints: true);
      };
      
      self._updateModal();
      self._pendingCurrentModalConfigUpdate = false;
      
    } else {
      self._computeSnapPoints();
      self._updateModal();
    };
  };
  
  func clearSnapPointOverride(completion: (() -> Void)?){
    guard let interpolationContext = self.interpolationContext,
          interpolationContext.isOverridingSnapPoints
    else { return };
  
    interpolationContext.mode = AdaptiveModalInterpolationMode(
      usingModalConfig: self.currentModalConfig,
      usingContext: self._layoutValueContext
    );
    
    self.snapToClosestSnapPoint();
  };
  
  func presentModal(
    viewControllerToPresent modalVC: UIViewController,
    presentingViewController targetVC: UIViewController,
    snapPointIndex: Int? = nil,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {

    self.presentModal(
      viewControllerToPresent: modalVC,
      presentingViewController: targetVC,
      snapPointIndex: snapPointIndex,
      animated: animated,
      animationConfig: animationConfig,
      shouldSetStateOnSnap: false,
      stateSnapping: .PRESENTING_PROGRAMMATIC,
      stateSnapped: .PRESENTED_PROGRAMMATIC,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func presentModal(
    viewControllerToPresent modalVC: UIViewController,
    presentingViewController targetVC: UIViewController,
    snapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) {
  
    let snapPointMatch = self.currentModalConfig.snapPoints.enumerated().first {
      $0.element.key == snapPointKey;
    };
  
    self.presentModal(
      viewControllerToPresent: modalVC,
      presentingViewController: targetVC,
      snapPointIndex: snapPointMatch?.offset,
      animated: animated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func dismissModal(
    useInBetweenSnapPoints: Bool = false,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    guard let modalVC = self.modalViewController else { return };
    
    let animationConfig = animationConfig
      ?? self.currentModalConfig.exitAnimationConfig;
    
    self._tempHideModalCommandArgs = (
      isAnimated: animated,
      mode: useInBetweenSnapPoints ? .inBetween : .direct,
      animationConfig: animationConfig,
      shouldSetStateOnSnap: false,
      stateSnapping: .DISMISSING_PROGRAMMATIC,
      stateSnapped: .DISMISSED_PROGRAMMATIC,
      extraAnimationBlock: extraAnimation
    );

    modalVC.dismiss(
      animated: animated,
      completion: {
        completion?();
      }
    );
  };
  
  func dismissModal(
    snapPointPreset: AdaptiveModalSnapPointPreset,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    guard let modalVC = self.modalViewController else { return };
    
    let animationConfig = animationConfig
      ?? self.currentModalConfig.exitAnimationConfig;
    
    self._tempHideModalCommandArgs = (
      isAnimated: animated,
      mode: .snapPointPreset(snapPointPreset),
      animationConfig: animationConfig,
      shouldSetStateOnSnap: false,
      stateSnapping: .DISMISSING_PROGRAMMATIC,
      stateSnapped: .DISMISSED_PROGRAMMATIC,
      extraAnimationBlock: extraAnimation
    );
    
    modalVC.dismiss(
      animated: animated,
      completion: {
        completion?();
      }
    );
  };
  
  func dismissModal(
    keyframe: AdaptiveModalKeyframeConfig,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    guard let modalVC = self.modalViewController else { return };
    
    let animationConfig = animationConfig
      ?? self.currentModalConfig.exitAnimationConfig;
    
    self._tempHideModalCommandArgs = (
      isAnimated: animated,
      mode: .keyframe(keyframe),
      animationConfig: animationConfig,
      shouldSetStateOnSnap: false,
      stateSnapping: .DISMISSING_PROGRAMMATIC,
      stateSnapped: .DISMISSED_PROGRAMMATIC,
      extraAnimationBlock: extraAnimation
    );

    modalVC.dismiss(
      animated: animated,
      completion: {
        completion?();
      }
    );
  };
    
  func snapTo(
    snapPointIndex nextIndex: Int,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
 
    let lastIndex = max(self.currentModalConfig.snapPoints.count - 1, 0);
    let nextIndexAdj = self._adjustSnapPointIndex(for: lastIndex);

    guard nextIndexAdj >= 0 && nextIndexAdj <= lastIndex else { return };
    
    let nextInterpolationStepItem = self.interpolationContext.mode.getMatchingItem(
      forSnapPointIndex: nextIndex
    );
    
    guard let nextInterpolationStepItem = nextInterpolationStepItem,
          interpolationContext.interpolationStepItemCurrent != nextInterpolationStepItem
    else { return };
    
    let isDismissing: Bool = {
      let isPresentingOrPresented =
           self.modalState.isPresented
        || self.modalState.isPresenting;
    
      let isDismissingToUnderShootSnapPoint =
           isPresentingOrPresented
        && nextIndexAdj == 0
        && self.shouldDismissModalOnSnapToUnderShootSnapPoint;
        
      let isDismissingToOverShootSnapPoint =
           isPresentingOrPresented
        && nextIndexAdj == self.currentModalConfig.overshootSnapPointIndex
        && self.shouldDismissModalOnSnapToOverShootSnapPoint;
        
      return
           isDismissingToUnderShootSnapPoint
        || isDismissingToOverShootSnapPoint;
    }();
    
    let isPresenting =
         !isDismissing
      && self.modalState.isDismissed
      && nextIndexAdj > 0;
    
    let stateSnapping: AdaptiveModalState = {
      if isDismissing {
        return .DISMISSING_PROGRAMMATIC;
      };
      
      if isPresenting {
        return .PRESENTING_PROGRAMMATIC;
      };
      
      return .SNAPPING_PROGRAMMATIC;
    }();
    
    let stateSnapped: AdaptiveModalState = {
      if isDismissing {
        return .DISMISSED_PROGRAMMATIC;
      };
      
      if isPresenting {
        return .PRESENTED_PROGRAMMATIC;
      };
      
      return .SNAPPED_PROGRAMMATIC;
    }();
    
    self._snapTo(
      snapPointIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      shouldSetStateOnSnap: true,
      stateSnapping: stateSnapping,
      stateSnapped: stateSnapped,
      extraAnimation: extraAnimation,
      completion: {
        completion?();
      }
    );
  };
  
  func snapToClosestSnapPoint(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let closestSnapPoint = self._getClosestSnapPoint(
      forRect: self.modalFrame ?? .zero,
      shouldExcludeUndershootSnapPoint: true
    );

    guard let closestSnapPoint = closestSnapPoint else { return };
    
    self.snapTo(
      snapPointIndex: closestSnapPoint.interpolationStepItem.snapPointIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func snapToPrevSnapPointIndex(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let nextIndex = self.interpolationContext.snapPointIndexCurrent - 1;
    
    self.snapTo(
      snapPointIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func snapToCurrentSnapPointIndex(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let nextIndex = self.interpolationContext.snapPointIndexCurrent;
    
    self.snapTo(
      snapPointIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func snapToNextSnapPointIndex(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    
    let nextIndex = self.interpolationContext.snapPointIndexCurrent + 1;
    
    self.snapTo(
      snapPointIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  /// Temporarily snap the modal to a custom snap point.
  /// The override snap point can be manually cleared via
  /// `clearSnapPointOverride`.
  ///
  /// Parameters
  /// * `overrideSnapPointConfig`: The custom snap point you want to snap to.
  ///
  /// * `prevSnapPointConfigs`: The snap points that precede the
  /// `overrideSnapPointConfig.
  ///
  ///   * Once you snap to any of these points, the
  ///     override snap point will be cleared automatically.
  ///
  ///   * By default, this param. will be populated automatically with the
  ///     existing snap points in your modal config that can potentially
  ///     precede `overrideSnapPointConfig`. The undershoot snap point will
  ///     always be added by default.
  ///
  ///  * `overshootSnapPointPreset`: The custom overshoot snap point for
  ///     `overrideSnapPointConfig`.
  ///
  func snapTo(
    overrideSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevSnapPointConfigs: [AdaptiveModalSnapPointConfig]? = nil,
    overshootSnapPointPreset: AdaptiveModalSnapPointPreset? = .automatic,
    inBetweenSnapPointsMinPercentDiff: CGFloat = 0.1,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) throws {
  
    let interpolationContext = self.interpolationContext!;
    self._cleanupSnapPointOverride();
    
    let prevSnapPointConfigs: [AdaptiveModalSnapPointConfig] = {
      if let prevSnapPointConfigs = prevSnapPointConfigs {
        return prevSnapPointConfigs;
      };
    
      let prevInterpolationPoints: [AdaptiveModalInterpolationPoint] = {
        let overrideInterpolationPoint = AdaptiveModalInterpolationPoint(
          usingModalConfig: self.currentModalConfig,
          snapPointIndex: 1,
          layoutValueContext: self._layoutValueContext,
          snapPointConfig: overrideSnapPointConfig
        );
        
        let items = interpolationContext.interpolationPoints.filter {
          let delta = $0.percent - overrideInterpolationPoint.percent;
          guard delta <= 0 else { return false };
          
          // tolerance
          return abs(delta) >= inBetweenSnapPointsMinPercentDiff;
        };
        
        guard items.count > 0 else {
          return [interpolationContext.interpolationPoints.first!];
        };
        
        return items;
      }();
    
      return prevInterpolationPoints.map {
        self.currentModalConfig.snapPoints[$0.snapPointIndex];
      };
    }();
    
    let overshootSnapPointPreset: AdaptiveModalSnapPointPreset? = {
      guard let overshootSnapPointPreset = overshootSnapPointPreset
      else { return nil };
    
      switch overshootSnapPointPreset.layoutPreset {
        case .automatic:
          return .getDefaultOvershootSnapPoint(
            forDirection: self.currentModalConfig.snapDirection,
            keyframeConfig: overshootSnapPointPreset.keyframeConfig
          );
        
        default:
          return overshootSnapPointPreset;
      };
    }();
    
    let overshootSnapPointConfig: AdaptiveModalSnapPointConfig? = {
      guard let overshootSnapPointPreset = overshootSnapPointPreset
      else { return nil };
      
      return AdaptiveModalSnapPointConfig(
        fromSnapPointPreset: overshootSnapPointPreset,
        fromBaseLayoutConfig: overrideSnapPointConfig.layoutConfig
      );
    }();
  
    var snapPoints = prevSnapPointConfigs;
    snapPoints.append(overrideSnapPointConfig);
    
    if let overshootSnapPointConfig = overshootSnapPointConfig {
      snapPoints.append(overshootSnapPointConfig);
    };
    
    interpolationContext.mode = .overrideSnapPoint(
      .Element.compute(
        usingConfig: self.currentModalConfig,
        usingContext: self._layoutValueContext,
        snapPoints: snapPoints
      )
    );
    
    let nextSnapPointIndex = prevSnapPointConfigs.count;
    self._shouldResetRangePropertyAnimators = true;
    
    self.snapTo(
      snapPointIndex: nextSnapPointIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func snapTo(
    key: AdaptiveModalSnapPointConfig.SnapPointKey,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) throws {
  
    let interpolationContext = self.interpolationContext!;
  
    let interpolationStepNext: AdaptiveModalInterpolationStepItem? = {
      switch key {
        case let .index(indexKey):
          return interpolationContext.mode.getMatchingItem(
            forSnapPointIndex: indexKey
          )!;
          
        case let .string(stringKey):
          return interpolationContext.mode.getMatchingItem(
            forStringKey: stringKey
          )!;
          
        case .undershootPoint:
          return interpolationContext.mode.getMatchingItem(
            forSnapPointKey: .undershootPoint
          )!;
          
        case .overshootPoint:
          return interpolationContext.mode.getMatchingItem(
            forSnapPointKey: .overshootPoint
          )!;
          
        case .unspecified:
          return nil;
      };
    }();
    
    guard let interpolationStepNext = interpolationStepNext else {
      throw NSError();
    };
    
    self.snapTo(
      snapPointIndex: interpolationStepNext.snapPointIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
};
