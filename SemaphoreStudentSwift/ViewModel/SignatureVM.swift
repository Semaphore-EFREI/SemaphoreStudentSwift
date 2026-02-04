//
//  SignatureVM.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 03/02/2026.
//

import Foundation
import SwiftUI
import UIKit
import Drapeau
import CoreImage



struct Line {
    var points = [CGPoint]()
    var color = Color.black
    var lineWidth: Double = 4
}



@MainActor
@Observable
class SignatureVM {
    
    // MARK: Attributs
    
    var image: SignatureImage
    var lines: [Line] = []
    var currentLine = Line()
    var signatureApparentSize: SignatureSize = .moyenne
    
    
    // MARK: Init
    
    init(signatureImage: SignatureImage) {
        self.image = signatureImage
    }
    
    
    func configurationEnvironmentObject(tailleÉcran: ScreenMetrics) {
        self.réinitialiserCanva()
        
        let largeur = tailleÉcran.width
        if largeur > 400 {
            self.signatureApparentSize = .moyenne
        } else {
            self.signatureApparentSize = .petite
        }
        
        self.image.tailleSignatureEnCGSize = obtenirTailleSignatureEnCGSize()
    }
    
    
    
    
    // MARK: Méthodes
    
    func réinitialiserCanva() {
        self.lines = []
    }
    
    
    func générerImageSignature() async {
        let largeur: CGFloat = 640
        let hauteur: CGFloat = 480
        
        self.image.image = renderLinesImage()
    }
    
    
    func renderLinesImage(outputSize: CGSize = CGSize(width: 640, height: 480), background: UIColor = .clear) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1                    // pixels exacts: 640x480
        format.opaque = (background != .clear)

        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)

        return renderer.image { ctx in
            let cg = ctx.cgContext

            // Fond
            cg.setFillColor(background.cgColor)
            cg.fill(CGRect(origin: .zero, size: outputSize))

            // Transform: repère canvas -> repère output (640x480)
            let canvasSize = obtenirTailleSignatureEnCGSize()
            let sx = outputSize.width  / max(canvasSize.width,  1)
            let sy = outputSize.height / max(canvasSize.height, 1)

            cg.saveGState()
            cg.scaleBy(x: sx, y: sy)

            // Qualité
            cg.setAllowsAntialiasing(true)
            cg.setShouldAntialias(true)
            cg.setLineCap(.round)
            cg.setLineJoin(.round)

            for line in lines {
                guard line.points.count >= 2 else { continue }

                cg.beginPath()
                cg.move(to: line.points[0])
                for p in line.points.dropFirst() {
                    cg.addLine(to: p)
                }

                // SwiftUI Color -> UIColor -> CGColor
                let uiColor = UIColor(line.color)
                cg.setStrokeColor(uiColor.cgColor)

                // Attention: comme on scale le contexte, l'épaisseur doit rester cohérente.
                // Ici, on dessine en "unités canvas", donc on garde lineWidth tel quel.
                cg.setLineWidth(CGFloat(line.lineWidth))

                cg.strokePath()
            }

            cg.restoreGState()
        }
    }
    
    
    private func créerChemin(from points: [CGPoint]) -> Path {
        var chemin = Path()
        
        if let premierPoint = points.first {
            chemin.move(to: premierPoint)
            for point in points.dropFirst() {
                chemin.addLine(to: point)
            }
        }
        
        return chemin
    }
    
    
    private func obtenirTailleSignatureEnCGSize() -> CGSize {
        switch self.signatureApparentSize {
        case .petite: return CGSize(width: 256, height: 192)
        case .moyenne: return CGSize(width: 320, height: 240)
        }
    }
}




enum SignatureSize {
    case petite, moyenne
}



@Observable
class SignatureImage {
    var image: UIImage?
    var tailleSignatureEnCGSize: CGSize = .zero
}
