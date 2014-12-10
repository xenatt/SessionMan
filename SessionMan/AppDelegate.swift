//
//  AppDelegate.swift
//  SessionMan
//
//  Created by Nattapong Pullkhow on 11/28/2557 BE.
//  Copyright (c) 2557 Nattapong Pullkhow. All rights reserved.
//

import Foundation
import Appkit
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow

    @IBAction func setQuite(sender : AnyObject) {
        if (sesPreferencesWindow.visible) {
            sesPreferencesWindow.orderOut(sesPreferencesWindow)
        } else if (ConfirmWindow.visible) {
            ConfirmWindow.orderOut(ConfirmWindow)
            window.orderFront(window)
        } else if (window.visible) {
            NSApplication.sharedApplication().terminate(self)
        }
    }

    @IBAction func forceQuit(sender : AnyObject) {
        doCancel()
        NSApplication.sharedApplication().terminate(self)
    }
    @IBAction func shutDownImageDO(sender : AnyObject) {
        if (withConfirm()) {
            setConfirm("shutdown")
        } else {
            doShutdown()
        }
    }
    @IBOutlet var shutdownIcon : NSButton
    @IBOutlet var restartIcon : NSButton
    @IBOutlet var sleepIcon : NSButton
    @IBOutlet var logoutIcon : NSButton
 
    @IBAction func restartIconDo(sender : AnyObject) {
        if (withConfirm()) {
            setConfirm("restart")
        } else {
            doShutdown()
        }
        
    }
    @IBAction func sleepIconDo(sender : AnyObject) {
        if (withConfirm()) {
            setConfirm("sleep")
        } else {
            doShutdown()
        }
    }
    @IBAction func logoutIconDo(sender : AnyObject) {
        if (withConfirm()) {
            setConfirm("logout")
        } else {
            doShutdown()
        }
    }
    
    //Confirmation window
    
    @IBOutlet var ConfirmWindow : NSPanel
    @IBOutlet var ConfirmActionIcon : NSButton
    @IBOutlet var ConfirmCancleIcon : NSButton
    
    @IBOutlet var ConfirmCountdownTEXT : NSTextField
    
    
    @IBAction func ConfirmActionIconDo(sender : AnyObject) {
        setAction()
    }

    
    @IBAction func ConfirmCancelIconDo(sender : AnyObject) {
        doCancel()
    }
 
    
    @IBOutlet var PrefConfirmCheck : NSButton
    
    @IBAction func PrefConfirmCheckDo(sender : AnyObject) {
        var Config = config()
        Config.setBoolKey("withconfirm", Setting: Config.AnyToBool(PrefConfirmCheck.state))
    }
    

    @IBOutlet var PrefConfirmTimerBox : NSPopUpButton
    
    @IBAction func PrefConfirmTimerBoxDo(sender : AnyObject) {
        var Config = config()
        var tmpBoxVal:Int = PrefConfirmTimerBox.titleOfSelectedItem.toInt()!
        Config.setIntKey("countdowntimer", Setting: tmpBoxVal)
    }
    @IBOutlet var sesPreferencesWindow : NSPanel
    
    
    @IBOutlet var AboutWindow : NSWindow
    @IBOutlet var VersionTEXT : NSTextField
    
    @IBAction func ShowAboutWindow(sender : AnyObject) {
        if(self.ConfirmWindow.visible) {
            doCancel()
        }
        if(!self.AboutWindow.visible) {
            self.AboutWindow.orderFront(AboutWindow)
            VersionTEXT.stringValue = "Version \(Version.Main()) build \(Version.Build())"

        }
    }
    @IBAction func ShowPreferencesWindow(sender : AnyObject) {
        if(!sesPreferencesWindow.visible) {
            sesPreferencesWindow.orderFront(sesPreferencesWindow)
            var Config = config()
            PrefConfirmCheck.state = Config.getIntKey("withconfirm")
                var PrefConfirmTimerConfig : AnyObject = Config.getKey("countdowntimer")
            PrefConfirmTimerBox.setTitle("\(PrefConfirmTimerConfig)")
        }
    }
    
    func doCancel() {
        if(self.ConfirmWindow.visible) {
            actinTimer.invalidate()
            actinTimer == nil
            ConfirmWindow.orderOut(ConfirmWindow)
            if (!self.window.visible) {
                self.window.orderFront(window)
            }

        }
    }

    func setCountDowntext(sender : AnyObject) {
        countText = countText - 1
        ConfirmCountdownTEXT.stringValue = "\(countText)"
        if (!cancleDo && countText <= 0 ) {
            actinTimer.invalidate()
            actinTimer == nil
            setAction()
            NSApplication.sharedApplication().terminate(self)
        }
    }
    

    func doShutdown() {
        if(!cancleDo) {
            var task = NSTask()
            var OSSarg = ["-e","tell application \"System Events\" to shut down"]
            task.launchPath = "/usr/bin/osascript"
            task.arguments = OSSarg
            task.launch()
        }
    }
    
    func doRestart() {
        if(!cancleDo) {
            var task = NSTask()
            var OSSarg = ["-e","tell application \"System Events\" to restart"]
            task.launchPath = "/usr/bin/osascript"
            task.arguments = OSSarg
            task.launch()
        }
    }
    func doLogout() {
        if(!cancleDo) {
            if (self.ConfirmWindow.visible) {
                self.ConfirmWindow.orderOut(ConfirmWindow)
            }
            if (self.window.visible) {
                self.window.orderOut(window)
            }
            var task = NSTask()
            var OSSarg = ["-e","tell application \"System Events\" to log out"]
            task.launchPath = "/usr/bin/osascript"
            task.arguments = OSSarg
            task.launch()
            NSApplication.sharedApplication().terminate(self)
        }
    }
    func doSleep() {
        if(!cancleDo) {
            var task = NSTask()
            var OSSarg = ["-e","tell application \"System Events\" to sleep"]
            task.launchPath = "/usr/bin/osascript"
            task.arguments = OSSarg
            task.launch()
        }
    }
    func withConfirm() ->Bool{
        var confirm:Bool {
        let Config = config()
            if(Config.getBoolKey("withconfirm")) {
                return true
            } else {
                return false
            }
        }
        return confirm
    }
    var sessionAction = String()
    var cancleDo = Bool()
    var countText = Int()


    func setConfirm(sesAction:String) {
        let Config = config()
        if(sesAction == "logout") {
            countText = 10
        } else {
            countText = Config.getIntKey("countdowntimer")
        }
        if(self.window.visible) { self.window.orderOut(window) }
        if(sesAction == "shutdown" || sesAction == "restart" || sesAction == "sleep" || sesAction == "logout") {
                sessionAction = "\(sesAction)"
            if(!self.ConfirmWindow.visible) {
                    ConfirmWindow.orderFront(ConfirmWindow)
                    setCountdown()
                    let actionIcon = NSImage(named: sesAction)
                    ConfirmActionIcon.image = actionIcon
                    ConfirmCountdownTEXT.stringValue = "\(countText)"
            } else if(!withConfirm()) {
                setAction()
            }
        }
    }
    func setAction() {
            if(ConfirmWindow.visible) {
                actinTimer.invalidate()
                actinTimer == nil
                if (self.ConfirmWindow.visible) {
                    self.ConfirmWindow.orderOut(ConfirmWindow)
                }
                if (self.window.visible) {
                   self.window.orderOut(window)
                }
                if(sessionAction == "shutdown") { doShutdown() }
                else if (sessionAction == "restart") { doRestart() }
                else if (sessionAction == "sleep") { doSleep() }
                else if (sessionAction == "logout") { doLogout() }
                NSApplication.sharedApplication().terminate(self)
            }
        }
    
     var actinTimer = NSTimer()
     func setCountdown() {
        if(self.ConfirmWindow.visible) {
            cancleDo = false
            actinTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "setCountDowntext:", userInfo: nil, repeats: true)
        }
    }
    
    class config {
        var UserFolderPath:NSString { return NSHomeDirectory() + "/Library/Application Support/SessionManager/" }
        var UserFilePath:NSString { return "\(UserFolderPath)config.plist" }
        var OriginFilePath:NSString { return NSBundle.mainBundle().pathForResource("config", ofType: "plist") }
        var FManager = NSFileManager.defaultManager()
        var FilePath:NSString {
        if (ExistsConfigFile()) {
            return self.UserFilePath
        } else {
            return self.OriginFilePath
            }
        }
        
        func ExistsConfigFile() ->Bool {
            if (self.FManager.fileExistsAtPath( self.UserFolderPath ) && self.FManager.fileExistsAtPath( self.UserFilePath )) {
                return true
            } else {
                if (!self.FManager.fileExistsAtPath( self.UserFolderPath )) {
                    self.FManager.createDirectoryAtPath(self.UserFolderPath, attributes: nil)
                }
                
                if (!self.FManager.fileExistsAtPath( self.UserFilePath )) {
                    self.FManager.copyItemAtPath(self.OriginFilePath, toPath: self.UserFilePath, error: nil)
                }
                if (self.FManager.fileExistsAtPath( self.UserFolderPath ) && self.FManager.fileExistsAtPath( self.UserFilePath )) {
                    return true
                } else {
                    return false
                }
            }
        }
        
        func listKey() ->NSMutableDictionary {
            var dict = NSMutableDictionary()
            if(ExistsConfigFile()) {
                var allConfigKey:Dictionary = NSDictionary(contentsOfFile: self.FilePath)
                for (key_,val_ : AnyObject) in allConfigKey {
                    dict.setValue(val_, forKey: "\(key_)")
                }
            }
            return dict
        }
        
        func getKey(ConfigKey:NSString) ->AnyObject{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return val_
                }
            }
            return 1
        }
        func getIntKey(ConfigKey:NSString) ->Int{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToInt(val_)
                }
            }
            return 1
        }
        func getStrKey(ConfigKey:NSString) ->String{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToString(val_)
                }
            }
            return "1"
        }
        func getBoolKey(ConfigKey:NSString) ->Bool{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToBool(val_)
                }
            }
            return false
        }
        
        func setKey(ConfigKey:String,Setting:Int) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setIntKey(ConfigKey:String,Setting:Int) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setStrKey(ConfigKey:String,Setting:String) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue("\(Setting)", forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setBoolKey(ConfigKey:String,Setting:Bool) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func AnyToString(Object_:AnyObject)->String {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            return "\(tmpObject_)"
        }
        func AnyToInt(Object_:AnyObject)->Int {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            var tmpObjectInt_:Int = tmpObject_.toInt()!
            return tmpObjectInt_
        }
        func AnyToBool(Object_:AnyObject)->Bool {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            if (tmpObject_ == "true" || tmpObject_ == "1") {
                return true
            }
            return false
        }
    }
    class Version {
        class func Main()->String {
            let version: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]
            return version as String
        }
        class func Build()->String {
            let build: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleVersion"]
            return build as String
        }
    }
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        //window.orderFront(window)
        shutdownIcon.toolTip = "Shut Down Computer"
        restartIcon.toolTip = "Restart Computer"
        sleepIcon.toolTip = "Sleep Computer"
        logoutIcon.toolTip = "LogOut From Session"
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

