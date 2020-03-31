//
//  ViewController.swift
//  InfiniteRows
//
//  Created by Ehsan Jahromi on 3/28/20.
//  Copyright © 2020 Ehsan Jahromi. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var array = (0..<50).map { String($0) }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
            for _ in 0..<3 {
                self?.addMoreData()
            }
            self?.tableView.reloadData()
        }
    }

    private func addMoreData() {
        array += Array(repeating: "", count: 10)
    }
    
}

//private func setupInfiniteScrolling() {
//    tableView.addInfiniteScrolling { [weak self] in
//        guard let strongSelf = self else {
//            return
//        }
//        if strongSelf.dataSource.canFetchMorePurchaseOptions {
//            let numberOfPurchaseOptionsInDataSource = strongSelf.dataSource.purchaseOptions.count
//            strongSelf.dataSource.fetchNextSetOfPurchaseOptions { [weak self] error in
//                if self?.dataSource.purchaseOptions.count != numberOfPurchaseOptionsInDataSource {
//                    self?.tableView.reloadData()
//                    self?.tableView.infiniteScrollingView?.stopAnimating()
//
//                    if error != nil {
//                        self?.presentAPIFailureAlert()
//                    }
//                    else {
//                        self?.tableView.infiniteScrollingView?.stopAnimating()
//                    }
//                }
//            }
//        }
//    }
//
//    tableView.mb_showCustomLoadingView()
//    dataSource.fetchNextSetOfPurchaseOptions { [weak self] error in
//        guard let strongSelf = self else {
//            return
//        }
//        strongSelf.tableView.reloadData()
//        strongSelf.tableView.mb_hideCustomLoadingView()
//        if error != nil {
//            strongSelf.navigationController?.popViewController(animated: true)
//            strongSelf.presentAPIFailureAlert()
//        }
//    }
//}


extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

