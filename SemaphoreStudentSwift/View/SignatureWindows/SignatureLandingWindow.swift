//
//  SignatureWindow.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 03/02/2026.
//

import SwiftUI
import Drapeau
import Styles


struct SignatureLandingWindow: ContextWindowProtocol {
    var body: some View {
        ContextWindow {
            VStack {
                Image("iPhone sur Balise")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
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
                Text("Appuyez sur \"Scanner la balise\" et collez votre appareil sur celle-ci")
                    .multilineTextAlignment(.center)
                    .drapDescription()
                    .foregroundStyle(Color.drapPrimaryText)
                
                DrapButton(icon: "wave.3.forward", title: "Scanner la balise") {
                    print()
                }
            }
        }
        .style(.stack)
        .drapButtonExpand()
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
                    SignatureLandingWindow()
                        .environmentObject(metrics)
                }
            }
        }
    }
}
