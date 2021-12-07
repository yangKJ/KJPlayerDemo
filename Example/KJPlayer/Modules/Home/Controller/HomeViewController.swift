//
//  HomeViewController.swift
//  KJPlayer_Example
//
//  Created by 77。 on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

import UIKit

class HomeViewController: UIViewController {
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bindViewModel()
    }
    
    private func setupUI() {
        self.view.addSubview(self.pagerView)
        self.view.addSubview(self.tableView)
        self.pagerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalTo(self.view).inset(15)
            make.height.equalTo(150)
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.pagerView.snp.bottom).offset(10)
            make.left.right.equalTo(self.view).inset(15)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }
    
    private func bindViewModel() {
        self.viewModel.loadDatas()
        self.viewModel.updateDataBlock = { [unowned self] in
            self.pagerView.reloadData()
        }
        self.typeIndex = 5
    }
    
    private lazy var pagerView: FSPagerView = {
        let pagerView = FSPagerView()
        pagerView.backgroundColor = UIColor.blue
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.isInfinite = true
        //pagerView.scrollDirection = .vertical
        pagerView.automaticSlidingInterval = 2
        pagerView.register(HomePagerViewCell.self, forCellWithReuseIdentifier: HomePagerViewCell.reuseIdentifier)
        return pagerView
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    fileprivate var typeIndex = 0 {
        didSet {
            let type = viewModel.transformerTypes[typeIndex]
            self.pagerView.transformer = FSPagerViewTransformer(type:type)
            switch type {
            case .crossFading, .zoomOut, .depth:
                self.pagerView.itemSize = FSPagerView.automaticSize
                self.pagerView.decelerationDistance = 1
            case .linear, .overlap:
                let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .ferrisWheel, .invertedFerrisWheel:
                self.pagerView.itemSize = CGSize(width: 250, height: 140)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .coverFlow:
                self.pagerView.itemSize = CGSize(width: 220, height: 170)
                self.pagerView.decelerationDistance = FSPagerView.automaticDistance
            case .cubic:
                let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                self.pagerView.decelerationDistance = 1
            }
        }
    }
}

// MARK: - FSPagerViewDataSource,FSPagerViewDelegate
extension HomeViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.homeDatas.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let item = pagerView.dequeueReusableCell(withReuseIdentifier: HomePagerViewCell.reuseIdentifier, at: index)
        (item as! HomePagerViewCell).dataModel = viewModel.homeDatas[index]
        return item
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let model: HomdeModel = viewModel.homeDatas[index]
        guard model.type == .video else { return }
        let vc: DetailsViewController = DetailsViewController()
        vc.videoUrl = model.url!
        vc.name = model.title!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource,UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transformerNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.selectionStyle = .none
        cell.textLabel?.text = viewModel.transformerNames[indexPath.row]
        cell.accessoryType = indexPath.row == self.typeIndex ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.typeIndex = indexPath.row
        if let visibleRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleRows, with: .automatic)
        }
    }
}
