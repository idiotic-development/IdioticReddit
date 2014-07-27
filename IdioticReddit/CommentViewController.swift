//
//  CommentViewController.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/16/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//


class CommentViewController: BaseTableViewController {
    var commentViewModel: CommentViewModel!
    override var tableViewModel: TableViewModel! {
        get {
            return self.commentViewModel
        }
        set {
            if newValue is CommentViewModel {
                self.commentViewModel = newValue as CommentViewModel
            } else {
                println("Not a comment view model")
            }
        }
    }
    
    // MARK: - Life Cycle
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var swipeCell: MCSwipeTableViewCell! = tableView.dequeueReusableCellWithIdentifier("MCSwipeTableViewCellIdentifier", forIndexPath: indexPath) as MCSwipeTableViewCell
        
        swipeCell.textLabel.text = self.commentViewModel.mainTextForCellAtIndex(indexPath.row)
        
        return swipeCell
    }
    

}
