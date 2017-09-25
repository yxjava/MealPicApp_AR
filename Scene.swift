//
//  Scene.swift
//  MealPicApp_AR
//
//  Created by Zhongheng Li on 9/24/17.
//  Copyright © 2017 MealPicApp. All rights reserved.
//

import SpriteKit
import ARKit
import Vision

class Scene: SKScene {
    
    
    var isDetected = false

    
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    func createGhostAnchor(){
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
       
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var result = ""
        
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        let hit = nodes(at: location)
        
        
        if let node = hit.first {
            if node.name == "itemName" {
                
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let remove = SKAction.removeFromParent()
                
                // Group the fade out and sound actions
                let groupDismissingActions = SKAction.group([fadeOut])
                // Create an action sequence
                let sequenceAction = SKAction.sequence([groupDismissingActions, remove])
                
                // Excecute the actions
                node.run(sequenceAction)
                
            }
            
            
        }
        
        
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
    
        
        guard let model = try?VNCoreMLModel(for: packagedFood().model ) else {
            
            fatalError("Faild to load CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model){ (request,error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                
                fatalError("Model faild to proccess image")
            }
            
            
            
            if let firstReulst =  results.first{
                
                result = firstReulst.identifier
                
            }
            
        }
        
        
        if isDetected == false {
            
            // Create anchor using the camera's current position
            if let currentFrame = sceneView.session.currentFrame {
                
                
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                
                do {
                    
                    try handler.perform([request])
                }
                catch{
                    
                    print(error)
                }
                
                // Create a transform with a translation of 1.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.2 // Originally this was -1.5
                let transform = simd_mul(currentFrame.camera.transform, translation)
                
                // Add a new anchor to the session
                let anchor = ARAnchor(transform: transform)
                
                // Set the identifier
                ARBridge.shared.anchorsToIdentifiers[anchor] = result //.identifier
                
                
                sceneView.session.add(anchor: anchor)
                
                isDetected = true
                
            }
        }
        else {
            
             isDetected = false
            
        }
        
        
        
        
    }
}
