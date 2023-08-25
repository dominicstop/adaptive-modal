//
//  RootViewController.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 08/25/2023.
//  Copyright (c) 2023 Dominic Go. All rights reserved.
//

import UIKit
import AdaptiveModal
import ComputableLayout


class ModalViewController: UIViewController {

  weak var modalManager: AdaptiveModalManager?;

  override func viewDidLoad() {
    self.view.backgroundColor = .clear;
    
    let dismissButton: UIButton = {
      let button = UIButton();
      
      button.setTitle("Dismiss Modal", for: .normal);
      
      if #available(iOS 15.0, *) {
        button.configuration = .filled()
      };
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonDismiss(_:)),
        for: .touchUpInside
      );
      
      button.sizeToFit();
      return button;
    }();
    
    let controlsView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .equalSpacing;
      stack.alignment = .center;
      stack.spacing = 10;
  
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

  @objc func onPressButtonDismiss(_ sender: UIButton){
    self.modalManager?.dismissModal(
      animated: true,
      animationConfig: .presetCurve(
        duration: 0.275,
        curve: .easeInOut
      )
    );
  };
};

class RootViewController : UIViewController {

  var adaptiveModalManager: AdaptiveModalManager?;

  override func viewDidLoad() {
    self.view.backgroundColor = .white;
    
    let presentButton: UIButton = {
      let button = UIButton();
      
      button.setTitle("Present View Controller", for: .normal);
      button.setTitleColor(.white, for: .normal);
      
      button.backgroundColor = .blue;
      button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15);
      button.layer.cornerRadius = 10;
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonPresentViewController(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
 
    let stackView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .equalSpacing;
      stack.alignment = .center;
      stack.spacing = 7;
      
      stack.addArrangedSubview(presentButton);
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
    
    let modalConfig = AdaptiveModalConfig(
      snapPoints: [
        // snap point - 1
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .percent(percentValue: 0.8),
            height: .percent(percentValue: 0.2)
          ),
          keyframeConfig: AdaptiveModalKeyframeConfig(
            modalShadowColor: .black,
            modalShadowOpacity: 0.1,
            modalShadowRadius: 10,
            modalCornerRadius: 15,
            modalMaskedCorners: .topCorners,
            backgroundColor: .black,
            backgroundOpacity: 0.1
          )
        ),

        // snap point - 2
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .percent(percentValue: 0.9),
            height: .percent(percentValue: 0.7)
          ),
          keyframeConfig: AdaptiveModalKeyframeConfig(
            backgroundOpacity: 0.3
          )
        ),
      ],
      snapDirection: .bottomToTop,
      undershootSnapPoint: .automatic,
      overshootSnapPoint: AdaptiveModalSnapPointPreset(
        layoutPreset: .fitScreenVertically
      )
    );
  
    let modalManager = AdaptiveModalManager(staticConfig: modalConfig);
    
    let modalVC = ModalViewController();
    modalVC.modalManager = modalManager;
    
    modalManager.presentModal(
      viewControllerToPresent: modalVC,
      presentingViewController: self
    );
  };
};


