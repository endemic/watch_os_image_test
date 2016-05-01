//
//  InterfaceController.swift
//  ImageTest WatchKit Extension
//
//  Created by Demick, Nathan on 4/29/16.
//  Copyright © 2016 Demick, Nathan. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var image: WKInterfaceImage!

    var maze: UIImage!
    let imageSize = CGSizeMake(100, 100)
    var position: CGPoint = CGPointMake(50, 50)
    var velocity: CGPoint = CGPointMake(0.5, 0.75)
    let speed: CGFloat = 3
    let ball = UIImage.init(named: "ball.png")!
    let block = UIImage.init(named: "block.png")!
    var timer: NSTimer!
    var mazeData: Array<Int> = [
        1,1,1,1,1,1,1,1,1,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,0,1,1,0,0,0,0,0,1,
        1,0,0,0,0,0,0,0,0,1,
        1,1,1,1,1,1,1,1,1,1
    ]

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        generateMazeImage()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        let interval:NSTimeInterval = 0.05
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "update:", userInfo: nil, repeats: true)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer.invalidate()
    }

    func generateMazeImage() {
        UIGraphicsBeginImageContext(imageSize)

        let blockSize = CGSizeMake(10, 10)

        for (index, val) in mazeData.enumerate() {
            let x: CGFloat = CGFloat(index % 10)
            let y: CGFloat = CGFloat(index / 10)

            if val == 1 {
                self.block.drawAtPoint(CGPointMake(x * blockSize.width, y * blockSize.height))
            }
        }

        maze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }

    func update(timer: NSTimer) {
        let halfWidth: CGFloat = 16
        let halfHeight: CGFloat = 16

        if position.x < (0 + halfWidth) || position.x > (100 - halfWidth) {
            velocity.x *= -1
        }

        if position.y < (0 + halfHeight) || position.y > (100 - halfHeight) {
            velocity.y *= -1
        }

        position.x += velocity.x * speed
        position.y += velocity.y * speed

        draw()
    }

    func draw() {
        UIGraphicsBeginImageContext(imageSize)
        let offset: CGPoint = CGPointMake(-16, -16)
        ball.drawAtPoint(CGPointMake(position.x + offset.x, position.y + offset.y))
        maze.drawAtPoint(CGPointMake(0, 0))
        image.setImage(UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext();
    }
}
