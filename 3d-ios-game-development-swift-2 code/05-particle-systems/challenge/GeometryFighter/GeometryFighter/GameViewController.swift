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
  var spawnTime:NSTimeInterval = 0
  var game = GameHelper.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupScene()
    setupCamera()
    setupHUD()
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
    scnView.allowsCameraControl = false
    // 3
    scnView.autoenablesDefaultLighting = true
    
    scnView.delegate = self
    scnView.playing = true
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
    cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
    // 4
    scnScene.rootNode.addChildNode(cameraNode)
  }
  
  func spawnShape() {
    // 1
    var geometry:SCNGeometry
    // 2
    switch ShapeType.random() {
    case .Box:
      geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
    case .Sphere:
      geometry = SCNSphere(radius: 0.5)
    case .Pyramid:
      geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
    case .Torus:
      geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
    case .Capsule:
      geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
    case .Cylinder:
      geometry = SCNCylinder(radius: 0.3, height: 2.5)
    case .Cone:
      geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
    case .Tube:
      geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
    }
    let color = UIColor.random()
    geometry.materials.first?.diffuse.contents = color
    
    // 4
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
    
    // 1
    let randomX = Float.random(min: -2, max: 2)
    let randomY = Float.random(min: 10, max: 18)
    // 2
    let force = SCNVector3(x: randomX, y: randomY , z: 0)
    // 3
    let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
    // 4
    geometryNode.physicsBody?.applyForce(force, atPosition: position, impulse: true)
    
    let trailEmitter = createTrail(color, geometry: geometry)
    geometryNode.addParticleSystem(trailEmitter)
    
    if color == UIColor.blackColor() {
      geometryNode.name = "BAD"
    } else {
      geometryNode.name = "GOOD"
    }
    
    // 5
    scnScene.rootNode.addChildNode(geometryNode)
  }
  
  func cleanScene() {
    // 1
    for node in scnScene.rootNode.childNodes {
      // 2
      if node.presentationNode.position.y < -2 {
        // 3
        node.removeFromParentNode()
      }
    }
  }
  
  // 1
  func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
    // 2
    let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
    // 3
    trail.particleColor = color
    // 4
    trail.emitterShape = geometry
    // 5
    return trail
  }
  
  func setupHUD() {
    game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
    scnScene.rootNode.addChildNode(game.hudNode)
  }
  
  func handleTouchFor(node: SCNNode) {
    if node.name == "GOOD" {
      game.score += 1
      createExplosion(node.geometry!, position: node.presentationNode.position,
        rotation: node.presentationNode.rotation)
      node.removeFromParentNode()
    } else if node.name == "BAD" {
      game.lives -= 1
      createExplosion(node.geometry!, position: node.presentationNode.position,
        rotation: node.presentationNode.rotation)
      node.removeFromParentNode()
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // 1
    let touch = touches.first!
    // 2
    let location = touch.locationInView(scnView)
    // 3
    let hitResults = scnView.hitTest(location, options: nil)
    // 4
    if hitResults.count > 0 {
      // 5
      let result = hitResults.first!
      // 6
      handleTouchFor(result.node)
    }
  }
  
  // 1
  func createExplosion(geometry: SCNGeometry, position: SCNVector3,
    rotation: SCNVector4) {
      // 2
      let explosion =
      SCNParticleSystem(named: "Explode.scnp", inDirectory:
        nil)!
      explosion.emitterShape = geometry
      explosion.birthLocation = .Surface
      // 3
      let rotationMatrix =
      SCNMatrix4MakeRotation(rotation.w, rotation.x,
        rotation.y, rotation.z)
      let translationMatrix =
      SCNMatrix4MakeTranslation(position.x, position.y, position.z)
      let transformMatrix =
      SCNMatrix4Mult(rotationMatrix, translationMatrix)
      // 4
      scnScene.addParticleSystem(explosion, withTransform: transformMatrix)
  }
}

// 1
extension GameViewController: SCNSceneRendererDelegate {
  // 2
  func renderer(renderer: SCNSceneRenderer, updateAtTime time:
    NSTimeInterval) {
      // 1
      if time > spawnTime {
        spawnShape()
        // 2
        spawnTime = time + NSTimeInterval(Float.random(min: 0.2, max: 1.5))
      }
      cleanScene()
      game.updateHUD()
  }
}
