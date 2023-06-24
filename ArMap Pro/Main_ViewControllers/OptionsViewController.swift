//
//  SettingsViewController.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 21.05.2021.
//

import UIKit
import SafariServices

class OptionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var hightLightAccountView: HighlightView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var infoButton: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var appearanceView: UIView!
    @IBOutlet weak var appearanceLabel: UILabel!
    @IBOutlet weak var lightImage: UIImageView!
    @IBOutlet weak var darkImage: UIImageView!
    @IBOutlet weak var systemImage: UIImageView!
    @IBOutlet weak var lightCheck: UIImageView!
    @IBOutlet weak var darkCheck: UIImageView!
    @IBOutlet weak var systemCheck: UIImageView!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var darkLabel: UILabel!
    @IBOutlet weak var systemLabel: UILabel!
    @IBOutlet weak var appearanceStack: UIStackView!
    
    @IBOutlet weak var appearanceStackHeight: NSLayoutConstraint!
    @IBOutlet weak var lightHeight: NSLayoutConstraint!
    @IBOutlet weak var lightWidth: NSLayoutConstraint!
    @IBOutlet weak var darkHeight: NSLayoutConstraint!
    @IBOutlet weak var darkWidth: NSLayoutConstraint!
    @IBOutlet weak var systemHeight: NSLayoutConstraint!
    @IBOutlet weak var systemWidth: NSLayoutConstraint!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineSwitch: UISwitch!
    
    @IBOutlet weak var mapTypeView: UIView!
    @IBOutlet weak var typeOfMapLabel: UILabel!
    @IBOutlet weak var mapTypeStack: UIStackView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var satelliteImage: UIImageView!
    @IBOutlet weak var hybridImage: UIImageView!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var satelliteLabel: UILabel!
    @IBOutlet weak var hybridLabel: UILabel!
    
    @IBOutlet weak var mapStackHeight: NSLayoutConstraint!
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    @IBOutlet weak var mapWidth: NSLayoutConstraint!
    @IBOutlet weak var satelliteHeight: NSLayoutConstraint!
    @IBOutlet weak var satelliteWidth: NSLayoutConstraint!
    @IBOutlet weak var hybridHeight: NSLayoutConstraint!
    @IBOutlet weak var hybridWidth: NSLayoutConstraint!
    
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var distanseDescription: UILabel!
    
    @IBOutlet var chooseDistanceView: UIView!
    @IBOutlet weak var doneContainerView: UIView!
    @IBOutlet weak var distancePickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var chooseDistanceBottom: NSLayoutConstraint!
    @IBOutlet weak var pickerBottom: NSLayoutConstraint!
    
    @IBOutlet weak var foreignView: UIView!
    @IBOutlet weak var foreignSwitch: UISwitch!
    @IBOutlet weak var foreignLabel: UILabel!
    
    @IBOutlet weak var documentsContainerView: UIView!
    @IBOutlet weak var documentsTableView: UITableView!
    @IBOutlet weak var documentsContainerHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var devView: UIView!
    @IBOutlet weak var devSwitch: UISwitch!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    let selectFeedback = UISelectionFeedbackGenerator()
    
    let blueColor = CGColor.init(srgbRed: 0.011, green: 0.461, blue: 1.000, alpha: 1.0)
    let greyBorder = CGColor.init(srgbRed: 0.393, green: 0.391, blue: 0.406, alpha: 1.0)
    
    let window = UIApplication.shared.windows[0]
    
    let renderDistanceData = ["300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200", "1300", "1400", "1500"]
    var pickerSelectedRow = -1
    
    let enDocuments = ["Privacy Policy", "Agreement on the processing data", "Terms of Use", "About us"]
    let ruDocuments = ["Политика Конфиденциальности", "Соглашение об обработке данных", "Условия использования", "О нас"]
    
    private var willBeDeinited: Bool = true
    
    // MARK: - View's lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        willBeDeinited = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if globalVariables.topSafeAreaLength == 0.0 {
            globalVariables.topSafeAreaLength = self.view.safeAreaInsets.top
        }
    
        self.view.layoutSubviews()
        self.scrollView.layoutSubviews()
        
        if scrollView.frame.height - globalVariables.bottomScreenLength >= documentsContainerView.frame.maxY + 16 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height + 0.5)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: documentsContainerView.frame.maxY + 80)
        }
        
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if willBeDeinited {
            chooseDistanceView?.removeFromSuperview()
            chooseDistanceView = nil
            distancePickerView?.delegate = nil
            distancePickerView?.dataSource = nil
            documentsTableView?.delegate = nil
            documentsTableView?.dataSource = nil
        }
    }
    
    // MARK: - Setup scene
    
    func setupScene() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if personalInfo.isAuthorised {
            accountView.removeFromSuperview()
            appearanceView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        }
        
        visualEffectView.removeConstraints(visualEffectView.constraints)
        visualEffectView.removeFromSuperview()
        self.view.addSubview(visualEffectView)
        visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: globalVariables.bottomScreenLength).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        visualEffectView.isHidden = true
        
        selectFeedback.prepare()
        
        scrollViewBottom.constant = -globalVariables.bottomScreenLength
        
        accountView.layer.cornerRadius = 16
        hightLightAccountView.layer.cornerRadius = 16
        accountView.backgroundColor = UIColor(named: "infoColor")
        Helpers().addShadow(view: accountView)
         
        if !globalVariables.production {
            devView.layer.cornerRadius = 16
            Helpers().addShadow(view: devView)
            if globalVariables.developeMode {
                devSwitch.isOn = true
            } else {
                devSwitch.isOn = false
            }
        } else {
            devView.removeFromSuperview()
        }
    
        appearanceView.layer.cornerRadius = 16
        appearanceView.backgroundColor = UIColor(named: "infoColor")
        Helpers().addShadow(view: appearanceView)
        
        offlineView.layer.cornerRadius = 16
        offlineView.backgroundColor = UIColor(named: "infoColor")
        Helpers().addShadow(view: offlineView)
        
        mapTypeView.layer.cornerRadius = 16
        mapTypeView.backgroundColor = UIColor(named: "infoColor")
        Helpers().addShadow(view: mapTypeView)
        
        distanceView.layer.cornerRadius = 16
        distanceView.backgroundColor = UIColor(named: "infoColor")
        Helpers().addShadow(view: distanceView)
        distanceLabel.text = String(globalVariables.renderDistance) + " m"
        
        foreignView.layer.cornerRadius = 16
        Helpers().addShadow(view: foreignView)
        
        let imagesWigth = (UIScreen.main.bounds.width - 80) / 3
        
        appearanceStackHeight.constant = imagesWigth
        lightHeight.constant = imagesWigth
        lightWidth.constant = imagesWigth
        darkHeight.constant = imagesWigth
        darkWidth.constant = imagesWigth
        systemHeight.constant = imagesWigth
        systemWidth.constant = imagesWigth
        
        lightImage.layer.masksToBounds = true
        lightImage.layer.cornerRadius = 15
        darkImage.layer.masksToBounds = true
        darkImage.layer.cornerRadius = 15
        systemImage.layer.masksToBounds = true
        systemImage.layer.cornerRadius = 15
        
        mapStackHeight.constant = imagesWigth
        mapHeight.constant = imagesWigth
        mapWidth.constant = imagesWigth
        satelliteHeight.constant = imagesWigth
        satelliteWidth.constant = imagesWigth
        hybridHeight.constant = imagesWigth
        hybridWidth.constant = imagesWigth
        
        mapImage.layer.masksToBounds = true
        mapImage.layer.cornerRadius = 15
        satelliteImage.layer.masksToBounds = true
        satelliteImage.layer.cornerRadius = 15
        hybridImage.layer.masksToBounds = true
        hybridImage.layer.cornerRadius = 15
        
        lightImage.layer.borderColor = greyBorder
        darkImage.layer.borderColor = greyBorder
        systemImage.layer.borderColor = greyBorder
        
        switch globalVariables.mapType {
        case "standart":
            mapLabel.textColor = UIColor.init(named: "mapCircle")
            satelliteLabel.textColor = UIColor(named: "textmaptype")
            hybridLabel.textColor = UIColor(named: "textmaptype")
            mapImage.layer.borderWidth = 3.0
            satelliteImage.layer.borderWidth = 0.0
            hybridImage.layer.borderWidth = 0.0
        case "satellite":
            satelliteLabel.textColor = UIColor.init(named: "mapCircle")
            mapLabel.textColor = UIColor(named: "textmaptype")
            hybridLabel.textColor = UIColor(named: "textmaptype")
            satelliteImage.layer.borderWidth = 3.0
            mapImage.layer.borderWidth = 0.0
            hybridImage.layer.borderWidth = 0.0
        case "hybride":
            hybridLabel.textColor = UIColor.init(named: "mapCircle")
            mapLabel.textColor = UIColor(named: "textmaptype")
            satelliteLabel.textColor = UIColor(named: "textmaptype")
            hybridImage.layer.borderWidth = 3.0
            mapImage.layer.borderWidth = 0.0
            satelliteImage.layer.borderWidth = 0.0
        default:
            break
        }
        
        switch globalVariables.appearanceMode {
        case "light":
            self.lightCheck.alpha = 1.0
            self.darkCheck.alpha = 0.0
            self.systemCheck.alpha = 0.0
            self.lightImage.layer.borderWidth = 3.0
            self.darkImage.layer.borderWidth = 0.0
            self.systemImage.layer.borderWidth = 0.0
            
        case "dark":
            self.lightCheck.alpha = 0.0
            self.darkCheck.alpha = 1.0
            self.systemCheck.alpha = 0.0
            self.lightImage.layer.borderWidth = 0.0
            self.darkImage.layer.borderWidth = 3.0
            self.systemImage.layer.borderWidth = 0.0
            
        case "system":
            self.lightCheck.alpha = 0.0
            self.darkCheck.alpha = 0.0
            self.systemCheck.alpha = 1.0
            self.lightImage.layer.borderWidth = 0.0
            self.darkImage.layer.borderWidth = 0.0
            self.systemImage.layer.borderWidth = 3.0
            
        default:
            break
        }
        
        mapImage.layer.borderColor = blueColor
        satelliteImage.layer.borderColor = blueColor
        hybridImage.layer.borderColor = blueColor
        
        documentsTableView.delegate = self
        documentsTableView.dataSource = self
        
        documentsTableView.layer.masksToBounds = true
        documentsTableView.layer.cornerRadius = 16
        documentsContainerView.layer.cornerRadius = 16
        documentsTableView.rowHeight = 52
        Helpers().addShadow(view: documentsContainerView)
        
        chooseDistanceView.clipsToBounds = true
        chooseDistanceView.layer.cornerRadius = 20
        chooseDistanceView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        chooseDistanceView.alpha = 0.0
        chooseDistanceBottom.constant = globalVariables.bottomScreenLength
        pickerBottom.constant = globalVariables.bottomScreenLength
        
        distancePickerView.delegate = self
        distancePickerView.dataSource = self
        distancePickerView.selectRow(globalVariables.renderDistance / 100 - 3, inComponent: 0, animated: false)
        
        offlineSwitch.isOn = globalVariables.offlineMode
        foreignSwitch.isOn = globalVariables.showForeignTags
    }
    
    // MARK: - Actions
    
    @IBAction func createAccount(_ sender: Any) {
        
        let VC = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(identifier:"CreateAccountViewController")
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        willBeDeinited = false
        
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func chooseDistance(_ sender: Any) {
        selectFeedback.selectionChanged()
        
        self.view.addSubview(self.chooseDistanceView)
        
        self.chooseDistanceView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.chooseDistanceView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.chooseDistanceView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        Helpers().addShadow(view: self.doneContainerView)
        
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.chooseDistanceView.alpha = 1
            self.visualEffectView.isHidden = false
        }, completion: nil)
        
    }
    
    @IBAction func didSelectDistance(_ sender: Any) {
        
        if pickerSelectedRow != -1 {
            globalVariables.renderDistance = (renderDistanceData[pickerSelectedRow] as NSString).integerValue
            distanceLabel.text = "\(globalVariables.renderDistance) m"
        }
        
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.chooseDistanceView.alpha = 0.0
            self.visualEffectView.isHidden = true
        }, completion: nil)
        chooseDistanceView.removeFromSuperview()
    }
    
    @IBAction func closeChoosingView(_ sender: Any) {
        UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.chooseDistanceView.alpha = 0.0
            self.visualEffectView.isHidden = true
        }, completion: nil)
        chooseDistanceView.removeFromSuperview()
    }
    
    @IBAction func changeOfflineMode(_ sender: UISwitch) {
        
        globalVariables.offlineMode = sender.isOn
        
        if sender.isOn {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(globalVariables.allTags), forKey:"offlineTagsList")
            UserDefaults.standard.set(try? PropertyListEncoder().encode(personalInfo.userAccount), forKey:"offlineUserAccount")
        } else {
            UserDefaults.standard.set(nil, forKey:"offlineTagsList")
        }
    }
    
    @IBAction func showForeignTags(_ sender: UISwitch) {
        globalVariables.showForeignTags = sender.isOn
    }
    
    @IBAction func switchDevMode(_ sender: Any) {
        if devSwitch.isOn {
            globalVariables.developeMode = true
        } else {
            globalVariables.developeMode = false
        }
        personalInfo.userAccount = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              exit(0)
             }
        }
    }
    
    // MARK: - Actions with appearance
    
    @IBAction func chooseLight(_ sender: Any) {
        selectFeedback.selectionChanged()
        globalVariables.appearanceMode = "light"
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.lightCheck.alpha = 1.0
            self.darkCheck.alpha = 0.0
            self.systemCheck.alpha = 0.0
            self.lightImage.layer.borderWidth = 3.0
            self.darkImage.layer.borderWidth = 0.0
            self.systemImage.layer.borderWidth = 0.0
            self.window.overrideUserInterfaceStyle = .light
        }, completion: nil)
        
    }
    
    @IBAction func chooseDark(_ sender: Any) {
        selectFeedback.selectionChanged()
        globalVariables.appearanceMode = "dark"
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.lightCheck.alpha = 0.0
            self.darkCheck.alpha = 1.0
            self.systemCheck.alpha = 0.0
            self.lightImage.layer.borderWidth = 0.0
            self.darkImage.layer.borderWidth = 3.0
            self.systemImage.layer.borderWidth = 0.0
            self.window.overrideUserInterfaceStyle = .dark
        }, completion: nil)
        
    }
    
    @IBAction func chooseSystem(_ sender: Any) {
        selectFeedback.selectionChanged()
        globalVariables.appearanceMode = "system"
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.lightCheck.alpha = 0.0
            self.darkCheck.alpha = 0.0
            self.systemCheck.alpha = 1.0
            self.lightImage.layer.borderWidth = 0.0
            self.darkImage.layer.borderWidth = 0.0
            self.systemImage.layer.borderWidth = 3.0
            self.window.overrideUserInterfaceStyle = .unspecified
        }, completion: nil)
        
    }
    
    // MARK: - Actions with mapType
    
    @IBAction func typeMap(_ sender: Any) {
        selectFeedback.selectionChanged()
        UIView.transition(with: mapTypeView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.mapLabel.textColor = UIColor.init(named: "mapCircle")
            self.satelliteLabel.textColor = UIColor(named: "textmaptype")
            self.hybridLabel.textColor = UIColor(named: "textmaptype")
            self.mapImage.layer.borderWidth = 3.0
            self.satelliteImage.layer.borderWidth = 0.0
            self.hybridImage.layer.borderWidth = 0.0
        }, completion: nil)
        globalVariables.mapType = "standart"
    }
    
    @IBAction func typeSatellite(_ sender: Any) {
        selectFeedback.selectionChanged()
        UIView.transition(with: mapTypeView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.satelliteLabel.textColor = UIColor.init(named: "mapCircle")
            self.mapLabel.textColor = UIColor(named: "textmaptype")
            self.hybridLabel.textColor = UIColor(named: "textmaptype")
            self.satelliteImage.layer.borderWidth = 3.0
            self.mapImage.layer.borderWidth = 0.0
            self.hybridImage.layer.borderWidth = 0.0
        }, completion: nil)
        globalVariables.mapType = "satellite"
    }
    
    @IBAction func typeHybrid(_ sender: Any) {
        selectFeedback.selectionChanged()
        UIView.transition(with: mapTypeView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.hybridLabel.textColor = UIColor.init(named: "mapCircle")
            self.mapLabel.textColor = UIColor(named: "textmaptype")
            self.satelliteLabel.textColor = UIColor(named: "textmaptype")
            self.hybridImage.layer.borderWidth = 3.0
            self.mapImage.layer.borderWidth = 0.0
            self.satelliteImage.layer.borderWidth = 0.0
        }, completion: nil)
        globalVariables.mapType = "hybride"
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        documentsContainerHeight.constant = CGFloat(enDocuments.count * 52 - 1)
        
        return enDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        let label = cell.viewWithTag(1) as! UILabel
        
        switch globalVariables.currentLanguage {
        case "en":
            label.text = enDocuments[indexPath.row]
        case "ru":
            label.text = ruDocuments[indexPath.row]
        default:
            break
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        documentsTableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        var url: URL!
        
        switch globalVariables.currentLanguage {
        case "en":
            if row == 0 {
                url = URL(string: globalVariables.websiteUrl + "en/policy/")
            } else if row == 1 {
                url = URL(string: globalVariables.websiteUrl + "en/agreement/")
            } else if row == 2 {
                url = URL(string: globalVariables.websiteUrl + "en/termsofuse/")
            } else if row == 3 {
                url = URL(string: globalVariables.websiteUrl + "en/mainpage/")
            }
        case "ru":
            if row == 0 {
                url = URL(string: globalVariables.websiteUrl + "ru/policy/")
            } else if row == 1 {
                url = URL(string: globalVariables.websiteUrl + "ru/agreement/")
            } else if row == 2 {
                url = URL(string: globalVariables.websiteUrl + "ru/termsofuse/")
            } else if row == 3 {
                url = URL(string: globalVariables.websiteUrl + "ru/mainpage/")
            }
        default:
            break
        }
        
        let vc = SFSafariViewController(url: url)
        
        willBeDeinited = false
        
        present(vc, animated: true)
        
    }
    
    // MARK: - Picker View Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return renderDistanceData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(renderDistanceData[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelectedRow = row
    }
}
