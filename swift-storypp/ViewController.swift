import UIKit

let host = "http://spp.gllen.com:3000/"
var io: SIOSocket!

class ViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var btnJoin: UIButton!
    
    @IBAction func btnJoinPressed(sender: UIButton) {
        attemptLogin()
    }
    

    @IBAction func txtUsernameChanged(sender: UITextField) {
        usernameEntryValidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtUsername.delegate = self
        
        usernameEntryValidate()
        self.connectToHost()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attemptLogin() {
        io.emit("add user", args: [txtUsername.text])
    }
    
    func usernameEntryValidate() {
        txtUsername.text = cleanUsername(txtUsername.text)
        
        if isUsernameValid(txtUsername.text) {
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
    
    func cleanUsername(attemptedUsername: String) -> String {

        var charactersToRemove = NSCharacterSet.alphanumericCharacterSet().invertedSet
        var cleanedUsername = "".join(attemptedUsername.componentsSeparatedByCharactersInSet(charactersToRemove))
        
        if countElements(attemptedUsername) > 12 {
            let validRange = Range(start: cleanedUsername.startIndex, end: advance(cleanedUsername.startIndex,12))
            return cleanedUsername.substringWithRange(validRange)
        }
        
        return cleanedUsername

    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        attemptLogin()
        return true
    }

    func connectToHost() {
        SIOSocket.socketWithHost(host, reconnectAutomatically: true, attemptLimit: 0, withDelay: 1, maximumDelay: 5, timeout: 20, response: {socket in
            
            io = socket
            
            socket.onConnect = {
                println("Connected to \(host)")
            }
            
            socket.on("login", callback: {(AnyObject data) -> Void in
                println(["login": data])
                socket.emit("new message", args: ["sssup"])
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
