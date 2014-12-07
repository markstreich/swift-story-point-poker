import UIKit

let host = "http://spp.gllen.com:3000/"

let validUsernameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
let validRoomnameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"

var io: SIOSocket!

class LoginViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtRoomname: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var btnJoin: UIButton!
    
    @IBAction func btnJoinPressed(sender: UIButton) {
        attemptLogin()
    }

    @IBAction func txtUsernameChanged(sender: UITextField) {
        joinFormValidate()
    }
    
    @IBAction func txtRoomnameChanged(sender: UITextField) {
        joinFormValidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtUsername.delegate = self
        
        joinFormValidate()
        self.connectToHost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attemptLogin() {
        var joinRoomname = txtRoomname.text
        if joinRoomname == "" {
            joinRoomname = "public"
        }
        io.emit("join", args: [[
            "username": txtUsername.text,
            "roomname": joinRoomname
            ]])
    }
    
    func joinFormValidate() {
        txtUsername.text = cleanUsername(txtUsername.text)
        txtRoomname.text = cleanRoomname(txtRoomname.text)
        
        if isUsernameValid(txtUsername.text) && isRoomnameValid(txtUsername.text) {
            btnJoin.enabled = true
        } else {
            btnJoin.enabled = false
        }
    }
    
    func isUsernameValid(attemptedUsername: String) -> Bool {
        if countElements(attemptedUsername) < 3 {
            return false
        }
        
        return true
    }
    
    func isRoomnameValid(attemptedRoomname: String) -> Bool {
        if countElements(attemptedRoomname) < 0 {
            return false
        }
        
        return true
    }
    
    func cleanUsername(attemptedUsername: String) -> String {
        
        var charactersToRemove = NSCharacterSet(charactersInString: validUsernameCharacters).invertedSet
        var cleanedUsername = "".join(attemptedUsername.componentsSeparatedByCharactersInSet(charactersToRemove))
        
        if countElements(cleanedUsername) > 12 {
            let validRange = Range(start: cleanedUsername.startIndex, end: advance(cleanedUsername.startIndex,12))
            return cleanedUsername.substringWithRange(validRange)
        }
        
        return cleanedUsername
        
    }
    
    func cleanRoomname(attemptedRoomname: String) -> String {
        
        var charactersToRemove = NSCharacterSet(charactersInString: validRoomnameCharacters).invertedSet
        var cleanedRoomname = "".join(attemptedRoomname.componentsSeparatedByCharactersInSet(charactersToRemove))
        
        if countElements(cleanedRoomname) > 24 {
            let validRange = Range(start: cleanedRoomname.startIndex, end: advance(cleanedRoomname.startIndex,24))
            return cleanedRoomname.substringWithRange(validRange)
        }
        
        return cleanedRoomname
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        attemptLogin()
        return true
    }

    func connectToHost() {
        SIOSocket.socketWithHost(host, reconnectAutomatically: true, attemptLimit: 0, withDelay: 1, maximumDelay: 5, timeout: 20, response: {socket in
            
            io = socket
            
            var chatViewController: ChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as ChatViewController
            
            
            socket.onConnect = {
                // testing: io.emit("join", args: [[ "username": "iostesting", "roomname": "public" ]])
                println("Connected to \(host)")
            }
            
            socket.on("login", callback: {(AnyObject aodata) -> Void in
                // testing: socket.emit("new message", args: ["ssssdfh sdfuhods houdfisgh fdgih dfgi hfgdhi fdghi ofgdhio gf hoifgd hiogdoudfisgh fdgih dfgi hfgdhi fdghi ofgdhio gf hoifgd hiogdoudfisgh fdgih dfgi hfgdhi fdghi ofgdhio gf hoifgd hiogdoudfisgh fdgih dfgi hfgdhi fdghi ofgdhio gf hoifgd hiogdfhio fgdohigdf hoisfh odsfho fsdoh sdfho fsdoh iup"])
                
                dispatch_async(dispatch_get_main_queue(), {
                    println(["login": aodata])
                    
                    if let data = aodata[0] as? NSDictionary {
                        if let roomname = data["roomname"] as? String {
                            chatViewController.roomname = roomname
                            if let username = data["username"] as? String {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(chatViewController, animated: true, completion: nil)
                                })
                            }
                        }
                    }
                    

                })
            })
            
            socket.on("login error", callback: {(AnyObject aodata) -> Void in
                println(["login error": aodata])
                if let data = aodata[0] as? NSDictionary {
                    if let errorMessage = data["message"] as? String {
                        dispatch_async(dispatch_get_main_queue(), {
                            Alert.Warning(self, message: errorMessage)
                        })
                    }
                }
            })
            
            socket.on("new message", callback: {(AnyObject aodata) -> Void in
                println(["new message": aodata])
                if let data = aodata[0] as? NSDictionary {
                    if let message = data["message"] as? String {
                        if let username = data["username"] as? String {
                            dispatch_async(dispatch_get_main_queue(), {
                                messages.append(ChatMessage(username: username, message: message))
                                chatViewController.tableView.reloadData()

                                
                                let delay = 0.1 * Double(NSEC_PER_SEC)
                                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                dispatch_after(time, dispatch_get_main_queue(), {
                                    let offset = CGPoint(x: 0, y: chatViewController.tblRoom.contentSize.height - chatViewController.tblRoom.frame.size.height)
                                    if chatViewController.tblRoom.contentSize.height > chatViewController.tblRoom.frame.size.height {
                                        chatViewController.tblRoom.setContentOffset(offset, animated: false)
                                    }
                                })
                                
                                
                            })
                        }
                    }
                }
            })

            

            
            socket.onDisconnect = {
                println("Disconnected from \(host)")
            }
        })
    }

}



public class Alert: NSObject {
    
    class func Warning(delegate: UIViewController, message: String) {
        var alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        delegate.presentViewController(alert, animated: true, completion: nil)
    }
    
}
