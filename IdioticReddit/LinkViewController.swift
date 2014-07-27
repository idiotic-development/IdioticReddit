//
//  LinkViewController.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/16/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//


class LinkViewController: BaseTableViewController {
    var linkViewModel: LinkViewModel!
    override var tableViewModel:TableViewModel! {
        get {
            return self.linkViewModel
        }
        set {
            if newValue is LinkViewModel {
                self.linkViewModel = newValue as LinkViewModel
            } else {
                println("Tried to set \(self).linkViewModel to \(newValue)")
            }
        }
    }
    
    // MARK: - Life Cycle
    
    init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - TableViewModelDelegateProtocol
    
    override func willLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)  {
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }
    
    override func didLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!) {
        self.tableView.endUpdates()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var swipeCell: MCSwipeTableViewCell! = tableView.dequeueReusableCellWithIdentifier("MCSwipeTableViewCellIdentifier", forIndexPath: indexPath) as MCSwipeTableViewCell
        
        self.setupCell(swipeCell, indexPath: indexPath)
        
        return swipeCell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)  {
        let controller = self.storyboard.instantiateViewControllerWithIdentifier("CommentViewController") as CommentViewController
        let viewModel = self.linkViewModel.viewModelForLinkAtIndex(indexPath.row)
        controller.commentViewModel = viewModel
        
        self.navigationController.pushViewController(controller, animated: true)
    }
    
}

// MARK: - Convenience

extension LinkViewController {
    func setupCell(swipeCell: MCSwipeTableViewCell, indexPath: NSIndexPath) {
        weak var weakSelf = self
        
        swipeCell.defaultColor = UIColor(red: 0.5362, green: 0.5485, blue: 0.5869, alpha: 1.0000)
        
        
        swipeCell.farLeftSection = MCSwipeSection(view: nil,
            color: UIColor.greenColor(),
            mode: .Switch,
            trigger: 0.25) {
                (MCSwipeTableViewCell cell, MCSwipeSection section) -> Void in
                if let strongSelf = weakSelf {
                    strongSelf.linkViewModel.upvoteForCellAtIndex(indexPath.row) {
                        (success: Bool) -> Void in
                        if success {
                            // TODO: Show Success banner
                            // TODO: Tint cell to green color
                        } else {
                            // TODO: Show failure banner
                        }
                    }
                }
            }
        
        swipeCell.midLeftSection = MCSwipeSection(view: nil,
            color: UIColor.blueColor(),
            mode: .Exit,
            trigger: 0.60) {
                (MCSwipeTableViewCell cell, MCSwipeSection section) -> Void in
                if let strongSelf = weakSelf {
                    strongSelf.linkViewModel.saveForCellAtIndex(indexPath.row) {
                        (success: Bool) -> Void in
                        // Removed cell from tableview
                        if success {
                            // TODO: Show Success banner
                            // TODO: Possibly completely remove cell in limbo
                        } else {
                            // TODO: Show failure banner
                            // TODO: Reinsert cell back into tableview
                        }
                    }
                }
        }
        
        swipeCell.farRightSection = MCSwipeSection(view: nil,
            color: UIColor.redColor(),
            mode: .Switch,
            trigger: -0.25) {
                (MCSwipeTableViewCell cell, MCSwipeSection section) -> Void in
                if let strongSelf = weakSelf {
                    strongSelf.linkViewModel.downvoteForCellAtIndex(indexPath.row) {
                        (success: Bool) -> Void in
                        if success {
                            // TODO: Show Success banner
                            // TODO: Change cell tint to red and grey out text
                        } else {
                            // TODO: Show failure banner
                        }
                    }
                }
        }

        swipeCell.midRightSection = MCSwipeSection(view: nil,
            color: UIColor.yellowColor(),
            mode: .Exit,
            trigger: -0.60) {
                (MCSwipeTableViewCell cell, MCSwipeSection section) -> Void in
                if let strongSelf = weakSelf {
                    strongSelf.linkViewModel.hideForCellAtIndex(indexPath.row) {
                        (success: Bool) -> Void in
                        // Removed cell from tableview
                        if success {
                            // TODO: Show Success banner
                            // TODO: Possibly completely remove cell in limbo
                        } else {
                            // TODO: Show failure banner
                            // TODO: Reinsert cell back into tableview
                        }

                    }
                }
        }
        
        swipeCell.textLabel.text = self.linkViewModel.mainTextForCellAtIndex(indexPath.row)
        
    }
}
