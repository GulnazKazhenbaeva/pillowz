//
//  RequestEditorManager.swift
//  Pillowz
//
//  Created by Samat on 22.11.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class RequestEditorManager: NSObject {
    static let sharedInstance = RequestEditorManager()
    
    //needed because when passing link and updating from server - link gets overwritten, and one controller has new object, but previous controller has old object
    var currentEditingRequest:Request?
}
