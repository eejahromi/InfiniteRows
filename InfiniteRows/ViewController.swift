//
//  ViewController.swift
//  InfiniteRows
//
//  Created by Ehsan Jahromi on 3/28/20.
//  Copyright © 2020 Ehsan Jahromi. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var array = (0..<40).map { String($0) }

    private var canLoadMore: Bool {
        return array.count < 60
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfiniteScrollViewHandler()
        tableView.tableFooterView = UIView()
    }

    private func setupInfiniteScrollViewHandler() {
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.canLoadMore {
                strongSelf.tableView.infiniteScrollView?.startAnimating()
                strongSelf.addMoreData() { data in
                    strongSelf.array += data
                    strongSelf.tableView.infiniteScrollView?.stopAnimating()
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
    }

    private func addMoreData(completion: @escaping ([String]) -> Void) {
        DispatchQueue.global().async {
            sleep(2)
            completion(Array(repeating: "", count: 10))
        }
    }
}

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

