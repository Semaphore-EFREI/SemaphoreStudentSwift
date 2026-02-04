//
//  SignatureResultWindow.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 03/02/2026.
//

import SwiftUI
import Drapeau
import Styles
import Faisceau


struct SignatureResultWindow: ContextWindowProtocol {
    
    // MARK: Attributes
    
    var signature: FaisceauSignature
    
    
    // MARK: View
    
    var body: some View {
        ContextWindow {
            VStack {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            }
            .contextToolbarTitle("")    // Vide pour aligner le bouton
            .contextToolbar {
                ContextToolbarButton(placement: .leading) {
                    DrapButton(icon: "xmark") {
                        print("")
                    }
                    .style(.actionBar)
                }
            }
        } bottomContent: {
            VStack(spacing: 29) {
                Text(message)
                    .multilineTextAlignment(.center)
                    .drapImportantDescription()
                    .foregroundStyle(Color.drapPrimaryText)
                
                DrapButton(title: "OK") {
                    print()
                }
                .drapButtonTint(color)
            }
        }
        .style(.stack)
        .drapButtonExpand()
    }
    
    
    
    // MARK: Methods
    
    var image: String {
        switch signature.status {
        case .absent, .late: "Absent"
        case .none: "Erreur"
        default: "Présent"
        }
    }
    
    var color: Color {
        switch signature.status {
        case .absent: .drapRed
        case .none: .drapBrown
        default: .drapGreen
        }
    }
    
    var message: String {
        switch signature.status {
        case .absent, .late: "Le délai est dépassé"
        case .none: "Une erreur s'est produite"
        default: "C'est tout bon !"
        }
    }
}





#Preview {
    @Previewable @State var show: Bool = false
    @Previewable @StateObject var metrics = ScreenMetrics()
    
    PreviewScaffold(disablePadding: true) {
        GeometryReader { geo in
            let safeInsets = geo.safeAreaInsets
            
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                    .onAppear {
                        metrics.update(from: geo, safeInsets: safeInsets)
                    }
                
                VStack {
                    DrapButton(title: "Afficher") {
                        show = true
                    }
                }
                .topOverlay(show: $show) {
                    SignatureResultWindow(signature: FaisceauSignature())
                        .environmentObject(metrics)
                }
            }
        }
    }
}
