//
//  ViewController.swift
//  IdioticReddit
//
//  Created by AJ Caldwell on 7/13/14.
//  Copyright (c) 2014 Idiotic Design and Development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.normalLogin()
        
        self.anime()
    }
    
    func anime() {
        RKClient.sharedClient().subredditWithName("anime") {
            (AnyObject object, NSError error) -> () in
            if !error {
                let controller = self.storyboard.instantiateViewControllerWithIdentifier("LinkViewController") as LinkViewController
                controller.linkViewModel = LinkViewModel(model: RKClient.sharedClient(), subreddit: object as RKSubreddit)
                self.navigationController.pushViewController(controller, animated: true)
            } else {
                println(error)
            }
        }
    }
    
    func normalLogin() {
        RKClient.sharedClient().signInWithUsername("IDDOfficial", password: "hUE-reo-SJK-4FQ") {
            (NSError error) -> () in
            if !error {
                print("Successful login!")
            } else {
                println(error)
            }
        }
    }
}

