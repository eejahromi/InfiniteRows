// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
            else {
                strongSelf.tableView.infiniteScrollView?.stopAnimating()
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

