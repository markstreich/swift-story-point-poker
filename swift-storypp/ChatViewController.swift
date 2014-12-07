import UIKit

var messages: [ChatMessage] = [ChatMessage]()

class ChatViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tblRoom: UITableView!
    @IBOutlet weak var lblRoomname: UINavigationItem!
    
    var roomname: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tblRoom.estimatedRowHeight = 40.0
        self.tblRoom.rowHeight = UITableViewAutomaticDimension;
        
        self.lblRoomname.title = self.roomname
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tblRoom.reloadData()
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
    
}
