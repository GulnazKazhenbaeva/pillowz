//
//  SpacesManager.swift
//  Pillowz
//
//  Created by Dias Ermekbaev on 04.08.2018.
//  Copyright © 2018 Samat. All rights reserved.
//

import UIKit

class SpacesManager: NSObject {
    static let shared = SpacesManager()
    var currentEditingSpace: Spaces!

    var spaceCRUDVC:NewSpaceCRUDViewController?
    var currentStepVC:StepViewController?

}
