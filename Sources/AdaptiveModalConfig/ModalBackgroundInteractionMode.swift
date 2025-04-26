//
//  ModalBackgroundInteractionMode.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/26/25.
//

public enum ModalBackgroundInteractionMode: String {
  static let `default`: Self = .automatic;

  case automatic;
  case dismiss, passthrough, ignore;
  
  var isPassThrough: Bool {
    switch self {
      case .passthrough: return true;
      default: return false;
    };
  };
};
