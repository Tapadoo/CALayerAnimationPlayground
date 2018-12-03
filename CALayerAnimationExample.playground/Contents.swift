
import UIKit
import PlaygroundSupport

class LoadingLayer: CALayer {
    
    var tintColor: UIColor? = UIColor.black
    @objc dynamic var percentage: CGFloat = 0
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
 
        if let other = layer as? LoadingLayer {
            self.tintColor = other.tintColor
            self.percentage = other.percentage
        }
        else {
            fatalError()
        }
        
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
        let center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
        
        let radius = (self.bounds.width*0.9)/2.0 //inset slightly
        let fillColor = self.tintColor ?? UIColor.black
        
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setFillColor(fillColor.cgColor)
        
        ctx.beginPath()
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: -.pi/2.0)
        
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addArc(center: CGPoint(x: 0, y: 0),
                   radius: radius,
                   startAngle: 0,
                   endAngle: (2*CGFloat.pi)*self.percentage,
                   clockwise: false)
        
        ctx.closePath()
        
        ctx.drawPath(using: .fill)
    }
    
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(LoadingLayer.percentage) {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        
        if event == #keyPath(LoadingLayer.percentage) {
            let anim = CABasicAnimation(keyPath: #keyPath(LoadingLayer.percentage))
            anim.byValue = 0.01
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.fromValue = presentation()?.percentage ?? 0
            return anim
        }
        return super.action(forKey: event)
    }
}

class LoadingView: UIView {
    override class var layerClass: AnyClass {
        return LoadingLayer.self
    }
    
    private var loadingLayer: LoadingLayer {
        return self.layer as! LoadingLayer
    }

    var percentage: CGFloat {
        get {
            return loadingLayer.percentage
        }
        set {
            var safeVal = max(0,newValue)
            safeVal = safeVal.truncatingRemainder(dividingBy: 1.0)
            loadingLayer.percentage = safeVal
            loadingLayer.setNeedsDisplay()
        }
    }
    
    override func tintColorDidChange() {
        loadingLayer.tintColor = self.tintColor
        loadingLayer.setNeedsDisplay()
    }
    
    private(set) var spinning: Bool = false
    
    func spin() {
        let anim = CABasicAnimation(keyPath: #keyPath(LoadingLayer.percentage))
        anim.fromValue = 0
        anim.toValue =  1.0
        anim.byValue = 0.01
        anim.duration = 2.0
        anim.repeatCount = MAXFLOAT
        
        loadingLayer.add(anim, forKey: "spin")
        spinning = true
    }
    
    func stop() {
        
        if let currentVal = loadingLayer.presentation()?.percentage {
            //Lets set the current val to the value of the layer shown during the animation - better than leaving the animation set to fill
            loadingLayer.percentage = currentVal
        }
        
        loadingLayer.removeAnimation(forKey: "spin")
        spinning = false
    }
    
}

class MyViewController : UIViewController {
    
    var loadingView: LoadingView!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: .zero)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.layer.cornerRadius = 10
        self.view.addSubview(loadingView)
        loadingView.backgroundColor = UIColor.darkGray
        loadingView.tintColor = UIColor.red
        
        loadingView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        loadingView.percentage = 0.12
        
        let incButton = UIButton(type: .custom)
        incButton.translatesAutoresizingMaskIntoConstraints = false
        incButton.setTitle("Increment", for: .normal)
        incButton.backgroundColor = UIColor.darkGray
        self.view.addSubview(incButton)
        
        incButton.widthAnchor.constraint(equalTo: loadingView.widthAnchor).isActive = true
        incButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        incButton.topAnchor.constraint(equalToSystemSpacingBelow: loadingView.bottomAnchor, multiplier: 1.0).isActive = true
        
        incButton.addTarget(self, action: #selector(incClicked), for: .touchUpInside)
        
        let spinButton = UIButton(type: .custom)
        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.setTitle("Spin", for: .normal)
        spinButton.backgroundColor = UIColor.darkGray
        self.view.addSubview(spinButton)
        
        spinButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        spinButton.topAnchor.constraint(equalToSystemSpacingBelow: incButton.bottomAnchor, multiplier: 1.0).isActive = true
        
        spinButton.addTarget(self, action: #selector(spinClicked), for: .touchUpInside)
        spinButton.widthAnchor.constraint(equalTo: incButton.widthAnchor).isActive = true
    }
    
    @objc func incClicked() {
        loadingView.percentage += 0.1
        if (loadingView.percentage >= 1.0) {
            loadingView.percentage = 0
        }
    }
    
    @objc func spinClicked() {
        if (!loadingView.spinning) {
            loadingView.spin()
        }
        else {
            loadingView.stop()
        }
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
