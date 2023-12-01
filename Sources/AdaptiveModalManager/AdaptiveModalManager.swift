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

  public enum PresentationState {
    case presenting, dismissing, none;
  };
  
  /// `self.hideModal` param
  enum HideModalMode: Equatable {
    case direct, inBetween;
    
    case snapPointPreset(AdaptiveModalSnapPointPreset);
    case keyframe(AdaptiveModalKeyframeConfig);
  };
  
  enum ModalRangePropertyAnimatorMode: Equatable {
    case modalPosition;
    case animatorFractionComplete;
  };
  
  // MARK: -  Properties - Config-Related
  // ------------------------------------
  
  public var modalConfig: AdaptiveModalConfigMode;
  
  private(set) public var prevModalConfig: AdaptiveModalConfig? = nil;
  
  private var _currentModalConfig: AdaptiveModalConfig?;
  public var currentModalConfig: AdaptiveModalConfig {
    switch self.modalConfig {
      case let .staticConfig(config):
        return config;
        
      case let .adaptiveConfig(defaultConfig, _):
        return self._currentModalConfig ?? defaultConfig;
    };
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
  
  private(set) public var dummyModalView: UIView?;
  
  private(set) public var modalWrapperLayoutView: AdaptiveModalWrapperView?;
  private(set) public var modalWrapperTransformView: AdaptiveModalWrapperView?;
  private(set) public var modalWrapperShadowView: AdaptiveModalWrapperView?;
  private(set) public var modalContentWrapperView: UIView?;
  
  public var modalDragHandleView: AdaptiveModalDragHandleView?;
  
  public weak var modalContentScrollView: UIScrollView?;
  
  public private(set) var prevModalFrame: CGRect = .zero;
  public private(set) var prevTargetFrame: CGRect = .zero;
  
  public private(set) var modalBackgroundView: UIView?;
  public private(set) var modalBackgroundVisualEffectView: UIVisualEffectView?;
  
  public private(set) var backgroundDimmingView: UIView?;
  public private(set) var backgroundVisualEffectView: UIVisualEffectView?;
  
  public private(set) var modalFrame: CGRect? {
    set {
      guard let newValue = newValue else { return };
      
      if let prevModalFrame = self.modalFrame {
        self.prevModalFrame = prevModalFrame;
      };
      
      guard !newValue.isNaN else { return };
      
      self.modalWrapperLayoutView?.frame = newValue;
      self.dummyModalView?.frame = newValue;
    }
    get {
      self.dummyModalView?.frame;
    }
  };
  
  private var modalSecondaryAxisValue: CGFloat? = nil;
  
  weak var modalConstraintLeft  : NSLayoutConstraint?;
  weak var modalConstraintRight : NSLayoutConstraint?;
  weak var modalConstraintTop   : NSLayoutConstraint?;
  weak var modalConstraintBottom: NSLayoutConstraint?;
  
  weak var modalDragHandleConstraintOffset: NSLayoutConstraint?;
  weak var modalDragHandleConstraintCenter: NSLayoutConstraint?;
  weak var modalDragHandleConstraintHeight: NSLayoutConstraint?;
  weak var modalDragHandleConstraintWidth : NSLayoutConstraint?;
  
  private var layoutKeyboardValues: ComputableLayoutKeyboardValues?;
  
  private var layoutValueContext: ComputableLayoutValueContext {
    let context: ComputableLayoutValueContext? = {
      if let targetVC = self.presentingViewController {
        return .init(
          fromTargetViewController: targetVC,
          keyboardValues: self.layoutKeyboardValues
        );
      };
      
      if let rootView = self.rootView {
        return .init(
          fromTargetView: rootView,
          keyboardValues: self.layoutKeyboardValues
        );
      };
      
      return nil;
    }();
    
    return context ?? .default;
  };
  
  private var isKeyboardVisible = false;
  
  var pendingCurrentModalConfigUpdate = false;
  
  // MARK: -  Properties - Config Interpolation Points
  // -------------------------------------------------
  
  /// The computed frames of the modal based on the snap points
  private(set) var configInterpolationSteps: [AdaptiveModalInterpolationPoint]!;
  
  var currentConfigInterpolationStep: AdaptiveModalInterpolationPoint {
    self.interpolationSteps[self.currentInterpolationIndex];
  };
  
  private var configInterpolationRangeInput: [CGFloat]! {
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
  
  private(set) var isOverridingSnapPoints = false;
  
  var prevOverrideInterpolationIndex = 0;
  var nextOverrideInterpolationIndex: Int?;
  
  var currentOverrideInterpolationIndex = 0 {
    didSet {
      self.prevOverrideInterpolationIndex = oldValue;
    }
  };
  
  var overrideSnapPoints: [AdaptiveModalSnapPointConfig]?;
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
  
  public private(set) var onModalWillSnapPrevIndex: Int?;
  public private(set) var onModalWillSnapNextIndex: Int?;
  
  public private(set) var prevInterpolationIndex: Int {
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
  
  public private(set) var nextInterpolationIndex: Int? {
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
  
  public private(set) var currentInterpolationIndex: Int {
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
      
      self.prevSnapPointConfig = {
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
  
  public private(set) var interpolationSteps: [AdaptiveModalInterpolationPoint]! {
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
  
  
  public private(set) var prevInterpolationStep: AdaptiveModalInterpolationPoint?;
  
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
  
  public var currentSnapPoints: [AdaptiveModalSnapPointConfig] {
    if self.shouldUseOverrideSnapPoints,
       let overrideSnapPoints = self.overrideSnapPoints {
      
      return overrideSnapPoints;
    };
  
    return self.currentModalConfig.snapPoints;
  };
  
  public private(set) var prevSnapPointConfig: AdaptiveModalSnapPointConfig?;
  
  public var currentSnapPointConfig: AdaptiveModalSnapPointConfig {
    return self.currentSnapPoints[
      self.currentInterpolationStep.snapPointIndex
    ];
  };
  
  // MARK: -  Properties - Animation-Related
  // ---------------------------------------
  
  weak var transitionContext: UIViewControllerContextTransitioning?;
  
  private var modalAnimator: UIViewPropertyAnimator?;

  var backgroundVisualEffectAnimator: AdaptiveModalRangePropertyAnimator?;
  var modalBackgroundVisualEffectAnimator: AdaptiveModalRangePropertyAnimator?;
  
  var displayLink: CADisplayLink?;
  var displayLinkStartTimestamp: CFTimeInterval?;
  
  var displayLinkEndTimestamp: CFTimeInterval? {
    guard let animator = self.modalAnimator,
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
  
  private var shouldResetRangePropertyAnimators = false;
  
  // MARK: -  Properties - Gesture-Related
  // -------------------------------------
  
  weak var modalGesture: UIPanGestureRecognizer?;
  weak var modalDragHandleGesture: UIPanGestureRecognizer?;
  weak var backgroundTapGesture: UITapGestureRecognizer?;
  weak var edgePanGesture: UIScreenEdgePanGestureRecognizer?;
  
  internal(set) public var gestureOffset: CGPoint?;
  internal(set) public var gestureVelocity: CGPoint?;
  internal(set) public var gestureInitialPoint: CGPoint?;
  
  internal(set) public var gesturePointPrev: CGPoint?;
  
  internal(set) public var gesturePoint: CGPoint? {
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
          self.showModalCommandArgs == nil
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
    return self.applyGestureOffsets(forGesturePoint: gesturePoint)
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
  
  internal(set) public var presentationState: PresentationState = .none;
  
  lazy var modalStateMachine = AdaptiveModalStateMachine(
    onStateWillChangeBlock: { [unowned self] in
      self.notifyOnModalStateWillChange($0, $1, $2);
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
    
  // MARK: -  Properties
  // -------------------
  
  /// Args for indirect call to `showModal` via `UIViewController.show`
  var showModalCommandArgs: (
    isAnimated: Bool,
    snapPointIndex: Int?,
    animationConfig: AdaptiveModalSnapAnimationConfig,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimationBlock: (() -> Void)?
  )?;
  
  /// Args for  indirect call to `hideModal` via `UIViewController.dismiss`
  var hideModalCommandArgs: (
    isAnimated: Bool,
    mode: HideModalMode,
    animationConfig: AdaptiveModalSnapAnimationConfig,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimationBlock: (() -> Void)?
  )?;
  
  private(set) var didTriggerSetup = false;
  
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
    self.modalAnimator?.isRunning ?? false;
  };
  
  public var currentSnapPointIndex: Int {
    self.currentInterpolationStep.snapPointIndex
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
  
  // MARK: - Functions - Setup
  // -------------------------
  
  func _setupObservers(){
    NotificationCenter.default.addObserver(self,
      selector: #selector(self._onKeyboardWillShow(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self._onKeyboardDidShow(notification:)),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    );

    NotificationCenter.default.addObserver(self,
      selector: #selector(self._onKeyboardWillHide(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self._onKeyboardDidHide(notification:)),
      name: UIResponder.keyboardDidHideNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self._onKeyboardWillChange(notification:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self._onKeyboardDidChange(notification:)),
      name: UIResponder.keyboardDidChangeFrameNotification,
      object: nil
    );
  };
  
  func _setupViewControllers() {
    guard let presentedVC = self.presentedViewController else { return };
  
    presentedVC.modalPresentationStyle = .custom;
    presentedVC.transitioningDelegate = self;
  };
  
  func _setupInitViews() {
    self.dummyModalView = UIView();
    
    self.modalWrapperLayoutView = {
      let wrapperView = AdaptiveModalWrapperView();
      wrapperView.modalManager = self;
      
      return wrapperView;
    }();
    
    self.modalWrapperTransformView = {
      let wrapperView = AdaptiveModalWrapperView();
      wrapperView.modalManager = self;
      
      return wrapperView;
    }();
    
    self.modalWrapperShadowView = {
      let wrapperView = AdaptiveModalWrapperView();
      wrapperView.modalManager = self;
      
      return wrapperView;
    }();
    
    self.modalContentWrapperView = UIView();
    
    self.modalBackgroundView = UIView();
    self.modalBackgroundVisualEffectView = UIVisualEffectView();
    
    self.backgroundDimmingView = UIView();
    self.backgroundVisualEffectView = UIVisualEffectView();
    
    if self.currentModalConfig.dragHandlePosition != .none {
      let dragHandle: AdaptiveModalDragHandleView = {
        if let dragHandleViewProvider = self.dragHandleViewProvider {
          return dragHandleViewProvider();
        };
        
        return .init();
      }();
      
      dragHandle.pointInsideHitSlop = self.currentModalConfig.dragHandleHitSlop;
      self.modalDragHandleView = dragHandle;
    };
  };
  
  func _setupGestureHandler() {
    guard let modalView = self.modalView else { return };
    modalView.gestureRecognizers?.removeAll();
    
    let gesture = UIPanGestureRecognizer(
      target: self,
      action: #selector(self._onDragPanGesture(_:))
    );
    
    self.modalGesture = gesture;
    gesture.isEnabled = self.isModalContentSwipeGestureEnabled;
    gesture.delegate = self;
    
    modalView.addGestureRecognizer(gesture);
    
    if let modalDragHandleView = self.modalDragHandleView {
      let gesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(self._onDragPanGesture(_:))
      );
    
      self.modalDragHandleGesture = gesture;
      gesture.isEnabled = self.isModalDragHandleGestureEnabled;
      
      modalDragHandleView.addGestureRecognizer(gesture);
    };
    
    if let bgDimmingView = self.backgroundDimmingView {
      let gesture = UITapGestureRecognizer(
        target: self,
        action: #selector(self._onBackgroundTapGesture(_:))
      );
      
      gesture.isEnabled = false;
      self.backgroundTapGesture = gesture;
      bgDimmingView.addGestureRecognizer(gesture);
    };
  };
  
  func _setupDummyModalView() {
    guard let rootView = self.rootView,
          let dummyModalView = self.dummyModalView
    else { return };
    
    dummyModalView.backgroundColor = .clear;
    dummyModalView.alpha = 0.1;
    dummyModalView.isUserInteractionEnabled = false;
    
    rootView.addSubview(dummyModalView);
  };

  func _setupAddViews() {
    guard let modalView = self.modalView,
          let modalWrapperView = self.modalWrapperView
    else { return };
    
    if let rootView = self.rootView,
       let modalWrapperView = self.modalWrapperView {
       
      rootView.addSubview(modalWrapperView);
    };
    
    if let bgVisualEffectView = self.backgroundVisualEffectView {
      modalWrapperView.addSubview(bgVisualEffectView);
      
      bgVisualEffectView.clipsToBounds = true;
      bgVisualEffectView.backgroundColor = .clear;
      bgVisualEffectView.isUserInteractionEnabled = false;
    };
    
    if let bgDimmingView = self.backgroundDimmingView {
      modalWrapperView.addSubview(bgDimmingView);
      
      bgDimmingView.clipsToBounds = true;
      bgDimmingView.backgroundColor = .black;
      bgDimmingView.alpha = 0;
    };
    
    let wrapperViews: [UIView] = {
      let views = [
        self.modalWrapperLayoutView,
        self.modalWrapperTransformView,
        self.modalWrapperShadowView,
        self.modalContentWrapperView,
        modalView,
      ];
      
      return views.compactMap { $0 };
    }();
    
    wrapperViews.enumerated().forEach {
      guard let prev = wrapperViews[safeIndex: $0.offset - 1] else {
        modalWrapperView.addSubview($0.element);
        return;
      };
      
      prev.addSubview($0.element);
    };
    
    let secondToLastIndex = wrapperViews.count - 2;
    let modalContentContainerView = wrapperViews[safeIndex: secondToLastIndex];
    
    guard let modalContentContainerView = modalContentContainerView
    else { return };
    
    modalContentContainerView.clipsToBounds = true;
    modalView.backgroundColor = .clear;
    
    if let modalBackgroundView = self.modalBackgroundView {
      modalContentContainerView.addSubview(modalBackgroundView);
      modalContentContainerView.sendSubviewToBack(modalBackgroundView);
      
      modalBackgroundView.backgroundColor =
        AdaptiveModalInterpolationPoint.defaultModalBackground;
      
      modalBackgroundView.isUserInteractionEnabled = false;
    };
    
    if let modalBGVisualEffectView = self.modalBackgroundVisualEffectView,
       let modalWrapperTransformView = self.modalWrapperTransformView {
       
      modalWrapperTransformView.addSubview(modalBGVisualEffectView);
      modalWrapperTransformView.sendSubviewToBack(modalBGVisualEffectView);
      
      modalBGVisualEffectView.clipsToBounds = true;
      modalBGVisualEffectView.backgroundColor = .clear;
    };
    
    if let modalDragHandleView = self.modalDragHandleView,
       let modalWrapperShadowView = self.modalWrapperShadowView {
       
      modalWrapperShadowView.addSubview(modalDragHandleView);
    };
    
    #if DEBUG
    if self.showDebugOverlay {
      let debugView = AdaptiveModalDebugOverlay(modalManager: self);
      self.debugView = debugView;
      
      modalWrapperView.addSubview(debugView);
    };
    #endif
  };
  
  func _setupDragHandleConstraints(shouldDeactivateOldConstraints: Bool){
    guard let modalDragHandleView = self.modalDragHandleView,
          let modalWrapperShadowView = self.modalWrapperShadowView
    else { return };
  
    modalDragHandleView.translatesAutoresizingMaskIntoConstraints = false;
    
    if shouldDeactivateOldConstraints {
      let dragHandleConstraintsKeys: [ReferenceWritableKeyPath<AdaptiveModalManager, NSLayoutConstraint?>] = [
        \.modalDragHandleConstraintOffset,
        \.modalDragHandleConstraintCenter,
        \.modalDragHandleConstraintHeight,
        \.modalDragHandleConstraintWidth ,
      ];
    
      let constraints = dragHandleConstraintsKeys.compactMap {
        self[keyPath: $0];
      };
    
      NSLayoutConstraint.deactivate(constraints);
    
      dragHandleConstraintsKeys.forEach {
        self[keyPath: $0] = nil;
      };
    };
    
    let dragHandleOffset: CGFloat = {
      guard let interpolationSteps = self.interpolationSteps,
            let undershoot = interpolationSteps.first
      else { return 0 };
      
      return undershoot.modalDragHandleOffset;
    }();
    
    let offsetConstraint: NSLayoutConstraint? = {
      switch self.currentModalConfig.dragHandlePosition {
        case .top:
          return modalDragHandleView.topAnchor.constraint(
            equalTo: modalWrapperShadowView.topAnchor,
            constant: dragHandleOffset
          );
          
        case .bottom:
          return modalDragHandleView.bottomAnchor.constraint(
            equalTo: modalWrapperShadowView.bottomAnchor,
            constant: dragHandleOffset
          );
          
        case .left:
          return modalDragHandleView.leftAnchor.constraint(
            equalTo: modalWrapperShadowView.leftAnchor,
            constant: dragHandleOffset
          );
          
        case .right:
          return modalDragHandleView.rightAnchor.constraint(
            equalTo: modalWrapperShadowView.rightAnchor,
            constant: dragHandleOffset
          );
          
        default:
          return nil;
      };
    }();
    
    var constraints: [NSLayoutConstraint] = [];
    
    if let offsetConstraint = offsetConstraint {
      constraints.append(offsetConstraint);
      self.modalDragHandleConstraintOffset = offsetConstraint;
    };
    
    let centerConstraint: NSLayoutConstraint? = {
      switch self.currentModalConfig.dragHandlePosition {
        case .top, .bottom:
          return modalDragHandleView.centerXAnchor.constraint(
            equalTo: modalWrapperShadowView.centerXAnchor
          );
          
        case .left, .right:
          return modalDragHandleView.centerYAnchor.constraint(
            equalTo: modalWrapperShadowView.centerYAnchor
          );
          
        default:
          return nil;
      };
    }();
    
    if let centerConstraint = centerConstraint {
      constraints.append(centerConstraint);
      self.modalDragHandleConstraintCenter = centerConstraint;
    };
    
    constraints += {
      let dragHandleSize = self.currentInterpolationStep.modalDragHandleSize;
      
      let heightConstraint = modalDragHandleView.heightAnchor.constraint(
        equalToConstant: dragHandleSize.height
      );
      
      let widthConstraint = modalDragHandleView.widthAnchor.constraint(
        equalToConstant: dragHandleSize.width
      );
      
      self.modalDragHandleConstraintHeight = heightConstraint;
      self.modalDragHandleConstraintWidth = widthConstraint;
      
      return [heightConstraint, widthConstraint];
    }();
    
    NSLayoutConstraint.activate(constraints);
  };
  
  func _setupViewConstraints() {
    guard let modalView = self.modalView,
          let modalWrapperView = self.modalWrapperView,
          
          let modalContentWrapperView = self.modalContentWrapperView
    else { return };
    
    if let rootView = self.rootView,
       let modalWrapperView = self.modalWrapperViewController?.view {
       
      modalWrapperView.translatesAutoresizingMaskIntoConstraints = false;
       
      NSLayoutConstraint.activate([
        modalWrapperView.topAnchor     .constraint(equalTo: rootView.topAnchor     ),
        modalWrapperView.bottomAnchor  .constraint(equalTo: rootView.bottomAnchor  ),
        modalWrapperView.leadingAnchor .constraint(equalTo: rootView.leadingAnchor ),
        modalWrapperView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
      ]);
    };
    
    if let bgVisualEffectView = self.backgroundVisualEffectView {
      bgVisualEffectView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        bgVisualEffectView.topAnchor     .constraint(equalTo: modalWrapperView.topAnchor     ),
        bgVisualEffectView.bottomAnchor  .constraint(equalTo: modalWrapperView.bottomAnchor  ),
        bgVisualEffectView.leadingAnchor .constraint(equalTo: modalWrapperView.leadingAnchor ),
        bgVisualEffectView.trailingAnchor.constraint(equalTo: modalWrapperView.trailingAnchor),
      ]);
    };
    
    let wrapperViews: [UIView] = {
      let views = [
        self.modalWrapperTransformView,
        self.modalWrapperShadowView,
        self.modalContentWrapperView,
      ];
      
      return views.compactMap { $0 };
    }();
    
    wrapperViews.forEach {
      guard let parentView = $0.superview else { return };
      $0.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        $0.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
        $0.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
        $0.widthAnchor  .constraint(equalTo: parentView.widthAnchor  ),
        $0.heightAnchor .constraint(equalTo: parentView.heightAnchor ),
      ]);
    };
    
    modalView.translatesAutoresizingMaskIntoConstraints = false;
    modalView.layoutMargins = .zero;
    
    self.modalConstraintLeft = modalView.leftAnchor.constraint(
      equalTo: modalContentWrapperView.leftAnchor,
      constant: 0
    );
    
    self.modalConstraintRight = modalView.rightAnchor.constraint(
      equalTo: modalContentWrapperView.rightAnchor,
      constant: 0
    );
    
    self.modalConstraintTop = modalView.topAnchor.constraint(
      equalTo: modalContentWrapperView.topAnchor,
      constant: 0
    );
    
    self.modalConstraintBottom = modalView.bottomAnchor.constraint(
      equalTo: modalContentWrapperView.bottomAnchor,
      constant: 0
    );
    
    NSLayoutConstraint.activate([
      self.modalConstraintLeft!,
      self.modalConstraintRight!,
      self.modalConstraintTop!,
      self.modalConstraintBottom!,
    ]);

    self._setupDragHandleConstraints(shouldDeactivateOldConstraints: false);
    
    if let bgDimmingView = self.backgroundDimmingView {
      bgDimmingView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        bgDimmingView.topAnchor.constraint(
          equalTo: modalWrapperView.topAnchor
        ),
        
        bgDimmingView.bottomAnchor.constraint(
          equalTo: modalWrapperView.bottomAnchor
        ),
        
        bgDimmingView.leadingAnchor.constraint(
          equalTo: modalWrapperView.leadingAnchor
        ),
        
        bgDimmingView.trailingAnchor.constraint(
          equalTo: modalWrapperView.trailingAnchor
        ),
      ]);
    };
    
    if let modalBGView = self.modalBackgroundView {
      modalBGView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        modalBGView.centerXAnchor.constraint(
          equalTo: modalContentWrapperView.centerXAnchor
        ),
        
        modalBGView.centerYAnchor.constraint(
          equalTo: modalContentWrapperView.centerYAnchor
        ),
        
        modalBGView.widthAnchor.constraint(
          equalTo: modalContentWrapperView.widthAnchor
        ),
        
        modalBGView.heightAnchor.constraint(
          equalTo: modalContentWrapperView.heightAnchor
        ),
      ]);
    };
    
    if let modalBGVisualEffectView = self.modalBackgroundVisualEffectView,
       let modalWrapperTransformView = self.modalWrapperTransformView {
       
      modalBGVisualEffectView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        modalBGVisualEffectView.centerXAnchor.constraint(
          equalTo: modalWrapperTransformView.centerXAnchor
        ),
        
        modalBGVisualEffectView.centerYAnchor.constraint(
          equalTo: modalWrapperTransformView.centerYAnchor
        ),
        
        modalBGVisualEffectView.widthAnchor.constraint(
          equalTo: modalWrapperTransformView.widthAnchor//,
          //constant: modalWrapperView.frame.width
        ),
        
        modalBGVisualEffectView.heightAnchor.constraint(
          equalTo: modalContentWrapperView.heightAnchor//,
          //constant: modalWrapperView.frame.height
        ),
      ]);
    };
    
    
    #if DEBUG
    if let debugView = self.debugView {
      debugView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        debugView.topAnchor.constraint(
          equalTo: modalWrapperView.topAnchor
        ),
        
        debugView.bottomAnchor.constraint(
          equalTo: modalWrapperView.bottomAnchor
        ),
        
        debugView.leadingAnchor.constraint(
          equalTo: modalWrapperView.leadingAnchor
        ),
        
        debugView.trailingAnchor.constraint(
          equalTo: modalWrapperView.trailingAnchor
        ),
      ]);
    };
    #endif
  };
  
  func _setupExtractScrollView(){
    guard let modalView = self.modalView
    else { return };
    
    func extractScrollView(inView view: UIView) -> UIScrollView? {
      for subview in view.subviews {
        if let scrollView = subview as? UIScrollView {
          return scrollView;
        };
        
        return extractScrollView(inView: subview);
      };
      
      return nil;
    };
    
    self.modalContentScrollView = extractScrollView(inView: modalView);
  };
  
  func _setupPrepareForPresentation(shouldForceReset: Bool = false) {
    guard let rootView = self.rootView else { return };

    let shouldReset =
      !self.didTriggerSetup || shouldForceReset;
    
    if shouldReset {
      self._cleanup();
    };
    
    self.rootView = rootView;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
    
    if shouldReset {
      self._setupInitViews();
      self._setupDummyModalView();
      self._setupGestureHandler();
      
      self._setupAddViews();
      self._setupViewConstraints();
      self._setupObservers();
      
      self._setupExtractScrollView();
    };
    
    self._updateModal();
    self.modalFrame = self.currentInterpolationStep.computedRect;
    self.modalWrapperLayoutView?.layoutIfNeeded();
    
    self.didTriggerSetup = true;
  };
  
  // MARK: - Functions - Cleanup-Related
  // -----------------------------------
  
  func _clearGestureValues() {
    self.gestureOffset = nil;
    self.gestureVelocity = nil;
    
    self.gesturePointPrev = nil;
    self.gesturePoint = nil;
    self.gestureInitialPoint = nil;
  };
  
  func _clearAnimators() {
    self.backgroundVisualEffectAnimator?.clear();
    self.backgroundVisualEffectAnimator = nil;
    
    self.modalBackgroundVisualEffectAnimator?.clear();
    self.modalBackgroundVisualEffectAnimator = nil;
    
    self.stopModalAnimator();
    self.modalAnimator = nil;
  };
  
  func _clearLayoutKeyboardValues(){
    self.layoutKeyboardValues = nil;
    self.isKeyboardVisible = false;
  };
  
  func _removeObservers(){
    let notificationNames = [
      UIResponder.keyboardWillShowNotification,
      UIResponder.keyboardDidShowNotification,
      UIResponder.keyboardWillHideNotification,
      UIResponder.keyboardDidHideNotification,
      UIResponder.keyboardWillChangeFrameNotification,
      UIResponder.keyboardDidChangeFrameNotification,
    ];
    
    notificationNames.forEach {
      NotificationCenter.default.removeObserver(self, name: $0, object: nil);
    };
    
    NotificationCenter.default.removeObserver(self);
  };
  
  func _cleanupViewControllers(){
    defer {
      self.modalWrapperViewController = nil;
      self.modalViewController = nil;
      self.presentingViewController = nil;
    };
  
    guard self.modalWrapperViewController != nil,
          let modalVC = self.modalViewController
    else { return };
  
    modalVC.willMove(toParent: nil);
    modalVC.removeFromParent();
    modalVC.view.removeFromSuperview();
  };
  
  func _cleanupViews() {
    let viewsToCleanup: [UIView?] = [
      self.dummyModalView,
      self.modalWrapperLayoutView,
      // self.modalWrapperTransformView,
      self.modalDragHandleView,
      self.modalWrapperShadowView,
      // self.modalContentWrapperView,
      // self.modalView,
      self.modalBackgroundView,
      self.modalBackgroundVisualEffectView,
      self.backgroundDimmingView,
      self.backgroundVisualEffectView
    ];
    
    viewsToCleanup.forEach {
      guard let view = $0 else { return };
      
      view.removeAllAncestorConstraints();
      view.removeFromSuperview();
    };
    
    self.rootView = nil;
    self.dummyModalView = nil;
    
    self.modalWrapperLayoutView = nil;
    self.modalWrapperTransformView = nil;
    self.modalWrapperShadowView = nil;
    self.modalContentWrapperView = nil;
    
    self.modalDragHandleView = nil;
    self.modalBackgroundView = nil;
    self.modalBackgroundVisualEffectView = nil;
    self.backgroundDimmingView = nil;
    self.backgroundVisualEffectView = nil;
    
    self.modalConstraintLeft = nil;
    self.modalConstraintRight = nil;
    self.modalConstraintTop = nil;
    self.modalConstraintBottom = nil;
    
    self.modalDragHandleConstraintOffset = nil;
    self.modalDragHandleConstraintCenter = nil;
    self.modalDragHandleConstraintHeight = nil;
    self.modalDragHandleConstraintWidth = nil;
    
    
    self.didTriggerSetup = false;
  };
  
  func _cleanupSnapPointOverride(){
    self.isOverridingSnapPoints = false;

    self.overrideSnapPoints = nil;
    self.overrideInterpolationPoints = nil;
    
    self.currentOverrideInterpolationIndex = 0;
    self.prevOverrideInterpolationIndex = 0;
    self.nextOverrideInterpolationIndex = nil;
  };
 
  func _cleanup() {
    self.modalFrame = .zero;
    self.prevModalFrame = .zero;
    self.prevTargetFrame = .zero;
    
    self._clearAnimators();
    self._clearLayoutKeyboardValues();
    
    self._cleanupViews();
    
    self._cleanupSnapPointOverride();
    self._removeObservers();
    self.endDisplayLink();
    
    self.currentInterpolationIndex = 0;
    self.modalSecondaryAxisValue = nil;
    
    self.shouldResetRangePropertyAnimators = false;
    self.pendingCurrentModalConfigUpdate = false;
    
    self.rangeAnimatorMode = .modalPosition;
    self._currentModalConfig = nil;
    
    #if DEBUG
    self.debugView?.notifyDidCleanup();
    #endif
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
 
      if !self.shouldResetRangePropertyAnimators,
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
    
      if !self.shouldResetRangePropertyAnimators,
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
    
    guard let nextPaddingLeft   = nextPaddingLeft  ,
          let nextPaddingRight  = nextPaddingRight ,
          let nextPaddingTop    = nextPaddingTop   ,
          let nextPaddingBottom = nextPaddingBottom,
          
          let modalConstraintLeft   = self.modalConstraintLeft  ,
          let modalConstraintRight  = self.modalConstraintRight ,
          let modalConstraintTop    = self.modalConstraintTop   ,
          let modalConstraintBottom = self.modalConstraintBottom
    else { return };
    
    let didChange =
         modalConstraintLeft  .constant != nextPaddingLeft
      || modalConstraintRight .constant != nextPaddingRight
      || modalConstraintTop   .constant != nextPaddingTop
      || modalConstraintBottom.constant != nextPaddingBottom;
      
    guard didChange else { return };
    
    modalConstraintLeft  .constant = nextPaddingLeft;
    modalConstraintRight .constant = nextPaddingRight;
    modalConstraintTop   .constant = nextPaddingTop;
    modalConstraintBottom.constant = nextPaddingBottom;
    
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

    guard let nextWidth = nextWidth,
          let nextHeight = nextHeight,
          
          let dragHandleConstraintWidth = self.modalDragHandleConstraintWidth,
          let dragHandleConstraintHeight = self.modalDragHandleConstraintHeight
    else { return };
    
    let didSizeChange =
         dragHandleConstraintWidth.constant != nextWidth
      || dragHandleConstraintHeight.constant != nextHeight;
      
    guard didSizeChange else { return };

    dragHandleConstraintWidth.constant = nextWidth;
    dragHandleConstraintHeight.constant = nextHeight;
    
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
    
    self.shouldResetRangePropertyAnimators = false;
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
      
      guard !self.shouldLockAxisToModalDirection,
            let secondaryAxis = self.modalSecondaryAxisValue
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
      self.applyGestureOffsets(forGesturePoint: gesturePoint);
      
    if !self.shouldLockAxisToModalDirection {
      self.modalSecondaryAxisValue =
        gesturePointWithOffset[keyPath: self.currentModalConfig.secondarySwipeAxis];
    };
  
    self._applyInterpolationToModal(forPoint: gesturePointWithOffset);
  };
  
  // MARK: - Functions - Helpers/Utilities
  // -------------------------------------
  
  private func stopModalAnimator(){
    self.modalAnimator?.stopAnimation(true);
    self.endDisplayLink();
    
    self.animationEventDelegate.invoke {
      $0.notifyOnModalAnimatorStop(sender: self);
    };
  };
  
  private func adjustInterpolationIndex(for nextIndex: Int) -> Int {
    if nextIndex == 0 {
      return self.canSnapToUnderShootSnapPoint
        ? 0
        : nextIndex + 1;
    };
    
    let overshootIndex = self.currentModalConfig.overshootSnapPointIndex;
    
    if let overshootIndex = overshootIndex,
       nextIndex == overshootIndex {
       
      return self.canSnapToOverShootSnapPoint
        ? nextIndex
        : overshootIndex - 1;
    };
    
    return nextIndex;
  };
  
  private func applyGestureOffsets(
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
  
  func debug(prefix: String? = ""){
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
      + "\n - layoutKeyboardValues: \(self.layoutKeyboardValues.debugDescription )"
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
    let context = context ?? self.layoutValueContext;
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
    guard case let .adaptiveConfig(defaultConfig, constrainedConfigs) = self.modalConfig
    else { return };
    
    let context = self.layoutValueContext.evaluableConditionContext;
    
    let match = constrainedConfigs.first {
      $0.evaluateConstraints(usingContext: context);
    };
    
    let prevConfig = self._currentModalConfig;
    let nextConfig = match?.config ?? defaultConfig;
    
    guard prevConfig != nextConfig else { return };
    
    self.prevModalConfig = prevConfig;
    self._currentModalConfig = nextConfig;
    
    self.pendingCurrentModalConfigUpdate = self.currentInterpolationIndex > 0;
    self.notifyOnCurrentModalConfigDidChange();
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
    interpolationIndex: Int,
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
        index: $0.snapPointIndex,
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
      
      return self.adjustInterpolationIndex(for: firstIndex);
    }();

    let interpolationPoint =
      self.interpolationSteps[closestInterpolationIndex];
    
    return (
      interpolationIndex: closestInterpolationIndex,
      interpolationPoint: interpolationPoint,
      snapDistance: delta[closestInterpolationIndex].delta
    );
  };
  
  func _getClosestSnapPoint(
    forRect currentRect: CGRect,
    shouldIgnoreAllowSnapping: Bool = false,
    shouldExcludeUndershootSnapPoint: Bool
  ) -> (
    interpolationIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    snapDistance: CGFloat
  )? {
  
    let interpolationSteps: [AdaptiveModalInterpolationPoint] = {
      guard !shouldIgnoreAllowSnapping else {
        if shouldExcludeUndershootSnapPoint {
          return self.interpolationSteps.filter {
            $0.key != .undershootPoint;
          };
        };
        
        return self.interpolationSteps;
      };
      
      return self.interpolationSteps.filter {
        return shouldExcludeUndershootSnapPoint
          ? $0.allowSnapping && $0.key != .undershootPoint
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
        snapPointIndex: item.snapPointIndex,
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
    
    let closestInterpolationPointIndex = self.adjustInterpolationIndex(
      for: firstMatch.snapPointIndex
    );
    
    let closestInterpolationPoint =
      self.interpolationSteps[closestInterpolationPointIndex];
    
    return (
      interpolationIndex: closestInterpolationPointIndex,
      snapPointConfig:
        self.currentModalConfig.snapPoints[closestInterpolationPointIndex],
        
      interpolationPoint: closestInterpolationPoint,
      snapDistance: deltaAvg[firstMatch.offset].delta
    );
  };
  
  func _animateModal(
    to interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool = true,
    animationConfigOverride: AdaptiveModalSnapAnimationConfig? = nil,
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
    
    if isAnimated {
      let snapAnimationConfig = animationConfigOverride
        ?? self.currentModalConfig.snapAnimationConfig;
      
      let animator = snapAnimationConfig.createAnimator(
        gestureInitialVelocity: self.gestureInitialVelocity
      );
      
      self.stopModalAnimator();
      self.modalAnimator = animator;
      
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
        self.endDisplayLink();
        self.modalAnimator = nil;
        
        #if DEBUG
        self.debugView?.notifyOnAnimateModalCompletion();
        #endif
      };
    
      animator.startAnimation();
      self.startDisplayLink(shouldAutoEndDisplayLink: true);
      
    } else {
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
    
    self.animationEventDelegate.invoke {
      $0.notifyOnModalAnimatorStart(
        sender: self,
        animator: self.modalAnimator,
        interpolationPoint: interpolationPoint,
        isAnimated: isAnimated
      );
    };
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
  
  // MARK: - Functions - Handlers
  // ----------------------------
  
  @objc func _onDragPanGesture(_ sender: UIPanGestureRecognizer) {
    var shouldClearGestureValues = false;
  
    let gesturePoint = sender.location(in: self.rootView);
    self.gesturePoint = gesturePoint;
    
    let gestureVelocity = sender.velocity(in: self.rootView);
    self.gestureVelocity = gestureVelocity;
    
    #if DEBUG
    self.debugView?.notifyOnDragPanGesture(sender);
    #endif
    
    switch sender.state {
      case .began:
        self.gestureInitialPoint = gesturePoint;
        
        if self.isKeyboardVisible,
           self.shouldDismissKeyboardOnGestureSwipe,
           self.currentOverrideInterpolationIndex <= 1,
           let modalView = self.modalView {
           
          modalView.endEditing(true);
          self._cancelModalGesture();
        };
    
      case .changed:
        if !self.isKeyboardVisible || self.isAnimating {
          self.stopModalAnimator();
        };
        
        self._applyInterpolationToModal(forGesturePoint: gesturePoint);
        self.notifyOnModalWillSnap(shouldSetState: true);
        
        let shouldSetState =
             self.modalState != .PRESENTING_GESTURE
          && self.modalState != .DISMISSING_GESTURE;
          
        if shouldSetState {
          self.modalStateMachine.setState(.GESTURE_DRAGGING);
        };
        
      case .cancelled, .ended:
        defer {
          shouldClearGestureValues = true;
        };
      
        guard self.shouldEnableSnapping else { break };
        let gestureFinalPointRaw = self.gestureFinalPoint ?? gesturePoint;
        
        let gestureFinalPoint =
          self.applyGestureOffsets(forGesturePoint: gestureFinalPointRaw);
          
        let shouldSetState =
             self.modalState != .PRESENTING_GESTURE
          && self.modalState != .DISMISSING_GESTURE;

        self.snapToClosestSnapPoint(
          forPoint: gestureFinalPoint,
          direction: self.gestureDirection,
          shouldSetStateOnSnap: true,
          stateSnapping: (shouldSetState
            ? .SNAPPING_FROM_GESTURE_DRAGGING
            : nil
          ),
          stateSnapped: nil,
          completion: {
            if self.modalState == .SNAPPING_FROM_GESTURE_DRAGGING {
              self.modalStateMachine.setState(.SNAPPED_FROM_GESTURE_DRAGGING);
            };
          }
        );
        
      default:
        break;
    };
    
    self.gestureEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalDragGesture(
        sender: self,
        gestureRecognizer: sender
      );
    };
    
    if shouldClearGestureValues {
      self._clearGestureValues();
    };
  };
  
  @objc func _onDragScreenEdge(_ sender: UIScreenEdgePanGestureRecognizer){
    switch sender.state {
      case .began:
      
        guard let viewControllerProvider = self.viewControllerProvider
        else { return };
        
        let (modalVC, presentingVC) = viewControllerProvider();
        
        self.modalStateMachine.stateOverride = .PRESENTING_GESTURE;
        self.modalStateMachine.setState(.PRESENTING_GESTURE);

        self.presentModal(
          viewControllerToPresent: modalVC,
          presentingViewController: presentingVC,
          snapPointIndex: 0,
          animated: false,
          shouldSetStateOnSnap: false,
          stateSnapping: .PRESENTING_GESTURE,
          stateSnapped: nil
        );
        
        self.currentInterpolationIndex = 0;
        self._onDragPanGesture(sender);
        
      case .ended:
        self.modalStateMachine.stateOverride = nil;
        self._onDragPanGesture(sender);
        
      default:
        self._onDragPanGesture(sender);
    };
  };
  
  @objc func _onBackgroundTapGesture(_ sender: UITapGestureRecognizer) {
    self.backgroundTapDelegate.invoke {
      $0.notifyOnBackgroundTapGesture(sender: sender);
    };
    
    switch self.currentInterpolationStep.backgroundTapInteraction {
      case .dismiss:
        self.dismissModal();
      
      default:
        break;
    };
  };
  
  @objc func _onKeyboardWillShow(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          !self.isAnimating
    else { return };
    
    self.isKeyboardVisible = true;
    self.layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();

    self._animateModal(
      to: self.currentInterpolationStep,
      animationConfigOverride: .animator(keyboardValues.keyboardAnimator)
    );
  };
  
  @objc func _onKeyboardDidShow(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification)
    else { return };
    
    self.isKeyboardVisible = true;
    self.layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };

  @objc func _onKeyboardWillHide(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          !self.isAnimating
    else { return };
    
    self._clearLayoutKeyboardValues();
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
    
    self._animateModal(
      to: self.currentInterpolationStep,
      animationConfigOverride: .animator(keyboardValues.keyboardAnimator),
      extraAnimation: nil
    ) { _ in
    
      self.isKeyboardVisible = false;
    };
  };
  
  @objc func _onKeyboardDidHide(notification: NSNotification) {
    self.isKeyboardVisible = false;
  };
  
  @objc func _onKeyboardWillChange(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          !self.isAnimating
    else { return };
    
    self.layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
    
    self._animateModal(
      to: self.currentInterpolationStep,
      animationConfigOverride: .animator(keyboardValues.keyboardAnimator)
    );
  };
  
  @objc func _onKeyboardDidChange(notification: NSNotification) {
    guard let keyboardValues = ComputableLayoutKeyboardValues(fromNotification: notification),
          self.presentationState == .none
    else { return };
    
    self.layoutKeyboardValues = keyboardValues;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };
  
  // MARK: - Functions - DisplayLink-Related
  // ---------------------------------------
    
  func startDisplayLink(shouldAutoEndDisplayLink: Bool) {
    self.shouldAutoEndDisplayLink = shouldAutoEndDisplayLink;
    
    let displayLink = CADisplayLink(
      target: self,
      selector: #selector(self._onDisplayLinkTick(displayLink:))
    );
    
    self.displayLink = displayLink;
    
    if #available(iOS 15.0, *) {
      displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120);
      
    } else {
      displayLink.preferredFramesPerSecond = 60;
    };
    
    displayLink.add(to: .current, forMode: .common);
  };
  
  func endDisplayLink() {
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
        self.endDisplayLink();
      };
    };
    
    if self.isSwiping && !self.isKeyboardVisible {
      shouldEndDisplayLink = true;
    };
    
    if self.displayLinkStartTimestamp == nil {
      self.displayLinkStartTimestamp = displayLink.timestamp;
    };
    
    let percent: CGFloat? = {
      switch self.rangeAnimatorMode {
        case .modalPosition:
          guard let dummyModalView = self.dummyModalView,
                let dummyModalViewLayer = dummyModalView.layer.presentation(),
                let interpolationRangeMaxInput = self.interpolationRangeMaxInput
          else {
            shouldEndDisplayLink = true;
            return nil;
          };
          
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
          guard let modalAnimator = modalAnimator else { return nil };
          return AdaptiveModalUtilities.invertPercent(modalAnimator.fractionComplete);
      };
    }();
    
    guard let percent = percent else { return };

    self._applyInterpolationToRangeAnimators(
      forInputPercentValue: percent
    );
  };
  
  // MARK: - Event Functions
  // -----------------------
  
  private func notifyOnCurrentModalConfigDidChange(){
    self.presentationEventsDelegate.invoke {
      $0.notifyOnCurrentModalConfigDidChange(
        sender: self,
        currentModalConfig: self.currentModalConfig,
        prevModalConfig: self.prevModalConfig
      );
    };
  };
  
  private func notifyOnModalWillSnap(shouldSetState: Bool) {
    let prevIndex = self.onModalWillSnapPrevIndex
      ?? self.currentInterpolationIndex;
      
    let nextIndexRaw: Int = {
      if let nextIndex = self.nextInterpolationIndex {
        return nextIndex;
      };
    
      let closestSnapPoint = self._getClosestSnapPoint();
      
      return closestSnapPoint?.interpolationPoint.snapPointIndex
        ?? self.currentInterpolationIndex;
    }();
    
    let nextIndex = self.adjustInterpolationIndex(for: nextIndexRaw);
    let nextInterpolationPoint = self.interpolationSteps[nextIndex];
    let nextSnapPointConfig = self.currentSnapPoints[nextIndex];
    
    guard prevIndex != nextIndex else { return };
    self.onModalWillSnapPrevIndex = nextIndex;
    
    let isDismissingToUnderShootSnapPoint =
         self.shouldDismissModalOnSnapToUnderShootSnapPoint
      && nextIndex == 0;
      
    let isDismissingToOverShootSnapPoint =
         self.shouldDismissModalOnSnapToOverShootSnapPoint
      && nextIndex == self.currentModalConfig.overshootSnapPointIndex;
    
    let isPresenting =
         self.currentInterpolationIndex == 0
      && nextIndex == 1;
      
    let isDismissing =
         isDismissingToUnderShootSnapPoint
      || isDismissingToOverShootSnapPoint;
      
    let nextState: AdaptiveModalState? = {
      if isDismissing {
        return self.modalState.isProgrammatic
          ? .DISMISSING_PROGRAMMATIC
          : .DISMISSING_GESTURE
      };
      
      if isPresenting {
        return self.modalState.isProgrammatic
          ? .PRESENTING_PROGRAMMATIC
          : .PRESENTING_GESTURE;
      };
      
      if self.isSwiping {
        return .GESTURE_DRAGGING;
      };
      
      if !self.isSwiping {
        return self.modalState.isProgrammatic
          ? .SNAPPING_PROGRAMMATIC
          : .SNAPPING_FROM_GESTURE_DRAGGING;
      };
      
      return nil;
    }();
    
    if shouldSetState,
       let nextState = nextState {
       
      self.modalStateMachine.setState(nextState);
    };
    
    /// Note:2023-09-23-23-01-02
    /// * `maskedCorners` cannot be animated, so we apply the next corner mask
    ///    immediately to make it less noticeable
    block:
    if let modalContentWrapperView = self.modalContentWrapperView {
      let maskCountCurrent = modalContentWrapperView.layer.maskedCorners.count;
      let maskCountNext = nextInterpolationPoint.modalMaskedCorners.count;
      
      // corner mask precedence
      // apply the next corner mask only if has more masked corners
      guard maskCountNext > maskCountCurrent else { break block };
      modalContentWrapperView.layer.maskedCorners = nextInterpolationPoint.modalMaskedCorners;
     
      if let modalBgEffectView = self.modalBackgroundVisualEffectView {
        modalBgEffectView.layer.maskedCorners = nextInterpolationPoint.modalMaskedCorners;
      };
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnModalWillSnap(
        sender: self,
        prevSnapPointIndex: prevIndex,
        nextSnapPointIndex: nextIndex,
        prevSnapPointConfig: self.prevSnapPointConfig,
        nextSnapPointConfig: nextSnapPointConfig,
        prevInterpolationPoint: self.prevInterpolationStep,
        nextInterpolationPoint: nextInterpolationPoint
      );
    };
  };
  
  private func notifyOnModalDidSnap(shouldSetState: Bool) {
    #if DEBUG
    self.debugView?.notifyOnModalDidSnap();
    #endif
    
    self.nextInterpolationIndex = nil;
      
    self.currentInterpolationStep.applyConfig(toModalManager: self);
    
    let shouldDismissOnSnapToUnderShootSnapPoint =
      self.currentInterpolationIndex == 0 &&
      self.shouldDismissModalOnSnapToUnderShootSnapPoint;
      
    let shouldDismissOnSnapToOverShootSnapPoint =
      self.currentInterpolationIndex == self.currentModalConfig.overshootSnapPointIndex &&
      self.shouldDismissModalOnSnapToOverShootSnapPoint;
    
    let shouldDismiss =
      shouldDismissOnSnapToUnderShootSnapPoint ||
      shouldDismissOnSnapToOverShootSnapPoint;
      
    let isPresenting =
         self.modalState.isPresenting
      || self.currentInterpolationIndex == 1
      && self.prevInterpolationIndex == 0;
      
    let nextState: AdaptiveModalState? = {
      if shouldDismiss {
        return self.modalState.isProgrammatic
          ? .DISMISSED_PROGRAMMATIC
          : .DISMISSED_GESTURE
      };
      
      if isPresenting {
        return self.modalState.isProgrammatic
          ? .PRESENTED_PROGRAMMATIC
          : .PRESENTED_GESTURE
      };
      
      return nil;
    }();
    
    if shouldSetState,
       let nextState = nextState {
       
      self.modalStateMachine.setState(nextState);
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnModalDidSnap(
        sender: self,
        prevSnapPointIndex: self.prevInterpolationIndex,
        currentSnapPointIndex: self.currentSnapPointIndex,
        prevSnapPointConfig: self.prevSnapPointConfig,
        currentSnapPointConfig: self.currentSnapPointConfig,
        prevInterpolationPoint: self.prevInterpolationStep,
        currentInterpolationPoint: self.currentInterpolationStep
      );
    };
    
    if self.shouldClearOverrideSnapPoints {
      self._cleanupSnapPointOverride();
    };
    
    self._clearAnimators();
  };
  
  private func notifyOnModalWillShow(){
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalWillShow(sender: self);
    };
  };
  
  private func notifyOnModalDidShow(){
    //self.modalState = .presented;
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalDidShow(sender: self);
    };
  };
  
  private func notifyOnModalWillHide(){
    if self.isKeyboardVisible,
       let modalView = self.modalView {
       
      modalView.endEditing(true);
    };
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalWillHide(sender: self);
    };
  };
  
  private func notifyOnModalDidHide(){
    self._cleanup();
    self._clearGestureValues();
    
    self.modalViewController?.dismiss(animated: false);
    self._cleanupViewControllers();
    
    self.presentationEventsDelegate.invoke {
      $0.notifyOnAdaptiveModalDidHide(sender: self);
    };
  };
  
  private func notifyOnModalStateWillChange(
    _ prevState   : AdaptiveModalState,
    _ currentState: AdaptiveModalState,
    _ nextState   : AdaptiveModalState
  ) {
  
    if nextState.isPresenting {
      self.notifyOnModalWillShow();
      
    } else if nextState.isPresented {
      self.notifyOnModalDidShow();
      
    } else if nextState.isDismissing {
      self.notifyOnModalWillHide();
      
    } else if nextState.isDismissed {
      self.notifyOnModalDidHide();
    };
    
    if prevState.isDismissed && currentState.isPresenting && nextState.isDismissed {
      #if DEBUG
      if self.shouldLogModalStateChanges {
        print("notifyOnModalPresentCancelled");
      };
      #endif
    
      self.presentationEventsDelegate.invoke {
        $0.notifyOnModalPresentCancelled(
          sender: self
        );
      };
      
    } else if currentState.isDismissing && !nextState.isDismissed {
      #if DEBUG
      if self.shouldLogModalStateChanges {
        print("notifyOnModalDismissCancelled");
      };
      #endif
      
      self.presentationEventsDelegate.invoke {
        $0.notifyOnModalDismissCancelled(
          sender: self
        );
      };
    };
    
    self.stateEventsDelegate.invoke {
      $0.notifyOnModalStateWillChange(
        sender: self,
        prevState: prevState,
        currentState: currentState,
        nextState: nextState
      );
    };
    
    #if DEBUG
    if self.shouldLogModalStateChanges {
      print(
        "onStateChangeBlock:",
        prevState, "->", currentState, "->", nextState
      );
    };
    #endif
  };

  // MARK: - Functions
  // -----------------
    
  func snapTo(
    interpolationIndex nextIndex: Int,
    interpolationPoint: AdaptiveModalInterpolationPoint? = nil,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    self.nextInterpolationIndex = nextIndex;
  
    let nextInterpolationPoint = interpolationPoint
      ?? self.interpolationSteps[nextIndex];
    
    self.notifyOnModalWillSnap(shouldSetState: shouldSetStateOnSnap);
    
    if let stateSnapping = stateSnapping {
      self.modalStateMachine.setState(stateSnapping);
    };
    
    self._animateModal(
      to: nextInterpolationPoint,
      isAnimated: isAnimated,
      animationConfigOverride: animationConfig,
      extraAnimation: extraAnimation
    ) { _ in
    
      self.currentInterpolationIndex = nextIndex;
      self.nextInterpolationIndex = nil;
      
      self.notifyOnModalDidSnap(shouldSetState: shouldSetStateOnSnap);
      
      if let stateSnapped = stateSnapped {
        self.modalStateMachine.setState(stateSnapped);
      };
      
      completion?();
    }
  };
  
  func snapToClosestSnapPoint(
    forPoint point: CGPoint,
    direction: AdaptiveModalConfig.SnapDirection?,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    completion: (() -> Void)? = nil
  ) {
    
    let coord = point[keyPath: self.currentModalConfig.inputValueKeyForPoint];
    let closestSnapPoint = self._getClosestSnapPoint(forCoord: coord)
      
    guard let closestSnapPoint = closestSnapPoint else { return };
    
    let nextInterpolationIndex =
      self.adjustInterpolationIndex(for: closestSnapPoint.interpolationIndex);
    
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
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
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
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ){
  
    let nextIndex = 0;
    
    self.stopModalAnimator();
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
              self.currentSnapPointConfig.layoutConfig
            ),
            keyframeConfig: keyframe
          );
          
        default:
          return nil;
      };
    }();
    
    if let undershootSnapPoint = undershootSnapPoint {
      self._clearAnimators();
    
      let currentSnapPoint: AdaptiveModalSnapPointConfig = {
        var newKeyframe = AdaptiveModalKeyframeConfig(
          fromInterpolationPoint: self.currentInterpolationStep
        );
        
        newKeyframe.computedRect = nil;
        return .snapPoint(
          key: self.currentSnapPointConfig.key,
          layoutConfig: self.currentSnapPointConfig.layoutConfig,
          keyframeConfig: newKeyframe
        );
      }();
      
      let snapPoints = AdaptiveModalSnapPointConfig.deriveSnapPoints(
        undershootSnapPoint: undershootSnapPoint,
        inBetweenSnapPoints: [currentSnapPoint],
        overshootSnapPoint: nil
      );

      self.overrideSnapPoints = snapPoints;
      
      self.overrideInterpolationPoints = {
        var points = AdaptiveModalInterpolationPoint.compute(
          usingConfig: self.currentModalConfig,
          usingContext: self.layoutValueContext,
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
      
      self.shouldResetRangePropertyAnimators = true;
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
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    shouldSetStateOnSnap: Bool,
    stateSnapping: AdaptiveModalState?,
    stateSnapped: AdaptiveModalState?,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let animationConfig = animationConfig
      ?? self.currentModalConfig.entranceAnimationConfig;
    
    self.showModalCommandArgs = (
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
  
  // MARK: - User-Invoked Functions
  // ------------------------------
  
  public func updateModalConfig(_ newConfig: AdaptiveModalConfigMode){
    self._cancelModalGesture();
    self.stopModalAnimator();
    
    self.modalConfig = newConfig;
    
    self._updateCurrentModalConfig();
    self._computeSnapPoints();
  };
  
  public func prepareForPresentation(
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
  
  public func setScreenEdgePanGestureRecognizer(
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
  
  public func notifyDidLayoutSubviews() {
    guard let rootView = self.rootView,
          let modalFrame = self.modalFrame
    else { return };
    
    let prevTargetFrame = self.prevTargetFrame;
    let nextTargetFrame = rootView.frame;
    
    guard prevTargetFrame != nextTargetFrame else { return };
    self.prevTargetFrame = nextTargetFrame;
    
    self._updateCurrentModalConfig();
    
    if self.pendingCurrentModalConfigUpdate {
    
      // config changes while a snap override is active is buggy...
      self._cleanupSnapPointOverride();
      self._computeSnapPoints();
      
      let closestSnapPoint = self._getClosestSnapPoint(
        forRect: modalFrame,
        shouldExcludeUndershootSnapPoint: true
      );
      
      self.currentConfigInterpolationIndex = closestSnapPoint?.interpolationIndex
        ?? self.currentConfigInterpolationIndex;
      
      let shouldUpdateDragHandleConstraints: Bool = {
        guard let prevConfig = self.prevModalConfig else {
          return false;
        };
        
        return self.currentModalConfig.dragHandlePosition != prevConfig.dragHandlePosition;
      }();
      
      if shouldUpdateDragHandleConstraints {
        self._setupDragHandleConstraints(shouldDeactivateOldConstraints: true);
      };
      
      self._updateModal();
      self.pendingCurrentModalConfigUpdate = false;
      
    } else {
      self._computeSnapPoints();
      self._updateModal();
    };
  };
  
  public func clearSnapPointOverride(completion: (() -> Void)?){
    guard self.isOverridingSnapPoints else { return };
  
    self._cleanupSnapPointOverride();
    self.snapToCurrentSnapPointIndex(completion: completion);
  };
  
  public func presentModal(
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
  
  public func presentModal(
    viewControllerToPresent modalVC: UIViewController,
    presentingViewController targetVC: UIViewController,
    snapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) {
  
    let snapPointMatch = self.interpolationSteps.first {
      $0.key == snapPointKey;
    };
  
    self.presentModal(
      viewControllerToPresent: modalVC,
      presentingViewController: targetVC,
      snapPointIndex: snapPointMatch?.snapPointIndex,
      animated: animated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  public func dismissModal(
    useInBetweenSnapPoints: Bool = false,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    guard let modalVC = self.modalViewController else { return };
    
    let animationConfig = animationConfig
      ?? self.currentModalConfig.exitAnimationConfig;
    
    self.hideModalCommandArgs = (
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
  
  public func dismissModal(
    snapPointPreset: AdaptiveModalSnapPointPreset,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    guard let modalVC = self.modalViewController else { return };
    
    let animationConfig = animationConfig
      ?? self.currentModalConfig.exitAnimationConfig;
    
    self.hideModalCommandArgs = (
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
  
  public func dismissModal(
    keyframe: AdaptiveModalKeyframeConfig,
    animated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    guard let modalVC = self.modalViewController else { return };
    
    let animationConfig = animationConfig
      ?? self.currentModalConfig.exitAnimationConfig;
    
    self.hideModalCommandArgs = (
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
  
  public func snapTo(
    snapPointIndex nextIndex: Int,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let lastIndex = max(self.interpolationSteps.count - 1, 0);
    let nextIndexAdj = self.adjustInterpolationIndex(for: nextIndex);
    
    guard nextIndexAdj >= 0 && nextIndexAdj <= lastIndex,
          nextIndexAdj != self.currentInterpolationIndex
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
    
    self.snapTo(
      interpolationIndex: nextIndex,
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
  
  public func snapToClosestSnapPoint(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let closestSnapPoint = self._getClosestSnapPoint(
      forRect: self.modalFrame ?? .zero,
      shouldExcludeUndershootSnapPoint: true
    );
    
    let nextInterpolationIndex = self.adjustInterpolationIndex(
      for: closestSnapPoint?.interpolationIndex ?? 1
    );
    
    let nextInterpolationPoint =
      self.interpolationSteps[nextInterpolationIndex];
    
    let prevFrame = self.modalFrame;
    let nextFrame = nextInterpolationPoint.computedRect;
    
    guard nextInterpolationIndex != self.currentInterpolationIndex,
          prevFrame != nextFrame
    else { return };
    
    self.snapTo(
      snapPointIndex: nextInterpolationIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  public func snapToPrevSnapPointIndex(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let nextIndex = self.currentInterpolationIndex - 1;
    
    self.snapTo(
      snapPointIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  public func snapToCurrentSnapPointIndex(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    let nextIndex = self.currentInterpolationIndex;
    
    self.snapTo(
      snapPointIndex: nextIndex,
      isAnimated: isAnimated,
      animationConfig: animationConfig,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  public func snapToNextSnapPointIndex(
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    
    let nextIndex = self.currentInterpolationIndex + 1;
    
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
  public func snapTo(
    overrideSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevSnapPointConfigs: [AdaptiveModalSnapPointConfig]? = nil,
    overshootSnapPointPreset: AdaptiveModalSnapPointPreset? = .automatic,
    inBetweenSnapPointsMinPercentDiff: CGFloat = 0.1,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) throws {
  
    self._cleanupSnapPointOverride();
    
    let prevSnapPointConfigs: [AdaptiveModalSnapPointConfig] = {
      if let prevSnapPointConfigs = prevSnapPointConfigs {
        return prevSnapPointConfigs;
      };
    
      let prevInterpolationPoints: [AdaptiveModalInterpolationPoint] = {
        let overrideInterpolationPoint = AdaptiveModalInterpolationPoint(
          usingModalConfig: self.currentModalConfig,
          snapPointIndex: 1,
          layoutValueContext: self.layoutValueContext,
          snapPointConfig: overrideSnapPointConfig
        );
        
        let items = self.configInterpolationSteps.filter {
          let delta = $0.percent - overrideInterpolationPoint.percent;
          guard delta <= 0 else { return false };
          
          // tolerance
          return abs(delta) >= inBetweenSnapPointsMinPercentDiff;
        };
        
        guard items.count > 0 else {
          return [self.configInterpolationSteps.first!];
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
    
    let nextInterpolationPointIndex = prevSnapPointConfigs.count;
    
    self.overrideSnapPoints = snapPoints;
    self._computeSnapPoints();
    
    guard let overrideInterpolationPoints = self.overrideInterpolationPoints,
          let nextInterpolationPoint =
            overrideInterpolationPoints[safeIndex: nextInterpolationPointIndex]
    else {
      throw NSError();
    };
    
    self.isOverridingSnapPoints = true;
    self.shouldResetRangePropertyAnimators = true;
    self.currentOverrideInterpolationIndex = nextInterpolationPointIndex;

    self._animateModal(
      to: nextInterpolationPoint,
      isAnimated: isAnimated,
      animationConfigOverride: animationConfig,
      extraAnimation: extraAnimation
    ) { _ in
      completion?();
    };
  };
  
  public func snapTo(
    key: AdaptiveModalSnapPointConfig.SnapPointKey,
    isAnimated: Bool = true,
    animationConfig: AdaptiveModalSnapAnimationConfig? = nil,
    animationBlock: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) throws {
  
    let matchingInterpolationPoint: AdaptiveModalInterpolationPoint? = {
      switch key {
        case let .index(indexKey):
          return self.configInterpolationSteps?.first {
            $0.snapPointIndex == indexKey;
          };
          
        case .string(_):
          return self.configInterpolationSteps.first {
            $0.key == key;
          };
          
        case .undershootPoint:
          return self.configInterpolationSteps?.first;
          
        case .overshootPoint:
          return self.configInterpolationSteps?.last;
          
        case .unspecified:
          return nil;
      };
    }();
    
    guard let matchingInterpolationPoint = matchingInterpolationPoint else {
      throw NSError();
    };
    
    self.nextConfigInterpolationIndex =
      matchingInterpolationPoint.snapPointIndex;
    
    self.modalStateMachine.setState(.SNAPPING_PROGRAMMATIC);
    self.notifyOnModalWillSnap(shouldSetState: false);
    
    self._animateModal(
      to: matchingInterpolationPoint,
      isAnimated: isAnimated,
      animationConfigOverride: animationConfig,
      extraAnimation: animationBlock
    ) { _ in
      
      self.modalStateMachine.setState(.SNAPPED_PROGRAMMATIC);
      self.notifyOnModalDidSnap(shouldSetState: false);
      completion?();
    };
  };
};
