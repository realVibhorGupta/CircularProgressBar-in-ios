//
//  ViewController.swift
//  CircularProgressBarFeature
//
//  Created by Vibhor Gupta on 3/25/18.
//  Copyright © 2018 Vibhor Gupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,URLSessionDownloadDelegate {

    var shapeLayer : CAShapeLayer!
    let urlString  = "https://unsplash.com/photos/kbkyZAfSuFs/download?force=true"

    var pulsatingLayer : CAShapeLayer!
    let percentageLabel : UILabel  = {

        let label  = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 34)

        label.textColor = .white
        return label
    }()
    //for light status bar
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    private func createCircleShape(strokeColor : UIColor , fillColor : UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath  = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0  , endAngle:2 * CGFloat.pi, clockwise: true)

        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 10
        layer.fillColor = fillColor.cgColor

        layer.lineCap = kCALineCapRound
        layer.position = view.center
        return layer
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNotificationObservers()


        view.backgroundColor = UIColor.backgroundColor



        // Do any additional setup after loading the view, typically from a nib.
//        let circularPath  = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0  , endAngle:2 * CGFloat.pi, clockwise: true)

        pulsatingLayer = createCircleShape(strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        //track
        let trackLayer = createCircleShape(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)

        view.layer.addSublayer(trackLayer)

        //Circle

        shapeLayer = createCircleShape(strokeColor: .outlineStrikeColor, fillColor: .clear)

        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2 , 0, 0, 1)
        view.layer.addSublayer(shapeLayer)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center



    }

    private func setUpNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    @objc private func handleEnterForeground(){
        animatePulsatingLayer()
    }
    //Animate about
    @objc private  func  animatePulsatingLayer(){

        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.5
        animation.duration = 0.6
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity

        pulsatingLayer.add(animation, forKey: "animatePulsatingLayer")


    }

    //Animate main Circle
    fileprivate func animateCircle() {
        let roundAnimation = CABasicAnimation(keyPath:"strokeEnd")
        roundAnimation.toValue = 1
        roundAnimation.duration = 2
        roundAnimation.fillMode = kCAFillModeForwards
        roundAnimation.isRemovedOnCompletion = false
        shapeLayer.add(roundAnimation, forKey:"roundAnimation" )
    }

    @objc private func handleTap(){

        handleDownloadingFile()
        // animateCircle()
    }


    private func handleDownloadingFile(){
        print("Downloading File")
        shapeLayer.strokeEnd = 0
        let urlConfiguration = URLSessionConfiguration.default

        let operationQueue = OperationQueue()
        let urlSession =  URLSession(configuration: urlConfiguration, delegate: self, delegateQueue: operationQueue)

        guard let url = URL(string : urlString) else {
            return
        }

        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()

    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("finished Downloading")
    }


    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print(totalBytesWritten,totalBytesExpectedToWrite)

        let percentage  = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)


        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage

        }
        print(percentage)
    }
}

