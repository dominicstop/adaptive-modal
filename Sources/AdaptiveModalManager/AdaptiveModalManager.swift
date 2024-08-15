//
//  AdaptiveModalManager.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/24/23.
//

import UIKit
import ComputableLayout
import DGSwiftUtilities


public class AdaptiveModalManager: NSObject {

  // MARK: -  Properties - Config-Related
  // ------------------------------------
  
  public var modalConfig: AdaptiveModalConfigMode;
  
  public internal(set) var prevModalConfig: AdaptiveModalConfig? = nil;
  
  var _currentModalConfig: AdaptiveModalConfig?;
  public var currentModalConfig: AdaptiveModalConfig {
    switch self.modalConfig {
      case let .staticConfig(config):
        return config;
        
      case let .adaptiveConfig(defaultConfig, _):
        return self._currentModalConfig ?? defaultConfig;
    };
  };
  
  var _animationModeOverride: AdaptiveModalAnimationMode?;
  var _animationMode: AdaptiveModalAnimationMode = .default;
  public var animationMode: AdaptiveModalAnimationMode {
    get {
      if let _animationModeOverride = self._animationModeOverride {
        return _animationModeOverride;
      };
      
      return self._animationMode;
    }
    set {
      self._animationMode = newValue;
    }
  };
  
  
  public var shouldEnableSnapping = true;
  public var shouldEnableOverShooting = true;
  public var shouldDismissKeyboardOnGestureSwipe = false;
  
  public var shouldLockAxisToModalDirection = false;
  
  public var overrideShouldSnapToUnderShootSnapPoint: Bool?;
  public var overrideShouldSnapToOvershootSnapPoint: Bool?;
  
  public var shouldDismissModalOnSnapToUnderShootSnapPoint = true;
  public var shouldDismissModalOnSnapToOverShootSnapPoint = false;
  
  public var isSwipeGestureEnabled = true {
    willSet {
      self.isModalContentSwipeGestureEnabled = newValue;
      self.isModalDragHandleGestureEnabled  = newValue;
    }
  };
  
  public var isModalContentSwipeGestureEnabled = true {
    willSet {
      self.modalGesture?.isEnabled = newValue;
    }
  };
  
  public var allowModalToDragWhenAtMinScrollViewOffset = true;
  public var allowModalToDragWhenAtMaxScrollViewOffset = true;
  
  public var isModalDragHandleGestureEnabled = true {
    willSet {
       self.modalDragHandleGesture?.isEnabled = newValue;
    }
  };
  
  public var isUsingAdaptiveModalConfig: Bool {
    switch self.modalConfig {
      case .staticConfig:
        return false;
        
      case let .adaptiveConfig(defaultConfig, _):
        return self.currentModalConfig != defaultConfig;
    };
  };
  
  // MARK: -  Properties - Layout-Related
  // ------------------------------------
  
  public var modalWrapperViewController: AdaptiveModalRootViewController?;
  
  public weak var modalViewController: UIViewController?;
  public weak var presentingViewController: UIViewController?;
  
  public weak var paginatedViewController: AdaptiveModalPageViewController?;
  
  public weak var presentedViewController: UIViewController? {
       self.modalWrapperViewController
    ?? self.modalViewController;
  };
  
  public var viewControllerProvider: (() -> (
    viewControllerToPresent: UIViewController,
    presentingViewController: UIViewController
  ))?;
  
  /// Provides a user-init custom "drag handle" view to use for the modal
  public var dragHandleViewProvider: (() -> AdaptiveModalDragHandleView)?;
  
  /// `transitionContext.containerView` or `UITransitionView`
  public weak var rootView: UIView?;
  
  public var modalWrapperView: UIView? {
    self.modalWrapperViewController?.view;
  };
  
  public var modalView: UIView? {
    self.modalViewController?.view;
  };
  
  public internal(set) var dummyModalView: UIView?;
  
  public internal(set) var modalWrapperLayoutView: AdaptiveModalWrapperView?;
  public internal(set) var modalWrapperTransformView: AdaptiveModalWrapperView?;
  public internal(set) var modalWrapperShadowView: AdaptiveModalWrapperView?;
  public internal(set) var modalContentWrapperView: UIView?;
  
  public var modalDragHandleView: AdaptiveModalDragHandleView?;
  
  public weak var modalContentScrollView: UIScrollView?;
  
  public internal(set) var prevModalFrame: CGRect = .zero;
  public internal(set) var prevTargetFrame: CGRect = .zero;
  
  public internal(set) var modalBackgroundView: UIView?;
  public internal(set) var modalBackgroundVisualEffectView: UIVisualEffectView?;
  
  public internal(set) var backgroundDimmingView: UIView?;
  public internal(set) var backgroundVisualEffectView: UIVisualEffectView?;
  
  public internal(set) var modalFrame: CGRect? {
    set {
      guard let newValue = newValue else { return };
      
      if let prevModalFrame = self.modalFrame {
        self.prevModalFrame = prevModalFrame;
      };
      
      guard !newValue.isNaN else { return };
      
      self.modalWrapperLayoutView?.frame = newValue;
      
      if !self.isAnimating {
        self.dummyModalView?.frame = newValue;
      };
      
    }
    get {
      self.dummyModalView?.frame;
    }
  };
  
  var _modalSecondaryAxisValue: CGFloat? = nil;
  
  weak var modalConstraintLeft  : NSLayoutConstraint?;
  weak var modalConstraintRight : NSLayoutConstraint?;
  weak var modalConstraintTop   : NSLayoutConstraint?;
  weak var modalConstraintBottom: NSLayoutConstraint?;
  
  weak var modalDragHandleConstraintOffset: NSLayoutConstraint?;
  weak var modalDragHandleConstraintCenter: NSLayoutConstraint?;
  weak var modalDragHandleConstraintHeight: NSLayoutConstraint?;
  weak var modalDragHandleConstraintWidth : NSLayoutConstraint?;
  
  var _layoutKeyboardValues: ComputableLayoutKeyboardValues?;
  
  var _layoutValueContext: ComputableLayoutValueContext {
    let context: ComputableLayoutValueContext? = {
      if let targetVC = self.presentingViewController {
        return .init(
          fromTargetViewController: targetVC,
          keyboardValues: self._layoutKeyboardValues
        );
      };
      
      if let rootView = self.rootView {
        return .init(
          fromTargetView: rootView,
          keyboardValues: self._layoutKeyboardValues
        );
      };
      
      return nil;
    }();
    
    return context ?? .default;
  };
  
  var _isKeyboardVisible = false;
  
  var _pendingCurrentModalConfigUpdate = false;
  
  // MARK: -  Properties - Config Interpolation Points
  // -------------------------------------------------
  
  /// The computed frames of the modal based on the snap points
  var configInterpolationSteps: [AdaptiveModalInterpolationPoint]!;
  
  var currentConfigInterpolationStep: AdaptiveModalInterpolationPoint {
    self.interpolationSteps[self.currentInterpolationIndex];
  };
  
  var configInterpolationRangeInput: [CGFloat]! {
    self.interpolationSteps.map { $0.percent };
  };
  
  var prevConfigInterpolationIndex = 0;
  var nextConfigInterpolationIndex: Int?;
  
  var currentConfigInterpolationIndex = 0 {
    didSet {
      self.prevConfigInterpolationIndex = oldValue;
    }
  };
  
  // MARK: -  Properties - Override Interpolation Points
  // ---------------------------------------------------
  
  public internal(set) var isOverridingSnapPoints = false;
  
  var prevOverrideInterpolationIndex = 0;
  var nextOverrideInterpolationIndex: Int?;
  
  var currentOverrideInterpolationIndex = 0 {
    didSet {
      self.prevOverrideInterpolationIndex = oldValue;
    }
  };
  
  var overrideSnapPoints: [AdaptiveModalSnapPoint]?;
  var overrideInterpolationPoints: [AdaptiveModalInterpolationPoint]?;
  
  var currentOverrideInterpolationStep: AdaptiveModalInterpolationPoint? {
    self.overrideInterpolationPoints?[self.currentOverrideInterpolationIndex];
  };
  
  var shouldUseOverrideSnapPoints: Bool {
       self.isOverridingSnapPoints
    && self.overrideSnapPoints          != nil
    && self.overrideInterpolationPoints != nil
  };
  
  var shouldClearOverrideSnapPoints: Bool {
    guard self.shouldUseOverrideSnapPoints,
          self.presentationState != .dismissing,
          let interpolationPoints = self.overrideInterpolationPoints
    else { return false };
    
    // The "last index" N is the overshoot snap point
    // N-1 index is the override snap point
    let secondToLastIndex = interpolationPoints.count - 2;

    return self.currentOverrideInterpolationIndex <= secondToLastIndex;
  };
  
  // MARK: -  Properties - Interpolation Points
  // ------------------------------------------
  
  public internal(set) var onModalWillSnapPrevIndex: Int?;
  public internal(set) var onModalWillSnapNextIndex: Int?;
  
  public internal(set) var prevInterpolationIndex: Int {
    get {
      self.shouldUseOverrideSnapPoints
        ? self.prevOverrideInterpolationIndex
        : self.prevConfigInterpolationIndex;
    }
    set {
      if self.shouldUseOverrideSnapPoints {
        self.prevOverrideInterpolationIndex = newValue;
        
      } else {
        self.prevConfigInterpolationIndex = newValue;
      };
    }
  };
  
  public internal(set) var nextInterpolationIndex: Int? {
    get {
      self.shouldUseOverrideSnapPoints
        ? self.nextOverrideInterpolationIndex
        : self.nextConfigInterpolationIndex;
    }
    set {
      if self.shouldUseOverrideSnapPoints {
        self.nextOverrideInterpolationIndex = newValue;
        
      } else {
        self.nextConfigInterpolationIndex = newValue;
      };
    }
  };
  
  public internal(set) var currentInterpolationIndex: Int {
    get {
      self.shouldUseOverrideSnapPoints
        ? self.currentOverrideInterpolationIndex
        : self.currentConfigInterpolationIndex;
    }
    set {
      if self.shouldUseOverrideSnapPoints {
        self.currentOverrideInterpolationIndex = newValue;
        
      } else {
        self.currentConfigInterpolationIndex = newValue;
      };
      
      self.prevInterpolationStep = {
        if self.isOverridingSnapPoints,
           let overrideInterpolationPoints = self.overrideInterpolationPoints {
          
          let prevIndex = self.currentOverrideInterpolationIndex;
          return overrideInterpolationPoints[safeIndex: prevIndex];
          
        } else {
          let prevIndex = self.currentInterpolationIndex;
          return self.configInterpolationSteps[safeIndex: prevIndex];
        };
      }();
      
      self.prevSnapPoint = {
        if self.isOverridingSnapPoints,
           let overrideSnapPoints = self.overrideSnapPoints {
          
          let prevIndex = self.currentOverrideInterpolationIndex;
          return overrideSnapPoints[safeIndex: prevIndex];
          
        } else {
          let prevIndex = self.currentInterpolationIndex;
          return self.currentModalConfig.snapPoints[safeIndex: prevIndex];
        };
      }();
    }
  };
  
  public internal(set) var interpolationSteps: [AdaptiveModalInterpolationPoint]! {
    get {
      self.shouldUseOverrideSnapPoints
        ? self.overrideInterpolationPoints
        : self.configInterpolationSteps
    }
    set {
      if self.shouldUseOverrideSnapPoints {
        self.overrideInterpolationPoints = newValue;
        
      } else {
        self.configInterpolationSteps = newValue;
      };
    }
  };
  
  public internal(set) var prevInterpolationStep: AdaptiveModalInterpolationPoint?;
  
  public var currentInterpolationStep: AdaptiveModalInterpolationPoint {
    self.interpolationSteps[self.currentInterpolationIndex];
  };
  
  public var interpolationRangeInput: [CGFloat]! {
    self.interpolationSteps.map { $0.percent };
  };
  
  public var interpolationRangeMaxInput: CGFloat? {
    guard let rootView = self.rootView else { return nil };
    return rootView.frame[keyPath: self.currentModalConfig.maxInputRangeKeyForRect];
  };
  
  public var currentSnapPoints: [AdaptiveModalSnapPoint] {
    if self.shouldUseOverrideSnapPoints,
       let overrideSnapPoints = self.overrideSnapPoints {
      
      return overrideSnapPoints;
    };
  
    return self.currentModalConfig.snapPoints;
  };
  
  public internal(set) var prevSnapPoint: AdaptiveModalSnapPoint?;
  
  public var currentSnapPoint: AdaptiveModalSnapPoint {
    return self.currentSnapPoints[
      self.currentInterpolationStep.snapPoint.index
    ];
  };
  
  // MARK: -  Properties - Animation-Related
  // ---------------------------------------
  
  weak var transitionContext: UIViewControllerContextTransitioning?;
  
  var _modalAnimator: UIViewPropertyAnimator?;

  var backgroundVisualEffectAnimator: AdaptiveModalRangePropertyAnimator?;
  var modalBackgroundVisualEffectAnimator: AdaptiveModalRangePropertyAnimator?;
  
  var displayLink: CADisplayLink?;
  var displayLinkStartTimestamp: CFTimeInterval?;
  
  var displayLinkEndTimestamp: CFTimeInterval? {
    guard let animator = self._modalAnimator,
          let displayLinkStartTimestamp = self.displayLinkStartTimestamp
    else { return nil };
    
    return displayLinkStartTimestamp + animator.duration;
  };
  
  var shouldAutoEndDisplayLink = true;
  
  var rangeAnimators: [AdaptiveModalRangePropertyAnimator?] {[
    self.backgroundVisualEffectAnimator,
    self.modalBackgroundVisualEffectAnimator
  ]};
  
  var rangeAnimatorMode: ModalRangePropertyAnimatorMode = .modalPosition;
  
  var _shouldResetRangePropertyAnimators = false;
  
  // MARK: -  Properties - Gesture-Related
  // -------------------------------------
  
  weak var modalGesture: UIPanGestureRecognizer?;
  weak var modalDragHandleGesture: UIPanGestureRecognizer?;
  weak var backgroundTapGesture: UITapGestureRecognizer?;
  weak var edgePanGesture: UIScreenEdgePanGestureRecognizer?;
  
  public internal(set) var gestureOffset: CGPoint?;
  public internal(set) var gestureVelocity: CGPoint?;
  public internal(set) var gestureInitialPoint: CGPoint?;
  
  public internal(set) var gesturePointPrev: CGPoint?;
  
  public internal(set) var gesturePoint: CGPoint? {
    didSet {
      self.gesturePointPrev = oldValue;
    }
  };
  
  var gesturePointDeltaInitial: CGPoint? {
    guard let gestureInitialPoint = self.gestureInitialPoint,
          let gesturePoint = self.gesturePoint
    else { return nil };
    
    return CGPoint(
      x: gestureInitialPoint.x - gesturePoint.x,
      y: gestureInitialPoint.y - gesturePoint.y
    );
  };
  
  var gesturePointDeltaPrev: CGPoint? {
    guard let gesturePointPrev = self.gesturePointPrev,
          let gesturePoint = self.gesturePoint
    else { return nil };
    
    return CGPoint(
      x: gesturePointPrev.x - gesturePoint.x,
      y: gesturePointPrev.y - gesturePoint.y
    );
  };
  
  var gestureInitialVelocity: CGVector {
    guard let gestureInitialPoint = self.gestureInitialPoint,
          let gestureFinalPoint   = self.gesturePoint,
          let gestureVelocity     = self.gestureVelocity
    else {
      return .zero;
    };
  
    let gestureInitialCoord =
      gestureInitialPoint[keyPath: self.currentModalConfig.inputValueKeyForPoint];
      
    let gestureFinalCoord =
      gestureFinalPoint[keyPath: self.currentModalConfig.inputValueKeyForPoint];
      
    let gestureVelocityCoord =
      gestureVelocity[keyPath: self.currentModalConfig.inputValueKeyForPoint];
    
    var velocity: CGFloat = 0;
    let distance = gestureFinalCoord - gestureInitialCoord;
    
    if distance != 0 {
      velocity = gestureVelocityCoord / distance;
    };

    return CGVector(dx: velocity, dy: velocity);
  };
  
  /// Based on the gesture's velocity and it's current position, estimate
  /// where would it eventually "stop" (i.e. it's final position) if it were to
  /// decelerate over time
  ///
  var gestureFinalPoint: CGPoint? {
    guard let gesturePoint = self.gesturePoint,
          let gestureVelocity = self.gestureVelocity
    else { return nil };
    
    let maxVelocity: CGFloat = 300;
    
    let gestureVelocityClamped = CGPoint(
      x: (gestureVelocity.x / 2).clamped(minMax: maxVelocity),
      y: (gestureVelocity.y / 2).clamped(minMax: maxVelocity)
    );
    
    let nextX = AdaptiveModalUtilities.computeFinalPosition(
      position: gesturePoint.x,
      initialVelocity: gestureVelocityClamped.x
    );
    
    let nextY = AdaptiveModalUtilities.computeFinalPosition(
      position: gesturePoint.y,
      initialVelocity: gestureVelocityClamped.y
    );
    
    return CGPoint(x: nextX, y: nextY);
  };
  
  var computedGestureOffset: CGPoint? {
    guard let gestureInitialPoint = self.gestureInitialPoint,
          let modalRect = self.modalFrame,
          
          /// When modal is presented via gesture, wait for `presentModal` to
          /// finish before computing offsets, so that the modal frame
          /// is not nil/zero.
          self._tempShowModalCommandArgs == nil
    else { return nil };
    
    if let gestureOffset = self.gestureOffset {
      return gestureOffset;
    };
    
    let xOffset: CGFloat = {
      switch self.currentModalConfig.snapDirection {
        case .rightToLeft:
          return gestureInitialPoint.x - modalRect.minX;
          
        case .leftToRight:
          return modalRect.maxX - gestureInitialPoint.x;
          
        case .bottomToTop, .topToBottom:
          // secondary axis
          return gestureInitialPoint.x - modalRect.minX;
      };
    }();
    
    let yOffset: CGFloat = {
      switch self.currentModalConfig.snapDirection {
        case .bottomToTop:
          return gestureInitialPoint.y - modalRect.minY;
          
        case .topToBottom:
          return modalRect.maxY - gestureInitialPoint.y;
          
        case .leftToRight, .rightToLeft:
          // secondary axis
          return gestureInitialPoint.y - modalRect.minY;
      };
    }();
  
    let offset = CGPoint(x: xOffset, y: yOffset);
    self.gestureOffset = offset;
    
    return offset;
  };
  
  var modalSwipeGestureEdgeRect: CGRect? {
    guard let modalFrame = self.modalFrame else { return nil };
    let modalConfig = self.currentModalConfig;
    
    let modalSwipeGestureEdgeHeight = modalConfig.modalSwipeGestureEdgeHeight;
    
    switch modalConfig.snapDirection {
      case .bottomToTop:
        return CGRect(
          origin: modalFrame.origin,
          size: CGSize(
            width: modalFrame.width,
            height: modalSwipeGestureEdgeHeight
          )
        );
        
      case .topToBottom:
        let offsetY = modalFrame.height - modalSwipeGestureEdgeHeight;
        let newY = modalFrame.origin.y + offsetY;
      
        return CGRect(
          origin: CGPoint(
            x: modalFrame.origin.x,
            y: newY
          ),
          size: CGSize(
            width: modalFrame.width,
            height: modalSwipeGestureEdgeHeight
          )
        );
        
      case .leftToRight:
        return CGRect(
          origin: modalFrame.origin,
          size: CGSize(
            width: modalFrame.width,
            height: modalSwipeGestureEdgeHeight
          )
        );
        
      case .rightToLeft:
        let offsetX = modalFrame.width - modalSwipeGestureEdgeHeight;
        let newX = modalFrame.origin.x + offsetX;
      
        return CGRect(
          origin: CGPoint(
            x: newX,
            y: modalFrame.origin.y
          ),
          size: CGSize(
            width: modalFrame.width,
            height: modalSwipeGestureEdgeHeight
          )
        );
    };
  };
  
  public var gesturePointWithOffsets: CGPoint? {
    guard let gesturePoint = self.gesturePoint else { return nil };
    return self._applyGestureOffsets(forGesturePoint: gesturePoint)
  };
  
  public var gestureDirection: AdaptiveModalConfig.SnapDirection? {
    guard let gesturePointNext = self.gesturePoint,
          let gesturePointPrev = self.gesturePointPrev
    else { return nil };
  
    let gestureCoordNext =
      gesturePointNext[keyPath: self.currentModalConfig.inputValueKeyForPoint];
      
    let gestureCoordPrev =
      gesturePointPrev[keyPath: self.currentModalConfig.inputValueKeyForPoint];
  
    return self.currentModalConfig.snapDirection.getDirection(
      next: gestureCoordNext,
      prev: gestureCoordPrev
    );
  };
  
  // MARK: -  Properties - Debug-Related
  // -----------------------------------
  
  var debugView: AdaptiveModalDebugOverlay?;
  
  private var _showDebugOverlay = false;
  public var showDebugOverlay: Bool {
    get {
      #if DEBUG
      return self._showDebugOverlay;
      #else
      return false;
      #endif
    }
    set {
      self._showDebugOverlay = newValue;
    }
  };
  
  public var shouldLogModalStateChanges = false;
  
  // MARK: -  Properties - Modal State
  // ---------------------------------
  
  public internal(set) var presentationState: PresentationState = .none;
  
  lazy var modalStateMachine = AdaptiveModalStateMachine(
    onStateWillChangeBlock: { [unowned self] in
      self._notifyOnModalStateWillChange($0, $1, $2);
    }
  );
  
  public var modalStatePrev: AdaptiveModalState {
    self.modalStateMachine.prevState;
  };
  
  public var modalState: AdaptiveModalState {
    self.modalStateMachine.currentState;
  };
  
  // MARK: -  Properties - Delegates
  // -------------------------------
  
  public var stateEventsDelegate =
    MulticastDelegate<AdaptiveModalStateEventsNotifiable>();
    
  public var presentationEventsDelegate =
    MulticastDelegate<AdaptiveModalPresentationEventsNotifiable>();
    
  public var gestureEventsDelegate =
    MulticastDelegate<AdaptiveModalGestureEventsNotifiable>();
  
  public var backgroundTapDelegate =
    MulticastDelegate<AdaptiveModalBackgroundTapDelegate>();
    
  public var animationEventDelegate =
    MulticastDelegate<AdaptiveModalAnimationEventsNotifiable>();
    
  public weak var displayLinkEventsDelegate:
    AdaptiveModalDisplayLinkEventsNotifiable?;
    
  // MARK: -  Properties
  // -------------------
  
  /// Args for indirect call to `showModal` via `UIViewController.show`
  var _tempShowModalCommandArgs: (
    isAnimated: Bool,
    snapPointIndex: Int?,
    animationConfig: AnimationConfig,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimationBlock: (() -> Void)?
  )?;
  
  /// Args for  indirect call to `hideModal` via `UIViewController.dismiss`
  var _tempHideModalCommandArgs: (
    isAnimated: Bool,
    mode: HideModalMode,
    animationConfig: AnimationConfig,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimationBlock: (() -> Void)?
  )?;
  
  var _didTriggerSetup = false;
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var isSwiping: Bool {
    let isModalGestureActive =
      self.modalGesture?.state.isActive ?? false;
      
    let isModalDragHandleGestureActive =
      self.modalDragHandleGesture?.state.isActive ?? false;

    return isModalGestureActive || isModalDragHandleGestureActive;
  };
  
  public var isAnimating: Bool {
    self._modalAnimator?.isRunning ?? false;
  };
  
  public var isAnimatingWithViewPropertyAnimatorDiscrete: Bool {
       self.isAnimating
    && self.animationMode == .viewPropertyAnimatorDiscrete;
  };
  
  public var currentSnapPointIndex: Int {
    self.currentInterpolationStep.snapPoint.index;
  };
  
  public var canSnapToUnderShootSnapPoint: Bool {
    let underShootSnapPoint = self.currentModalConfig.undershootSnapPoint;
 
    return self.overrideShouldSnapToUnderShootSnapPoint
      ?? underShootSnapPoint.keyframeConfig?.allowSnapping
      ?? true;
  };
  
  public var canSnapToOverShootSnapPoint: Bool {
    let overshootSnapPoint = self.currentModalConfig.overshootSnapPoint;
 
    return self.overrideShouldSnapToOvershootSnapPoint
      ?? overshootSnapPoint?.keyframeConfig?.allowSnapping
      ?? false;
  };

  // MARK: - Init
  // ------------
  
  public init(
    presentingViewController presentingVC: UIViewController? = nil,
    staticConfig: AdaptiveModalConfig
  ) {
    self.modalConfig = .staticConfig(staticConfig);
    self.presentingViewController = presentingVC;
    
    super.init();
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };
  
  public init(
    presentingViewController presentingVC: UIViewController? = nil,
    adaptiveConfig: AdaptiveModalConfigMode
  ) {
    self.modalConfig = adaptiveConfig;
    self.presentingViewController = presentingVC;
    
    super.init();
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };
  
  deinit {
    self._clearAnimators();
    self._removeObservers();
  };

  // MARK: - Functions - Interpolation-Related Helpers
  // -------------------------------------------------
  
  func _interpolate(
    inputValue: CGFloat,
    rangeInput: [CGFloat]? = nil,
    rangeOutput: [AdaptiveModalInterpolationPoint]? = nil,
    rangeOutputKey: KeyPath<AdaptiveModalInterpolationPoint, CGFloat>,
    shouldClampMin: Bool = false,
    shouldClampMax: Bool = false
  ) -> CGFloat? {
  
    guard let interpolationSteps      = rangeOutput ?? self.interpolationSteps,
          let interpolationRangeInput = rangeInput  ?? self.interpolationRangeInput
    else { return nil };
  
    return AdaptiveModalUtilities.interpolate(
      inputValue: inputValue,
      rangeInput: interpolationRangeInput,
      rangeOutput: interpolationSteps.map {
        $0[keyPath: rangeOutputKey];
      },
      shouldClampMin: shouldClampMin,
      shouldClampMax: shouldClampMax
    );
  };
  
  func _interpolateColor(
    inputValue: CGFloat,
    rangeInput: [CGFloat]? = nil,
    rangeOutput: [AdaptiveModalInterpolationPoint]? = nil,
    rangeOutputKey: KeyPath<AdaptiveModalInterpolationPoint, UIColor>,
    shouldClampMin: Bool = false,
    shouldClampMax: Bool = false
  ) -> UIColor? {
  
    guard let interpolationSteps      = rangeOutput ?? self.interpolationSteps,
          let interpolationRangeInput = rangeInput  ?? self.interpolationRangeInput
    else { return nil };
  
    return AdaptiveModalUtilities.interpolateColor(
      inputValue: inputValue,
      rangeInput: interpolationRangeInput,
      rangeOutput: interpolationSteps.map {
        $0[keyPath: rangeOutputKey];
      },
      shouldClampMin: shouldClampMin,
      shouldClampMax: shouldClampMax
    );
  };
  
  func _getInterpolationStepRange(
   forInputPercentValue inputPercentValue: CGFloat
  ) -> (
    rangeStart: AdaptiveModalInterpolationPoint,
    rangeEnd: AdaptiveModalInterpolationPoint
  )? {
    guard let interpolationSteps = self.interpolationSteps,
          let minStep = interpolationSteps.first,
          let maxStep = interpolationSteps.last
    else { return nil };
    
    let lastIndex = interpolationSteps.count - 1;
    
    let minStepValue = minStep.percent;
    let maxStepValue = maxStep.percent;
    
    if inputPercentValue <= minStepValue {
      return (
        rangeStart: minStep,
        rangeEnd: interpolationSteps[1]
      );
    };
    
    if inputPercentValue >= maxStepValue {
      return (
        rangeStart: interpolationSteps[lastIndex - 1],
        rangeEnd: maxStep
      );
    };
    
    let firstMatch = interpolationSteps.enumerated().first {
      guard let nextItem = interpolationSteps[safeIndex: $0.offset + 1]
      else { return false };
      
      let percentCurrent = $0.element.percent;
      let percentNext    = nextItem.percent;
      
      /// `inputPercentValue` is between the range of `percentCurrent`
      /// and `percentNext`
      ///
      return inputPercentValue >= percentCurrent &&
             inputPercentValue <= percentNext;
    };
    
    guard let rangeStart = firstMatch?.element,
          let rangeStartIndex = firstMatch?.offset,
          let rangeEnd = interpolationSteps[safeIndex: rangeStartIndex + 1]
    else { return nil };
    
    return (rangeStart, rangeEnd);
  };
  
  // MARK: - Functions - Property Interpolators
  // ------------------------------------------
  
  func _applyInterpolationToModalBackgroundVisualEffect(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
  
    let animator: AdaptiveModalRangePropertyAnimator? = {
      let interpolationRange = self._getInterpolationStepRange(
        forInputPercentValue: inputPercentValue
      );
      
      guard let interpolationRange = interpolationRange else { return nil };
      let animator = self.modalBackgroundVisualEffectAnimator;
      
      let animatorRangeDidChange = animator?.didRangeChange(
        interpolationRangeStart: interpolationRange.rangeStart,
        interpolationRangeEnd: interpolationRange.rangeEnd
      );
 
      if !self._shouldResetRangePropertyAnimators,
         var animator = animator,
         let animatorRangeDidChange = animatorRangeDidChange {
         
        if animatorRangeDidChange {
          animator.update(
            interpolationRangeStart: interpolationRange.rangeStart,
            interpolationRangeEnd: interpolationRange.rangeEnd
          );
        };
         
        return animator;
      };
      
      animator?.clear();
      
      guard let visualEffectView = self.modalBackgroundVisualEffectView
      else { return nil };
      
      visualEffectView.effect = nil;
      
      return AdaptiveModalRangePropertyAnimator(
        interpolationRangeStart: interpolationRange.rangeStart,
        interpolationRangeEnd: interpolationRange.rangeEnd,
        forComponent: visualEffectView,
        interpolationOutputKey: \.modalBackgroundVisualEffectIntensity
      ) {
        $0.effect = $1.modalBackgroundVisualEffect;
      };
    }();
    
    guard let animator = animator else { return };
    self.modalBackgroundVisualEffectAnimator = animator;
    
    animator.setFractionComplete(
      forInputPercentValue: inputPercentValue.clamped(min: 0, max: 1)
    );
  };

  func _applyInterpolationToBackgroundVisualEffect(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
  
    let animator: AdaptiveModalRangePropertyAnimator? = {
      let interpolationRange = self._getInterpolationStepRange(
        forInputPercentValue: inputPercentValue
      );
      
      guard let interpolationRange = interpolationRange else { return nil };
      let animator = self.backgroundVisualEffectAnimator;
      
      let animatorRangeDidChange = animator?.didRangeChange(
        interpolationRangeStart: interpolationRange.rangeStart,
        interpolationRangeEnd: interpolationRange.rangeEnd
      );
    
      if !self._shouldResetRangePropertyAnimators,
         var animator = animator,
         let animatorRangeDidChange = animatorRangeDidChange {
         
        if animatorRangeDidChange {
          animator.update(
            interpolationRangeStart: interpolationRange.rangeStart,
            interpolationRangeEnd: interpolationRange.rangeEnd
          );
        };
         
        return animator;
      };
      
      animator?.clear();
      
      guard let visualEffectView = self.backgroundVisualEffectView
      else { return nil };
      
      visualEffectView.effect = nil;
      
      return AdaptiveModalRangePropertyAnimator(
        interpolationRangeStart: interpolationRange.rangeStart,
        interpolationRangeEnd: interpolationRange.rangeEnd,
        forComponent: visualEffectView,
        interpolationOutputKey: \.backgroundVisualEffectIntensity
      ) {
        $0.effect = $1.backgroundVisualEffect;
      };
    }();
    
    guard let animator = animator else { return };
    self.backgroundVisualEffectAnimator = animator;
    
    animator.setFractionComplete(
      forInputPercentValue: inputPercentValue.clamped(min: 0, max: 1)
    );
  };
  
  func _applyInterpolationToModalPadding(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalView = self.modalView else { return };
    let clampingConfig = self.currentModalConfig.interpolationClampingConfig;
    
    let clampingKeysMin = clampingConfig.clampingKeysLeft;
    let clampingKeysMax = clampingConfig.clampingKeysRight;
  
    let nextPaddingLeft = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.left,
      shouldClampMin: clampingKeysMin.contains(.modalPaddingLeft),
      shouldClampMax: clampingKeysMax.contains(.modalPaddingLeft)
    );
    
    let nextPaddingRight = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.right,
      shouldClampMin: clampingKeysMin.contains(.modalPaddingRight),
      shouldClampMax: clampingKeysMax.contains(.modalPaddingRight)
    );
    
    let nextPaddingTop = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.top,
      shouldClampMin: clampingKeysMin.contains(.modalPaddingTop),
      shouldClampMax: clampingKeysMax.contains(.modalPaddingTop)
    );
    
    let nextPaddingBottom = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.bottom,
      shouldClampMin: clampingKeysMin.contains(.modalPaddingBottom),
      shouldClampMax: clampingKeysMax.contains(.modalPaddingBottom)
    );
    
    var didPaddingChange = false;
    
    if let nextPaddingLeft = nextPaddingLeft,
       let modalConstraintLeft = self.modalConstraintLeft,
       modalConstraintLeft.constant != nextPaddingLeft {
      
      modalConstraintLeft.constant = nextPaddingLeft;
      didPaddingChange = true;
    };
    
    if let nextPaddingRight = nextPaddingRight,
       let modalConstraintRight = self.modalConstraintRight,
       modalConstraintRight.constant != nextPaddingRight {
      
      modalConstraintRight.constant = nextPaddingRight;
      didPaddingChange = true;
    };
    
    if let nextPaddingTop = nextPaddingTop,
       let modalConstraintTop = self.modalConstraintTop,
       modalConstraintTop.constant != nextPaddingTop {
      
      modalConstraintTop.constant = nextPaddingTop;
      didPaddingChange = true;
    };
    
    if let nextPaddingBottom = nextPaddingBottom,
       let modalConstraintBottom = self.modalConstraintBottom,
       modalConstraintBottom.constant != nextPaddingBottom {
      
      modalConstraintBottom.constant = nextPaddingBottom;
      didPaddingChange = true;
    };
    
    guard didPaddingChange else { return };
    modalView.updateConstraints();
    modalView.setNeedsLayout();
  };
  
  func _applyInterpolationToModalDragHandleOffset(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalDragHandleView = self.modalDragHandleView else { return };
    let clampingConfig = self.currentModalConfig.interpolationClampingConfig;
    
    let clampingKeysMin = clampingConfig.clampingKeysLeft;
    let clampingKeysMax = clampingConfig.clampingKeysRight;
  
    let nextDragHandleOffset = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalDragHandleOffset,
      shouldClampMin: clampingKeysMin.contains(.modalDragHandleOffset),
      shouldClampMax: clampingKeysMax.contains(.modalDragHandleOffset)
    );

    guard let nextDragHandleOffset = nextDragHandleOffset,
          nextDragHandleOffset.isFinite,
          
          let modalDragHandleConstraintOffset = self.modalDragHandleConstraintOffset,
          modalDragHandleConstraintOffset.constant != nextDragHandleOffset
    else { return };
    
    modalDragHandleConstraintOffset.constant = nextDragHandleOffset;
    
    modalDragHandleView.updateConstraints();
    modalDragHandleView.setNeedsLayout();
  };
  
  func _applyInterpolationToModalDragHandleSize(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalDragHandleView = self.modalDragHandleView else { return };
    let clampingConfig = self.currentModalConfig.interpolationClampingConfig;
    
    let clampingKeysMin = clampingConfig.clampingKeysLeft;
    let clampingKeysMax = clampingConfig.clampingKeysRight;
  
    let nextWidth = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalDragHandleSize.width,
      shouldClampMin: clampingKeysMin.contains(.modalDragHandleSizeWidth),
      shouldClampMax: clampingKeysMax.contains(.modalDragHandleSizeWidth)
    );
    
    let nextHeight = self._interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalDragHandleSize.height,
      shouldClampMin: clampingKeysMin.contains(.modalDragHandleSizeHeight),
      shouldClampMax: clampingKeysMax.contains(.modalDragHandleSizeHeight)
    );
    
    var didSizeChange = false;
    
    if let nextWidth = nextWidth,
       let dragHandleConstraintWidth = self.modalDragHandleConstraintWidth,
       dragHandleConstraintWidth.constant != nextWidth {
      
      dragHandleConstraintWidth.constant = nextWidth;
      didSizeChange = true;
    };
    
    if let nextHeight = nextHeight,
       let dragHandleConstraintHeight = self.modalDragHandleConstraintHeight,
       dragHandleConstraintHeight.constant != nextHeight {
       
       dragHandleConstraintHeight.constant = nextHeight;
       didSizeChange = true;
    };
      
    guard didSizeChange else { return };

    modalDragHandleView.updateConstraints();
    modalDragHandleView.setNeedsLayout();
  };
  
  // MARK: - Functions - Apply Interpolators
  // ----------------------------------------
  
  func _applyInterpolationToRangeAnimators(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    self._applyInterpolationToBackgroundVisualEffect(
      forInputPercentValue: inputPercentValue
    );
    
    self._applyInterpolationToModalBackgroundVisualEffect(
      forInputPercentValue: inputPercentValue
    );
    
    self._shouldResetRangePropertyAnimators = false;
  };
  
  func _applyInterpolationToModal(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalView = self.modalView else { return };
    let clampingConfig = self.currentModalConfig.interpolationClampingConfig;
    
    let clampingKeysMin = clampingConfig.clampingKeysLeft;
    let clampingKeysMax = clampingConfig.clampingKeysRight;
    
    let rangeInput = self.interpolationSteps.map {
      $0[keyPath: \.percent]
    };
    
    self.modalFrame = {
      let nextRect = AdaptiveModalUtilities.interpolateRect(
        inputValue: inputPercentValue,
        rangeInput: rangeInput,
        rangeOutput: AdaptiveModalUtilities.extractValuesFromArray(
          for: self.interpolationSteps,
          key: \.computedRect
        ),
        shouldClampMinHeight: clampingKeysMin.contains(.modalSizeHeight),
        shouldClampMaxHeight: clampingKeysMax.contains(.modalSizeHeight),
        shouldClampMinWidth: clampingKeysMin.contains(.modalSizeWidth),
        shouldClampMaxWidth: clampingKeysMax.contains(.modalSizeWidth),
        shouldClampMinX: clampingKeysMin.contains(.modalOriginX),
        shouldClampMaxX: clampingKeysMax.contains(.modalOriginX),
        shouldClampMinY: clampingKeysMin.contains(.modalOriginY),
        shouldClampMaxY: clampingKeysMax.contains(.modalOriginY)
      );
      
      guard let nextRect = nextRect else {
        return self.modalFrame;
      };
      
      let shouldAdjustSecondaryAxis: Bool =
           !self.shouldLockAxisToModalDirection
        && !self.isAnimatingWithViewPropertyAnimatorDiscrete
      
      guard shouldAdjustSecondaryAxis,
            let secondaryAxis = self._modalSecondaryAxisValue
      else {
        return nextRect;
      };
      
      let secondaryAxisAdj: CGFloat = {
        let dampingPercentRaw = self._interpolate(
          inputValue: inputPercentValue,
          rangeOutputKey: \.secondaryGestureAxisDampingPercent
        );
        
        if dampingPercentRaw == 1 {
          return nextRect.origin[keyPath: self.currentModalConfig.secondarySwipeAxis];
        };
        
        if dampingPercentRaw == 0 {
          return secondaryAxis;
        };
        
        guard let dampingPercentRaw = dampingPercentRaw else {
          return secondaryAxis;
        };
        
        let dampingPercent =
          AdaptiveModalUtilities.invertPercent(dampingPercentRaw);
        
        let secondaryAxisAdj =  AdaptiveModalUtilities.interpolate(
          inputValue: dampingPercent,
          rangeInput: [0, 1],
          rangeOutput: [
            nextRect.origin[keyPath: self.currentModalConfig.secondarySwipeAxis],
            secondaryAxis
          ]
        );
        
        return secondaryAxisAdj ?? secondaryAxis;
      }();
      
      let nextOrigin: CGPoint = {
        if self.currentModalConfig.snapDirection.isVertical {
          return CGPoint(
            x: secondaryAxisAdj,
            y: nextRect.origin.y
          );
        };
        
        return CGPoint(
          x: nextRect.origin.x,
          y: secondaryAxisAdj
        );
      }();
      
      return CGRect(
        origin: nextOrigin,
        size: nextRect.size
      );
    }();
    
    self._applyInterpolationToModalPadding(
      forInputPercentValue: inputPercentValue
    );
    
    self._applyInterpolationToModalDragHandleSize(
      forInputPercentValue: inputPercentValue
    );
    
    self._applyInterpolationToModalDragHandleOffset(
      forInputPercentValue: inputPercentValue
    );
    
    block:
    if self.currentModalConfig.shouldSetModalScrollViewContentInsets,
       let modalContentScrollView = self.modalContentScrollView {
       
      let interpolatedInsets = AdaptiveModalUtilities.interpolateEdgeInsets(
        inputValue: inputPercentValue,
        rangeInput: rangeInput,
        rangeOutput: AdaptiveModalUtilities.extractValuesFromArray(
          for: self.interpolationSteps,
          key: \.computedModalScrollViewContentInsets
        )
      );
      
      guard let interpolatedInsets = interpolatedInsets else { break block };
      
      modalContentScrollView.contentInset = interpolatedInsets;
      modalContentScrollView.adjustedContentInsetDidChange();
    };
    
    block:
    if self.currentModalConfig.shouldSetModalScrollViewVerticalScrollIndicatorInsets,
       let modalContentScrollView = self.modalContentScrollView {
       
      guard #available(iOS 11.1, *) else { break block };
       
      let interpolatedInsets = AdaptiveModalUtilities.interpolateEdgeInsets(
        inputValue: inputPercentValue,
        rangeInput: rangeInput,
        rangeOutput: AdaptiveModalUtilities.extractValuesFromArray(
          for: self.interpolationSteps,
          key: \.computedModalScrollViewVerticalScrollIndicatorInsets
        )
      );
      
      guard let interpolatedInsets = interpolatedInsets else { break block };
      modalContentScrollView.verticalScrollIndicatorInsets = interpolatedInsets;
    };
    
    block:
    if self.currentModalConfig.shouldSetModalScrollViewHorizontalScrollIndicatorInsets,
       let modalContentScrollView = self.modalContentScrollView {
       
      guard #available(iOS 11.1, *) else { break block };
      
      let interpolatedInsets = AdaptiveModalUtilities.interpolateEdgeInsets(
        inputValue: inputPercentValue,
        rangeInput: rangeInput,
        rangeOutput: AdaptiveModalUtilities.extractValuesFromArray(
          for: self.interpolationSteps,
          key: \.computedModalScrollViewHorizontalScrollIndicatorInsets
        )
      );
       
      guard let interpolatedInsets = interpolatedInsets else { break block };
      modalContentScrollView.horizontalScrollIndicatorInsets = interpolatedInsets;
    };
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperTransformView,
      forPropertyKey: \.layer.transform,
      withValue: {
        let transform3D = AdaptiveModalUtilities.interpolateTransform3D(
          inputValue: inputPercentValue,
          rangeInput: rangeInput,
          rangeOutput: AdaptiveModalUtilities.extractValuesFromArray(
            for: self.interpolationSteps,
            key: \.modalTransform
          ),
          shouldClampMinTranslateX: clampingKeysMin.contains(.modalTransformTranslateX),
          shouldClampMaxTranslateX: clampingKeysMax.contains(.modalTransformTranslateX),
          shouldClampMinTranslateY: clampingKeysMin.contains(.modalTransformTranslateY),
          shouldClampMaxTranslateY: clampingKeysMax.contains(.modalTransformTranslateY),
          shouldClampMinTranslateZ: clampingKeysMin.contains(.modalTransformTranslateZ),
          shouldClampMaxTranslateZ: clampingKeysMax.contains(.modalTransformTranslateZ),
          shouldClampMinScaleX: clampingKeysMin.contains(.modalTransformTranslateX),
          shouldClampMaxScaleX: clampingKeysMax.contains(.modalTransformTranslateX),
          shouldClampMinScaleY: clampingKeysMin.contains(.modalTransformScaleY),
          shouldClampMaxScaleY: clampingKeysMax.contains(.modalTransformScaleY),
          shouldClampMinRotationX: clampingKeysMin.contains(.modalTransformRotateX),
          shouldClampMaxRotationX: clampingKeysMax.contains(.modalTransformRotateX),
          shouldClampMinRotationY: clampingKeysMin.contains(.modalTransformRotateY),
          shouldClampMaxRotationY: clampingKeysMax.contains(.modalTransformRotateY),
          shouldClampMinRotationZ: clampingKeysMin.contains(.modalTransformRotateZ),
          shouldClampMaxRotationZ: clampingKeysMax.contains(.modalTransformRotateZ),
          shouldClampMinPerspective: clampingKeysMin.contains(.modalTransformPerspective),
          shouldClampMaxPerspective: clampingKeysMax.contains(.modalTransformPerspective),
          shouldClampMinSkewX: clampingKeysMin.contains(.modalTransformSkewX),
          shouldClampMaxSkewX: clampingKeysMax.contains(.modalTransformSkewX),
          shouldClampMinSkewY: clampingKeysMin.contains(.modalTransformSkewY),
          shouldClampMaxSkewY: clampingKeysMax.contains(.modalTransformSkewY)
        );
        
        return transform3D?.transform;
      }()
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: modalView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalContentOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperLayoutView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.borderWidth,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBorderWidth
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.borderColor,
      withValue: {
        let color = self._interpolateColor(
          inputValue: inputPercentValue,
          rangeOutputKey: \.modalBorderColor
        );
        
        return color?.cgColor;
      }()
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.shadowColor,
      withValue:  {
        let color = self._interpolateColor(
          inputValue: inputPercentValue,
          rangeOutputKey: \.modalShadowColor
        );
        
        return color?.cgColor;
      }()
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.shadowOffset,
      withValue: {
        AdaptiveModalUtilities.interpolateSize(
          inputValue: inputPercentValue,
          rangeInput: rangeInput,
          rangeOutput: AdaptiveModalUtilities.extractValuesFromArray(
            for: self.interpolationSteps,
            key: \.modalShadowOffset
          )
        )
      }()
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.shadowOpacity,
      withValue: {
        let value = self._interpolate(
          inputValue: inputPercentValue,
          rangeOutputKey: \.modalShadowOpacity
        );
        
        guard let value = value else { return nil };
        return Float(value);
      }()
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.shadowRadius,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalShadowRadius
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalContentWrapperView,
      forPropertyKey: \.layer.cornerRadius,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalCornerRadius
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundView,
      forPropertyKey: \.backgroundColor,
      withValue:  self._interpolateColor(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBackgroundColor
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBackgroundOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundVisualEffectView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBackgroundVisualEffectOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundVisualEffectView,
      forPropertyKey: \.layer.cornerRadius,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalCornerRadius
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalDragHandleView,
      forPropertyKey: \.backgroundColor,
      withValue:  self._interpolateColor(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalDragHandleColor
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalDragHandleView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalDragHandleOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalDragHandleView,
      forPropertyKey: \.layer.cornerRadius,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalDragHandleCornerRadius
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.backgroundDimmingView,
      forPropertyKey: \.backgroundColor,
      withValue:  self._interpolateColor(
        inputValue: inputPercentValue,
        rangeOutputKey: \.backgroundColor
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.backgroundDimmingView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.backgroundOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.backgroundVisualEffectView,
      forPropertyKey: \.alpha,
      withValue:  self._interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.backgroundVisualEffectOpacity
      )
    );
    
    self._applyInterpolationToRangeAnimators(
      forInputPercentValue: inputPercentValue
    );
    
    self.animationEventDelegate.invoke {
      $0.notifyOnModalAnimatorPercentChanged(
        sender: self,
        percent: inputPercentValue
      );
    };
    
    #if DEBUG
    self.debugView?.notifyOnApplyInterpolationToModal();
    #endif
  };
  
  func _applyInterpolationToModal(forPoint point: CGPoint) {
    guard let interpolationRangeMaxInput = self.interpolationRangeMaxInput
    else { return };
    
    let inputValue = point[keyPath: self.currentModalConfig.inputValueKeyForPoint];
    
    let shouldInvertPercent: Bool = {
      switch currentModalConfig.snapDirection {
        case .bottomToTop, .rightToLeft: return true;
        default: return false;
      };
    }();
    
    let percent = inputValue / interpolationRangeMaxInput;
    
    let percentClamped: CGFloat = {
      guard !self.shouldEnableOverShooting else { return percent };
      
      let secondToLastIndex = self.currentModalConfig.snapPointLastIndex - 1;
      let maxPercent = self.interpolationRangeInput[secondToLastIndex];
      
      return percent.clamped(max: maxPercent);
    }();
    
    let percentAdj = shouldInvertPercent
      ? AdaptiveModalUtilities.invertPercent(percentClamped)
      : percentClamped;
      
    self._applyInterpolationToModal(forInputPercentValue: percentAdj);
  };
  
  func _applyInterpolationToModal(forGesturePoint gesturePoint: CGPoint) {
    let gesturePointWithOffset =
      self._applyGestureOffsets(forGesturePoint: gesturePoint);
      
    if !self.shouldLockAxisToModalDirection {
      self._modalSecondaryAxisValue =
        gesturePointWithOffset[keyPath: self.currentModalConfig.secondarySwipeAxis];
    };
  
    self._applyInterpolationToModal(forPoint: gesturePointWithOffset);
  };
  
  // MARK: - Functions - Helpers/Utilities
  // -------------------------------------
  
  func _stopModalAnimator(){
    self._endDisplayLink();
    
    guard let modalAnimator = self._modalAnimator,
          modalAnimator.isRunning
    else { return };
    
    modalAnimator.stopAnimation(false);
    self._modalAnimator = nil;
    
    self.animationEventDelegate.invoke {
      $0.notifyOnModalAnimatorStop(sender: self);
    };
  };
  
  func _adjustInterpolationIndex(for nextIndex: Int) -> Int {
    if nextIndex == 0 {
      return self.canSnapToUnderShootSnapPoint
        ? 0
        : nextIndex + 1;
    };
    
    if let lastSnapPoint = self.currentSnapPoints.last,
       lastSnapPoint.type == .overshootSnapPoint,
       nextIndex >= lastSnapPoint.index,
       self.currentSnapPoints.count >= 3  {
      
      return self.canSnapToOverShootSnapPoint
        ? nextIndex
        : nextIndex - 1;
    };
    
    return nextIndex;
  };
  
  func _applyGestureOffsets(
    forGesturePoint gesturePoint: CGPoint
  ) -> CGPoint {
  
    guard let computedGestureOffset = self.computedGestureOffset
    else { return gesturePoint };
    
    let x: CGFloat = {
      switch self.currentModalConfig.snapDirection {
        case .leftToRight:
          return gesturePoint.x + computedGestureOffset.x;
          
        case .rightToLeft:
          return gesturePoint.x - computedGestureOffset.x;
      
        case .bottomToTop, .topToBottom:
          // secondary axis
          return gesturePoint.x - computedGestureOffset.x;
      };
    }();
    
    let y: CGFloat = {
      switch self.currentModalConfig.snapDirection {
        case .topToBottom:
          return gesturePoint.y + computedGestureOffset.y;
          
        case .bottomToTop:
          return gesturePoint.y - computedGestureOffset.y;
          
        case .leftToRight, .rightToLeft:
          // secondary axis
          return gesturePoint.y - computedGestureOffset.y;
      };
    }();
    
    return CGPoint(x: x, y: y);
  };
  
  func _debug(prefix: String? = ""){
    print(
        "\n - AdaptiveModalManager.debug - \(prefix ?? "N/A")"
      + "\n - modalView: \(self.modalView?.debugDescription ?? "N/A")"
      + "\n - modalView frame: \(self.modalView?.frame.debugDescription ?? "N/A")"
      + "\n - modalView superview: \(self.modalView?.superview.debugDescription ?? "N/A")"
      + "\n - rootView: \(self.rootView?.debugDescription ?? "N/A")"
      + "\n - rootView frame: \(self.rootView?.frame.debugDescription ?? "N/A")"
      + "\n - rootView superview: \(self.rootView?.superview.debugDescription ?? "N/A")"
      + "\n - modalViewController: \(self.modalViewController?.debugDescription ?? "N/A")"
      + "\n - presentingViewController: \(self.presentingViewController?.debugDescription ?? "N/A")"
      + "\n - currentInterpolationIndex: \(self.currentInterpolationIndex)"
      + "\n - currentOverrideInterpolationIndex: \(self.currentOverrideInterpolationIndex)"
      + "\n - currentConfigInterpolationIndex: \(self.currentConfigInterpolationIndex)"
      + "\n - currentInterpolationStep: computedRect \(self.currentInterpolationStep.computedRect)"
      + "\n - currentConfigInterpolationStep computedRect: \(self.currentConfigInterpolationStep.computedRect)"
      + "\n - currentOverrideInterpolationStep computedRect: \(self.currentOverrideInterpolationStep?.computedRect.debugDescription ?? "N/A")"
      + "\n - currentOverrideInterpolationStep modalPadding: \(self.currentOverrideInterpolationStep?.modalPadding ?? .zero)"
      + "\n - modalView gestureRecognizers: \(self.modalView?.gestureRecognizers.debugDescription ?? "N/A")"
      + "\n - isOverridingSnapPoints: \(self.isOverridingSnapPoints)"
      + "\n - shouldUseOverrideSnapPoints: \(self.shouldUseOverrideSnapPoints)"
      + "\n - shouldClearOverrideSnapPoints: \(self.shouldClearOverrideSnapPoints)"
      + "\n - layoutKeyboardValues: \(self._layoutKeyboardValues.debugDescription )"
      + "\n - presentationState: \(self.presentationState )"
      + "\n - interpolationSteps.computedRect: \(self.interpolationSteps.map({ $0.computedRect }))"
      + "\n - configInterpolationSteps.computedRect: \(self.configInterpolationSteps.map({ $0.computedRect }))"
      + "\n - overrideInterpolationPoints.computedRect: \((self.overrideInterpolationPoints ?? []).map({ $0.computedRect }))"
      + "\n - interpolationSteps.percent: \(self.interpolationSteps.map({ $0.percent }))"
      + "\n - interpolationSteps.backgroundVisualEffectIntensity: \(self.interpolationSteps.map({ $0.backgroundVisualEffectIntensity }))"
      + "\n - interpolationSteps.backgroundVisualEffect: \(self.interpolationSteps.map({ $0.backgroundVisualEffect }))"
      + "\n"
    );
  };
  
  // MARK: - Functions
  // -----------------
  
  func _computeSnapPoints(
    usingLayoutValueContext context: ComputableLayoutValueContext? = nil
  ) {
    let context = context ?? self._layoutValueContext;
    let modalConfig = self.currentModalConfig;
    
    self.configInterpolationSteps = .Element.compute(
      usingConfig: modalConfig,
      usingContext: context
    );
    
    if let overrideSnapPoints = self.overrideSnapPoints {
      self.overrideInterpolationPoints = .Element.compute(
        usingConfig: modalConfig,
        usingContext: context,
        snapPoints: overrideSnapPoints
      );
    };
  };
  
  func _updateCurrentModalConfig(){
    let context = self._layoutValueContext.evaluableConditionContext;
    
    let nextConfig: AdaptiveModalConfig = {
      switch self.modalConfig {
        case let .adaptiveConfig(defaultConfig, constrainedConfigs):
          let match = constrainedConfigs.first {
            $0.evaluateConstraints(usingContext: context);
          };
          
          return match?.config ?? defaultConfig;
          
        case let .staticConfig(config):
          return config;
      };
    }();
  
    let prevConfig = self._currentModalConfig;
    guard prevConfig != nextConfig else { return };
    
    self.prevModalConfig = prevConfig;
    self._currentModalConfig = nextConfig;
    
    self._pendingCurrentModalConfigUpdate = self.currentInterpolationIndex > 0;
    self._notifyOnCurrentModalConfigDidChange();
  };
  
  func _updateModal() {
    guard !self.isAnimating else { return };
        
    if let gesturePoint = self.gesturePoint {
      self._applyInterpolationToModal(forGesturePoint: gesturePoint);
    
    } else if self.currentInterpolationStep.computedRect != self.modalFrame {
      self.currentInterpolationStep.applyAnimation(toModalManager: self);
    };
    
    #if DEBUG
    self.debugView?.notifyOnUpdateModal();
    #endif
  };
  
  func _getClosestSnapPoint(
    forCoord coord: CGFloat? = nil,
    shouldIgnoreAllowSnapping: Bool = false
  ) -> (
    interpolationPoint: AdaptiveModalInterpolationPoint,
    snapDistance: CGFloat
  )? {
  
    guard let inputRect = self.modalFrame else { return nil };
    
    let inputCoord = coord ??
      inputRect[keyPath: self.currentModalConfig.inputValueKeyForRect];
      
    let interpolationSteps: [AdaptiveModalInterpolationPoint] = {
      guard !shouldIgnoreAllowSnapping else {
        return self.interpolationSteps;
      };
      
      return self.interpolationSteps.filter {
        $0.allowSnapping
      };
    }();
    
    let delta = interpolationSteps.map {
      let coord = $0.computedRect[
        keyPath: self.currentModalConfig.inputValueKeyForRect
      ];
      
      return (
        index: $0.snapPoint.index,
        delta: abs(inputCoord - coord)
      );
    };
    
    let deltaSorted = delta.sorted {
      $0.delta < $1.delta
    };
    
    let closestInterpolationIndex: Int = {
      let firstIndex = deltaSorted.first?.index
        ?? self.currentInterpolationIndex;
    
      guard !shouldIgnoreAllowSnapping else {
        return firstIndex;
      };
      
      return self._adjustInterpolationIndex(for: firstIndex);
    }();

    let interpolationPoint =
      self.interpolationSteps[closestInterpolationIndex];
    
    return (
      interpolationPoint: interpolationPoint,
      snapDistance: delta[closestInterpolationIndex].delta
    );
  };
  
  func _getClosestSnapPoint(
    forRect currentRect: CGRect,
    shouldIgnoreAllowSnapping: Bool = false,
    shouldExcludeUndershootSnapPoint: Bool
  ) -> (
    interpolationPoint: AdaptiveModalInterpolationPoint,
    snapDistance: CGFloat
  )? {
  
    let interpolationSteps: [AdaptiveModalInterpolationPoint] = {
      guard !shouldIgnoreAllowSnapping else {
        if shouldExcludeUndershootSnapPoint {
          return self.interpolationSteps.filter {
            $0.snapPoint.type != .undershootSnapPoint;
          };
        };
        
        return self.interpolationSteps;
      };
      
      return self.interpolationSteps.filter {
        return shouldExcludeUndershootSnapPoint
          ? $0.allowSnapping && $0.snapPoint.type != .undershootSnapPoint
          : $0.allowSnapping
      };
    }();
  
    let keysToComputeDelta: [KeyPath<CGRect, CGFloat>] = [
      \.minX, \.midX, \.maxX, \.width ,
      \.minY, \.midY, \.maxY, \.height,
    ];
  
    let delta = interpolationSteps.map { item in
      let deltas = keysToComputeDelta.map {
        abs(item.computedRect[keyPath: $0] - currentRect[keyPath: $0]);
      };
      
      return (
        snapPointIndex: item.snapPoint.index,
        deltas: deltas
      );
    };
    
    let deltaAvg = delta.map {
      let sum = $0.deltas.reduce(0) { $0 + $1 };
      
      return (
        snapPointIndex: $0.snapPointIndex,
        delta: sum / CGFloat(keysToComputeDelta.count)
      );
    };
    
    let deltaAvgIndexed = deltaAvg.enumerated().map {(
      offset: $0.offset,
      snapPointIndex: $0.element.snapPointIndex,
      delta: $0.element.delta
    )};
    
    let deltaAvgSorted = deltaAvgIndexed.sorted {
      $0.delta < $1.delta;
    };
    
    guard let firstMatch = deltaAvgSorted.first else {
      return nil;
    };
    
    let closestInterpolationPointIndex = self._adjustInterpolationIndex(
      for: firstMatch.snapPointIndex
    );
    
    let closestInterpolationPoint =
      self.interpolationSteps[closestInterpolationPointIndex];
      
    return (
      interpolationPoint: closestInterpolationPoint,
      snapDistance: deltaAvg[firstMatch.offset].delta
    );
  };
  
  func _animateModal(
    to interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool = true,
    animationConfigOverride: AnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: ((UIViewAnimatingPosition) -> Void)? = nil
  ) {
  
    let animationBlock = {
      extraAnimation?();
        
      interpolationPoint.applyAnimation(toModalManager: self);
    };
    
    #if DEBUG
    self.debugView?.notifyOnAnimateModal(interpolationPoint: interpolationPoint);
    #endif
    
    self.modalWrapperLayoutView?.layoutIfNeeded();
    
    let startAnimation = {
      guard isAnimated else {
        // not animated, immediately apply animation
        return {
          animationBlock();
        
          interpolationPoint.applyAnimation(
            toModalBackgroundEffectView: self.modalBackgroundVisualEffectView,
            toBackgroundVisualEffectView: self.backgroundVisualEffectView
          );
        
          extraAnimation?();
          completion?(.end);
          
          #if DEBUG
          self.debugView?.notifyOnAnimateModalCompletion();
          #endif
        };
      };
      
      let snapAnimationConfig = animationConfigOverride
        ?? self.currentModalConfig.snapAnimationConfig;
      
      let animator = snapAnimationConfig.createAnimator(
        gestureInitialVelocity: self.gestureInitialVelocity
      );
      
      self._stopModalAnimator();
      self._modalAnimator = animator;
      
      animator.addAnimations {
        animationBlock();
      };
      
      if let completion = completion {
        animator.addCompletion(completion);
      };
      
      animator.addCompletion { position in
        self.animationEventDelegate.invoke {
          $0.notifyOnModalAnimatorCompletion(
            sender: self,
            position: position
          );
        };
      };
      
      animator.addCompletion { _ in
        self._stopModalAnimator();
        
        #if DEBUG
        self.debugView?.notifyOnAnimateModalCompletion();
        #endif
      };
      
      return {
        animator.startAnimation();
        self._startDisplayLink(shouldAutoEndDisplayLink: true);
      };
    }();
    
    self.animationEventDelegate.invoke {
      $0.notifyOnModalAnimatorStart(
        sender: self,
        animator: self._modalAnimator,
        interpolationPoint: interpolationPoint,
        isAnimated: isAnimated
      );
    };
    
    startAnimation();
  };
  
  func _cancelModalGesture(){
    guard let modalGesture = self.modalGesture else { return };
    let currentValue = modalGesture.isEnabled;
    
    modalGesture.isEnabled = false;
    modalGesture.isEnabled = currentValue;
    
    if let modalDragHandleGesture = self.modalDragHandleGesture {
      modalDragHandleGesture.isEnabled = false;
      modalDragHandleGesture.isEnabled = currentValue;
    };
  };
  
  // MARK: - Functions - DisplayLink-Related
  // ---------------------------------------
    
  func _startDisplayLink(shouldAutoEndDisplayLink: Bool) {
    self.shouldAutoEndDisplayLink = shouldAutoEndDisplayLink;
    
    let displayLink = CADisplayLink(
      target: self,
      selector: #selector(self._onDisplayLinkTick(displayLink:))
    );
    
    self.displayLink = displayLink;
    
    if #available(iOS 15.0, *) {
      displayLink.preferredFrameRateRange = CAFrameRateRange(
        minimum: 60,
        maximum: 120
      );
      
    } else {
      displayLink.preferredFramesPerSecond = 60;
    };
    
    displayLink.add(to: .current, forMode: .common);
  };
  
  func _endDisplayLink() {
    self.shouldAutoEndDisplayLink = true;
    self.displayLink?.invalidate();
  };
  
  @objc func _onDisplayLinkTick(displayLink: CADisplayLink) {
    var shouldEndDisplayLink = false;
    
    defer {
      #if DEBUG
      self.debugView?.notifyOnDisplayLinkTick();
      #endif
    
      if shouldEndDisplayLink && self.shouldAutoEndDisplayLink {
        self._endDisplayLink();
      };
    };
    
    if self.isSwiping && !self._isKeyboardVisible {
      shouldEndDisplayLink = true;
    };
    
    if self.displayLinkStartTimestamp == nil {
      self.displayLinkStartTimestamp = displayLink.timestamp;
    };
    
    guard let dummyModalView = self.dummyModalView,
          let dummyModalViewLayer = dummyModalView.layer.presentation()
    else {
      shouldEndDisplayLink = true;
      return;
    };
    
    let percent: CGFloat? = {
      switch self.rangeAnimatorMode {
        case .modalPosition:
          guard let interpolationRangeMaxInput = self.interpolationRangeMaxInput
          else { return nil };
          
          let prevModalFrame = self.prevModalFrame;
          let nextModalFrame = dummyModalViewLayer.frame;
          
          guard prevModalFrame != nextModalFrame else { return nil };
          self.prevModalFrame = nextModalFrame;
          
          let inputCoord =
            nextModalFrame[keyPath: self.currentModalConfig.inputValueKeyForRect];
            
          let percent = inputCoord / interpolationRangeMaxInput;
          
          let percentAdj = self.currentModalConfig.shouldInvertPercent
            ? AdaptiveModalUtilities.invertPercent(percent)
            : percent;
            
          return percentAdj;
          
        case .animatorFractionComplete:
          guard let modalAnimator = self._modalAnimator else { return nil };
          return AdaptiveModalUtilities.invertPercent(modalAnimator.fractionComplete);
      };
    }();
    
    guard let percent = percent else { return };
    
    self._applyInterpolationToRangeAnimators(
      forInputPercentValue: percent
    );
    
    if self.isAnimatingWithViewPropertyAnimatorDiscrete {
      self._applyInterpolationToModal(
        forInputPercentValue: percent
      );
    };
    
    self.displayLinkEventsDelegate?.onDisplayLinkTick(
      sender: self,
      displayLink: displayLink,
      modalFrame: dummyModalViewLayer.frame
    );
  };

  // MARK: - Functions - Internal Modal Controls
  // -------------------------------------------
    
  func snapTo(
    interpolationIndex nextIndex: Int,
    interpolationPoint: AdaptiveModalInterpolationPoint? = nil,
    isAnimated: Bool = true,
    animationConfig: AnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    self.nextInterpolationIndex = nextIndex;
  
    let nextInterpolationPoint = interpolationPoint
      ?? self.interpolationSteps[nextIndex];
    
    self._notifyOnModalWillSnap(shouldSetState: shouldSetStateOnSnap);
    
    if let stateSnapping = stateSnapping {
      self.modalStateMachine.setState(stateSnapping);
    };
    
    let shouldOverrideAnimationMode = {
      let isPresentingOrDismissing =
           self.modalState.isPresenting
        || self.modalState.isDismissing;
    
      if isPresentingOrDismissing || self.modalState.isProgrammatic {
        return true;
      };
      
      guard let modalFrame = self.modalFrame else { return false };
      
      let modalCoordCurrent = modalFrame[
        keyPath: self.currentModalConfig.inputValueKeyForRect
      ];
        
      let modalCoordNext = nextInterpolationPoint.computedRect[
        keyPath: self.currentModalConfig.inputValueKeyForRect
      ];
      
      let modalCoordDelta = abs(modalCoordCurrent - modalCoordNext);
      
      let MIN_DELTA: CGFloat = 200;
      return modalCoordDelta <= MIN_DELTA;
    }();
    
    if shouldOverrideAnimationMode {
      self._animationModeOverride = .viewPropertyAnimatorContinuous;
    };
    
    self._animateModal(
      to: nextInterpolationPoint,
      isAnimated: isAnimated,
      animationConfigOverride: animationConfig,
      extraAnimation: extraAnimation
    ) { _ in
    
      self.currentInterpolationIndex = nextIndex;
      self.nextInterpolationIndex = nil;
      
      self._notifyOnModalDidSnap(shouldSetState: shouldSetStateOnSnap);
      
      if let stateSnapped = stateSnapped {
        self.modalStateMachine.setState(stateSnapped);
      };
      
      self._animationModeOverride = nil;
      completion?();
    }
  };
  
  func snapToClosestSnapPoint(
    forPoint point: CGPoint,
    direction: AdaptiveModalConfig.SnapDirection?,
    animationConfig: AnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    completion: (() -> Void)? = nil
  ) {
    
    let coord = point[keyPath: self.currentModalConfig.inputValueKeyForPoint];
    let closestSnapPoint = self._getClosestSnapPoint(forCoord: coord)
      
    guard let closestSnapPoint = closestSnapPoint else { return };
    
    let nextInterpolationIndex = self._adjustInterpolationIndex(
      for: closestSnapPoint.interpolationPoint.snapPoint.index
    );
    
    let nextInterpolationPoint =
      self.interpolationSteps[nextInterpolationIndex];
 
    let prevFrame = self.modalFrame;
    let nextFrame = nextInterpolationPoint.computedRect;
    
    guard prevFrame != nextFrame else {
      completion?();
      return;
    };
   
    self.snapTo(
      interpolationIndex: nextInterpolationIndex,
      animationConfig: animationConfig,
      shouldSetStateOnSnap: shouldSetStateOnSnap,
      stateSnapping: stateSnapping,
      stateSnapped: stateSnapped,
      completion: completion
    );
  };
  
  func showModal(
    snapPointIndex: Int? = nil,
    isAnimated: Bool = true,
    animationConfig: AnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let nextIndex = snapPointIndex ??
      self.currentModalConfig.initialSnapPointIndex;

    self.snapTo(
      interpolationIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      shouldSetStateOnSnap: shouldSetStateOnSnap,
      stateSnapping: stateSnapping,
      stateSnapped: stateSnapped,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func hideModal(
    mode: HideModalMode,
    isAnimated: Bool = true,
    animationConfig: AnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ){
  
    let nextIndex = 0;
    
    self._stopModalAnimator();
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
    
    let undershootSnapPoint: AdaptiveModalSnapPointPreset? = {
      switch mode {
        case .direct:
          return self.currentModalConfig.undershootSnapPoint;
          
        case let .snapPointPreset(snapPointPreset):
          if snapPointPreset.keyframeConfig == nil {
            return .init(
              layoutPreset: snapPointPreset.layoutPreset,
              keyframeConfig: .defaultUndershootKeyframe
            );
          };
          
          return snapPointPreset;
          
        case let .keyframe(keyframe):
          return .init(
            layoutPreset: .layoutConfig(
              self.currentSnapPoint.layoutConfig
            ),
            keyframeConfig: keyframe
          );
          
        default:
          return nil;
      };
    }();
    
    if let undershootSnapPoint = undershootSnapPoint {
      self._clearAnimators();
    
      let currentSnapPointConfig: AdaptiveModalSnapPointConfig = {
        var newKeyframe = AdaptiveModalKeyframeConfig(
          fromInterpolationPoint: self.currentInterpolationStep
        );
        
        newKeyframe.computedRect = nil;
        
        return AdaptiveModalSnapPointConfig(
          key: self.currentSnapPoint.key,
          layoutConfig: self.currentSnapPoint.layoutConfig,
          keyframeConfig: newKeyframe
        );
      }();
      
      let snapPoints = AdaptiveModalSnapPoint.deriveSnapPoints(
        undershootSnapPoint: undershootSnapPoint,
        inBetweenSnapPoints: [currentSnapPointConfig],
        overshootSnapPoint: nil
      );

      self.overrideSnapPoints = snapPoints;
      
      self.overrideInterpolationPoints = {
        var points = AdaptiveModalInterpolationPoint.compute(
          usingConfig: self.currentModalConfig,
          usingContext: self._layoutValueContext,
          snapPoints: overrideSnapPoints,
          shouldCheckForPercentCollision: false
        );
        
        let lastIndex = points.count - 1;
        
        for index in 0 ..< points.count {
          points[index].percent =  CGFloat(index) / CGFloat(lastIndex);
        };
        
        return points;
      }();
      
      let undershootInterpolationPoint =
        self.overrideInterpolationPoints![nextIndex];
      
      self.isOverridingSnapPoints = true;
      self.currentOverrideInterpolationIndex = 1;
      
      self._shouldResetRangePropertyAnimators = true;
      self.rangeAnimatorMode = .animatorFractionComplete;
      
      self.snapTo(
        interpolationIndex: nextIndex,
        interpolationPoint: undershootInterpolationPoint,
        isAnimated: isAnimated,
        animationConfig: animationConfig,
        shouldSetStateOnSnap: shouldSetStateOnSnap,
        stateSnapping: stateSnapping,
        stateSnapped: stateSnapped,
        extraAnimation: extraAnimation,
        completion: {
          self.rangeAnimatorMode = .modalPosition;
          completion?();
        }
      );
    
    } else {
      self.snapTo(
        interpolationIndex: nextIndex,
        isAnimated: isAnimated,
        animationConfig: animationConfig,
        shouldSetStateOnSnap: shouldSetStateOnSnap,
        stateSnapping: stateSnapping,
        stateSnapped: stateSnapped,
        extraAnimation: extraAnimation,
        completion: completion
      );
    };
  };
  
  func presentModal(
    viewControllerToPresent modalVC: UIViewController,
    presentingViewController targetVC: UIViewController,
    snapPointIndex: Int? = nil,
    animated: Bool = true,
    animationConfig: AnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let animationConfig = animationConfig
      ?? self.currentModalConfig.entranceAnimationConfig;
    
    self._tempShowModalCommandArgs = (
      isAnimated: animated,
      snapPointIndex: snapPointIndex,
      animationConfig: animationConfig,
      shouldSetStateOnSnap: shouldSetStateOnSnap,
      stateSnapping: stateSnapping,
      stateSnapped: stateSnapped,
      extraAnimationBlock: extraAnimation
    );
    
    self.prepareForPresentation(
      viewControllerToPresent: modalVC,
      presentingViewController: targetVC
    );
    
    guard let presentedVC = self.presentedViewController else { return };

    targetVC.present(
      presentedVC,
      animated: true,
      completion: {
        completion?();
      }
    );
  };
};
