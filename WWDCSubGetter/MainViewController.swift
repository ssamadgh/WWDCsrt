//
//  MainViewController.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Cocoa

final class MainViewController: NSViewController, TextFileViewDelegate, NSTextFieldDelegate, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate, ProgressView {
    
    // MARK: - Enums
    
    /// An enum for tabView items based on its identifier
    enum TabViewID: String {
        case session, videoLink, textFile
    }
    
    /// An enum for wwdc selection `popUpButton`
    enum WWDC: Int {
        case of2013 = 2013, of2014, of2015, of2016, of2017, of2018
    }
    
    /// An enum for detect which radio button in session tabView is selected. single session or all sessions.
    enum Session: Equatable {
        static func ==(lhs: MainViewController.Session, rhs: MainViewController.Session) -> Bool {
            switch (lhs, rhs) {
            case (.allSessions, .allSessions):
                return true
            case let (.singleSession(lSubtitle), .singleSession(rSubtitle)):
                return lSubtitle == rSubtitle
            default:
                return false
            }
        }
        
        case singleSession(Subtitle)
        case allSessions
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak  var comboBox: NSComboBox!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    @IBOutlet weak var videoLinkTextField: NSTextField!
    @IBOutlet weak var textFileViewLabel: NSTextField!
    @IBOutlet weak var singleSessionButton: NSButton!
    @IBOutlet weak var allSessionsButton: NSButton!
    @IBOutlet weak var destinationTextField: NSTextField!
    @IBOutlet weak var getButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var circularIndicator: NSProgressIndicator!
    @IBOutlet weak var videoLinkTabViewStatusLabel: NSTextField!
    @IBOutlet weak var getButtonStatusLabel: NSTextField!

    let operationQueue = OperationQueue()
    
    var draggedTextFileURL: URL?
    var draggedTextFileSubtitles: [Subtitle] = []
    
    var wwdcVideosSubtitlesDic: [WWDC: [Subtitle]] = [:]
    
    /// A computed property whic gets selected wwdc based on `popUpButton` selection
    var selectedWWDC: WWDC {
        return WWDC(rawValue: Int(self.popUpButton.selectedItem!.title)!)!
    }
    
    /// A computed property whic gets a subtitle array based on `selectedWWDC`
    var selectedWWWDCSubtitles: [Subtitle] {
        let subtitles = self.wwdcVideosSubtitlesDic[selectedWWDC]
        return subtitles ?? []
    }
    
    /// subtitle created after inputting a link in to `videoLinkTextField`
    var videoLinkSubtitle: Subtitle?
    
    var session: Session?
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting delegate of view in text File tabView to `MainViewController`
        
        for tabViewItem in self.tabView.tabViewItems {
            if tabViewItem.identifier as! String == TabViewID.textFile.rawValue {
                (tabViewItem.view as! TextFileView).delegate = self
            }
        }
        
        self.videoLinkTextField.delegate = self
        
        self.comboBox.usesDataSource = true
        self.comboBox.delegate = self
        self.comboBox.dataSource = self
        self.comboBox.completes = true
        
        
        self.getSubtitlesForSelectedWWDC()
        
        // Checking if there is `documentDirectory` set it as default destination.
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            model.destinationURL = dir
            self.destinationTextField.placeholderString = dir.path
        }
        
        self.videoLinkTabViewStatusLabel.stringValue = ""
        self.getButtonStatusLabel.stringValue = ""
        
//        self.progressIndicator.doubleValue 
    }
    
    // MARK: - Session tabView methods
    
    @IBAction func popUpButtonClicked(_ sender: NSPopUpButton) {
        self.getSubtitlesForSelectedWWDC()
    }
    
    // MARK: Radio buttons methods
    
    @IBAction func singleSessionSelected(_ sender: NSButton) {
        self.toggleSession(for: self.session)
    }
    
    @IBAction func allSessionsSelected(_ sender: NSButton) {
        self.session = .allSessions
        self.comboBox.stringValue = ""
        self.toggleSession(for: self.session)
    }
    
    func toggleSession(for session: Session?) {
        self.allSessionsButton.state = session == .allSessions ? .on : .off
        self.singleSessionButton.state = session == .allSessions ? .off : .on
    }
    
    // MARK: ComboBox methods
    
    @IBAction func comboBoxselectedAction(_ sender: NSComboBox) {
        print(sender.stringValue)
        let string = sender.stringValue
        if !string.isEmpty {
            let filteredSubtitles = self.selectedWWWDCSubtitles.filter { $0.videoName == string}
            if !filteredSubtitles.isEmpty {
                self.session = Session.singleSession(filteredSubtitles.first!)
                self.toggleSession(for: self.session)
            }
        }
        else {
            self.session = nil
            self.singleSessionButton.state = .off
        }
        
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.selectedWWWDCSubtitles.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return self.selectedWWWDCSubtitles[index].videoName
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        let filteredSubtitles = self.selectedWWWDCSubtitles.filter { $0.videoName == string}
        
        return !filteredSubtitles.isEmpty ? self.selectedWWWDCSubtitles.index(of: filteredSubtitles.first!)! : NSNotFound
    }
    
    // MARK: - Video Link tabView methods
    
    override func controlTextDidChange(_ obj: Notification) {
        if (obj.object as? NSTextField) === self.videoLinkTextField {
            guard !self.videoLinkTextField.stringValue.isEmpty else {
                self.videoLinkTabViewStatusLabel.stringValue = ""
                return
            }
            let convertToSubtitleOperation = ConvertToSubtitleOperation(from: self.videoLinkTextField.stringValue, type: .videoLink) { (subtitles) in
                if !subtitles.isEmpty {
                    self.videoLinkSubtitle = subtitles.first
                    DispatchQueue.main.async {
                        self.videoLinkTextField.stringValue = self.videoLinkSubtitle!.videoURL
                        self.videoLinkTabViewStatusLabel.stringValue = "Ready to download subtitle"
                        self.videoLinkTabViewStatusLabel.textColor = NSColor.moss
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.videoLinkTabViewStatusLabel.stringValue = "Error: Video Link is not valid"
                        self.videoLinkTabViewStatusLabel.textColor = NSColor.red
                    }
                }
            }
            
            self.operationQueue.addOperation(convertToSubtitleOperation)
        }
    }
    
    // MARK: - Text File tabView method
    
    func droppedTextFileURL(_ url: URL) {
        
        self.draggedTextFileURL = url
        
        let convertToSubtitleOperation = ConvertToSubtitleOperation(from: url.path, type: .textFile) { (subtitles) in
            if !subtitles.isEmpty {
                self.draggedTextFileSubtitles = subtitles
                
                DispatchQueue.main.async {
                    self.textFileViewLabel.stringValue = """
                    ready for getting subtitles for WWDC videos in text file at address:
                    
                    "\(url.path)"
                    """
                    self.textFileViewLabel.textColor = NSColor.moss
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showErrorForTexFileViewTabAnimately()
                }
            }
        }
        
        self.operationQueue.addOperation(convertToSubtitleOperation)
    }
    
    func showErrorForTexFileViewTabAnimately() {
        self.textFileViewLabel.stringValue = """
        Error: The urls in text file is not valid.
        """
        self.textFileViewLabel.textColor = NSColor.red
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 1
                self.textFileViewLabel.animator().alphaValue = 0
            }, completionHandler: {
                self.textFileViewLabel.stringValue = ""
                self.textFileViewLabel.alphaValue = 1
            })
            
        })
    }

    
    // MARK: - Choose Destination address methods
    
    @IBAction func chooseDestinationButtonClicked(_ sender: NSButton) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                let url = panel.urls[0]
                model.destinationURL = url
                self.destinationTextField.placeholderString = url.path
            }
        }
    }
    
    // MARK: - Get button methods for getting subtitles
    
    // When user pressing the Get button we check to see which tab is selected and based on it we getting appropriate subtitles.
    
    @IBAction func getSubtitleButtonClicked(_ sender: NSButton) {
        
        switch self.tabView.selectedTabViewItem?.identifier as! String {
        case TabViewID.session.rawValue:
            self.getSubtitleFromSession()
            
        case TabViewID.videoLink.rawValue:
            self.getSubtitleFromVideoLink()
            
        case TabViewID.textFile.rawValue:
            self.getSubtitleFromTexFile()
        default:
            break
        }
        
        if !model.isEmpty {
            self.startGetSubtitleOperation()
        }
        else {
            let error = "Error: No valid video link is imported."
            self.endDownloadingStatus(withError: error)
            self.endDownloadingStatus()
        }
    }
    
    
    func getSubtitleFromSession() {
        if session != nil {
            model.clear()
            switch self.session! {
            case .singleSession(let subtitle):
                model.update(subtitle)
                
            case .allSessions:
                model.update(self.selectedWWWDCSubtitles)
            }
        }
    }
    
    func getSubtitleFromVideoLink() {
        guard let subtitle = self.videoLinkSubtitle else {return }
        model.clear()
        model.update(subtitle)
    }
    
    func getSubtitleFromTexFile() {
        let subtitles = self.draggedTextFileSubtitles
        guard  !subtitles.isEmpty else { return }
        model.clear()
        model.update(subtitles)
    }
    
    func startGetSubtitleOperation() {
        self.getButton.isEnabled = false
        self.getButtonStatusLabel.textColor = .black
        self.getButtonStatusLabel.stringValue = "downloading Subtitles 0 of \(model.allSubtitles().count)"
        
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = Double(model.allSubtitles().count)
        SubtitlesProgress.min = self.progressIndicator.minValue
        SubtitlesProgress.max = self.progressIndicator.maxValue
        SubtitlesProgress.progressView = self
        self.progressIndicator.alphaValue = 1
        self.progressIndicator.startAnimation(nil)

        let operation = GetSubtitlesOperation {
            self.endDownloadingStatus()
        }
        self.operationQueue.addOperation(operation)
    }
    
    func endDownloadingStatus(withError: String? = nil) {
        var delayTime: Int = 2
        if withError != nil {
            delayTime = 0
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(delayTime)) {
            self.getButton.isEnabled = true
            self.circularIndicator.stopAnimation(nil)
            self.getButtonStatusLabel.stringValue = withError ?? ""
            self.getButtonStatusLabel.textColor = .red
            self.progressIndicator.doubleValue = 0
            SubtitlesProgress.current = self.progressIndicator.doubleValue
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.alphaValue = 0
        }
    }
    
    
    /// This method gets subtitle array based on popUp button selection and caches it in `wwdcVideosSubtitlesDic`.
    
    func getSubtitlesForSelectedWWDC() {
        let selectedYear = self.popUpButton.selectedItem!.title
        let selectedWWDC = WWDC(rawValue: Int(selectedYear)!)!
        
        guard self.wwdcVideosSubtitlesDic[selectedWWDC] == nil else {
            self.comboBox.reloadData()
            return
        }
        
        let fileName = "WWDC\(selectedYear)_links"
        let path = Bundle.main.path(forResource: fileName, ofType: "txt")!
        
        let convertToSubtitleOperation = ConvertToSubtitleOperation(from: path, type: .textFile) { (subtitles) in
            self.wwdcVideosSubtitlesDic[selectedWWDC] = subtitles
            
            DispatchQueue.main.async {
                self.comboBox.reloadData()
            }
        }
        self.operationQueue.addOperation(convertToSubtitleOperation)
    }
    
    // MARK: ProgressView protocol method
    
    func progressChanged(to value: Double) {
        DispatchQueue.main.async {
            self.progressIndicator.doubleValue = value
            self.getButtonStatusLabel.stringValue = "downloading Subtitles \(Int(value)) of \(model.allSubtitles().count)"

        }
    }

}


extension NSColor {
    open class var moss: NSColor {
        return NSColor(deviceRed: 0, green: 144/255, blue: 81/255, alpha: 1)
    }
}
