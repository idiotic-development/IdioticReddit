//
//  TableViewModel.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/18/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//

//import UIKit

typealias RequestCompletion = (success: Bool) -> ()

@objc protocol TableViewModelDelegateProtocol: BaseViewModelDelegateProtocol {
    func willLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)
    func didLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)
}

protocol RedditVotableCellViewModelProtocol {
    func upvoteForCellAtIndex(index: Int, completion: RequestCompletion) -> Void
    func downvoteForCellAtIndex(index: Int, completion: RequestCompletion) -> Void
    func voteRatioForCellAtIndex(index: Int) -> CGFloat
}

protocol RedditHideableCellViewModelProtocol {
    func hideForCellAtIndex(index: Int, completion: RequestCompletion) -> Void
    func unhideForCellAtIndex(index: Int, completion: RequestCompletion) -> Void
}

protocol RedditSaveableCellViewModelProtocol {
    func saveForCellAtIndex(index: Int, completion: RequestCompletion) -> Void
    func unsaveForCellAtIndex(index: Int, completion: RequestCompletion) -> Void
}

protocol RedditCategorizableCellViewModelProtocol: RedditSaveableCellViewModelProtocol, RedditHideableCellViewModelProtocol {
    
}

let kDefaultRKPaginationLimit: UInt = 10

class TableViewModel: BaseViewModel {
    var pagination: RKPagination! = RKPagination(limit: kDefaultRKPaginationLimit)
    var isLoadingData: Bool! = false
    var tableViewModelDelegate: TableViewModelDelegateProtocol?
    var tableViewData: [AnyObject]! = [AnyObject]()
    
    override var viewModelDelegate: BaseViewModelDelegateProtocol? {
        get {
            return self.tableViewModelDelegate
        }
        set {
            if let protocolConformant = newValue as? RidiculasWorkaround {
                self.tableViewModelDelegate = protocolConformant
            } else {
                println("Tried to set a non conforming object to be a tableViewModelDelegate")
            }
        }
    }

    // MARK: Life Cycle
    
    init(model: RKClient!) {
        super.init(model: model)

    }
    
    func loadNewData() {
        assert(false, "Need to override")
    }
    
    
    // MARK: - Reddit Table View Data

    /// TODO: Use 'SDWebImageDownloader' to download images asynchronously with callbacks
    /// TODO: If selfpost, return selfpost pic, if NSFW return NSFW placeholder, if nil and not self post return nil, if nil return nil
    func thumbnailForCellAtIndex(index: Int) -> NSURL? {
        assert(false, "Need to implement")
        return nil
    }
    
    func mainTextForCellAtIndex(index: Int) -> String! {
        assert(false, "Need to implement")
        return ""
    }
    
    func detailTextForCellAtIndex(index: Int) -> String! {
        assert(false, "Need to implement")
        return ""
    }
    
    func cellCount() -> Int! {
        assert(false, "Need to implement")
        return 0
    }
    
    func reloadAllData() {
        assert(false, "Need to implement")
    }
    
}

// MARK: - Convenience

extension TableViewModel {
    func errorClosureFromSuccessClosure(successClosure: RequestCompletion) -> ((error: NSError?) -> ()) {
        return ({
            (error: NSError?) -> () in
            if error != nil {
                println(error)
            }
            successClosure(success: !error)
        })
    }
    func indexPathsForArrayToAppend(array: [AnyObject]) -> [NSIndexPath]! {
        var indexPaths = [NSIndexPath]()
        let currentCellCount = self.cellCount()
        
        for var index = 0; index < array.count; ++index {
            let path = NSIndexPath(forRow: (currentCellCount + index), inSection: 0)
            indexPaths.append(path)
        }
        
        return indexPaths
    }
}


// MARK: - Workarounds

private extension TableViewModel {
    private class RidiculasWorkaround: NSObject, TableViewModelDelegateProtocol {
        // http://stackoverflow.com/questions/24111009/bound-value-in-a-conditional-binding-must-be-of-optional-type

        func willLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)  {
            
        }
        func didLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)  {
            
        }
    
    }
}
