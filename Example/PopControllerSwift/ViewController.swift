//
//  ViewController.swift
//  swiftExample
//
//  Created by heath wang on 2021/4/27.
//  Copyright © 2021 Heath Wang. All rights reserved.
//

import UIKit
import SnapKit
import PopControllerSwift

class ViewController: UIViewController {

    var dataSource = ["Bottom Sheet", "Top Bar", "Full Dialog", "Auto Size", "Navigation"]

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.rowHeight = 44
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Swift example";
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        let cellData = dataSource[indexPath.row]
        
        cell.textLabel?.text = cellData
        cell.accessoryType = .none
        return cell
        
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            let vc = HWBottomAuthViewController()
            // init PopControllerSwift, config it, finally present it.
            let popVC = PopController(presenting: vc)
            popVC.popPosition = .bottom
            popVC.popType = .bounceInFromBottom
            popVC.dismissType = .slideOutToBottom
            popVC.shouldDismissOnBackgroundTouch = false
            popVC.springConfig = SpringAnimationConfig(damping: 0.7, velocity: 0)
            popVC.animationDuration = 0.3
            popVC.present(in: self)
            
        case 1:

            let vc = HWTopBarController()
            let popVC = PopController(presenting:vc)
            popVC.backgroundAlpha = 0
            popVC.popPosition = .top
            popVC.popType = .bounceInFromTop
            popVC.dismissType = .slideOutToTop
            popVC.containerView.layer.cornerRadius = 0;
            popVC.present(in: self)
            
        case 2:
            
            let fullVC = HWFullDialogController()
            // use category method to present.
            let pop = fullVC.present(using: .shrinkIn, dismissWith: .slideOutToBottom, at: .center, dismissOnBackgroundTouch: true)
            pop.containerView.layer.cornerRadius = 0
            
        case 3:
            let vc = HWAutoSizeController()
            vc.present()
            
        case 4:
            let nav = HWNavigationController(rootViewController: HWBaseChildController())
            nav.present(using: .growIn, dismissWith: .bounceOutToBottom, at: .bottom)
            
        default: break
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}

