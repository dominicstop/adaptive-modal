//
//  AdaptiveModalPaginatedTestViewController.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 9/1/23.
//

import UIKit
import AdaptiveModal
import ComputableLayout

fileprivate class ModalViewController: UIViewController {

  static var shouldLogFocusEvents = false;

  weak var modalManager: AdaptiveModalManager?;
  
  var instanceID = -1;
  var snapPointIndex = -1 {
    willSet {
      self.labelSnapPointIndex.text = "Snap Point Index: \(newValue)";
    }
  };
  
  var didToggleShouldIncreaseModalIndexOnTap: ((Bool) -> Void)?;
  
  var shouldIncreaseModalIndexOnTap = true;
  
  lazy var labelEmoji: UILabel = {
    let label = UILabel();
    
    let emojiList = ["⭐️", "💖", "⚛️", "🛁", "🐞"];
    let emoji = emojiList[self.instanceID % emojiList.count];

    label.text = emoji;
    label.font = .systemFont(ofSize: 32);
    
    return label;
  }();
  
  lazy var labelInstanceID: UILabel = {
    let label = UILabel();

    label.text = "VC Instance: \(self.instanceID)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .systemFont(ofSize: 20, weight: .bold);
    
    return label;
  }();
  
  lazy var labelSnapPointIndex: UILabel = {
    let label = UILabel();
    
    label.text = "Snap Point Index: \(self.snapPointIndex)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .systemFont(ofSize: 18);
    
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(Self.onPressLabelSnapPointIndex(_:))
    );
    
    label.addGestureRecognizer(tapGesture);
    label.isUserInteractionEnabled = true;

    return label;
  }();
  
  override func viewDidLoad() {
    self.view.backgroundColor = .clear;
    
    let dismissButton: UIButton = {
      let button = UIButton();
      
      let colors: [UIColor] = [
        .systemRed,
        .systemOrange,
        .systemYellow,
        .systemGreen,
        .systemBlue,
        .systemPurple
      ];
      
      button.setTitle("Dismiss Modal", for: .normal);
      button.configuration = {
        var config: UIButton.Configuration = .filled();
        config.baseBackgroundColor = colors[self.instanceID % colors.count];
        
        return config;
      }();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonDismiss(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
   
    let controlsView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .fill;
      stack.alignment = .center;
      stack.spacing = 1;
      
      stack.addArrangedSubview(self.labelEmoji);
      stack.addArrangedSubview(self.labelInstanceID);
      stack.addArrangedSubview(self.labelSnapPointIndex);
      
      stack.setCustomSpacing(17, after: self.labelSnapPointIndex);
      stack.addArrangedSubview(dismissButton);
      
      return stack;
    }();
    
    controlsView.translatesAutoresizingMaskIntoConstraints = false;
    self.view.addSubview(controlsView);
    
    NSLayoutConstraint.activate([
      controlsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      controlsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
    ]);
  };
  
  @objc func onPressLabelSnapPointIndex(_ sender: UITapGestureRecognizer){
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
      self.didToggleShouldIncreaseModalIndexOnTap?(false);
    
    } else if currentIndex == 0 {
      self.shouldIncreaseModalIndexOnTap = true;
      self.didToggleShouldIncreaseModalIndexOnTap?(true);
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
        duration: 0.3,
        curve: .easeIn
      )
    );
  };
};

extension ModalViewController: AdaptiveModalPresentationEventsNotifiable {

  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    prevSnapPointConfig: AdaptiveModalSnapPointConfig?,
    nextSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    nextInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.snapPointIndex = nextSnapPointIndex;
  };
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    prevSnapPointConfig: AdaptiveModalSnapPointConfig?,
    currentSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    currentInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.snapPointIndex = currentSnapPointIndex;
  };
  
  func notifyOnAdaptiveModalWillShow(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDidShow(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnAdaptiveModalWillHide(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDidHide(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnModalPresentCancelled(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnModalDismissCancelled(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  ) {
    // no-op
  };
};

extension ModalViewController: AdaptiveModalPageFocusEventsNotifiable {
  
  func notifyOnModalPageWillFocus(
    sender: AdaptiveModalPageViewController,
    pageToBlur: AdaptiveModalResolvedPageItemConfig?,
    pageToFocus: AdaptiveModalResolvedPageItemConfig
  ) {
  
    if Self.shouldLogFocusEvents {
      print(
        "ModalViewController",
        "\n - AdaptiveModalPageFocusEventsNotifiable",
        "\n - notifyOnModalPageWillFocus",
        "\n - pageToBlur?.pageKey", pageToBlur?.pageKey ?? "N/A",
        "\n - pageToFocus?.pageKey", pageToFocus.pageKey ?? "N/A",
        "\n"
      );
    };
  };
  
  func notifyOnModalPageDidFocus(
    sender: AdaptiveModalPageViewController,
    blurredPage: AdaptiveModalResolvedPageItemConfig?,
    focusedPage: AdaptiveModalResolvedPageItemConfig
  ) {
  
    if Self.shouldLogFocusEvents {
      print(
        "ModalViewController",
        "\n - AdaptiveModalPageFocusEventsNotifiable",
        "\n - notifyOnModalPageDidFocus",
        "\n - blurredPage?.pageKey", blurredPage?.pageKey ?? "N/A",
        "\n - focusedPage?.pageKey", focusedPage.pageKey ?? "N/A",
        "\n"
      );
    };
  };
  
  func notifyOnModalPageWillBlur(
    sender: AdaptiveModalPageViewController,
    pageToBlur: AdaptiveModalResolvedPageItemConfig?,
    pageToFocus: AdaptiveModalResolvedPageItemConfig
  ) {
  
    if Self.shouldLogFocusEvents {
      print(
        "ModalViewController",
        "\n - AdaptiveModalPageFocusEventsNotifiable",
        "\n - notifyOnModalPageWillBlur",
        "\n - pageToBlur?.pageKey", pageToBlur?.pageKey ?? "N/A",
        "\n - pageToFocus?.pageKey", pageToFocus.pageKey ?? "N/A",
        "\n"
      );
    };
  };
  
  func notifyOnModalPageDidBlur(
    sender: AdaptiveModalPageViewController,
    blurredPage: AdaptiveModalResolvedPageItemConfig?,
    focusedPage: AdaptiveModalResolvedPageItemConfig
  ) {
  
    if Self.shouldLogFocusEvents {
      print(
        "ModalViewController",
        "\n - AdaptiveModalPageFocusEventsNotifiable",
        "\n - notifyOnModalPageDidBlur",
        "\n - blurredPage?.pageKey", blurredPage?.pageKey ?? "N/A",
        "\n - focusedPage?.pageKey", focusedPage.pageKey ?? "N/A",
        "\n"
      );
    };
  };
};

class AdaptiveModalPageTestViewController: UIViewController {
  
  static var shouldLogPageChangeEvents = false;

  let modalConfigs: [AdaptiveModalConfigDemoPresets] = [
    .demo01,
    .demo03,
    .demo07,
    .demo08,
    .demo10,
    .demo12,
    .demo15
  ];
  
  var currentModalConfigPresetCounter = 0;
  
  var currentModalConfigPresetIndex: Int {
    self.currentModalConfigPresetCounter % self.modalConfigs.count
  };
  
  var currentModalConfigPreset: AdaptiveModalConfigDemoPresets {
    self.modalConfigs[self.currentModalConfigPresetIndex];
  };
  
  var counterLabel: UILabel?;
  
  override func viewDidLoad() {
    self.view.backgroundColor = .white;
    
    let dummyBackgroundView: UIView = {
      let imageView = UIImageView(
        image: UIImage(named: "DummyBackgroundImage")
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
    
    let counterLabel: UIView = {
      let label = UILabel();
      
      label.text = "\(self.currentModalConfigPresetIndex)";
      label.font = .systemFont(ofSize: 26, weight: .bold);
      label.textColor = .black;
      
      self.counterLabel = label;
      
      let labelContainer = UIView();
      labelContainer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
      labelContainer.layer.cornerRadius = 10;
      
      labelContainer.addSubview(label);
      
      label.translatesAutoresizingMaskIntoConstraints = false;
      labelContainer.translatesAutoresizingMaskIntoConstraints = false;
      
      NSLayoutConstraint.activate([
        labelContainer.widthAnchor.constraint(equalToConstant: 45),
        labelContainer.heightAnchor.constraint(equalToConstant: 45),
        label.centerXAnchor.constraint(equalTo: labelContainer.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor),
      ]);

      return labelContainer;
    }();
    
    let presentButton: UIButton = {
      let button = UIButton();
      button.setTitle("Present View Controller", for: .normal);
      button.configuration = .filled();
      
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
      button.configuration = .filled();
      
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
      button.configuration = .filled();
      
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
      stack.spacing = 12;
      
      stack.addArrangedSubview(counterLabel);
      stack.setCustomSpacing(24, after: counterLabel);
      
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
  
  @objc func onPressButtonPresentViewController(_ sender: UIButton) {
    let currentModalConfig = self.currentModalConfigPreset.config;
    let snapPoints = currentModalConfig.snapPoints;
  
    let modalManager = AdaptiveModalManager(staticConfig: currentModalConfig);
    
    func makePageVC(instanceID: Int) -> ModalViewController {
      let modalVC = ModalViewController();
      modalVC.modalManager = modalManager;
      modalVC.instanceID = instanceID;
      
      modalManager.presentationEventsDelegate.add(modalVC);
      return modalVC;
    };
    
    let pageConfigItems = snapPoints.enumerated().map {
      AdaptiveModalPageItemConfig(
        pageKey: "\($0.offset)",
        associatedSnapPoints: [
          .index($0.offset + 1)
        ],
        viewController: makePageVC(instanceID: $0.offset)
      );
    };
    
    let pageVcItems = pageConfigItems.map {
      $0.viewController as! ModalViewController;
    };
    
    let didToggleShouldIncreaseModalIndexOnTapBlock = { (flag: Bool) in
      pageVcItems.forEach {
        $0.shouldIncreaseModalIndexOnTap = flag;
      };
    };
    
    pageVcItems.forEach {
      $0.didToggleShouldIncreaseModalIndexOnTap = didToggleShouldIncreaseModalIndexOnTapBlock;
    };
    
    let pageVC = AdaptiveModalPageViewController(pages: pageConfigItems);
    pageVC.pageChangeEventDelegate.add(self);
    
    modalManager.presentModal(
      viewControllerToPresent: pageVC,
      presentingViewController: self
    );
  };
  
  @objc func onPressButtonNextConfig(_ sender: UIButton) {
    self.currentModalConfigPresetCounter += 1;
    self.counterLabel!.text = "\(self.currentModalConfigPresetIndex)";
  };
  
  @objc func onPressButtonNextRoute(_ sender: UIButton) {
    let routeManager = RouteManager.sharedInstance;
    routeManager.routeCounter += 1;
    routeManager.applyCurrentRoute();
  };
};


extension AdaptiveModalPageTestViewController: AdaptiveModalPageChangeEventsNotifiable {
  func notifyOnModalPageWillChange(
    sender: AdaptiveModal.AdaptiveModalPageViewController,
    prevPage: AdaptiveModal.AdaptiveModalResolvedPageItemConfig?,
    nextPage: AdaptiveModal.AdaptiveModalResolvedPageItemConfig
  ) {
    
    if Self.shouldLogPageChangeEvents {
      print(
        "AdaptiveModalPageTestViewController",
        "\n - AdaptiveModalPageChangeEventsNotifiable",
        "\n - notifyOnPageWillChange",
        "\n - prevPage?.pageKey", prevPage?.pageKey ?? "N/A",
        "\n - nextPage?.pageKey", nextPage.pageKey ?? "N/A",
        "\n"
      );
    };
  };
  
  func notifyOnModalPageDidChange(
    sender: AdaptiveModal.AdaptiveModalPageViewController,
    prevPage: AdaptiveModal.AdaptiveModalResolvedPageItemConfig?,
    currentPage: AdaptiveModal.AdaptiveModalResolvedPageItemConfig
  ) {
  
    if Self.shouldLogPageChangeEvents {
      print(
        "AdaptiveModalPageTestViewController",
        "\n - AdaptiveModalPageChangeEventsNotifiable",
        "\n - notifyOnPageDidChange",
        "\n - prevPage?.pageKey", prevPage?.pageKey ?? "N/A",
        "\n - nextPage?.pageKey", currentPage.pageKey ?? "N/A",
        "\n"
      );
    };
  };
};
