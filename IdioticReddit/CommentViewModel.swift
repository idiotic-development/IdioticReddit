//
//  CommentViewModel.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/16/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//


class CommentViewModel: TableViewModel {
    let link: RKLink!
    var comments: [RKComment]!

    override var tableViewData: [AnyObject]! {
        get {
            return self.comments
        }
        set {
            if newValue is [RKComment] {
                self.comments = newValue as [RKComment]
            } else {
                println("Tried to set bad value \(self) of [RKComment]")
            }
        }
    }
    
    init(model: RKClient!, link:RKLink) {
        self.link = link
        super.init(model: model)
    }
    
    override func loadNewData() {
        self.model.commentsForLink(self.link) {
            (NSArray collection, RKPagination pagination, NSError error) in
            if !error {
                self.comments = collection as [RKComment]
            }
//            completion(error: error)
            }
    }
    
    override func detailTextForCellAtIndex(index: Int) -> String! {
        return self.comments[index].body
    }
    
    override func mainTextForCellAtIndex(index: Int) -> String!  {
        return self.comments[index].author
    }
    
    override func thumbnailForCellAtIndex(index: Int) -> NSURL?  {
        return nil
    }
    
    override func cellCount() -> Int!  {
        return (self.comments ? self.comments!.count : 0)
    }
}
