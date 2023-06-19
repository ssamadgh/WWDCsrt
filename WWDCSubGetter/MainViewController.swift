//
//  MainViewController.swift
//  WWDC.srt
//
//  Created by Seyed Samad Gholamzadeh on 7/19/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Cocoa

/// An enum for wwdc selection `popUpButton`

let lastWWDC = WWDC.of2018

enum WWDC: String {
	//tech-talks
	case of2013 = "2013", of2014 = "2014", of2015 = "2015", of2016 = "2016", of2017 = "2017", techTalks = "Tech Talks",
         of2018 = "2018", of2019 = "2019", of2020 = "2020", of2021 = "2021", of2022 = "2022", of2023 = "2023"
	
	var stringValue: String {
		switch self {
		case .of2013:
			return "wwdc2013"
		case .of2014:
			return "wwdc2014"
		case .of2015:
			return "wwdc2015"
		case .of2016:
			return "wwdc2016"
		case .of2017:
			return "wwdc2017"
		case .techTalks:
			return "tech-talks"
		case .of2018:
			return "wwdc2018"
		case .of2019:
			return "wwdc2019"
		case .of2020:
			return "wwdc2020"
        case .of2021:
            return "wwdc2021"
        case .of2022:
            return "wwdc2022"
        case .of2023:
            return "wwdc2023"
		}
	}
		
}

final class MainViewController: NSViewController, TextFileViewDelegate, NSTextFieldDelegate, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate, ProgressView {
	
    var isTesting: Bool = false
	
    // MARK: - Enums
    
    /// An enum for tabView items based on its identifier
    enum TabViewID: String {
        case session, videoLink, textFile
    }
	
    /// An enum for detect which radio button in session tabView is selected. single session or all sessions.
    enum Session: Equatable {
        static func ==(lhs: MainViewController.Session, rhs: MainViewController.Session) -> Bool {
            switch (lhs, rhs) {
            case (.allSessions, .allSessions):
                return true
            case let (.singleSession(lTitle), .singleSession(rTitle)):
                return lTitle == rTitle
            default:
                return false
            }
        }
		
//        case singleSession(Subtitle)
		case singleSession(String)
        case allSessions
    }
	
	enum GetState {
		case subtitle, downloadLinks
	}
	    
    // MARK: - Properties
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var comboBox: NSComboBox!
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

	@IBOutlet weak var hdSdButtonsHolderBox: NSBox!
	
	@IBOutlet weak var getSubtitleRadioButton: NSButton!
	
	@IBOutlet weak var getDownloadLinkRadioButton: NSButton!
	
	@IBOutlet weak var videoCheckmark: NSButton!
	
	@IBOutlet weak var pdfCheckmark: NSButton!

	@IBOutlet weak var sampleCodeCheckmark: NSButton!

	@IBOutlet weak var checkmarksView: NSView!
	
	@IBOutlet weak var hdRadioButton: NSButton!
	
	@IBOutlet weak var sdRadioButton: NSButton!
	
	let presenter = Presenter()
	
    var draggedTextFileURL: URL?
    var draggedTextFileSubtitles: [Subtitle] = []
    
    var wwdcVideosSubtitlesDic: [WWDC: [Subtitle]] = [:]
	
	var sessionsListArray: [String] = []
	
    /// A computed property whic gets selected wwdc based on `popUpButton` selection
    var selectedWWDC: WWDC {
        return WWDC(rawValue: self.popUpButton.selectedItem!.title)!
    }
    
    /// A computed property whic gets a subtitle array based on `selectedWWDC`
    var selectedWWWDCSubtitles: [Subtitle] {
        let subtitles = self.wwdcVideosSubtitlesDic[selectedWWDC]
        return subtitles ?? []
    }
    
    /// subtitle created after inputting a link in to `videoLinkTextField`
    var videoLinkSubtitle: Subtitle?
    
    var session: Session?
	
	var getState: GetState = .subtitle
	
	var videoQuality: VideoQuality = .hd
	
	var wwdcsSessionsUpdateStatusDic: [WWDC:Bool] = [:]
	
	
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

		self.getSessionsListForSelecteWWDC()

		// Checking if there is `documentDirectory` set it as default destination.
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

			let destination = dir.appendingPathComponent("\(selectedWWDC.stringValue)")
            model.destinationURL = destination
            self.destinationTextField.placeholderString = dir.path
        }
        
        self.videoLinkTabViewStatusLabel.stringValue = ""
        self.getButtonStatusLabel.stringValue = ""
        
//        self.progressIndicator.doubleValue
		self.getSubtitleRadioButton.state = .on
		self.checkmarksView.alphaValue = 0.0
		self.videoCheckmark.state = .on
		self.hdSdButtonsHolderBox.alphaValue = 1.0
		self.hdRadioButton.state = .on
		
		if isTesting {
			let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("com.samad.WWDC.srt")
			
			NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: cachesFolder.path)
		}

		
    }
    
    // MARK: - Session tabView methods
    
    @IBAction func popUpButtonClicked(_ sender: NSPopUpButton) {
		self.getSessionsListForSelecteWWDC()

		if let path = self.destinationTextField.placeholderString {
			let url = URL(fileURLWithPath: path)
			let destination = url.appendingPathComponent("\(selectedWWDC.stringValue)")
			
			model.destinationURL = destination
		}
		self.session = nil
		self.comboBox.stringValue = ""
		self.toggleSession(for: self.session)

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
		guard  session != nil else {
			self.allSessionsButton.state = .off
			self.singleSessionButton.state = .off
			return
		}
        self.allSessionsButton.state = session == .allSessions ? .on : .off
        self.singleSessionButton.state = session == .allSessions ? .off : .on
    }
	
	@IBAction func getSubtitleSelected(_ sender: NSButton) {
		self.getState = .subtitle
		self.toggleGetState(for: self.getState)
	}
	
	@IBAction func getDownloadLinksSelected(_ sender: NSButton) {
		self.getState = .downloadLinks
		self.toggleGetState(for: self.getState)
	}

	
	func toggleGetState(for getState: GetState) {
		self.getSubtitleRadioButton.state = getState == .subtitle ? .on : .off
		self.getDownloadLinkRadioButton.state = getState == .subtitle ? .off : .on
		self.getDownloadLinkRadioButton.title = getState == .subtitle ? "Get Download Links" : "Get Download Links for"
		self.checkmarksView.alphaValue = getState == .subtitle ? 0.0 : 1.0
		
	}
	
	@IBAction func hdRadioButtonAction(_ sender: NSButton) {
		self.videoQuality = .hd
		self.toggleVideoQuality(for: self.videoQuality)
	}
	
	@IBAction func sdRadioButtonAction(_ sender: NSButton) {
		self.videoQuality = .sd
		self.toggleVideoQuality(for: self.videoQuality)
	}
	
	func toggleVideoQuality(for quality: VideoQuality) {
		self.hdRadioButton.state = quality == .hd ? .on : .off
		self.sdRadioButton.state = quality == .hd ? .off : .on
	}


	
	//MARK: Chekmark buttons methods
	
	@IBAction func videoChekmarkAction(_ sender: NSButton) {
		self.hdSdButtonsHolderBox.alphaValue = self.videoCheckmark.state == .on ? 1.0 : 0.0
	}
	
    // MARK: ComboBox methods
    
    @IBAction func comboBoxselectedAction(_ sender: NSComboBox) {
        print(sender.stringValue)
        let title = sender.stringValue
        if !title.isEmpty {
			
			let filteredList = self.sessionsListArray.filter { $0 == title }
			if !filteredList.isEmpty {
				self.session = Session.singleSession(title)
				self.toggleSession(for: self.session)
			}

        }
        else {
            self.session = nil
            self.singleSessionButton.state = .off
        }
        
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
		return self.sessionsListArray.count

    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
		return self.sessionsListArray[index]

    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
		let filteredList = self.sessionsListArray.filter { $0 == string }
		return !filteredList.isEmpty ? self.sessionsListArray.index(of: filteredList.first!)! : NSNotFound
    }
    
    // MARK: - Video Link tabView methods
    
	override func controlTextDidChange(_ obj: Notification) {
		
		guard (obj.object as? NSTextField) === self.videoLinkTextField,
			!self.videoLinkTextField.stringValue.isEmpty else {
				self.videoLinkTabViewStatusLabel.stringValue = ""
				return
		}
		
		self.presenter.convertToSubtitle(from: self.videoLinkTextField.stringValue, type: .videoLink) { (subtitles) in
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
		
	}
    
    // MARK: - Text File tabView method
    
    func droppedTextFileURL(_ url: URL) {
        
        self.draggedTextFileURL = url
        
        self.presenter.convertToSubtitle(from: url.path, type: .textFile) { (subtitles) in
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
				
				let destination = url.appendingPathComponent("\(self.selectedWWDC.stringValue)")

                model.destinationURL = destination
                self.destinationTextField.placeholderString = url.path
            }
        }
    }
    
    // MARK: - Get button methods for getting subtitles
    
    // When user pressing the Get button we check to see which tab is selected and based on it we getting appropriate subtitles.
    
    @IBAction func getSubtitleButtonClicked(_ sender: NSButton) {

        switch self.tabView.selectedTabViewItem?.identifier as! String {
        case TabViewID.session.rawValue:
			switch self.getState {
			case .subtitle:
				self.getSubtitleFromSession(for: selectedWWDC)
			case .downloadLinks:
				var types: [SessionDataTypes] = []
				
				if self.videoCheckmark.state == .on {
					if self.hdRadioButton.state == .on {
						types.append(.video(.hd))
					}
					else {
						types.append(.video(.sd))
					}
				}
				
				if self.pdfCheckmark.state == .on {
					types.append(.pdf)
				}
				
				if self.sampleCodeCheckmark.state == .on {
					types.append(.sampleCode)
				}
				
				
				self.downloadLinks(for: types)
				
				break
			}
			
        case TabViewID.videoLink.rawValue:
            self.getSubtitleFromVideoLink()
            
        case TabViewID.textFile.rawValue:
            self.getSubtitleFromTexFile()
        default:
            break
        }
        
    }
    
    
	func getSubtitleFromSession(for wwdc: WWDC) {
		
		if session != nil {
			model.clear()
			switch self.session! {
			case .singleSession(let title):
				
				//				let title = "102 _ Platforms State of the Union"
				
				let textArray = title.split(separator: " ")
				let sessionNumber = String(textArray.first!)
				let hdVideoURL = linksModel.hdVideoCacheURLFor(wwdc)
				
				func getSubtitle() {
					let data = try! String(contentsOfFile:hdVideoURL.path, encoding: String.Encoding.utf8)
					var searchString = ""
					if wwdc == .techTalks {
						searchString = "/\(sessionNumber)"
					}
					else {
                        // before 2020: "/sessionNumber/sessionNumber",
                        // after 2020:  "/sessionNumber"
						searchString = "/\(sessionNumber)"
					}
					let hdVideoLinksArray = data.components(separatedBy: "\n").filter { $0.contains(searchString) }
					if let videoLink = hdVideoLinksArray.first {
						if let subtitle = Subtitle(videoURL: videoLink) {
							model.update(subtitle)
						}
					}
					
					DispatchQueue.main.async {
						if !model.isEmpty {
							self.startGetSubtitleOperation(for: wwdc)
						}
						else {
							let error = "Error: No valid video link is imported."
							self.endDownloadingStatus(withError: error)
							self.endDownloadingStatus()
						}

					}
					
					
				}
				
				if FileManager.default.fileExists(atPath: hdVideoURL.path) {
					try? FileManager.default.removeItem(at: hdVideoURL)
				}
				
				self.presenter.getLinks(for: [.video(.hd)], wwdcYear: wwdc, sessionNumber: sessionNumber, copyToUserDestinationURL: false) {
					getSubtitle()
				}

				
			case .allSessions:
				
				let hdVideoURL = linksModel.hdVideoCacheURLFor(wwdc)
				
				func getSubtitles() {
					self.presenter.convertToSubtitle(from: hdVideoURL.path, type: .textFile) { (subtitles) in
						
						DispatchQueue.main.async {
							model.update(subtitles)
							
							if !model.isEmpty {
								self.startGetSubtitleOperation(for: self.selectedWWDC)
							}
							else {
								let error = "Error: No valid video link is imported."
								self.endDownloadingStatus(withError: error)
								self.endDownloadingStatus()
							}
							
						}
					}
				}
				
				if FileManager.default.fileExists(atPath: hdVideoURL.path) {
					try? FileManager.default.removeItem(at: hdVideoURL)
				}

				self.presenter.getLinks(for: [.video(.hd)], wwdcYear: wwdc, copyToUserDestinationURL: false) {
						getSubtitles()
					}

			}
		}
		else {
			let error = "Error: No valid video link is imported."
			self.endDownloadingStatus(withError: error)
			self.endDownloadingStatus()
		}
		

    }
	
	func downloadLinks(for types: [SessionDataTypes]) {
		
		if session != nil {
			switch self.session! {
			case .singleSession(let title):
				
				let textArray = title.split(separator: " ")
				let sessionNumber = String(textArray.first!)
				
				self.getLinks(for: types, wwdcYear: self.selectedWWDC, sessionNumber: sessionNumber, copyToUserDestinationURL: true) {
					
					let userDestinationURL = model.destinationURL!
					
					NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: userDestinationURL.path)
					
				}

				break
			case .allSessions:
				
				var selectedTypes = Set(types)

				let fileManager = FileManager.default

				do {
					
					for type in selectedTypes {
						switch type {
						case let .video(quality):
							let userHdVideoLinksURL = linksModel.userHdVideoLinksURLFor(selectedWWDC)
							let userSdVideoLinksURL = linksModel.userSdVideoLinksURLFor(selectedWWDC)

							let userVideoLinksURL = quality == .hd ? userHdVideoLinksURL : userSdVideoLinksURL
							let videoCacheURL = quality == .hd ? linksModel.hdVideoCacheURLFor(self.selectedWWDC) : linksModel.sdVideoCacheURLFor(self.selectedWWDC)
							
							if fileManager.fileExists(atPath: videoCacheURL.path) {
								try? fileManager.removeItem(at: videoCacheURL)
							}
							
						case .pdf:
							let userPdfLinksURL = linksModel.userPdfLinksURLFor(selectedWWDC)
							let pdfLinksCacheURL = linksModel.pdfLinksCacheURLFor(self.selectedWWDC)
							
							if fileManager.fileExists(atPath: pdfLinksCacheURL.path) {
								try? fileManager.removeItem(at: userPdfLinksURL)
							}
							
						case .sampleCode:
							
							let userSampleCodesLinksURL = linksModel.userSampleCodesLinksURLFor(selectedWWDC)
							let sampleCodesLinksCacheURL = linksModel.sampleCodesLinksCacheURLFor(selectedWWDC)
							
							if fileManager.fileExists(atPath: sampleCodesLinksCacheURL.path) {
								try? fileManager.removeItem(at: userSampleCodesLinksURL)
							}
							
						}
						
					}
					
				}
				catch {
					print(error)
				}
				
				guard !selectedTypes.isEmpty else {
					let userDestinationURL = model.destinationURL!
					
					NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: userDestinationURL.path)

					return
				}
				
				self.getLinks(for: Array(selectedTypes), wwdcYear: self.selectedWWDC, copyToUserDestinationURL: true) {
					
					let userDestinationURL = model.destinationURL!
					
					NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: userDestinationURL.path)

				}
				
				break
				
			}
		}
		else {
			let error = "Error: No valid video link is imported."
			self.endDownloadingStatus(withError: error)
			self.endDownloadingStatus()
		}
	}
	
	func getSubtitlesFromPath(path: String) -> [Subtitle] {
		var subtitles: [Subtitle] = []
		let semaphore = DispatchSemaphore.init(value: 0)
		
		self.presenter.convertToSubtitle(from: path, type: .textFile) { (subs) in
			subtitles = subs
//			model.update(subtitles)
			semaphore.signal()
		}
		
		semaphore.wait()
		return subtitles
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
    
    func startGetSubtitleOperation(for wwdc: WWDC) {
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

        self.presenter.getSubtitles {
            self.endDownloadingStatus()
			
			let userDestinationURL = model.destinationURL!
			
			NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: userDestinationURL.path)

        }
		
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
        let selectedWWDC = WWDC(rawValue: selectedYear)!
        
        guard self.wwdcVideosSubtitlesDic[selectedWWDC] == nil else {
            self.comboBox.reloadData()
            return
        }
        
        let fileName = "WWDC\(selectedYear)_links"
		guard let path = Bundle.main.path(forResource: fileName, ofType: "txt") else { return }
        
        self.presenter.convertToSubtitle(from: path, type: .textFile) { (subtitles) in
            self.wwdcVideosSubtitlesDic[selectedWWDC] = subtitles
            
            DispatchQueue.main.async {
                self.comboBox.reloadData()
            }
        }
		
    }
	
	
	func getSessionsListForSelecteWWDC() {
		
		let wwdcYear = self.popUpButton.selectedItem!.title
		let selectedWWDC = WWDC(rawValue: wwdcYear)!
		
		let titleURL = linksModel.titlesCacheURLFor(selectedWWDC)
		
		let sessionListFileExist = FileManager.default.fileExists(atPath: titleURL.path)
		
		func configureSessionList() {
			DispatchQueue.global().async {
				let data = try! String(contentsOfFile:titleURL.path, encoding: String.Encoding.utf8)
				let sessionsListArray = data.components(separatedBy: "\n")
				self.sessionsListArray = sessionsListArray
				DispatchQueue.main.async {
					self.comboBox.reloadData()
				}
			}
		}
		
		if sessionListFileExist {
			configureSessionList()
			let isUpdated = (self.wwdcsSessionsUpdateStatusDic[selectedWWDC] ?? false)
			guard !isUpdated else { return }
			self.getSessionsList(for: selectedWWDC, inBackground: true, copyToUserDestinationURL: false) {
				configureSessionList()
			}
			
		}
		else {
			
			self.getSessionsList(for: selectedWWDC, inBackground: false, copyToUserDestinationURL: false) {
				configureSessionList()
			}
		}
		
	}
	
	
	func getSessionsList(for wwdcYear: WWDC, inBackground: Bool, copyToUserDestinationURL: Bool, completionHandler: @escaping () -> Void) {
		
		if !inBackground {
			self.getButton.isEnabled = false
			self.comboBox.isEnabled = false
			self.popUpButton.isEnabled = false
			self.circularIndicator.startAnimation(nil)
		}
		
		self.presenter.getSessionsList(for: wwdcYear, copyToUserDestinationURL: copyToUserDestinationURL) {
			self.wwdcsSessionsUpdateStatusDic[wwdcYear] = true
			DispatchQueue.main.async {
				if !inBackground {
					self.getButton.isEnabled = true
					self.comboBox.isEnabled = true
					self.popUpButton.isEnabled = true
					self.circularIndicator.stopAnimation(nil)
				}
				completionHandler()
			}
			
		}
		
	}
	
	func getLinks(for types: [SessionDataTypes], wwdcYear: WWDC, sessionNumber: String? = nil, copyToUserDestinationURL: Bool, completionHandler: @escaping () -> Void) {
		
		self.getButton.isEnabled = false
		self.comboBox.isEnabled = false
		self.popUpButton.isEnabled = false
		self.circularIndicator.startAnimation(nil)
		
		self.presenter.getLinks(for: types, wwdcYear: wwdcYear, sessionNumber: sessionNumber, copyToUserDestinationURL: copyToUserDestinationURL) {
			
			DispatchQueue.main.async {
				self.getButton.isEnabled = true
				self.comboBox.isEnabled = true
				self.popUpButton.isEnabled = true
				self.circularIndicator.stopAnimation(nil)
				completionHandler()
			}
			
		}

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
