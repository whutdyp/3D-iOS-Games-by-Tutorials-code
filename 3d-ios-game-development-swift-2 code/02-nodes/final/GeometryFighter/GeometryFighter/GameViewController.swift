/*
 * Copyright (c) 2015 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SceneKit

class GameViewController: UIViewController {

  var scnView: SCNView!
  var scnScene: SCNScene!
  var cameraNode: SCNNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupScene()
    setupCamera()
    spawnShape()
  }

  override func shouldAutorotate() -> Bool {
    return true
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  func setupView() {
    scnView = self.view as! SCNView
    
    // 1
    scnView.showsStatistics = true
    // 2
    scnView.allowsCameraControl = true
    // 3
    scnView.autoenablesDefaultLighting = true
    
  }
  
  func setupScene() {
    scnScene = SCNScene()
    scnView.scene = scnScene
    scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
  }
  
  func setupCamera() {
    // 1
    cameraNode = SCNNode()
    // 2
    cameraNode.camera = SCNCamera()
    // 3
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
    // 4
    scnScene.rootNode.addChildNode(cameraNode)
  }
  
  func spawnShape() {
    // 1
    var geometry:SCNGeometry
    // 2
    switch ShapeType.random() {
    default:
      // 3
      geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
    }  
    // 4
    let geometryNode = SCNNode(geometry: geometry)
    // 5
    scnScene.rootNode.addChildNode(geometryNode)
  }
  
}
