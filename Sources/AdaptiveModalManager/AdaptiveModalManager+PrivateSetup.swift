//
//  AdaptiveModalManager+PrivateSetup.swift
//  
//
//  Created by Dominic Go on 12/1/23.
//

import UIKit

extension AdaptiveModalManager {
  
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
      !self._didTriggerSetup || shouldForceReset;
    
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
    
    self._didTriggerSetup = true;
  };
};
