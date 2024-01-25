//
//  AdaptiveModalPresentationTest.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/7/23.
//

import UIKit
import AdaptiveModal

fileprivate class TestModalViewController:
  UIViewController,
  AdaptiveModalBackgroundTapDelegate,
  AdaptiveModalAnimationEventsNotifiable,
  AdaptiveModalStateEventsNotifiable,
  AdaptiveModalPresentationEventsNotifiable,
  AdaptiveModalGestureEventsNotifiable {

  enum ContentMode {
    case buttons, scrollview;
  };
  
  var shouldIncreaseModalIndexOnTap = true;
  
  static var enableLogging = false;

  weak var modalManager: AdaptiveModalManager?;
  
  var onCurrentModalConfigDidChangeBlock: (() -> Void)? = nil;
  var onAdaptiveModalDidShow: (() -> Void)? = nil;
  
  var contentMode: ContentMode = .buttons;
  
  var showDismissButton = true;
  var showCustomSnapPointButton = false;
  var showTextInputField = false;
  
  var shouldSetOverrideOverShootSnapPoint = false;
  
  var edgePanRecognizer: UIScreenEdgePanGestureRecognizer?;

  lazy var floatingViewLabel: UILabel = {
    let label = UILabel();
    
    label.text = "\(self.modalManager?.currentInterpolationIndex ?? -1)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .boldSystemFont(ofSize: 22);
    
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(Self.onPressLabel(_:))
    );
    
    label.addGestureRecognizer(tapGesture);
    label.isUserInteractionEnabled = true;

    return label;
  }();
  
  override func viewDidLoad() {
    self.view.backgroundColor = .clear;
    
    let dismissButton: UIButton = {
      let button = UIButton();
      
      button.setTitle("Dismiss Modal", for: .normal);
      button.configuration = .filled();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonDismiss(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let customSnapPointButton: UIButton = {
      let button = UIButton();
      
      button.setTitle("Custom Snap Point", for: .normal);
      button.configuration = .filled();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonCustomSnapPoint(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let textInputField: UITextField = {
      let textField = UITextField();
    
      textField.placeholder = "Enter text here";
      textField.font = UIFont.systemFont(ofSize: 15);
      textField.borderStyle = UITextField.BorderStyle.roundedRect;
      textField.autocorrectionType = UITextAutocorrectionType.no;
      textField.keyboardType = UIKeyboardType.default;
      textField.returnKeyType = UIReturnKeyType.done;
      textField.clearButtonMode = UITextField.ViewMode.whileEditing;
      textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center;
      
      return textField;
    }();
    
    let controlsView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .equalSpacing;
      stack.alignment = .center;
      stack.spacing = 10;
      
      stack.addArrangedSubview(self.floatingViewLabel);
      
      if self.showTextInputField {
        stack.addArrangedSubview(textInputField);
      };
      
      if self.showDismissButton {
        stack.addArrangedSubview(dismissButton);
      };
      
      if self.showCustomSnapPointButton {
        stack.addArrangedSubview(customSnapPointButton);
      };
      
      return stack;
    }();
    
    switch self.contentMode {
      case .buttons:
        controlsView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(controlsView);
        
        NSLayoutConstraint.activate([
          controlsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
          controlsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]);
            
      case .scrollview:
        let stackView: UIStackView = {
          let stack = UIStackView();
          
          stack.axis = .vertical;
          stack.distribution = .fillProportionally;
          stack.alignment = .center;
          stack.spacing = 15;
                    
          return stack;
        }();
        
        stackView.addArrangedSubview(controlsView);
        stackView.setCustomSpacing(40, after: controlsView);
        
        for index in 0...30 {
          let label = UILabel();
          
          label.text = "\(index)";
          label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
          label.font = .boldSystemFont(ofSize: 22);

          stackView.addArrangedSubview(label);
          stackView.setCustomSpacing(15, after: label);
        };
        
        let scrollView: UIScrollView = {
          let scrollView = UIScrollView();
          
          scrollView.showsHorizontalScrollIndicator = false;
          scrollView.showsVerticalScrollIndicator = true;
          return scrollView
        }();
        
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        scrollView.addSubview(stackView);
        
        NSLayoutConstraint.activate([
          stackView.topAnchor.constraint(
            equalTo: scrollView.topAnchor,
            constant: 40
          ),
          
          stackView.bottomAnchor.constraint(
            equalTo: scrollView.bottomAnchor,
            constant: -100
          ),
          
          stackView.centerXAnchor.constraint(
            equalTo: scrollView.centerXAnchor
          ),
        ]);
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(scrollView);
        
        NSLayoutConstraint.activate([
          scrollView.topAnchor     .constraint(equalTo: self.view.topAnchor     ),
          scrollView.bottomAnchor  .constraint(equalTo: self.view.bottomAnchor  ),
          scrollView.leadingAnchor .constraint(equalTo: self.view.leadingAnchor ),
          scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]);
    };
  };
  
  @objc func onPressLabel(_ sender: UITapGestureRecognizer){
    guard let modalManager = self.modalManager else { return };
    let modalConfig = modalManager.currentModalConfig;

    
    let currentIndex = modalManager.currentInterpolationIndex;
    let lastIndex = {
      guard let overshootIndex = modalConfig.overshootSnapPointIndex else {
        return modalConfig.snapPointLastIndex;
      };
      
      return overshootIndex - 1;
    }();
    
    if currentIndex == lastIndex {
      self.shouldIncreaseModalIndexOnTap = false;
    
    } else if currentIndex == 0 {
      self.shouldIncreaseModalIndexOnTap = true;
    };
    
    if self.shouldIncreaseModalIndexOnTap {
      modalManager.snapToNextSnapPointIndex();
    
    } else {
      modalManager.snapToPrevSnapPointIndex();
    };
  };
  
  @objc func onPressButtonDismiss(_ sender: UIButton){
    self.modalManager?.dismissModal(
      animated: true,
      animationConfig: .presetCurve(
        duration: 0.275,
        curve: .easeInOut
      )
    );
  };
  
  @objc func onPressButtonCustomSnapPoint(_ sender: UIButton){
    let snapPoint = AdaptiveModalSnapPointConfig(
      key: .string("custom"),
      layoutConfig: .init(
        horizontalAlignment: .center,
        verticalAlignment: .center,
        width: .stretch(
          offsetValue: .constant(15 * 2),
          offsetOperation: .subtract
        ),
        height: .stretch,
        marginTop: .multipleValues([
          .safeAreaInsets(insetKey: \.top),
          .constant(15),
        ]),
        marginBottom: .multipleValues([
          .safeAreaInsets(insetKey: \.bottom),
          .keyboardRelativeSize(sizeKey: \.height),
          .constant(15),
        ])
      ),
      keyframeConfig: .init(
        modalCornerRadius: 15,
        modalMaskedCorners: .allCorners,
        modalBackgroundOpacity: 0.85,
        modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
        modalBackgroundVisualEffectIntensity: 1
      )
    );
    
    let overShootSnapPoint = AdaptiveModalSnapPointPreset(
      layoutPreset: .offscreenLeft
    );
  
    try? self.modalManager?.snapTo(
      overrideSnapPointConfig: snapPoint,
      overshootSnapPointPreset: self.shouldSetOverrideOverShootSnapPoint
        ? overShootSnapPoint
        : nil
    );
  };
  
  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    nextInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    
    let prevSnapPointIndex = prevInterpolationPoint?.snapPoint.index;
    let nextSnapPointIndex = nextInterpolationPoint.snapPoint.index;
    
    self.floatingViewLabel.text = "\(nextSnapPointIndex)";
    
    if Self.enableLogging {
      print(
        "notifyOnModalWillSnap",
        "\n - prevSnapPointIndex:", prevSnapPointIndex ?? -1,
        "\n - nextSnapPointIndex:", nextSnapPointIndex,
        "\n"
      );
    };
  };
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    currentInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    
    let prevSnapPointIndex = prevInterpolationPoint?.snapPoint.index;
    let currentSnapPointIndex = currentInterpolationPoint.snapPoint.index;
    
    self.floatingViewLabel.text = "\(currentSnapPointIndex)";
    
    if Self.enableLogging {
      print(
        "notifyOnModalDidSnap",
        "\n - prevSnapPointIndex:", prevSnapPointIndex ?? -1,
        "\n - currentSnapPointIndex:", currentSnapPointIndex,
        "\n"
      );
    };
  };
  
  func notifyOnAdaptiveModalWillShow(sender: AdaptiveModalManager) {
    if Self.enableLogging {
      print("onAdaptiveModalWillShow");
    };
  };
  
  func notifyOnAdaptiveModalDidShow(sender: AdaptiveModalManager) {
    self.onAdaptiveModalDidShow?();
    
    if Self.enableLogging {
      print("onAdaptiveModalDidShow");
    };
  };
  
  func notifyOnAdaptiveModalWillHide(sender: AdaptiveModalManager) {
    if Self.enableLogging {
      print("onAdaptiveModalWillHide");
    };
  };
  
  func notifyOnAdaptiveModalDidHide(sender: AdaptiveModalManager) {
    if Self.enableLogging {
      print("onAdaptiveModalDidHide");
    };
  };
  
  func notifyOnModalPresentCancelled(sender: AdaptiveModalManager) {
    if Self.enableLogging {
      print("notifyOnModalPresentCancelled");
    };
  };
  
  func notifyOnModalDismissCancelled(sender: AdaptiveModalManager) {
    if Self.enableLogging {
      print("notifyOnModalDismissCancelled");
    };
  };
  
  func notifyOnAdaptiveModalDragGesture(
    sender: AdaptiveModalManager,
    gestureRecognizer: UIGestureRecognizer
  ) {
    self.onCurrentModalConfigDidChangeBlock?();
    
    if Self.enableLogging {
      print(
        "notifyOnAdaptiveModalDragGesture",
        "\n - sender.gesturePoint:", sender.gesturePoint?.debugDescription ?? "N/A",
        "\n - sender.gestureInitialPoint:", sender.gestureInitialPoint?.debugDescription ?? "N/A",
        "\n - sender.gestureOffset:", sender.gestureOffset?.debugDescription ?? "N/A",
        "\n - sender.gesturePointWithOffsets", sender.gesturePointWithOffsets?.debugDescription ?? "N/A",
        "\n"
      );
    };
  };
  
  func notifyOnBackgroundTapGesture(sender: UIGestureRecognizer) {
    if Self.enableLogging {
      print("notifyOnBackgroundTapGesture");
    };
  };
  
  func notifyOnModalAnimatorStart(
    sender: AdaptiveModalManager,
    animator: UIViewPropertyAnimator?,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool
  ) {
    if Self.enableLogging {
      print(
        "notifyOnModalAnimatorStart",
        "\n - interpolationPoint.percent:", interpolationPoint.percent,
        "\n - isAnimated:", isAnimated,
        "\n"
      );
    };
  };
  
  func notifyOnModalAnimatorStop(sender: AdaptiveModalManager) {
    if Self.enableLogging {
      print("notifyOnModalAnimatorStop");
    };
  };
  
  func notifyOnModalAnimatorPercentChanged(
    sender: AdaptiveModalManager,
    percent: CGFloat
  ) {
    if Self.enableLogging {
      print(
        "notifyOnModalAnimatorPercentChanged",
        "\n - percent:", percent,
        "\n"
      );
    };
  };
  
  func notifyOnModalAnimatorCompletion(
    sender: AdaptiveModalManager,
    position: UIViewAnimatingPosition
  ) {
    if Self.enableLogging {
      print(
        "notifyOnModalAnimatorCompletion",
        "\n - position:", position,
        "\n"
      );
    };
  };
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  ) {
    if Self.enableLogging {
      print(
        "notifyOnCurrentModalConfigDidChange",
        "\n - currentModalConfig:", currentModalConfig.debugDescription,
        "\n - prevModalConfig:", prevModalConfig.debugDescription,
        "\n"
      );
    };
  };
  
  func notifyOnModalStateWillChange(
    sender: AdaptiveModalManager,
    prevState: AdaptiveModalState,
    currentState: AdaptiveModalState,
    nextState: AdaptiveModalState
  ) {
    // no-op
  };
};

class AdaptiveModalConfigDemoViewController : UIViewController {

  lazy var adaptiveModalManager = AdaptiveModalManager(
    presentingViewController: self,
    staticConfig: self.currentModalConfigPreset.config
  );
  
  let modalConfigs = AdaptiveModalConfigDemoPresets.allCases;
  
  var currentModalConfigPresetCounter = 0;
  
  var currentModalConfigPresetIndex: Int {
    self.currentModalConfigPresetCounter % self.modalConfigs.count
  };
  
  var currentModalConfigPreset: AdaptiveModalConfigDemoPresets {
    self.modalConfigs[self.currentModalConfigPresetIndex];
  };
  
  var currentModalManagerAdjustmentBlock: (AdaptiveModalManager) -> Void {
  
    let defaultBlock: (AdaptiveModalManager) -> Void = {
      $0.shouldEnableOverShooting = true;
    
      $0.overrideShouldSnapToUnderShootSnapPoint = nil;
      $0.overrideShouldSnapToOvershootSnapPoint = nil;
      
      $0.shouldDismissModalOnSnapToUnderShootSnapPoint = true;
      $0.shouldDismissModalOnSnapToOverShootSnapPoint = false;
      
      $0.shouldDismissKeyboardOnGestureSwipe = false;
    };
  
    switch self.currentModalConfigPreset {
      case .demo04: return {
        guard !$0.isUsingAdaptiveModalConfig else { return };
      
        $0.overrideShouldSnapToOvershootSnapPoint = true;
        $0.shouldDismissModalOnSnapToOverShootSnapPoint = true;
      };
      
      case .demo09: return {
        $0.shouldDismissKeyboardOnGestureSwipe = true;
      };
      
      case .demo07: return {
        guard !$0.isUsingAdaptiveModalConfig else { return };
        
        $0.shouldEnableOverShooting = false;
      };
      
      case .demo12: return {
        guard !$0.isUsingAdaptiveModalConfig else { return };
        
        $0.overrideShouldSnapToOvershootSnapPoint = true;
        $0.shouldDismissModalOnSnapToOverShootSnapPoint = true;
      };
      
      default:
        return defaultBlock;
    };
  };
  
  var counterLabel: UILabel?;
  
  override func viewDidLoad() {
    self.view.backgroundColor = .white;
    
    let dummyBackgroundView: UIView = {
      let imageView = UIImageView(
        image: UIImage(named: "DummyBackgroundImage2")
      );
      
      imageView.contentMode = .scaleAspectFill;
      return imageView;
    }();
    
    self.view.addSubview(dummyBackgroundView);
    dummyBackgroundView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint.activate([
      dummyBackgroundView.topAnchor     .constraint(equalTo: self.view.topAnchor     ),
      dummyBackgroundView.bottomAnchor  .constraint(equalTo: self.view.bottomAnchor  ),
      dummyBackgroundView.leadingAnchor .constraint(equalTo: self.view.leadingAnchor ),
      dummyBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ]);
    
    let counterLabel: UILabel = {
      let label = UILabel();
      
      label.text = "\(self.currentModalConfigPresetIndex)";
      label.font = .systemFont(ofSize: 24, weight: .bold);
      label.textColor = .white;
      
      self.counterLabel = label;

      return label;
    }();
    
    let presentButton: UIButton = {
      let button = UIButton();
      button.setTitle("Present View Controller", for: .normal);
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonPresentViewController(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let nextConfigButton: UIButton = {
      let button = UIButton();
      button.setTitle("Next Modal Config", for: .normal);
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonNextConfig(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let nextRouteButton: UIButton = {
      let button = UIButton();
      button.setTitle("Next Route", for: .normal);
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonNextRoute(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let stackView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .fill;
      stack.alignment = .center;
      stack.spacing = 0;
      
      stack.addArrangedSubview(counterLabel);
      stack.setCustomSpacing(15, after: counterLabel);
      
      stack.addArrangedSubview(presentButton);
      stack.addArrangedSubview(nextConfigButton);
      stack.addArrangedSubview(nextRouteButton);
      
      return stack;
    }();
    
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    self.view.addSubview(stackView);
    
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
    ]);
  };
  
  override func viewDidLayoutSubviews() {

  };
  
  func getViewControllerToPresent() -> (
    modalManager: AdaptiveModalManager,
    presentingVC: UIViewController,
    presentedVC: UIViewController
  ) {
    let testVC = TestModalViewController();
    
    switch self.currentModalConfigPreset {
      case .demo07, .demo08:
        testVC.showCustomSnapPointButton = true;
        
      case .demo09:
        testVC.showCustomSnapPointButton = true;
        testVC.showTextInputField = true;
        
      case .demo10:
        testVC.showCustomSnapPointButton = true;
        
      case .demo11:
        testVC.showTextInputField = true;
        testVC.showCustomSnapPointButton = true;
        
      case .demo12:
        testVC.showCustomSnapPointButton = true;
        testVC.shouldSetOverrideOverShootSnapPoint = true;
        
      case .demo13:
        testVC.contentMode = .scrollview;
        testVC.showCustomSnapPointButton = true;
        
      case .demo14:
        testVC.contentMode = .scrollview;
        
      case .demo15:
        testVC.contentMode = .scrollview;
        testVC.showCustomSnapPointButton = true;
      
      default: break;
    };
    
    let (modalManager, topVC): (AdaptiveModalManager, UIViewController) = {
      if let presentedVC = self.view.window?.topmostPresentedViewController {
        let modalManager = AdaptiveModalManager(
          presentingViewController: presentedVC,
          adaptiveConfig: .adaptiveConfig(
            defaultConfig: self.currentModalConfigPreset.config,
            constrainedConfigs: self.currentModalConfigPreset.constrainedConfigs
          )
        );
        
        return (modalManager, presentedVC);
      
      } else {
        self.adaptiveModalManager.modalConfig = .adaptiveConfig(
          defaultConfig: self.currentModalConfigPreset.config,
          constrainedConfigs: self.currentModalConfigPreset.constrainedConfigs
        );
        
        return (self.adaptiveModalManager, self);
      };
    }();
    
    testVC.modalManager = modalManager;
    
    modalManager.stateEventsDelegate.add(testVC);
    modalManager.presentationEventsDelegate.add(testVC);
    modalManager.gestureEventsDelegate.add(testVC);
    
    modalManager.backgroundTapDelegate.add(testVC);
    modalManager.animationEventDelegate.add(testVC);
    
    self.currentModalManagerAdjustmentBlock(modalManager);
    
    testVC.onCurrentModalConfigDidChangeBlock = { [weak self] in
      guard let self = self else { return };
      self.currentModalManagerAdjustmentBlock(modalManager);
    };
    
    testVC.onAdaptiveModalDidShow = { [weak self] in
      guard let self = self else { return };
      self.currentModalManagerAdjustmentBlock(modalManager);
    };
    
    return (
      modalManager: modalManager,
      presentingVC: testVC,
      presentedVC: topVC
    );
  };
  
  @objc func onPressButtonPresentViewController(_ sender: UIButton) {
    let (modalManager, testVC, topVC) = self.getViewControllerToPresent();
    
    modalManager.presentModal(
      viewControllerToPresent: testVC,
      presentingViewController: topVC
    );
  };
  
  @objc func onPressButtonNextConfig(_ sender: UIButton) {
    self.currentModalConfigPresetCounter += 1;
    self.counterLabel!.text = "\(self.currentModalConfigPresetIndex)";
    
    self.view.gestureRecognizers?.forEach {
      self.view.removeGestureRecognizer($0);
    };
    
    let swipeEdge: UIRectEdge? = {
      switch self.currentModalConfigPreset {
        case .demo03,
             .demo05,
             .demo07,
             .demo10:
          return .left;
          
        case .demo12:
          return .right;
          
        default:
          return nil;
      };
    }();
    
    if let swipeEdge = swipeEdge {
    
      let edgePan = UIScreenEdgePanGestureRecognizer();
      edgePan.edges = swipeEdge;
      
      self.adaptiveModalManager.setScreenEdgePanGestureRecognizer(
        edgePanGesture: edgePan,
        viewControllerProvider: {
          let (_, testVC, topVC) = self.getViewControllerToPresent();
        
          return (
            viewControllerToPresent: testVC,
            presentingViewController: topVC
          );
        }
      );
      
      self.view.addGestureRecognizer(edgePan);
    };
  };
  
  @objc func onPressButtonNextRoute(_ sender: UIButton) {
    let routeManager = RouteManager.sharedInstance;
    routeManager.routeCounter += 1;
    routeManager.applyCurrentRoute();
  };
};
