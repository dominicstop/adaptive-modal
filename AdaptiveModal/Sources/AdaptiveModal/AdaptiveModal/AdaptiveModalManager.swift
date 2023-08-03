//
//  AdaptiveModalManager.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/24/23.
//

import UIKit

public class AdaptiveModalManager: NSObject {

  public enum PresentationState {
    case presenting, dismissing, none;
  };

  // MARK: -  Properties - Config-Related
  // ------------------------------------
  
  public var modalConfig: AdaptiveModalConfig;
  
  public var shouldEnableSnapping = true;
  public var shouldEnableOverShooting = true;
  public var shouldDismissKeyboardOnGestureSwipe = false;
  
  public var shouldLockAxisToModalDirection = false;
  
  public var shouldSnapToUnderShootSnapPoint = true;
  public var shouldSnapToOvershootSnapPoint = false;
  
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
  
  // MARK: -  Properties - Layout-Related
  // ------------------------------------
  
  var debugView: AdaptiveModalDebugOverlay?;
  
  public var modalWrapperViewController: AdaptiveModalRootViewController?;
  
  public weak var modalViewController: UIViewController?;
  public weak var presentingViewController: UIViewController?;
  
  public weak var presentedViewController: UIViewController? {
       self.modalWrapperViewController
    ?? self.modalViewController;
  };
  
  /// `transitionContext.containerView` or `UITransitionView`
  public weak var targetView: UIView?;
  
  /// * If `modalViewController` was presented via the modal manager,
  ///   then the "root view" (i.e. the view in which we place the modal-related
  ///   views) will be `modalWrapperViewController`
  ///
  /// * Otherwise, the "root view" will be `targetView`.
  ///
  /// * Note: This view is typically the size of the window, while the modal
  ///   wrapper views are the size of the modal.
  ///
  public var modalRootView: UIView? {
       self.modalWrapperViewController?.view
    ?? self.targetView
  };
  
  public var modalView: UIView? {
    self.modalViewController?.view;
  };
  
  public var dummyModalView: UIView?;
  
  public var modalWrapperLayoutView: AdaptiveModalWrapperView?;
  public var modalWrapperTransformView: AdaptiveModalWrapperView?;
  public var modalWrapperShadowView: AdaptiveModalWrapperView?;
  public var modalContentWrapperView: UIView?;
  
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
  weak var modalDragHandleConstraintHeight: NSLayoutConstraint?;
  weak var modalDragHandleConstraintWidth : NSLayoutConstraint?;
  
  private var layoutKeyboardValues: RNILayoutKeyboardValues?;
  
  private var layoutValueContext: RNILayoutValueContext {
    let context: RNILayoutValueContext? = {
      if let targetVC = self.presentingViewController {
        return .init(
          fromTargetViewController: targetVC,
          keyboardValues: self.layoutKeyboardValues
        );
      };
      
      if let targetView = self.targetView {
        return .init(
          fromTargetView: targetView,
          keyboardValues: self.layoutKeyboardValues
        );
      };
      
      return nil;
    }();
    
    return context ?? .default;
  };
  
  private var isKeyboardVisible = false;
  
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
  
  private var shouldResetRangePropertyAnimators = false;
  
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
       self.shouldUseOverrideSnapPoints
    && self.currentOverrideInterpolationIndex < overrideInterpolationPoints!.count - 2
    && self.presentationState != .dismissing
  };
  
  // MARK: -  Properties - Interpolation Points
  // ------------------------------------------
  
  private var onModalWillSnapPrevIndex: Int?;
  private var onModalWillSnapNextIndex: Int?;
  
  public private(set) var prevInterpolationIndex: Int {
    get {
      self.shouldSnapToOvershootSnapPoint
        ? self.prevOverrideInterpolationIndex
        : self.prevConfigInterpolationIndex;
    }
    set {
      if self.shouldSnapToOvershootSnapPoint {
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
    }
  };
  
  public private(set) var interpolationSteps: [AdaptiveModalInterpolationPoint]! {
    get {
      self.shouldUseOverrideSnapPoints
        ? self.overrideInterpolationPoints
        : self.configInterpolationSteps
    }
    set {
      if self.shouldSnapToOvershootSnapPoint {
        self.overrideInterpolationPoints = newValue;
        
      } else {
        self.configInterpolationSteps = newValue;
      };
    }
  };
  
  public var currentInterpolationStep: AdaptiveModalInterpolationPoint {
    self.interpolationSteps[self.currentInterpolationIndex];
  };
  
  public var interpolationRangeInput: [CGFloat]! {
    self.interpolationSteps.map { $0.percent };
  };
  
  public var interpolationRangeMaxInput: CGFloat? {
    guard let targetView = self.targetView else { return nil };
    return targetView.frame[keyPath: self.modalConfig.maxInputRangeKeyForRect];
  };
  
  public var currentSnapPointConfig: AdaptiveModalSnapPointConfig {
    self.modalConfig.snapPoints[
      self.currentInterpolationStep.snapPointIndex
    ];
  };
  
  // MARK: -  Properties - Animation-Related
  // ---------------------------------------
  
  weak var transitionContext: UIViewControllerContextTransitioning?;
  
  private var modalAnimator: UIViewPropertyAnimator?;
  
  var extraAnimationBlockPresent: (() -> Void)?;
  var extraAnimationBlockDismiss: (() -> Void)?;

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
  
  // MARK: -  Properties - Gesture-Related
  // -------------------------------------
  
  weak var modalGesture: UIPanGestureRecognizer?;
  weak var modalDragHandleGesture: UIPanGestureRecognizer?;
  weak var backgroundTapGesture: UITapGestureRecognizer?;
  
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
      gestureInitialPoint[keyPath: self.modalConfig.inputValueKeyForPoint];
      
    let gestureFinalCoord =
      gestureFinalPoint[keyPath: self.modalConfig.inputValueKeyForPoint];
      
    let gestureVelocityCoord =
      gestureVelocity[keyPath: self.modalConfig.inputValueKeyForPoint];
    
    var velocity: CGFloat = 0;
    let distance = gestureFinalCoord - gestureInitialCoord;
    
    if distance != 0 {
      velocity = gestureVelocityCoord / distance;
    };
    
    let snapAnimationConfig = self.modalConfig.snapAnimationConfig;
    
    velocity = velocity.clamped(
      min: -snapAnimationConfig.maxGestureVelocity,
      max:  snapAnimationConfig.maxGestureVelocity
    );
    
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
          let modalRect = self.modalFrame
    else { return nil };
    
    if let gestureOffset = self.gestureOffset {
      return gestureOffset;
    };
    
    let xOffset: CGFloat = {
      switch self.modalConfig.snapDirection {
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
      switch self.modalConfig.snapDirection {
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
    
    return CGRect(
      origin: modalFrame.origin,
      size: CGSize(
        width: modalFrame.width,
        height: self.modalConfig.modalSwipeGestureEdgeHeight
      )
    );
  };
  
  public var gesturePointWithOffsets: CGPoint? {
    guard let gesturePoint = self.gesturePoint else { return nil };
    return self.applyGestureOffsets(forGesturePoint: gesturePoint)
  };
  
  // MARK: -  Properties
  // -------------------
  
  private var _showDebugOverlay = false;
  
  private(set) var didTriggerSetup = false;
  internal(set) public var presentationState: PresentationState = .none;
  
  public weak var eventDelegate: AdaptiveModalEventNotifiable?;
  public weak var backgroundTapDelegate: AdaptiveModalBackgroundTapDelegate?;
  public weak var animationEventDelegate: AdaptiveModalAnimationEventsNotifiable?;

  // MARK: - Computed Properties
  // ---------------------------
  
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

  // MARK: - Init
  // ------------
  
  public init(modalConfig: AdaptiveModalConfig) {
    self.modalConfig = modalConfig;
    
    super.init();
    self.computeSnapPoints();
  };
  
  deinit {
    self.clearAnimators();
    self.removeObservers();
  };
  
  // MARK: - Functions - Setup
  // -------------------------
  
  private func setupObservers(){
    NotificationCenter.default.addObserver(self,
      selector: #selector(self.onKeyboardWillShow(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self.onKeyboardDidShow(notification:)),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    );

    NotificationCenter.default.addObserver(self,
      selector: #selector(self.onKeyboardWillHide(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self.onKeyboardDidHide(notification:)),
      name: UIResponder.keyboardDidHideNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self.onKeyboardWillChange(notification:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    );
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(self.onKeyboardDidChange(notification:)),
      name: UIResponder.keyboardDidChangeFrameNotification,
      object: nil
    );
  };
  
  func setupViewControllers() {
    guard let presentedVC = self.presentedViewController else { return };
  
    presentedVC.modalPresentationStyle = .custom;
    presentedVC.transitioningDelegate = self;
  };
  
  func setupInitViews() {
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
    
    if self.modalConfig.dragHandlePosition != .none {
      let dragHandle = AdaptiveModalDragHandleView();
      dragHandle.pointInsideHitSlop = self.modalConfig.dragHandleHitSlop;
      
      self.modalDragHandleView = dragHandle;
    };
  };
  
  func setupGestureHandler() {
    guard let modalView = self.modalView else { return };
    modalView.gestureRecognizers?.removeAll();
    
    let gesture = UIPanGestureRecognizer(
      target: self,
      action: #selector(self.onDragPanGesture(_:))
    );
    
    self.modalGesture = gesture;
    gesture.isEnabled = self.isModalContentSwipeGestureEnabled;
    gesture.delegate = self;
    
    modalView.addGestureRecognizer(gesture);
    
    if let modalDragHandleView = self.modalDragHandleView {
      let gesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(self.onDragPanGesture(_:))
      );
    
      self.modalDragHandleGesture = gesture;
      gesture.isEnabled = self.isModalDragHandleGestureEnabled;
      
      modalDragHandleView.addGestureRecognizer(gesture);
    };
    
    if let bgDimmingView = self.backgroundDimmingView {
      let gesture = UITapGestureRecognizer(
        target: self,
        action: #selector(self.onBackgroundTapGesture(_:))
      );
      
      gesture.isEnabled = false;
      self.backgroundTapGesture = gesture;
      bgDimmingView.addGestureRecognizer(gesture);
    };
  };
  
  func setupDummyModalView() {
    guard let targetView = self.targetView,
          let dummyModalView = self.dummyModalView
    else { return };
    
    dummyModalView.backgroundColor = .clear;
    dummyModalView.alpha = 0.1;
    dummyModalView.isUserInteractionEnabled = false;
    
    targetView.addSubview(dummyModalView);
  };

  func setupAddViews() {
    guard let modalView = self.modalView,
          let modalRootView = self.modalRootView
    else { return };
    
    if let targetView = self.targetView,
       let modalRootView = self.modalWrapperViewController?.view {
       
      targetView.addSubview(modalRootView);
    };
    
    if let bgVisualEffectView = self.backgroundVisualEffectView {
      modalRootView.addSubview(bgVisualEffectView);
      
      bgVisualEffectView.clipsToBounds = true;
      bgVisualEffectView.backgroundColor = .clear;
      bgVisualEffectView.isUserInteractionEnabled = false;
    };
    
    if let bgDimmingView = self.backgroundDimmingView {
      modalRootView.addSubview(bgDimmingView);
      
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
        modalRootView.addSubview($0.element);
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
    
    if let modalBGVisualEffectView = self.modalBackgroundVisualEffectView {
      modalContentContainerView.addSubview(modalBGVisualEffectView);
      modalContentContainerView.sendSubviewToBack(modalBGVisualEffectView);
      
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
      
      modalRootView.addSubview(debugView);
    };
    #endif
  };
  
  func setupViewConstraints() {
    guard let modalView = self.modalView,
          let modalRootView = self.modalRootView,
          
          let modalContentWrapperView = self.modalContentWrapperView
    else { return };
    
    if let targetView = self.targetView,
       let modalRootView = self.modalWrapperViewController?.view {
       
      modalRootView.translatesAutoresizingMaskIntoConstraints = false;
       
      NSLayoutConstraint.activate([
        modalRootView.topAnchor     .constraint(equalTo: targetView.topAnchor     ),
        modalRootView.bottomAnchor  .constraint(equalTo: targetView.bottomAnchor  ),
        modalRootView.leadingAnchor .constraint(equalTo: targetView.leadingAnchor ),
        modalRootView.trailingAnchor.constraint(equalTo: targetView.trailingAnchor),
      ]);
    };
    
    if let bgVisualEffectView = self.backgroundVisualEffectView {
      bgVisualEffectView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        bgVisualEffectView.topAnchor     .constraint(equalTo: modalRootView.topAnchor     ),
        bgVisualEffectView.bottomAnchor  .constraint(equalTo: modalRootView.bottomAnchor  ),
        bgVisualEffectView.leadingAnchor .constraint(equalTo: modalRootView.leadingAnchor ),
        bgVisualEffectView.trailingAnchor.constraint(equalTo: modalRootView.trailingAnchor),
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

    
    scope:
    if let modalDragHandleView = self.modalDragHandleView,
       let modalWrapperShadowView = self.modalWrapperShadowView {
       
      modalDragHandleView.translatesAutoresizingMaskIntoConstraints = false;
      
      let dragHandleOffset: CGFloat = {
        guard let interpolationSteps = self.interpolationSteps,
              let undershoot = interpolationSteps.first
        else { return 0 };
        
        return undershoot.modalDragHandleOffset;
      }();
      
      let offsetConstraint: NSLayoutConstraint? = {
        switch self.modalConfig.dragHandlePosition {
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
      
      guard let offsetConstraint = offsetConstraint else { break scope };
      self.modalDragHandleConstraintOffset = offsetConstraint;
      
      var constraints = [offsetConstraint];
      
      switch self.modalConfig.dragHandlePosition {
        case .top, .bottom: constraints.append(
          modalDragHandleView.centerXAnchor.constraint(
            equalTo: modalWrapperShadowView.centerXAnchor
          )
        );
          
        case .left, .right: constraints.append(
          modalDragHandleView.centerYAnchor.constraint(
            equalTo: modalWrapperShadowView.centerYAnchor
          )
        );
          
        default: break;
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
    
    if let bgDimmingView = self.backgroundDimmingView {
      bgDimmingView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        bgDimmingView.topAnchor.constraint(
          equalTo: modalRootView.topAnchor
        ),
        
        bgDimmingView.bottomAnchor.constraint(
          equalTo: modalRootView.bottomAnchor
        ),
        
        bgDimmingView.leadingAnchor.constraint(
          equalTo: modalRootView.leadingAnchor
        ),
        
        bgDimmingView.trailingAnchor.constraint(
          equalTo: modalRootView.trailingAnchor
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
    
    if let modalBGVisualEffectView = self.modalBackgroundVisualEffectView {
      modalBGVisualEffectView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        modalBGVisualEffectView.centerXAnchor.constraint(
          equalTo: modalContentWrapperView.centerXAnchor
        ),
        
        modalBGVisualEffectView.centerYAnchor.constraint(
          equalTo: modalContentWrapperView.centerYAnchor
        ),
        
        modalBGVisualEffectView.widthAnchor.constraint(
          equalTo: modalContentWrapperView.widthAnchor
        ),
        
        modalBGVisualEffectView.heightAnchor.constraint(
          equalTo: modalContentWrapperView.heightAnchor
        ),
      ]);
    };
    
    
    #if DEBUG
    if let debugView = self.debugView {
      debugView.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        debugView.topAnchor.constraint(
          equalTo: modalRootView.topAnchor
        ),
        
        debugView.bottomAnchor.constraint(
          equalTo: modalRootView.bottomAnchor
        ),
        
        debugView.leadingAnchor.constraint(
          equalTo: modalRootView.leadingAnchor
        ),
        
        debugView.trailingAnchor.constraint(
          equalTo: modalRootView.trailingAnchor
        ),
      ]);
    };
    #endif
  };
  
  func setupExtractScrollView(){
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
  
  // MARK: - Functions - Cleanup-Related
  // -----------------------------------
  
  private func clearGestureValues() {
    self.gestureOffset = nil;
    self.gestureVelocity = nil;
    
    self.gesturePointPrev = nil;
    self.gesturePoint = nil;
    self.gestureInitialPoint = nil;
  };
  
  private func clearAnimators() {
    self.backgroundVisualEffectAnimator?.clear();
    self.backgroundVisualEffectAnimator = nil;
    
    self.modalBackgroundVisualEffectAnimator?.clear();
    self.modalBackgroundVisualEffectAnimator = nil;
    
    self.stopModalAnimator();
    self.modalAnimator = nil;
  };
  
  private func clearLayoutKeyboardValues(){
    self.layoutKeyboardValues = nil;
    self.isKeyboardVisible = false;
  };
  
  private func removeObservers(){
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
  
  private func cleanupViewControllers(){
    guard self.modalWrapperViewController != nil,
          let modalVC = self.modalViewController
    else { return };
  
    modalVC.willMove(toParent: nil);
    modalVC.removeFromParent();
    modalVC.view.removeFromSuperview();
  };
  
  private func cleanupViews() {
    let viewsToCleanup: [UIView?] = [
      self.modalDragHandleView,
      self.dummyModalView,
      self.modalWrapperLayoutView,
      // self.modalWrapperTransformView,
      self.modalWrapperShadowView,
      // self.modalContentWrapperView,
      // self.modalView,
      // self.modalContentWrapperView,
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
    
    self.targetView = nil;
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
    
    self.didTriggerSetup = false;
  };
  
  private func cleanupSnapPointOverride(){
    self.isOverridingSnapPoints = false;
    self.shouldResetRangePropertyAnimators = false;
    
    self.overrideSnapPoints = nil;
    self.overrideInterpolationPoints = nil;
    
    self.prevOverrideInterpolationIndex = 0;
    self.nextOverrideInterpolationIndex = nil;
    self.currentOverrideInterpolationIndex = 0;
  };
 
  private func cleanup() {
    self.modalFrame = .zero;
    self.prevModalFrame = .zero;
    self.prevTargetFrame = .zero;
    
    self.clearGestureValues();
    self.clearAnimators();
    self.clearLayoutKeyboardValues();
    
    self.cleanupViews();
    
    self.cleanupSnapPointOverride();
    self.removeObservers();
    self.endDisplayLink();
    
    self.currentInterpolationIndex = 0;
    
    #if DEBUG
    self.debugView?.notifyDidCleanup();
    #endif
  };

  // MARK: - Functions - Interpolation-Related Helpers
  // -------------------------------------------------
  
  private func interpolate(
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
  
  private func interpolateColor(
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
  
  private func interpolateEdgeInsets(
    inputValue: CGFloat,
    rangeInput: [CGFloat]? = nil,
    rangeOutput: [AdaptiveModalInterpolationPoint]? = nil,
    rangeOutputKey: KeyPath<AdaptiveModalInterpolationPoint, UIEdgeInsets>,
    shouldClampMin: Bool = false,
    shouldClampMax: Bool = false
  ) -> UIEdgeInsets? {
  
    guard let interpolationSteps      = rangeOutput ?? self.interpolationSteps,
          let interpolationRangeInput = rangeInput  ?? self.interpolationRangeInput
    else { return nil };
    
    let insetTop = AdaptiveModalUtilities.interpolate(
      inputValue: inputValue,
      rangeInput: interpolationRangeInput,
      rangeOutput: interpolationSteps.map {
        $0[keyPath: rangeOutputKey].top;
      },
      shouldClampMin: shouldClampMin,
      shouldClampMax: shouldClampMax
    );
    
    let insetLeft = AdaptiveModalUtilities.interpolate(
      inputValue: inputValue,
      rangeInput: interpolationRangeInput,
      rangeOutput: interpolationSteps.map {
        $0[keyPath: rangeOutputKey].left;
      },
      shouldClampMin: shouldClampMin,
      shouldClampMax: shouldClampMax
    );
    
    let insetBottom = AdaptiveModalUtilities.interpolate(
      inputValue: inputValue,
      rangeInput: interpolationRangeInput,
      rangeOutput: interpolationSteps.map {
        $0[keyPath: rangeOutputKey].bottom;
      },
      shouldClampMin: shouldClampMin,
      shouldClampMax: shouldClampMax
    );
    
    let insetRight = AdaptiveModalUtilities.interpolate(
      inputValue: inputValue,
      rangeInput: interpolationRangeInput,
      rangeOutput: interpolationSteps.map {
        $0[keyPath: rangeOutputKey].right;
      },
      shouldClampMin: shouldClampMin,
      shouldClampMax: shouldClampMax
    );
    
    guard let insetTop = insetTop,
          let insetLeft = insetLeft,
          let insetBottom  = insetBottom,
          let insetRight = insetRight
    else { return nil };
          
    return UIEdgeInsets(
      top: insetTop,
      left: insetLeft,
      bottom: insetBottom,
      right: insetRight
    );
  };
  
  private func getInterpolationStepRange(
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
  
  // MARK: - Functions - Value Interpolators
  // ---------------------------------------
  
  private func interpolateModalRect(
    forInputPercentValue inputPercentValue: CGFloat
  ) -> CGRect? {
  
    let clampConfig = modalConfig.interpolationClampingConfig;

    let nextHeight = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.computedRect.height,
      shouldClampMin: clampConfig.shouldClampModalLastHeight,
      shouldClampMax: clampConfig.shouldClampModalInitHeight
    );
    
    let nextWidth = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.computedRect.width,
      shouldClampMin: clampConfig.shouldClampModalLastWidth,
      shouldClampMax: clampConfig.shouldClampModalInitWidth
    );
    
    let nextX = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.computedRect.origin.x,
      shouldClampMin: clampConfig.shouldClampModalLastX,
      shouldClampMax: clampConfig.shouldClampModalInitX
    );
    
    let nextY = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.computedRect.origin.y,
      shouldClampMin: clampConfig.shouldClampModalLastY,
      shouldClampMax: clampConfig.shouldClampModalInitY
    );
    
    guard let nextX = nextX,
          let nextY = nextY,
          let nextWidth  = nextWidth,
          let nextHeight = nextHeight
    else { return nil };
          
    return CGRect(
      x: nextX,
      y: nextY,
      width: nextWidth,
      height: nextHeight
    );
  };
  
  private func interpolateModalTransform(
    forInputPercentValue inputPercentValue: CGFloat
  ) -> CGAffineTransform? {

    let clampConfig = modalConfig.interpolationClampingConfig;

    let nextModalRotation = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalRotation,
      shouldClampMin: clampConfig.shouldClampModalInitRotation,
      shouldClampMax: clampConfig.shouldClampModalLastRotation
    );
    
    let nextScaleX = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalScaleX,
      shouldClampMin: clampConfig.shouldClampModalLastScaleX,
      shouldClampMax: clampConfig.shouldClampModalLastScaleX
    );
    
    let nextScaleY = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalScaleY,
      shouldClampMin: clampConfig.shouldClampModalLastScaleY,
      shouldClampMax: clampConfig.shouldClampModalLastScaleY
    );
    
    let nextTranslateX = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalTranslateX,
      shouldClampMin: clampConfig.shouldClampModalInitTranslateX,
      shouldClampMax: clampConfig.shouldClampModalLastTranslateX
    );
    
    let nextTranslateY = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalTranslateY,
      shouldClampMin: clampConfig.shouldClampModalInitTranslateY,
      shouldClampMax: clampConfig.shouldClampModalLastTranslateY
    );
    
    let nextTransform: CGAffineTransform = {
      var transforms: [CGAffineTransform] = [];
      
      if let rotation = nextModalRotation {
        transforms.append(
          .init(rotationAngle: rotation)
        );
      };
      
      if let nextScaleX = nextScaleX,
         let nextScaleY = nextScaleY {
         
        transforms.append(
          .init(scaleX: nextScaleX, y: nextScaleY)
        );
      };
      
      if let nextTranslateX = nextTranslateX,
         let nextTranslateY = nextTranslateY {
         
        transforms.append(
          .init(translationX: nextTranslateX, y: nextTranslateY)
        );
      };
      
      return transforms.reduce(.identity) {
        $0.concatenating($1);
      };
    }();
 
    return nextTransform;
  };
  
  private func interpolateModalShadowOffset(
    forInputPercentValue inputPercentValue: CGFloat
  ) -> CGSize? {

    let nextWidth = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalShadowOffset.width
    );
    
    let nextHeight = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalShadowOffset.height
    );
    
    guard let nextWidth = nextWidth,
          let nextHeight = nextHeight
    else { return nil };

    return CGSize(width: nextWidth, height: nextHeight);
  };

  private func interpolateModalBorderRadius(
    forInputPercentValue inputPercentValue: CGFloat
  ) -> CGFloat? {
  
    return self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalCornerRadius
    );
  };
  
  // MARK: - Functions - Property Interpolators
  // ------------------------------------------
  
  private func applyInterpolationToModalBackgroundVisualEffect(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
  
    let animator: AdaptiveModalRangePropertyAnimator? = {
      let interpolationRange = self.getInterpolationStepRange(
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

  private func applyInterpolationToBackgroundVisualEffect(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
  
    let animator: AdaptiveModalRangePropertyAnimator? = {
      let interpolationRange = self.getInterpolationStepRange(
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
  
  private func applyInterpolationToModalPadding(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalView = self.modalView else { return };
  
    let nextPaddingLeft = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.left,
      shouldClampMin: true,
      shouldClampMax: true
    );
    
    let nextPaddingRight = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.right,
      shouldClampMin: true,
      shouldClampMax: true
    );
    
    let nextPaddingTop = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.top,
      shouldClampMin: true,
      shouldClampMax: true
    );
    
    let nextPaddingBottom = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalPaddingAdjusted.bottom,
      shouldClampMin: true,
      shouldClampMax: true
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
  
  private func applyInterpolationToModalDragHandleOffset(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalDragHandleView = self.modalDragHandleView else { return };
  
    let nextDragHandleOffset = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalDragHandleOffset,
      shouldClampMin: true,
      shouldClampMax: true
    );

    guard let nextDragHandleOffset = nextDragHandleOffset,
          let modalDragHandleConstraintOffset = self.modalDragHandleConstraintOffset,
          
          modalDragHandleConstraintOffset.constant != nextDragHandleOffset
    else { return };

    modalDragHandleConstraintOffset.constant = nextDragHandleOffset;
    
    modalDragHandleView.updateConstraints();
    modalDragHandleView.setNeedsLayout();
  };
  
  private func applyInterpolationToModalDragHandleSize(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalDragHandleView = self.modalDragHandleView else { return };
  
    let nextWidth = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalDragHandleSize.width,
      shouldClampMin: true,
      shouldClampMax: true
    );
    
    let nextHeight = self.interpolate(
      inputValue: inputPercentValue,
      rangeOutputKey: \.modalDragHandleSize.height,
      shouldClampMin: true,
      shouldClampMax: true
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
  
  private func applyInterpolationToRangeAnimators(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    self.applyInterpolationToBackgroundVisualEffect(
      forInputPercentValue: inputPercentValue
    );
    
    self.applyInterpolationToModalBackgroundVisualEffect(
      forInputPercentValue: inputPercentValue
    );
    
    self.shouldResetRangePropertyAnimators = false;
  };
  
  private func applyInterpolationToModal(
    forInputPercentValue inputPercentValue: CGFloat
  ) {
    guard let modalView = self.modalView else { return };
    
    self.modalFrame = {
      let nextRect = self.interpolateModalRect(
        forInputPercentValue: inputPercentValue
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
        let dampingPercentRaw = self.interpolate(
          inputValue: inputPercentValue,
          rangeOutputKey: \.secondaryGestureAxisDampingPercent
        );
        
        if dampingPercentRaw == 1 {
          return nextRect.origin[keyPath: self.modalConfig.secondarySwipeAxis];
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
            nextRect.origin[keyPath: self.modalConfig.secondarySwipeAxis],
            secondaryAxis
          ]
        );
        
        return secondaryAxisAdj ?? secondaryAxis;
      }();
      
      let nextOrigin: CGPoint = {
        if self.modalConfig.snapDirection.isVertical {
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
    
    self.applyInterpolationToModalPadding(
      forInputPercentValue: inputPercentValue
    );
    
    self.applyInterpolationToModalDragHandleSize(
      forInputPercentValue: inputPercentValue
    );
    
    self.applyInterpolationToModalDragHandleOffset(
      forInputPercentValue: inputPercentValue
    );
    
    block:
    if self.modalConfig.shouldSetModalScrollViewContentInsets,
       let modalContentScrollView = self.modalContentScrollView {
       
      let interpolatedInsets = self.interpolateEdgeInsets(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalScrollViewContentInsets
      );
      
      guard let interpolatedInsets = interpolatedInsets else { break block };
      
      modalContentScrollView.contentInset = interpolatedInsets;
      modalContentScrollView.adjustedContentInsetDidChange();
    };
    
    block:
    if self.modalConfig.shouldSetModalScrollViewVerticalScrollIndicatorInsets,
       let modalContentScrollView = self.modalContentScrollView {
       
      guard #available(iOS 11.1, *) else { break block };
       
      let interpolatedInsets = self.interpolateEdgeInsets(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalScrollViewVerticalScrollIndicatorInsets
      );
      
      guard let interpolatedInsets = interpolatedInsets else { break block };
      modalContentScrollView.verticalScrollIndicatorInsets = interpolatedInsets;
    };
    
    block:
    if self.modalConfig.shouldSetModalScrollViewHorizontalScrollIndicatorInsets,
       let modalContentScrollView = self.modalContentScrollView {
       
      guard #available(iOS 11.1, *) else { break block };
       
      let interpolatedInsets = self.interpolateEdgeInsets(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalScrollViewHorizontalScrollIndicatorInsets
      );
      
      guard let interpolatedInsets = interpolatedInsets else { break block };
      modalContentScrollView.horizontalScrollIndicatorInsets = interpolatedInsets;
    };
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperTransformView,
      forPropertyKey: \.transform,
      withValue:  self.interpolateModalTransform(
        forInputPercentValue: inputPercentValue
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: modalView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalContentOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperLayoutView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.borderWidth,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBorderWidth
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.borderColor,
      withValue: {
        let color = self.interpolateColor(
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
        let color = self.interpolateColor(
          inputValue: inputPercentValue,
          rangeOutputKey: \.modalShadowColor
        );
        
        return color?.cgColor;
      }()
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.shadowOffset,
      withValue:  self.interpolateModalShadowOffset(
        forInputPercentValue: inputPercentValue
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalWrapperShadowView,
      forPropertyKey: \.layer.shadowOpacity,
      withValue: {
        let value = self.interpolate(
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
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalShadowRadius
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalContentWrapperView,
      forPropertyKey: \.layer.cornerRadius,
      withValue:  self.interpolateModalBorderRadius(
        forInputPercentValue: inputPercentValue
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundView,
      forPropertyKey: \.backgroundColor,
      withValue:  self.interpolateColor(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBackgroundColor
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBackgroundOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalBackgroundVisualEffectView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalBackgroundVisualEffectOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalDragHandleView,
      forPropertyKey: \.backgroundColor,
      withValue:  self.interpolateColor(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalDragHandleColor
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalDragHandleView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalDragHandleOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.modalDragHandleView,
      forPropertyKey: \.layer.cornerRadius,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.modalDragHandleCornerRadius
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.backgroundDimmingView,
      forPropertyKey: \.backgroundColor,
      withValue:  self.interpolateColor(
        inputValue: inputPercentValue,
        rangeOutputKey: \.backgroundColor
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.backgroundDimmingView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.backgroundOpacity
      )
    );
    
    AdaptiveModalUtilities.unwrapAndSetProperty(
      forObject: self.backgroundVisualEffectView,
      forPropertyKey: \.alpha,
      withValue:  self.interpolate(
        inputValue: inputPercentValue,
        rangeOutputKey: \.backgroundVisualEffectOpacity
      )
    );
    
    self.applyInterpolationToRangeAnimators(
      forInputPercentValue: inputPercentValue
    );
    
    self.animationEventDelegate?.notifyOnModalAnimatorPercentChanged(
      sender: self,
      percent: inputPercentValue
    );
    
    #if DEBUG
    self.debugView?.notifyOnApplyInterpolationToModal();
    #endif
  };
  
  private func applyInterpolationToModal(forPoint point: CGPoint) {
    guard let interpolationRangeMaxInput = self.interpolationRangeMaxInput
    else { return };
    
    let inputValue = point[keyPath: self.modalConfig.inputValueKeyForPoint];
    
    let shouldInvertPercent: Bool = {
      switch modalConfig.snapDirection {
        case .bottomToTop, .rightToLeft: return true;
        default: return false;
      };
    }();
    
    let percent = inputValue / interpolationRangeMaxInput;
    
    let percentClamped: CGFloat = {
      guard !self.shouldEnableOverShooting else { return percent };
      
      let secondToLastIndex = self.modalConfig.snapPointLastIndex - 1;
      let maxPercent = self.interpolationRangeInput[secondToLastIndex];
      
      return percent.clamped(max: maxPercent);
    }();
    
    let percentAdj = shouldInvertPercent
      ? AdaptiveModalUtilities.invertPercent(percentClamped)
      : percentClamped;
      
    self.applyInterpolationToModal(forInputPercentValue: percentAdj);
  };
  
  private func applyInterpolationToModal(forGesturePoint gesturePoint: CGPoint) {
    let gesturePointWithOffset =
      self.applyGestureOffsets(forGesturePoint: gesturePoint);
      
    if !self.shouldLockAxisToModalDirection {
      self.modalSecondaryAxisValue =
        gesturePointWithOffset[keyPath: self.modalConfig.secondarySwipeAxis];
    };
  
    self.applyInterpolationToModal(forPoint: gesturePointWithOffset);
  };
  
  // MARK: - Functions - Helpers/Utilities
  // -------------------------------------
  
  private func stopModalAnimator(){
    self.modalAnimator?.stopAnimation(true);
    self.animationEventDelegate?.notifyOnModalAnimatorStop(sender: self);
  };
  
  private func adjustInterpolationIndex(for nextIndex: Int) -> Int {
    if nextIndex == 0 {
      return self.shouldSnapToUnderShootSnapPoint
        ? nextIndex
        : 1;
    };
    
    let lastIndex = self.interpolationSteps.count - 1;
    
    if nextIndex == lastIndex {
      return self.shouldSnapToOvershootSnapPoint
        ? nextIndex
        : lastIndex - 1;
    };
    
    return nextIndex;
  };
  
  private func applyGestureOffsets(
    forGesturePoint gesturePoint: CGPoint
  ) -> CGPoint {
  
    guard let computedGestureOffset = self.computedGestureOffset
    else { return gesturePoint };
    
    let x: CGFloat = {
      switch self.modalConfig.snapDirection {
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
      switch self.modalConfig.snapDirection {
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
      + "\n - targetView: \(self.targetView?.debugDescription ?? "N/A")"
      + "\n - targetView frame: \(self.targetView?.frame.debugDescription ?? "N/A")"
      + "\n - targetView superview: \(self.targetView?.superview.debugDescription ?? "N/A")"
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
  
  private func computeSnapPoints(
    usingLayoutValueContext context: RNILayoutValueContext? = nil
  ) {
    let context = context ?? self.layoutValueContext;
    
    self.configInterpolationSteps = .Element.compute(
      usingModalConfig: self.modalConfig,
      layoutValueContext: context
    );
    
    if let overrideSnapPoints = self.overrideSnapPoints {
      self.overrideInterpolationPoints = .Element.compute(
        usingModalConfig: self.modalConfig,
        snapPoints: overrideSnapPoints,
        layoutValueContext: context
      );
    };
  };
  
  private func updateModal() {
    guard !self.isAnimating else { return };
        
    if let gesturePoint = self.gesturePoint {
      self.applyInterpolationToModal(forGesturePoint: gesturePoint);
    
    } else if self.currentInterpolationStep.computedRect != self.modalFrame {
      self.currentInterpolationStep.applyAnimation(toModalManager: self);
    };
    
    #if DEBUG
    self.debugView?.notifyOnUpdateModal();
    #endif
  };
  
  private func getClosestSnapPoint(forCoord coord: CGFloat? = nil) -> (
    interpolationIndex: Int,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    snapDistance: CGFloat
  ) {
    let inputRect = self.modalFrame!;
    
    let inputCoord = coord ??
      inputRect[keyPath: self.modalConfig.inputValueKeyForRect];
    
    let delta = self.interpolationSteps.map {
      let coord =
        $0.computedRect[keyPath: self.modalConfig.inputValueKeyForRect];
      
      return abs(inputCoord - coord);
    };
    
    let deltaSorted = delta.enumerated().sorted {
      $0.element < $1.element
    };
    
    let closestSnapPoint = deltaSorted.first!;
    let closestInterpolationIndex = closestSnapPoint.offset;
    
    let interpolationPoint = interpolationSteps[closestInterpolationIndex];
    
    return (
      interpolationIndex: closestInterpolationIndex,
      interpolationPoint: interpolationPoint,
      snapDistance: closestSnapPoint.element
    );
  };
  
  private func getClosestSnapPoint(
    forRect currentRect: CGRect
  ) -> (
    interpolationIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    snapDistance: CGFloat
  ) {
    let delta = interpolationSteps.map {
      CGRect(
        x: abs($0.computedRect.origin.x - currentRect.origin.x),
        y: abs($0.computedRect.origin.y - currentRect.origin.y),
        width : abs($0.computedRect.size.height - currentRect.size.height),
        height: abs($0.computedRect.size.height - currentRect.size.height)
      );
    };
    
    let deltaAvg = delta.map {
      ($0.origin.x + $0.origin.y + $0.width + $0.height) / 4;
    };
    
    let deltaAvgSorted = deltaAvg.enumerated().sorted {
      $0.element < $1.element;
    };
    
    let closestInterpolationPointIndex = deltaAvgSorted.first!.offset;
      
    let closestInterpolationPoint =
      interpolationSteps[closestInterpolationPointIndex];
    
    return (
      interpolationIndex: closestInterpolationPointIndex,
      snapPointConfig: self.modalConfig.snapPoints[closestInterpolationPointIndex],
      interpolationPoint: closestInterpolationPoint,
      snapDistance: deltaAvg[closestInterpolationPointIndex]
    );
  };
  
  private func animateModal(
    to interpolationPoint: AdaptiveModalInterpolationPoint,
    animator: UIViewPropertyAnimator? = nil,
    isAnimated: Bool = true,
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
      let animator: UIViewPropertyAnimator = animator ?? {
        let gestureInitialVelocity = self.gestureInitialVelocity;
        let snapAnimationConfig = self.modalConfig.snapAnimationConfig;
          
        let springTiming = UISpringTimingParameters(
          dampingRatio: snapAnimationConfig.springDampingRatio,
          initialVelocity: gestureInitialVelocity
        );

        return UIViewPropertyAnimator(
          duration: snapAnimationConfig.springAnimationSettlingTime,
          timingParameters: springTiming
        );
      }();
      
      self.stopModalAnimator();
      self.modalAnimator = animator;
      
      animator.addAnimations {
        animationBlock();
      };
      
      if let completion = completion {
        animator.addCompletion(completion);
      };
      
      if let delegate = self.animationEventDelegate {
        animator.addCompletion {
          delegate.notifyOnModalAnimatorCompletion(
            sender: self,
            position: $0
          );
        }
      };
      
      animator.addCompletion { _ in
        self.endDisplayLink();
        self.modalAnimator = nil;
        
        #if DEBUG
        self.debugView?.notifyOnAnimateModalCompletion();
        #endif
      };
    
      animator.startAnimation();
      self.startDisplayLink();
      
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
    
    self.animationEventDelegate?.notifyOnModalAnimatorStart(
      sender: self,
      animator: self.modalAnimator,
      interpolationPoint: interpolationPoint,
      isAnimated: isAnimated
    );
  };
  
  private func cancelModalGesture(){
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
  
  @objc private func onDragPanGesture(_ sender: UIPanGestureRecognizer) {
    var shouldClearGestureValues = false;
  
    let gesturePoint = sender.location(in: self.targetView);
    self.gesturePoint = gesturePoint;
    
    let gestureVelocity = sender.velocity(in: self.targetView);
    self.gestureVelocity = gestureVelocity;
    
    #if DEBUG
    self.debugView?.notifyOnDragPanGesture(sender);
    #endif
    
    switch sender.state {
      case .began:
        self.gestureInitialPoint = gesturePoint;
        
        if self.isKeyboardVisible,
           self.shouldDismissKeyboardOnGestureSwipe,
           let modalView = self.modalView {
           
          modalView.endEditing(true);
          self.cancelModalGesture();
        };
    
      case .changed:
        if !self.isKeyboardVisible || self.isAnimating {
          self.stopModalAnimator();
        };
        
        self.applyInterpolationToModal(forGesturePoint: gesturePoint);
        self.notifyOnModalWillSnap();
        
      case .cancelled, .ended:
        defer {
          shouldClearGestureValues = true;
        };
      
        guard self.shouldEnableSnapping else { break };
        let gestureFinalPointRaw = self.gestureFinalPoint ?? gesturePoint;
        
        let gestureFinalPoint =
          self.applyGestureOffsets(forGesturePoint: gestureFinalPointRaw);
        
        self.snapToClosestSnapPoint(forPoint: gestureFinalPoint);
        
      default:
        break;
    };
    
    self.eventDelegate?.notifyOnAdaptiveModalDragGesture(
      sender: self,
      gestureRecognizer: sender
    );
    
    if shouldClearGestureValues {
      self.clearGestureValues();
    };
  };
  
  @objc private func onBackgroundTapGesture(_ sender: UITapGestureRecognizer) {
    self.backgroundTapDelegate?.notifyOnBackgroundTapGesture(sender: sender);
    
    switch self.currentInterpolationStep.backgroundTapInteraction {
      case .dismiss:
        self.dismissModal();
      
      default:
        break;
    };
  };
  
  @objc private func onKeyboardWillShow(notification: NSNotification) {
    guard let keyboardValues = RNILayoutKeyboardValues(fromNotification: notification),
          self.presentationState != .dismissing
    else { return };
    
    self.isKeyboardVisible = true;
    self.layoutKeyboardValues = keyboardValues;
    self.computeSnapPoints();

    self.animateModal(
      to: self.currentInterpolationStep,
      animator: keyboardValues.keyboardAnimator
    );
  };
  
  @objc private func onKeyboardDidShow(notification: NSNotification) {
    guard let keyboardValues = RNILayoutKeyboardValues(fromNotification: notification)
    else { return };
    
    self.isKeyboardVisible = true;
    self.layoutKeyboardValues = keyboardValues;
    self.computeSnapPoints();
  };

  @objc private func onKeyboardWillHide(notification: NSNotification) {
    guard let keyboardValues = RNILayoutKeyboardValues(fromNotification: notification)
    else { return };
    
    self.clearLayoutKeyboardValues();
    self.computeSnapPoints();
    
    self.animateModal(
      to: self.currentInterpolationStep,
      animator: keyboardValues.keyboardAnimator,
      extraAnimation: nil
    ) { _ in
    
      self.isKeyboardVisible = false;
    };
  };
  
  @objc private func onKeyboardDidHide(notification: NSNotification) {
    self.isKeyboardVisible = false;
  };
  
  @objc private func onKeyboardWillChange(notification: NSNotification) {
    guard let keyboardValues = RNILayoutKeyboardValues(fromNotification: notification),
          self.presentationState == .none,
          !self.isAnimating
    else { return };
    
    self.layoutKeyboardValues = keyboardValues;
    self.computeSnapPoints();
    
    self.animateModal(
      to: self.currentInterpolationStep,
      animator: keyboardValues.keyboardAnimator
    );
  };
  
  @objc private func onKeyboardDidChange(notification: NSNotification) {
    guard let keyboardValues = RNILayoutKeyboardValues(fromNotification: notification),
          self.presentationState == .none
    else { return };
    
    self.layoutKeyboardValues = keyboardValues;
    self.computeSnapPoints();
  };
  
  // MARK: - Functions - DisplayLink-Related
  // ---------------------------------------
    
  func startDisplayLink(shouldAutoEndDisplayLink: Bool) {
    self.shouldAutoEndDisplayLink = shouldAutoEndDisplayLink;
    
    let displayLink = CADisplayLink(
      target: self,
      selector: #selector(self.onDisplayLinkTick(displayLink:))
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
  
  @objc private func onDisplayLinkTick(displayLink: CADisplayLink) {
    var shouldEndDisplayLink = false;
    
    defer {
      #if DEBUG
      self.debugView?.notifyOnDisplayLinkTick();
      #endif
    
      if shouldEndDisplayLink && self.shouldAutoEndDisplayLink {
        self.endDisplayLink();
      };
    };
    
    guard let dummyModalView = self.dummyModalView,
          let dummyModalViewLayer = dummyModalView.layer.presentation(),
          let interpolationRangeMaxInput = self.interpolationRangeMaxInput
    else {
      shouldEndDisplayLink = true;
      return;
    };
    
    if self.isSwiping && !self.isKeyboardVisible {
      shouldEndDisplayLink = true;
    };
    
    if self.displayLinkStartTimestamp == nil {
      self.displayLinkStartTimestamp = displayLink.timestamp;
    };
    
    let prevModalFrame = self.prevModalFrame;
    let nextModalFrame = dummyModalViewLayer.frame;

    guard prevModalFrame != nextModalFrame else { return };
    
    let inputCoord =
      nextModalFrame[keyPath: self.modalConfig.inputValueKeyForRect];
      
    let percent = inputCoord / interpolationRangeMaxInput;
    
    let percentAdj = self.modalConfig.shouldInvertPercent
      ? AdaptiveModalUtilities.invertPercent(percent)
      : percent;
    
    self.applyInterpolationToRangeAnimators(
      forInputPercentValue: percentAdj
    );
    
    self.prevModalFrame = nextModalFrame;
  };
  
  // MARK: - Event Functions
  // -----------------------
  
  private func notifyOnModalWillSnap() {
    let interpolationSteps = self.interpolationSteps!;
    
    let prevIndex = self.onModalWillSnapPrevIndex
      ?? self.currentInterpolationIndex;
      
    let nextIndexRaw: Int = {
      if let nextIndex = self.nextInterpolationIndex {
        return nextIndex;
      };
    
      let closestSnapPoint = self.getClosestSnapPoint();
      return closestSnapPoint.interpolationPoint.snapPointIndex;
    }();
    
    let nextIndex = self.adjustInterpolationIndex(for: nextIndexRaw);
    let nextPoint = self.interpolationSteps[nextIndex];
    
    guard prevIndex != nextIndex else { return };
    self.onModalWillSnapPrevIndex = nextIndex;
    
    self.eventDelegate?.notifyOnModalWillSnap(
      sender: self,
      prevSnapPointIndex: interpolationSteps[prevIndex].snapPointIndex,
      nextSnapPointIndex: interpolationSteps[nextIndex].snapPointIndex,
      snapPointConfig: self.modalConfig.snapPoints[nextPoint.snapPointIndex],
      interpolationPoint: nextPoint
    );
    
    let shouldDismissOnSnapToUnderShootSnapPoint =
      nextIndex == 0 && self.shouldDismissModalOnSnapToUnderShootSnapPoint;
      
    let shouldDismissOnSnapToOverShootSnapPoint =
      nextIndex == self.modalConfig.overshootSnapPointIndex &&
      self.shouldDismissModalOnSnapToOverShootSnapPoint;
    
    let shouldDismiss =
      shouldDismissOnSnapToUnderShootSnapPoint ||
      shouldDismissOnSnapToOverShootSnapPoint;
      
    let isPresenting = self.currentInterpolationIndex == 0 && nextIndex == 1;
      
    if shouldDismiss {
      self.notifyOnModalWillHide();
      
    } else if isPresenting {
      self.notifyOnModalWillShow();
    };
  };
  
  private func notifyOnModalDidSnap() {
    #if DEBUG
    self.debugView?.notifyOnModalDidSnap();
    #endif
    
    self.nextInterpolationIndex = nil;
  
    self.eventDelegate?.notifyOnModalDidSnap(
      sender: self,
      prevSnapPointIndex:
        self.interpolationSteps[self.prevInterpolationIndex].snapPointIndex,
        
      currentSnapPointIndex:
        self.interpolationSteps[self.currentInterpolationIndex].snapPointIndex,
        
      snapPointConfig: self.currentSnapPointConfig,
      interpolationPoint: self.currentInterpolationStep
    );
    
    self.currentInterpolationStep.applyConfig(toModalManager: self);
    
    let shouldDismissOnSnapToUnderShootSnapPoint =
      self.currentInterpolationIndex == 0 &&
      self.shouldDismissModalOnSnapToUnderShootSnapPoint;
      
    let shouldDismissOnSnapToOverShootSnapPoint =
      self.currentInterpolationIndex == self.modalConfig.overshootSnapPointIndex &&
      self.shouldDismissModalOnSnapToOverShootSnapPoint;
    
    let shouldDismiss =
      shouldDismissOnSnapToUnderShootSnapPoint ||
      shouldDismissOnSnapToOverShootSnapPoint;
      
    let wasPresented =
      self.currentInterpolationIndex == 1 &&
      self.prevInterpolationIndex == 0;
    
    if shouldDismiss {
      self.notifyOnModalDidHide();
      
    } else if wasPresented {
      self.notifyOnModalDidShow();
    };
    
    if self.shouldClearOverrideSnapPoints {
      self.cleanupSnapPointOverride();
    };
    
    self.clearAnimators();
  };
  
  private func notifyOnModalWillShow(){
    self.eventDelegate?.notifyOnAdaptiveModalWillShow(sender: self);
  };
  
  private func notifyOnModalDidShow(){
    self.eventDelegate?.notifyOnAdaptiveModalDidShow(sender: self);
  };
  
  private func notifyOnModalWillHide(){
    if self.isKeyboardVisible,
       let modalView = self.modalView {
       
      modalView.endEditing(true);
    };
    
    self.eventDelegate?.notifyOnAdaptiveModalWillHide(sender: self);
  };
  
  private func notifyOnModalDidHide(){
    self.cleanup();
    self.modalViewController?.dismiss(animated: false);
    self.cleanupViewControllers();
    
    self.eventDelegate?.notifyOnAdaptiveModalDidHide(sender: self);
  };

  // MARK: - Functions
  // -----------------
    
  func snapTo(
    interpolationIndex nextIndex: Int,
    interpolationPoint: AdaptiveModalInterpolationPoint? = nil,
    isAnimated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    self.nextInterpolationIndex = nextIndex;
  
    let nextInterpolationPoint = interpolationPoint
      ?? self.interpolationSteps[nextIndex];
      
    self.notifyOnModalWillSnap();
  
    self.animateModal(
      to: nextInterpolationPoint,
      isAnimated: isAnimated,
      extraAnimation: extraAnimation
    ) { _ in
    
      self.currentInterpolationIndex = nextIndex;
      self.nextInterpolationIndex = nil;
      
      self.notifyOnModalDidSnap();
      completion?();
    }
  };
  
  func snapToClosestSnapPoint(
    forPoint point: CGPoint,
    completion: (() -> Void)? = nil
  ) {
    let coord = point[keyPath: self.modalConfig.inputValueKeyForPoint];
    let closestSnapPoint = self.getClosestSnapPoint(forCoord: coord);
    
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
      completion: completion
    );
  };
  
  func showModal(
    isAnimated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    let nextIndex = self.modalConfig.initialSnapPointIndex;
    
    self.snapTo(
      interpolationIndex: nextIndex,
      isAnimated: isAnimated,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  func hideModal(
    useInBetweenSnapPoints: Bool = false,
    isAnimated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ){
  
    let nextIndex = 0;
    
    if useInBetweenSnapPoints {
      self.snapTo(
        interpolationIndex: nextIndex,
        isAnimated: isAnimated,
        extraAnimation: extraAnimation,
        completion: completion
      );
    
    } else {
      self.computeSnapPoints();
      
      let currentSnapPointConfig = self.currentSnapPointConfig;
      let currentInterpolationStep = self.currentInterpolationStep;
  
      let undershootSnapPointConfig = AdaptiveModalSnapPointConfig(
        fromSnapPointPreset: self.modalConfig.undershootSnapPoint,
        fromBaseLayoutConfig: currentSnapPointConfig.layoutConfig
      );
      
      var undershootInterpolationPoint = AdaptiveModalInterpolationPoint(
        usingModalConfig: self.modalConfig,
        snapPointIndex: nextIndex,
        layoutValueContext: self.layoutValueContext,
        snapPointConfig: undershootSnapPointConfig
      );
      
      undershootInterpolationPoint.modalCornerRadius =
        currentInterpolationStep.modalCornerRadius;
      
      self.snapTo(
        interpolationIndex: nextIndex,
        interpolationPoint: undershootInterpolationPoint,
        isAnimated: isAnimated,
        extraAnimation: extraAnimation,
        completion: completion
      );
    };
  };
  
  // MARK: - User-Invoked Functions
  // ------------------------------
  
  public func prepareForPresentation(
    targetView: UIView? = nil,
    shouldForceReset: Bool = false
  ) {
    guard let modalView = modalView ?? self.modalView,
          let targetView = targetView ?? self.targetView
    else { return };

    let didViewsChange =
      modalView !== self.modalView || targetView !== self.targetView;
      
    let shouldReset =
      !self.didTriggerSetup || didViewsChange || shouldForceReset;
    
    if shouldReset {
      self.cleanup();
    };
    
    self.targetView = targetView;
    self.computeSnapPoints();
    
    if shouldReset {
      self.setupInitViews();
      self.setupDummyModalView();
      self.setupGestureHandler();
      
      self.setupAddViews();
      self.setupViewConstraints();
      self.setupObservers();
      
      self.setupExtractScrollView();
    };
    
    self.updateModal();
    self.modalFrame = self.currentInterpolationStep.computedRect;
    self.modalWrapperLayoutView?.layoutIfNeeded();
    
    self.didTriggerSetup = true;
  };
  
  public func prepareForPresentation(
    viewControllerToPresent presentedVC: UIViewController,
    presentingViewController presentingVC: UIViewController
  ) {
    self.modalViewController = presentedVC;
    self.presentingViewController = presentingVC;
    
    let modalWrapperVC = AdaptiveModalRootViewController();
    self.modalWrapperViewController = modalWrapperVC;
    
    modalWrapperVC.view.addSubview(presentedVC.view);
    modalWrapperVC.addChild(presentedVC);
    presentedVC.didMove(toParent: presentedVC);
    
    self.setupViewControllers();
  };
  
  public func notifyDidLayoutSubviews() {
    guard let targetView = self.targetView else { return };
    
    let prevTargetFrame = self.prevTargetFrame;
    let nextTargetFrame = targetView.frame;
    
    guard prevTargetFrame != nextTargetFrame else { return };
    self.prevTargetFrame = nextTargetFrame;
  
    self.computeSnapPoints();
    self.updateModal();
  };
  
  public func clearSnapPointOverride(completion: (() -> Void)?){
    guard self.isOverridingSnapPoints else { return };
  
    self.cleanupSnapPointOverride();
    self.snapToCurrentIndex(completion: completion);
  };
  
  public func presentModal(
    viewControllerToPresent modalVC: UIViewController,
    presentingViewController targetVC: UIViewController,
    extraAnimation: (() -> Void)? = nil,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) {
  
    self.extraAnimationBlockPresent = extraAnimation;
  
    self.prepareForPresentation(
      viewControllerToPresent: modalVC,
      presentingViewController: targetVC
    );
    
    guard let presentedVC = self.presentedViewController else { return };
    
    targetVC.present(
      presentedVC,
      animated: animated,
      completion: completion
    );
  };
  
  public func dismissModal(
    animated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    guard let modalVC = self.modalViewController else { return };
    self.extraAnimationBlockDismiss = extraAnimation;
    
    modalVC.dismiss(
      animated: animated,
      completion: completion
    );
  };
  
  public func snapToClosestSnapPoint(
    isAnimated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
    let closestSnapPoint = self.getClosestSnapPoint(
      forRect: self.modalFrame ?? .zero
    );
    
    let nextInterpolationIndex =
      self.adjustInterpolationIndex(for: closestSnapPoint.interpolationIndex);
    
    let nextInterpolationPoint =
      self.interpolationSteps[nextInterpolationIndex];
    
    let prevFrame = self.modalFrame;
    let nextFrame = nextInterpolationPoint.computedRect;
    
    guard nextInterpolationIndex != self.currentInterpolationIndex,
          prevFrame != nextFrame
    else { return };
    
    self.snapTo(
      interpolationIndex: nextInterpolationIndex,
      isAnimated: isAnimated,
      extraAnimation: extraAnimation
    ) {
      completion?();
    };
  };
  
  public func snapToCurrentIndex(
    isAnimated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) {
  
    self.snapTo(
      interpolationIndex: self.currentInterpolationIndex,
      isAnimated: isAnimated,
      extraAnimation: extraAnimation,
      completion: completion
    );
  };
  
  public func snapTo(
    overrideSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevSnapPointConfigs: [AdaptiveModalSnapPointConfig]? = nil,
    overshootSnapPointPreset: AdaptiveModalSnapPointPreset? = .automatic,
    fallbackSnapPointKey: AdaptiveModalSnapPointConfig.SnapPointKey? = nil,
    inBetweenSnapPointsMinPercentDiff: CGFloat = 0.1,
    isAnimated: Bool = true,
    extraAnimation: (() -> Void)? = nil,
    completion: (() -> Void)? = nil
  ) throws {
  
    self.cleanupSnapPointOverride();
    
    let prevSnapPointConfigs: [AdaptiveModalSnapPointConfig] = {
      if let prevSnapPointConfigs = prevSnapPointConfigs {
        return prevSnapPointConfigs;
      };
    
      let prevInterpolationPoints: [AdaptiveModalInterpolationPoint] = {
        let overrideInterpolationPoint = AdaptiveModalInterpolationPoint(
          usingModalConfig: self.modalConfig,
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
        self.modalConfig.snapPoints[$0.snapPointIndex];
      };
    }();
    
    let overshootSnapPointPreset: AdaptiveModalSnapPointPreset? = {
      guard let overshootSnapPointPreset = overshootSnapPointPreset
      else { return nil };
    
      switch overshootSnapPointPreset.layoutPreset {
        case .automatic:
          return .getDefaultOvershootSnapPoint(
            forDirection: self.modalConfig.snapDirection,
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
    self.computeSnapPoints();
    
    guard let overrideInterpolationPoints = self.overrideInterpolationPoints,
          let nextInterpolationPoint =
            overrideInterpolationPoints[safeIndex: nextInterpolationPointIndex]
    else {
      throw NSError();
    };
    
    self.isOverridingSnapPoints = true;
    self.shouldResetRangePropertyAnimators = true;
    self.currentOverrideInterpolationIndex = nextInterpolationPointIndex;
    
    self.animateModal(
      to: nextInterpolationPoint,
      isAnimated: isAnimated,
      extraAnimation: extraAnimation
    ) { _ in
      completion?();
    };
  };
  
  public func snapTo(
    key: AdaptiveModalSnapPointConfig.SnapPointKey,
    isAnimated: Bool = true,
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
      
    self.notifyOnModalWillSnap();
    
    self.animateModal(
      to: matchingInterpolationPoint,
      extraAnimation: animationBlock
    ) { _ in
      self.notifyOnModalDidSnap();
      completion?();
    };
  };
};

// MARK: - UIGestureRecognizerDelegate
// -----------------------------------

extension AdaptiveModalManager: UIGestureRecognizerDelegate {

  public func gestureRecognizerShouldBegin(
    _ gestureRecognizer: UIGestureRecognizer
  ) -> Bool {
  
    guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer
    else { return true };
  
    let currentInterpolationStep = self.currentInterpolationStep;
    
    let secondaryGestureAxisDampingPercent =
      currentInterpolationStep.secondaryGestureAxisDampingPercent;
      
    let isLockedToPrimaryAxis = secondaryGestureAxisDampingPercent >= 1;
    let velocity = panGesture.velocity(in: self.modalView);
    
    let primaryAxisVelocity =
      velocity[keyPath: self.modalConfig.inputValueKeyForPoint];
    
    return isLockedToPrimaryAxis
      ? abs(primaryAxisVelocity) > 0
      : true;
  };
  
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
  
    guard let modalView = self.modalView,
          let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
          let modalContentScrollView = self.modalContentScrollView
    else { return false };
    
    let modalContentScrollViewGestures =
      modalContentScrollView.gestureRecognizers ?? [];
      
    guard modalContentScrollViewGestures.contains(otherGestureRecognizer)
    else { return false };
    
    func cancelOtherGesture() {
      otherGestureRecognizer.isEnabled.toggle();
      otherGestureRecognizer.isEnabled.toggle();
    };
    
    let gesturePoint = panGesture.location(in: self.targetView);
    
    let gestureVelocity = panGesture.velocity(in: modalView);
    
    let gestureVelocityCoord = gestureVelocity[
      keyPath: self.modalConfig.inputValueKeyForPoint
    ];
      
    let modalContentScrollViewOffset = modalContentScrollView.contentOffset[
      keyPath: self.modalConfig.inputValueKeyForPoint
    ];
    
    let modalContentMinScrollViewOffset = modalContentScrollView.minContentOffset[
      keyPath: self.modalConfig.inputValueKeyForPoint
    ];
    
    let modalContentMaxScrollViewOffset = modalContentScrollView.maxContentOffset[
      keyPath: self.modalConfig.inputValueKeyForPoint
    ];
    
    if !modalContentScrollView.isScrollEnabled {
      return true;
    };
    
    if let modalSwipeGestureEdgeRect = self.modalSwipeGestureEdgeRect,
       modalSwipeGestureEdgeRect.contains(gesturePoint) {
      
      cancelOtherGesture();
      return true;
    };
    
    if modalContentScrollView.isDecelerating {
      return false;
    };
    
    if abs(gestureVelocityCoord) > 500 {
      return false;
    };
    
    if self.allowModalToDragWhenAtMinScrollViewOffset,
       modalContentScrollViewOffset <= modalContentMinScrollViewOffset,
       gestureVelocityCoord > 0 {
      
      cancelOtherGesture();
      return true;
    };
    
    if self.allowModalToDragWhenAtMaxScrollViewOffset,
       modalContentScrollViewOffset >= modalContentMaxScrollViewOffset,
       gestureVelocityCoord < 0 {
    
      return true;
    };
  
    return false;
  };
};
