//
//  TableViewController.swift
//  AYRefrash
//
//  Created by 王亚威 on 2023/6/13.
//

import UIKit

fileprivate let pageCount  = 10
fileprivate let headerH: CGFloat  = 50
fileprivate let footerH: CGFloat  = 50

class TableViewController: UITableViewController {
    /// 数据源
    lazy var count  = 0
    /// 上拉刷新控件
    lazy var footer: UIView = {
        let footer = UIView()
        footer.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerH)
        return footer
    }()
    
    /// 上拉刷新控件里的文字
    lazy var footerLabel: UILabel = {
        let footerLabel = UILabel()
        footerLabel.frame = footer.bounds
        footerLabel.text = "上拉可以加载更多"
        footerLabel.textColor = UIColor.white
        footerLabel.textAlignment = .center
        footerLabel.backgroundColor = UIColor.red
        return footerLabel
    }()
    
    /// 上拉刷新控件正在刷新
    lazy var footerRefreshing: Bool = false
    
    /// 下拉刷新控件
    lazy var header: UIView = {
        let header = UIView()
        header.frame = CGRect.init(x: 0, y: -headerH, width: self.tableView.bounds.width, height: headerH)
        return header
    }()
    
    /// 下拉刷新控件里的文字
    lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.frame = header.bounds
        headerLabel.text = "下拉刷新"
        headerLabel.textColor = UIColor.white
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = UIColor.red
        return headerLabel
    }()
    
    /// 下拉刷新刷新控件正在刷新
    lazy var headerRefreshing: Bool = false

    
    /// UITableViewHeaderView
    lazy var idLabel: UILabel = {
        let idLabel = UILabel()
        idLabel.frame = CGRect.init(x: 0, y: 0, width: self.tableView.bounds.width, height: 50)
        idLabel.text = "广告"
        idLabel.textAlignment = .center
        idLabel.backgroundColor = UIColor.blue
        return idLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.backgroundColor = UIColor.white
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
        
        setupRefresh()
        
        self.tableView.reloadData()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "刷新", style: .done, target: self, action: #selector(headerBeginRefresh))
    }
    
    
    func setupRefresh() {
        self.tableView.tableHeaderView = idLabel

        self.header.addSubview(headerLabel)
        self.tableView.addSubview(header)
        self.footer.addSubview(footerLabel)
        self.tableView.tableFooterView = footer
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.footer.isHidden = count == 0
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !self.headerRefreshing else {
            return
        }
        let offsetY = -(self.header.bounds.height + self.tableView.safeAreaInsets.top)
        if tableView.contentOffset.y <= offsetY {
            self.headerBeginRefresh()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dealFooter()
        dealHeader()
    }

    //MARK: - 下拉刷新
    
    @objc func headerBeginRefresh() {
        self.headerLabel.text = "正在刷新数据..."
        self.headerLabel.backgroundColor = UIColor.green
        self.headerRefreshing = true
        UIView.animate(withDuration: 0.25) {
            var inset = self.tableView.contentInset
            inset.top += self.header.bounds.height
            self.tableView.contentInset = inset
            
            let offsetY = -(inset.top+self.tableView.safeAreaInsets.top)
            self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: offsetY)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.count = 5
            self.tableView.reloadData()
            self.headerEndRefresh()
        }
    }

    // MARK: - 结束下拉刷新

    func headerEndRefresh() {
        self.headerRefreshing = false
        UIView.animate(withDuration: 0.25) {
            var inset = self.tableView.contentInset
            inset.top -= self.header.bounds.height
            self.tableView.contentInset = inset
        }
    }

    // MARK: - 上拉刷新

    func footerBeginRefresh() {
        self.footerLabel.text = "正在加载更多数据..."
        self.footerLabel.backgroundColor = UIColor.green
        self.footerRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.count += pageCount
            self.tableView.reloadData()
            self.footerEndRefresh()
        }
    }

    // MARK: - 结束上拉刷新

    func footerEndRefresh() {
        self.footerRefreshing = false
        self.footerLabel.text = "上拉可以加载更多"
        self.footerLabel.backgroundColor = UIColor.red
    }
    
    func dealFooter() {
        var headerAndFooterHeight: CGFloat = 0
        if let footer = self.tableView.tableFooterView {
            headerAndFooterHeight += footer.bounds.height
        }
        if let header = self.tableView.tableHeaderView {
            headerAndFooterHeight += header.bounds.height
        }

        guard tableView.contentSize.height > headerAndFooterHeight else { return }
        
        guard !self.footerRefreshing else { return }
        
        let offsetY = tableView.contentSize.height + tableView.contentInset.bottom - tableView.frame.height
        if tableView.contentOffset.y >= offsetY, tableView.contentOffset.y > -tableView.safeAreaInsets.top {
            self.footerBeginRefresh()
        }
    }
    
    func dealHeader() {
        if self.headerRefreshing { return }
        let offsetY = -(self.header.bounds.height + self.tableView.safeAreaInsets.top)
        if tableView.contentOffset.y < offsetY {
            self.headerLabel.text = "松手立即刷新"
            self.headerLabel.backgroundColor = UIColor.orange
        } else {
            self.headerLabel.text = "下拉可以刷新"
            self.headerLabel.backgroundColor = UIColor.red
        }
    }

}
