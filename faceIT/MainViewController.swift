//
//  ViewController.swift
//  faceIT
//
//  Created by Michael Ruhl on 07.07.17.
//  Copyright © 2017 NovaTec GmbH. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

import RxSwift
import RxCocoa
import Async
import PKHUD

class MainViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var bottomLabel: UILabel!
    var 👜 = DisposeBag()
    
    var faces: [Face] = []
    var visibleFaces = 0
            
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    let model: VNCoreMLModel = try! VNCoreMLModel(for: faces_model().model)
    
    let data = Dataset()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        bounds = sceneView.bounds
        bottomLabel.text = "ToDo for Today: \n1. 2pm meeting at Hall \n2. 9pm General Assembly"
        bottomLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        Observable<Int>.interval(0.6, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .concatMap{ _ in  self.faceObservation() }
            .flatMap{ Observable.from($0)}
            .flatMap{ self.faceClassification(face: $0.observation, image: $0.image, frame: $0.frame) }
            .subscribe { [unowned self] event in
                guard let element = event.element else {
                    print("No element available")
                    return
                }
                self.updateNode(classes: element.classes, position: element.position, frame: element.frame)
            }.disposed(by: 👜)
        
        
        Observable<Int>.interval(1.0, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .subscribe { [unowned self] _ in
                
                self.faces.filter{ $0.updated.isAfter(seconds: 1.5) && !$0.hidden }.forEach{ face in
                    print("Hide node: \(face.name)")
                    Async.main { self.hideFace(face: face)}
                }
            }.disposed(by: 👜)
    }
    
    func hideFace(face: Face) {
        if face.hidden {
            return
        }
        face.node.hide()
        if self.visibleFaces == 0 {
            self.bottomLabel.isHidden = true
        }
    }
    
    func showFace(face: Face) {
        if !face.hidden {
            return
        }
        face.node.show()
        self.visibleFaces += 1
        if self.visibleFaces > 0 {
            self.bottomLabel.isHidden = false
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

        switch camera.trackingState {
        case .limited(.initializing):
            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: "Initializing", subtitle: nil)
            PKHUD.sharedHUD.show()
        case .notAvailable:
            print("Not available")
        default:
            PKHUD.sharedHUD.hide()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        👜 = DisposeBag()
        sceneView.session.pause()
    }
    
    // MARK: - Face detections
    
    private func faceObservation() -> Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]> {
        return Observable<[(observation: VNFaceObservation, image: CIImage, frame: ARFrame)]>.create{ observer in
            guard let frame = self.sceneView.session.currentFrame else {
                print("No frame available")
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Verify tracking state and abort
//            guard case .normal = frame.camera.trackingState else {
//                print("Tracking not available: \(frame.camera.trackingState)")
//                observer.onCompleted()
//                return Disposables.create()
//            }
            
            // Create and rotate image
            let image = CIImage.init(cvPixelBuffer: frame.capturedImage).rotate
            
            let facesRequest = VNDetectFaceRectanglesRequest { request, error in
                guard error == nil else {
                    print("Face request error: \(error!.localizedDescription)")
                    observer.onCompleted()
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation] else {
                    print("No face observations")
                    observer.onCompleted()
                    return
                }
                
                // Map response
                let response = observations.map({ (face) -> (observation: VNFaceObservation, image: CIImage, frame: ARFrame) in
                    return (observation: face, image: image, frame: frame)
                })
                observer.onNext(response)
                observer.onCompleted()
                
            }
            try? VNImageRequestHandler(ciImage: image).perform([facesRequest])
            
            return Disposables.create()
        }
    }
    
    private func faceClassification(face: VNFaceObservation, image: CIImage, frame: ARFrame) -> Observable<(classes: [VNCoreMLFeatureValueObservation], position: SCNVector3, frame: ARFrame)> {
        return Observable<(classes: [VNCoreMLFeatureValueObservation], position: SCNVector3, frame: ARFrame)>.create{ observer in
            
            // Determine position of the face
            let boundingBox = self.transformBoundingBox(face.boundingBox)
            guard let worldCoord = self.normalizeWorldCoord(boundingBox) else {
                print("No feature point found")
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Create Classification request
            let request = VNCoreMLRequest(model: self.model, completionHandler: { request, error in
                guard error == nil else {
                    print("ML request error: \(error!.localizedDescription)")
                    observer.onCompleted()
                    return
                }
                
                guard let classifications = request.results as? [VNCoreMLFeatureValueObservation] else {
                    print("No classifications")
                    observer.onCompleted()
                    return
                }
//                VNClassificationObservation
                observer.onNext(classes: classifications, position: worldCoord, frame: frame)
                observer.onCompleted()
            })
            request.imageCropAndScaleOption = .scaleFit
            
            do {
                let pixel = image.cropImage(toFace: face)
                try VNImageRequestHandler(ciImage: pixel, options: [:]).perform([request])
            } catch {
                print("ML request handler error: \(error.localizedDescription)")
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func updateNode(classes: [VNCoreMLFeatureValueObservation], position: SCNVector3, frame: ARFrame) {
        
        guard let observation = classes.first else {
            print("No classification found")
            return
        }
        
        if observation.confidence < 0.60 {
            print("not so sure")
            return
        }
        guard let name = data.find_closest(observation: observation) else {
            print("not sure")
            return
        }
        
        print("""
            observation: \(name)
            """ )
        
        self.faces.filter({ !$0.hidden}).forEach({face in hideFace(face: face)})
        // Filter for existent face
        let results = self.faces.filter{ $0.name == name && $0.timestamp != frame.timestamp}
            .sorted{ $0.node.position.distance(toVector: position) < $1.node.position.distance(toVector: position) }
        
        // Create new face
        guard let existentFace = results.first else {
            let node = SCNNode.init(withText: name, position: position)
            
            Async.main {
                self.sceneView.scene.rootNode.addChildNode(node)
//                showFace(face: <#T##Face#>)
                node.show()
                self.visibleFaces += 1
                self.bottomLabel.isHidden = false
                
            }
            let face = Face.init(name: name, node: node, timestamp: frame.timestamp)
            self.faces.append(face)
            return
        }
        
        // Update existent face
        Async.main {
            
            // Filter for face that's already displayed
            if let displayFace = results.filter({ !$0.hidden }).first  {
                
                let distance = displayFace.node.position.distance(toVector: position)
                if(distance >= 0.15 ) {
                    displayFace.node.move(position)
                }
                displayFace.timestamp = frame.timestamp
                
            } else {
                existentFace.node.position = position
                self.showFace(face: existentFace)
                existentFace.timestamp = frame.timestamp
            }
        }
    }

    /// In order to get stable vectors, we determine multiple coordinates within an interval.
    ///
    /// - Parameters:
    ///   - boundingBox: Rect of the face on the screen
    /// - Returns: the normalized vector
    private func normalizeWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        
        var array: [SCNVector3] = []
        Array(0...2).forEach{_ in
            if let position = determineWorldCoord(boundingBox) {
                array.append(position)
            }
            usleep(12000) // .012 seconds
        }

        if array.isEmpty {
            return nil
        }
        
        return SCNVector3.center(array)
    }
    
    
    /// Determine the vector from the position on the screen.
    ///
    /// - Parameter boundingBox: Rect of the face on the screen
    /// - Returns: the vector in the sceneView
    private func determineWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        let arHitTestResults = sceneView.hitTest(CGPoint(x: boundingBox.midX, y: boundingBox.midY), types: [.featurePoint])
        
        // Filter results that are to close
        if let closestResult = arHitTestResults.filter({ $0.distance > 0.10 }).first {
//            print("vector distance: \(closestResult.distance)")
            return SCNVector3.positionFromTransform(closestResult.worldTransform)
        }
        return nil
    }
    
    
    /// Transform bounding box according to device orientation
    ///
    /// - Parameter boundingBox: of the face
    /// - Returns: transformed bounding box
    private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
        var size: CGSize
        var origin: CGPoint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            size = CGSize(width: boundingBox.width * bounds.height,
                          height: boundingBox.height * bounds.width)
        default:
            size = CGSize(width: boundingBox.width * bounds.width,
                          height: boundingBox.height * bounds.height)
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            origin = CGPoint(x: boundingBox.minY * bounds.width,
                             y: boundingBox.minX * bounds.height)
        case .landscapeRight:
            origin = CGPoint(x: (1 - boundingBox.maxY) * bounds.width,
                             y: (1 - boundingBox.maxX) * bounds.height)
        case .portraitUpsideDown:
            origin = CGPoint(x: (1 - boundingBox.maxX) * bounds.width,
                             y: boundingBox.minY * bounds.height)
        default:
            origin = CGPoint(x: boundingBox.minX * bounds.width,
                             y: (1 - boundingBox.maxY) * bounds.height)
        }
        
        return CGRect(origin: origin, size: size)
    }
}
