//
//  SwiftLocaitonPicker.swift
//  SwiftLocaitonPicker
//
//  Created by xiaohei-C on 2017/8/16.
//  Copyright © 2017年 com. All rights reserved.
//

import UIKit

let HSCREEN_WIDTH = UIScreen.main.bounds.size.width
let HSCREEN_HEIGHT = UIScreen.main.bounds.size.height
let POP_VIEW_HEIGHT:CGFloat = HSCREEN_WIDTH >= 414 ? 290 : 280
let BTN_COLOR = UIColor(red: 5/255, green: 114/255, blue: 246/255, alpha: 1)
let TOOL_BAR_COLOR = UIColor(red: 246/255, green: 247/255, blue: 248/255, alpha: 1)
let TOP_TITLE_COLOR = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)


enum LocationPickerType {
    case level1(province: String)
    case level2(province: String, city: String)
    case level3(province: String, city: String, town: String)
    
    var getLocationArr:[String] {
        switch self {
        case .level1(let province):
            return [province]
        case .level2(let r):
            return [r.province, r.city]
        case .level3(let r):
            return [r.province, r.city, r.town]
        }
    }
    
    var address:String {
        return getLocationArr.joined(separator: " ")
    }
}


class SwiftLocationPicker: UIView {


    /// 底部内容视图
    lazy var contentView:UIView = {
        let rect = CGRect(x: 0, y: HSCREEN_HEIGHT, width: HSCREEN_WIDTH, height: POP_VIEW_HEIGHT)
        var contentView = UIView(frame: rect)
        contentView.backgroundColor = UIColor.white
        return contentView
    }()
    
    
    /// 滚动视图
    lazy var pickerView:UIPickerView = {
        let rect = CGRect(x: 0, y: 40, width: HSCREEN_WIDTH, height: POP_VIEW_HEIGHT - 40)
        var pickerView = UIPickerView(frame: rect)
        pickerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pickerView.backgroundColor = UIColor.white
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    
    /// 工具栏视图
    lazy var topToolBar:UIView = {
        let rect = CGRect(x: 0, y: 0, width: HSCREEN_WIDTH, height: 40)
        var topToolBar = UIView(frame: rect)
        topToolBar.backgroundColor = TOOL_BAR_COLOR
        return topToolBar
    }()
    

    /// 标题
    lazy var topTitle:UILabel = {
        let rect = CGRect(x: 70, y: 5, width: HSCREEN_WIDTH - 140, height: 30)
        var titleLabel = UILabel(frame: rect)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = TOP_TITLE_COLOR
        return titleLabel
    }()
    
    
    /// 取消按钮
    lazy var cancelButton:UIButton = {
        let rect = CGRect(x: 0, y: 5, width: 70, height: 30)
        var cancelBtn = UIButton(type: .system)
        cancelBtn.frame = rect
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn.addTarget(self, action: #selector(canceBtnClicked), for: .touchUpInside)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(BTN_COLOR, for: .normal)
        return cancelBtn
    }()
    
    
    /// 完成按钮
    lazy var finishButton:UIButton = {
        let rect = CGRect(x: HSCREEN_WIDTH - 70, y: 5, width: 70, height: 30)
        var finishBtn = UIButton(type: .system)
        finishBtn.frame = rect
        finishBtn.titleLabel?.textAlignment = .center
        finishBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        finishBtn.addTarget(self, action: #selector(finishBtnClicked), for: .touchUpInside)
        finishBtn.setTitle("确定", for: .normal)
        finishBtn.setTitleColor(BTN_COLOR, for: .normal)
        return finishBtn
    }()
    
    
    /// 是否标题显示当前选择地区
    public var isAppearLociton = false
    
    fileprivate var addressDict:[String: Any] = [:]
    fileprivate var provinceArray:[String] = []
    fileprivate var cityArray:[String] = []
    fileprivate var townArray:[String] = []
    fileprivate var doneBlock:((String)->())?
    fileprivate var pickerType:LocationPickerType = .level1(province: "广东省") {
        didSet {
            if isAppearLociton == true {
                topTitle.text = pickerType.getLocationArr.joined(separator: "")
            }
        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: HSCREEN_WIDTH, height: HSCREEN_HEIGHT))
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.isUserInteractionEnabled = true

        // 初始化子视图
        self.addSubview(contentView)
        self.contentView.addSubview(pickerView)
        self.contentView.addSubview(topToolBar)
        self.topToolBar.addSubview(topTitle)
        self.topToolBar.addSubview(cancelButton)
        self.topToolBar.addSubview(finishButton)
        
        // 初始化数据
        self.loadDataSouce()
        self.setPikcerData()
    }
    
    convenience init(_ locationPickerStyle: LocationPickerType, title:String = "", completeBlock: @escaping (_: String) -> Void) {
        self.init()
        
        self.topTitle.text = title
        self.pickerType = locationPickerStyle
        self.setPikcerData()
        
        doneBlock = { completeBlock($0) }
    }
    
    
    convenience init(_ location: String... ,title:String = "", completeBlock: @escaping (_: String) -> Void) {
        self.init()
        
        switch location.count {
        case 1:
            pickerType = .level1(province: location[0])
        case 2:
            pickerType = .level2(province: location[0], city: location[1])
        case 3:
            pickerType = .level3(province: location[0], city: location[1], town: location[2])
        default:
            print("iuput Error")
        }
        
        self.topTitle.text = title
        self.setPikcerData()
        
        doneBlock = { completeBlock($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 加载相关数据
extension SwiftLocationPicker {
    
    fileprivate func setPikcerData() {
        
        pickerView.setNeedsLayout()
        
        switch pickerType {
        case .level1(province: let province):
            
            self.provinceArray = getProvinceArr()
            
            let provinceIndex = provinceArray.index(of: province)!
            pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
            
        case .level2(province: let province, city: let city):
            
            self.provinceArray = getProvinceArr()
            self.cityArray = getCityArr(province)
            
            let provinceIndex = provinceArray.index(of: province)!
            let cityIndex = cityArray.index(of: city)!
            pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
            pickerView.selectRow(cityIndex, inComponent: 1, animated: true)

        case .level3(province: let province, city: let city, town: let town):
            
            self.provinceArray = getProvinceArr()
            self.cityArray = getCityArr(province)
            self.townArray = getTownArr(province, city: city)
            
            let provinceIndex = provinceArray.index(of: province)!
            let cityIndex = cityArray.index(of: city)!
            let townIndex = townArray.index(of: town)!
            pickerView.selectRow(provinceIndex, inComponent: 0, animated: true)
            pickerView.selectRow(cityIndex, inComponent: 1, animated: true)
            pickerView.selectRow(townIndex, inComponent: 2, animated: true)
        }
    }

    fileprivate func loadDataSouce() {
        
        guard let path = Bundle.main.path(forResource: "Address", ofType: "plist") else { return }
        guard let addressDic = NSDictionary(contentsOfFile: path) as? [String:Any] else { return }
        self.addressDict = addressDic
    }

    fileprivate func getProvinceArr() -> [String] {
        
        return addressDict.map { $0.key }
    }
    
    fileprivate func getCityArr(_ province: String) -> [String] {
        
        guard let guangdong = addressDict[province] as? [Any],
              let citys = guangdong.first as? [String: Any] else {
              return [] }
        
        return citys.map { $0.key }
    }

    fileprivate func getTownArr(_ province:String, city:String) -> [String] {
        
        guard let citysObject = addressDict[province] as? [Any],
              let citys = citysObject.first as? [String: Any],
              let towns = citys[city] as? [String] else {
              return [] }
        
        return towns
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension SwiftLocationPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum ComponentType:Int {
        case province = 0
        case city = 1
        case town = 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        switch pickerType {
        case .level1:
            return 1
        case .level2:
            return 2
        case .level3:
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let componentType = ComponentType(rawValue: component) else {
            return 0
        }
        
        switch componentType {
        case .province:
            return provinceArray.count
        case .city:
            return cityArray.count
        case .town:
            return townArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        guard let componentType = ComponentType(rawValue: component) else {
            return nil
        }
        
        switch componentType {
        case .province:
            return provinceArray[row]
        case .city:
            return cityArray[row]
        case .town:
            return townArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let componentType = ComponentType(rawValue: component) else {
            return
        }
        
        switch componentType {
        case .province:
            
            let province = provinceArray[row]
            
            switch pickerType {
            case .level1:
                
                pickerType = .level1(province: province)
                
            case .level2:
                
                cityArray = getCityArr(province)
                pickerView.reloadComponent(1)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                
                let city = cityArray.first!
                pickerType = .level2(province: province, city: city)
                
            case .level3:
            
                cityArray = getCityArr(province)
                pickerView.reloadComponent(1)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                
                guard let firstCity = cityArray.first else { return }
                
                townArray = getTownArr(province, city: firstCity)
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                
                let town = townArray.first!
                pickerType = .level3(province: province, city: firstCity, town: town)
            }

        case .city:
            
            let city = cityArray[row]
            
            switch pickerType {
            case .level2(let r):
                
                pickerType = .level2(province: r.province, city: city)
                
            case .level3(let r):
                
                self.townArray = getTownArr(r.province, city: city)
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                
                let town = townArray.first!
                pickerType = .level3(province: r.province, city: city, town: town)
            default:
                break
            }
            
        case .town:
            
            guard case let .level3(r) = pickerType else { return }
            let town = townArray[row]
            pickerType = .level3(province: r.province, city: r.city, town: town)
        }
    }
}

// MARK: - 自定义视图显示
extension SwiftLocationPicker {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = [provinceArray, cityArray, townArray][component][row]
        return label
    }
}


// MARK: - 工具栏按钮及点击背景事件
extension SwiftLocationPicker {
    
    func finishBtnClicked(_ btn: UIButton) {
        self.doneBlock?(pickerType.address)
        self.removeSelfFromSupView()
    }
    
    func canceBtnClicked(_ btn: UIButton) {
        self.removeSelfFromSupView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeSelfFromSupView()
    }
}

// MARK: - 显示 | 移除视图
extension SwiftLocationPicker {

    func show() {
        UIApplication.shared.delegate?.window!?.addSubview(self)
        var frame = contentView.frame
        if frame.origin.y == HSCREEN_HEIGHT {
            frame.origin.y -= POP_VIEW_HEIGHT
            UIView.animate(withDuration: 0.3, animations: { _ in
                self.contentView.frame = frame
            })
        }
    }

    func removeSelfFromSupView() {
        var selfFrame = contentView.frame
        if selfFrame.origin.y == HSCREEN_HEIGHT - POP_VIEW_HEIGHT {
            selfFrame.origin.y += POP_VIEW_HEIGHT
            UIView.animate(withDuration: 0.3, animations: { _ in
                self.contentView.frame = selfFrame
            }) { _  in
                self.removeFromSuperview()
            }
        }
    }
}


