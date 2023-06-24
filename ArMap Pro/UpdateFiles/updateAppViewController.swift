//
//  updateAppViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 28.12.2021.
//

import UIKit

class UpdateAppViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableView2Height: NSLayoutConstraint!
    @IBOutlet weak var updateLater: UIButton!
    @IBOutlet weak var updateConstraint: NSLayoutConstraint!
    
    private var kritic: Bool = globalVariables.kriticUpdate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalVariables.currentLanguage = Locale.current.languageCode ?? "en"
        
        self.tableViewBottom.isActive = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if globalVariables.currentLanguage == "en" {
            self.tableView.rowHeight = 152
            tableViewHeight.constant = 151
        } else {
            self.tableView.rowHeight = 170
            tableViewHeight.constant = 169
        }
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        self.tableView.rowHeight = 50
        
        self.updateLater.layer.masksToBounds = true
        self.updateLater.layer.cornerRadius = 16
        
        
        
        self.overrideUserInterfaceStyle = .dark
        
        tableView2Height.constant = 49
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if kritic {
            self.updateLater.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        
        self.scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + 1)
        
        self.updateConstraint?.constant = scrollView.frame.height - tableView2.frame.maxY - 140
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if tableView.tag == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "AppNewVersion", for: indexPath)
            let image = cell.viewWithTag(9) as! UIImageView
            image.layer.masksToBounds = true
            image.layer.cornerRadius = 14
            
            let label = cell.viewWithTag(4) as! UILabel
            label.text = "ARmap " + globalVariables.availableVersion
            
        } else if tableView.tag == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "UpdateButton", for: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            if globalVariables.currentLanguage == "en" {
                return 152
            } else {
                return 170
            }
        } else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.tag == 1 {
            if let url = URL(string: "itms-apps://apple.com/app/id1580275636") {
                UIApplication.shared.open(url)
            }
        }
        
    }
    
    @IBAction func updateLater(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        var vcs = self.navigationController!.viewControllers
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        vcs.append(rootViewController)
        self.navigationController?.setViewControllers(vcs, animated: true)
    }
    
    
}
