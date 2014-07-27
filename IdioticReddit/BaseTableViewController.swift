//
//  BaseTableViewController.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/22/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController, TableViewModelDelegateProtocol {
    var tableViewModel: TableViewModel!
    
    // MARK: - Life Cycle
    
    init(style: UITableViewStyle)  {
        super.init(style: style)
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(self.tableViewModel, "Need a view model")
        
        self.tableViewModel.tableViewModelDelegate = self
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        
        self.tableViewModel.active = true
        
    }
    
    override func viewDidDisappear(animated: Bool)  {
        
        self.tableViewModel.active = false
        
        super.viewDidDisappear(animated)
    }
    
    // MARK: - TableViewModelDelegateProtocol
    
    func willLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)  {
        assert(false, "Override me please. ")
    }
    
    func didLoadNewDataForIndexPaths(indexPaths: [NSIndexPath]!)  {
        assert(false, "Override me please. ")
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.cellCount()
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (scrollView.contentSize.height == 0 || self.tableViewModel.isLoadingData)
        {
            return;
        }
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height))
        {
            self.tableViewModel.loadNewData();
        }
    }
    
}
