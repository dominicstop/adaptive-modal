//
//  AdaptiveModalPageFocusEventsNotifiable.swift
//  
//
//  Created by Dominic Go on 9/7/23.
//

import UIKit


public protocol AdaptiveModalPageFocusEventsNotifiable: UIViewController {

  func notifyOnModalPageWillFocus(
    sender: AdaptiveModalPageViewController,
    pageToBlur: AdaptiveModalResolvedPageItemConfig?,
    pageToFocus: AdaptiveModalResolvedPageItemConfig
  );
  
  func notifyOnModalPageDidFocus(
    sender: AdaptiveModalPageViewController,
    blurredPage: AdaptiveModalResolvedPageItemConfig?,
    focusedPage: AdaptiveModalResolvedPageItemConfig
  );
  
  func notifyOnModalPageWillBlur(
    sender: AdaptiveModalPageViewController,
    pageToBlur: AdaptiveModalResolvedPageItemConfig?,
    pageToFocus: AdaptiveModalResolvedPageItemConfig
  );
  
  func notifyOnModalPageDidBlur(
    sender: AdaptiveModalPageViewController,
    blurredPage: AdaptiveModalResolvedPageItemConfig?,
    focusedPage: AdaptiveModalResolvedPageItemConfig
  );
  
};


