import UIKit

extension UIView {
    
    func viewOrigin() -> CGPoint {
        return self.frame.origin
    }
    
    func setViewOrigin(newOrigin: CGPoint) {
        var newFrame = self.frame
        newFrame.origin = newOrigin
        self.frame = newFrame
    }
    
    func viewSize() -> CGSize {
        return self.frame.size
    }
    
    func setViewSize(newSize: CGSize) {
        var newFrame = self.frame
        newFrame.size = newSize
        self.frame = newFrame
    }
    
    func x() -> CGFloat {
        return self.frame.origin.x
    }
    
    func setX(newX: CGFloat) {
        var newFrame = self.frame
        newFrame.origin.x = newX
        self.frame = newFrame
    }
    
    func y() -> CGFloat {
        return self.frame.origin.y
    }
    
    func setY(newY: CGFloat) {
        var newFrame = self.frame
        newFrame.origin.y = newY
        self.frame = newFrame
    }
    
    func height() -> CGFloat {
        return self.frame.size.height
    }
    
    func setHeight(newHeight: CGFloat) {
        var newFrame = self.frame
        newFrame.size.height = newHeight
        self.frame = newFrame
    }
    
    func width() -> CGFloat {
        return self.frame.size.width
    }
    
    func setWidth(newWidth: CGFloat) {
        var newFrame = self.frame
        newFrame.size.width = newWidth
        self.frame = newFrame
    }
    
    func left() -> CGFloat {
        return self.frame.origin.x
    }
    
    func setLeft(left: CGFloat) {
        self.setX(newX: left)
    }
    
    func right() -> CGFloat {
        return self.frame.origin.x + self.frame.size.width
    }
    
    func setRight(right: CGFloat) {
        self.setX(newX: right - self.width())
    }
    
    func top() -> CGFloat {
        return self.y()
    }
    
    func setTop(top: CGFloat) {
        self.setY(newY: top)
    }
    
    func bottom() -> CGFloat {
        return self.y() + self.frame.size.height
    }
    
    func centerr() -> CGPoint {
        return CGPoint(x: self.left() + self.middleX(), y: self.top() + self.middleY())
    }
    
    func setCenter(newCenter: CGPoint) {
        self.setLeft(left: newCenter.x - self.middleX())
        self.setTop(top: newCenter.y - self.middleY())
    }
    
    func middlePoint() -> CGPoint {
        return CGPoint(x: self.middleX(), y: self.middleY())
    }
    
    func middleX() -> CGFloat {
        return self.width()/2
    }
    
    func middleY() -> CGFloat {
        return self.height()/2
    }
    
}
