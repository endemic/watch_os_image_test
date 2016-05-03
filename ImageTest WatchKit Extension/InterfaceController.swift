//
//  InterfaceController.swift
//  ImageTest WatchKit Extension
//
//  Created by Demick, Nathan on 4/29/16.
//  Copyright © 2016 Demick, Nathan. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class InterfaceController: WKInterfaceController {

    let motionManager = CMMotionManager()

    @IBOutlet var image: WKInterfaceImage!

    var maze: UIImage!
    let imageSize = CGSizeMake(134, 134)
    var position: CGPoint = CGPointMake(50, 50)
    var velocity: CGPoint = CGPointMake(0.5, 0.75)
    var acceleration: CGPoint = CGPointZero
    let objectSize = CGSizeMake(10, 10)
    let speed: CGFloat = 3
    let ball = UIImage.init(named: "ball.png")!
    let block = UIImage.init(named: "block.png")!
    var timer: NSTimer!
    var mazeData: Array<Int> = [
        1,1,1,1,1,1,1,1,1,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,1,0,0,0,0,1,0,1,
        1,0,1,0,0,0,0,1,0,1,
        1,0,1,0,0,0,0,1,0,1,
        1,0,1,0,0,0,0,1,0,1,
        1,0,1,1,1,1,1,1,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,1,1,1,1,1,1,1,1,1
    ]

    // NOTE: 38mm watch width is 272px
    //       42mm watch width is 312px

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        generateMazeImage()
        motionManager.accelerometerUpdateInterval = 0.1
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        let interval:NSTimeInterval = 0.032 // ~30 fps
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "update:", userInfo: nil, repeats: true)


        // Try to get accelerometer data
        if motionManager.accelerometerAvailable {
            let handler: CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                guard let unwrappedData = data else {
                    return
                }

                self.acceleration.x = CGFloat(unwrappedData.acceleration.x)
                self.acceleration.y = CGFloat(unwrappedData.acceleration.y)
            }

            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer.invalidate()
    }

    func generateMazeImage() {
        UIGraphicsBeginImageContext(imageSize)

        for (index, val) in mazeData.enumerate() {
            let mazeSize = Int(sqrt(Double(mazeData.count)))
            let x: CGFloat = CGFloat(index % mazeSize)
            let y: CGFloat = CGFloat(index / mazeSize)

            if val == 1 {
                self.block.drawAtPoint(CGPointMake(x * objectSize.width, y * objectSize.height))
            }
        }

        maze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }

    func update(timer: NSTimer) {
//        let halfWidth = objectSize.width / 2
//        let halfHeight = objectSize.height / 2
        let mazeSize = Int(sqrt(Double(mazeData.count)))

        var xCollision = false
        var yCollision = false


        //        velocity.x += acceleration.x
        //        velocity.y += acceleration.y

        let previousPosition = position

        position.x += velocity.x * speed
        position.y += velocity.y * speed

        for (index, val) in mazeData.enumerate() {
            if val == 0 {
                continue
            }

            let x: CGFloat = CGFloat(index % mazeSize)
            let y: CGFloat = CGFloat(index / mazeSize)

            // AABB collision detection
            if abs(position.x - x) < objectSize.width {
                xCollision = true
            }
            if abs(position.y - y) < objectSize.height {
                yCollision = true
            }
        }

        if xCollision {
            position.x = previousPosition.x
        }

        if yCollision {
            position.y = previousPosition.y
        }

//        if position.x < (0 + halfWidth) || position.x > (imageSize.width - halfWidth) {
//            velocity.x *= -1
//        }
//
//        if position.y < (0 + halfHeight) || position.y > (imageSize.height - halfHeight) {
//            velocity.y *= -1
//        }


        draw()
    }

    func draw() {
        UIGraphicsBeginImageContext(imageSize)
        let offset: CGPoint = CGPointMake(-5, -5)
        ball.drawAtPoint(CGPointMake(position.x + offset.x, position.y + offset.y))
        maze.drawAtPoint(CGPointMake(0, 0))
        image.setImage(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext();
    }
}
