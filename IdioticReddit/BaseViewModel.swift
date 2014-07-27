//
//  BaseViewModel.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/13/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//
typealias LoadedNewDataClosure = (error: NSError?) -> Void

@objc protocol BaseViewModelDelegateProtocol: NSObjectProtocol {
    
}

class BaseViewModel: NSObject {
    var model: RKClient!
    var requests: [NSURLSessionDataTask]! = [NSURLSessionDataTask]()
    var viewModelDelegate: BaseViewModelDelegateProtocol? = nil
    
    var active: Bool = false {
        didSet {
            if oldValue != active {
                if active {
                    self.didBecomeActive()
                } else {
                    self.didBecomeInactive()
                }
            }
        }
    }
    
    init(model: RKClient!)  {
        self.model = model
        super.init()
    }
    
    func didBecomeActive() {
        
    }
    
    func didBecomeInactive() {
        
    }
}
