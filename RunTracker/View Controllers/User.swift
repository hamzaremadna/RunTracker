//
//  User.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var email: String?
  var Date: String?
  var hist: String?

  init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
      self.Date = dictionary["Date"] as? String ?? ""
    self.hist = dictionary["hist"] as? String ?? ""

  }
}
