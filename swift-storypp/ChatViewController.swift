import UIKit

var messages: [ChatMessage] = [ChatMessage]()

class ChatViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tblRoom: UITableView!
    
    @IBOutlet weak var lblRoomname: UINavigationItem!
    
    var keyboardSize: CGSize!
    
    var roomname: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tblRoom.estimatedRowHeight = 40.0
        self.tblRoom.rowHeight = UITableViewAutomaticDimension;
     
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)

        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ChatMessageCell = tableView.dequeueReusableCellWithIdentifier("Cell") as ChatMessageCell

        var message = messages[indexPath.row];
        
        // format username color/bold
        var mtlMessage = NSMutableAttributedString()
        mtlMessage = NSMutableAttributedString(string: message.username + "  " + message.message, attributes: nil)
        mtlMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location:0,length:countElements(message.username)))
        mtlMessage.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(18.0), range: NSRange(location:0,length:countElements(message.username)))
        
        // word wrap
        cell.lblMessage.numberOfLines = 0
        cell.lblMessage.attributedText = mtlMessage

        return cell
    }
    
    
    func setRoomname(roomname: String) {
        self.roomname = roomname
        self.lblRoomname.title = roomname
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let info: Dictionary = notification.userInfo!
        if let aValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            keyboardSize = aValue.CGRectValue().size
        }
        println(keyboardSize.height + tblRoom.contentInset.bottom)
        var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(tblRoom.contentInset.top, tblRoom.contentInset.left, (keyboardSize.height + tblRoom.contentInset.bottom), tblRoom.contentInset.right)
        tblRoom.con
        
        let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)
        let isLandscape = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
        
        if isPortrait {
            println("Device is in PORTRAIT orientation and the keyboard size is \(keyboardSize.height)")
        } else if isLandscape {
            println("Device is in LANDSCAPE orientation and the keyboard size is \(keyboardSize.height)")
        }
    }
    
}
