//
//  ViewController.swift
//  AYRefrash
//
//  Created by 王亚威 on 2023/6/13.
//

import UIKit

class ViewController: UIViewController {
    
     lazy var tableView: UITableView = {
         let tableView = UITableView()
         tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
         tableView.delegate = self
         tableView.dataSource = self
         tableView.backgroundColor = UIColor.red
         return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
   
    }
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

