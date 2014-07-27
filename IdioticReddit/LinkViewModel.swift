//
//  LinkViewModel.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/14/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//

// TODO Include time since creation also 

class LinkViewModel: TableViewModel, RedditVotableCellViewModelProtocol, RedditCategorizableCellViewModelProtocol {
    let subreddit: RKSubreddit!
    var links: [RKLink]! = [RKLink]()
    
    override var tableViewData: [AnyObject]! {
        get {
            return self.links
        }
        set {
            if newValue is [RKLink] {
                self.links = newValue as [RKLink]
            } else {
                println("Tried to set bad value \(self) of [RKLink]")
            }
        }
    }

    
    // MARK: - Life Cycle
    
    init(model: RKClient!, subreddit: RKSubreddit) {
        self.subreddit = subreddit
        super.init(model: model)
    }
    

    // MARK: - BaseTableViewModel
    
    override func didBecomeActive()  {
        super.didBecomeActive()
        self.loadNewData()
    }
    
    override func loadNewData()  {
        self.isLoadingData = true
        weak var weakSelf = self
        
        self.model.linksInSubreddit(self.subreddit, pagination: self.pagination ) {
            (NSArray collection, RKPagination pagination, NSError error) in
            if error {
                println("Failed to get links with error: \(error)")
            }
            if let strongSelf = weakSelf {
                if let newLinks = collection as? [RKLink] {
                    if !error  {
                        let indexPaths = strongSelf.indexPathsForArrayToAppend(collection as [RKLink])
                        
                        if strongSelf.tableViewModelDelegate?.respondsToSelector(Selector("willLoadNewDataForIndexPaths:")) {
                            strongSelf.tableViewModelDelegate!.willLoadNewDataForIndexPaths(indexPaths)
                        }
                        
                        // TODO: I'm not sure how to make immutable arrays yet
                        var workAroundArray = [RKLink]()
                        
                        for link in self.links {
                            workAroundArray.append(link)
                        }
                        
                        for link in newLinks {
                            workAroundArray.append(link)
                        }
                        
                        self.links = workAroundArray
                        
                        strongSelf.pagination = pagination
                        
                        if strongSelf.tableViewModelDelegate?.respondsToSelector(Selector("didLoadNewDataForIndexPaths:")) {
                            strongSelf.tableViewModelDelegate!.didLoadNewDataForIndexPaths(indexPaths)
                        }
                    }
                
                }
                strongSelf.isLoadingData = false
            }
        }
    }
    
    
    // MARK: - TableViewModel
    
    override func mainTextForCellAtIndex(index: Int) -> String!  {
        return self.links[index].title
    }
    
    override func detailTextForCellAtIndex(index: Int) -> String!  {
        return self.links[index].domain
    }
    
    
    override func thumbnailForCellAtIndex(index: Int) -> NSURL?  {
        return self.links[index].thumbnailURL
    }
    
    override func cellCount() -> Int!  {
        return self.links.count
    }
    
    override func reloadAllData()  {
        self.links = [RKLink]()
        self.pagination = RKPagination(limit: kDefaultRKPaginationLimit)
        self.loadNewData()
    }
    
    func authorTextForCellAtIndex(index: Int) -> String!  {
        return self.links[index].author
    }
    
    
    
    // MARK: - RedditVotableCellViewModel
    
    func upvoteForCellAtIndex(index: Int, completion: RequestCompletion)  {
        self.model.upvote(self.links[index], self.errorClosureFromSuccessClosure(completion))
    }
    
    func downvoteForCellAtIndex(index: Int, completion: RequestCompletion)  {
        self.model.downvote(self.links[index], self.errorClosureFromSuccessClosure(completion))
    }
    
    func voteRatioForCellAtIndex(index: Int) -> CGFloat {
        return self.links[index].upvoteRatio
    }
    
    // MARK: - RedditCategorizableCellViewModel
    
    func saveForCellAtIndex(index: Int, completion: RequestCompletion)  {
        self.model.saveLink(self.links[index], self.errorClosureFromSuccessClosure(completion))
    }
    
    func unsaveForCellAtIndex(index: Int, completion: RequestCompletion)  {
        self.model.unsaveLink(self.links[index], self.errorClosureFromSuccessClosure(completion))
    }
    
    func hideForCellAtIndex(index: Int, completion: RequestCompletion)  {
        self.model.hideLink(self.links[index], self.errorClosureFromSuccessClosure(completion))
    }
    
    func unhideForCellAtIndex(index: Int, completion: RequestCompletion)  {
        self.model.unhideLink(self.links[index], self.errorClosureFromSuccessClosure(completion))
        
    }
    
    
    // MARK: - Model Spawning
    
    func viewModelForLinkAtIndex(index:Int) -> CommentViewModel {
        return CommentViewModel(model: self.model , link: self.links[index])
    }
    
}

