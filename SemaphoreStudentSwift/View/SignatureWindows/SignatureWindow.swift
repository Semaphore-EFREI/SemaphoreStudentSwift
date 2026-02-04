//
//  SignatureWindow.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 03/02/2026.
//

import SwiftUI
import Drapeau
import Styles
import Faisceau


struct SignatureWindow: ContextWindowProtocol {
    
    // MARK: Attributes
    
    var vm = SignatureVM(signatureImage: SignatureImage())
    
    var courseToRecover: FaisceauCourse?
    
    
    // MARK: View
    
    var body: some View {
        ContextWindow {
            content
                .contextToolbarTitle(courseToRecover?.name ?? "", description: courseToRecover?.date.timestampToDateAndTime ?? "")    // Vide pour aligner le bouton
                .contextToolbar {
                    ContextToolbarButton(placement: .trailing) {
                        DrapButton(icon: "eraser.line.dashed") {
                            vm.lines = []
                        }
                        .style(.actionBar)
                    }
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let newPoint = value.location
                        vm.currentLine.points.append(newPoint)
                        vm.lines.append(vm.currentLine)
                    }
                    .onEnded { _ in
                        vm.lines.append(vm.currentLine)
                        vm.currentLine = Line(points: [])
                    })
                .frame(width: 320, height: 240)
        } bottomContent: {
            VStack(spacing: 29) {
                DrapButton(icon: "signature", title: "Signer", disabled: vm.lines.isEmpty) {
                    print()
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .drapButtonExpand()
    }
    
    
    var content: some View {
        ZStack {
            if vm.lines.isEmpty {
                Text("Signez ici avec votre doigt")
                    .drapHandwrittenDescription()
                    .foregroundStyle(Color.drapQuaternaryText)
            }
            Canvas { context, size in
                for line in vm.lines {
                    var path = Path()
                    path.addLines(line.points)
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
            }
        }
        .frame(maxHeight: .infinity)
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
                    SignatureWindow(courseToRecover: FaisceauCourse(id: UUID(), name: "Matter and Waves", date: 145453987, endDate: 145454890, isOnline: false, signatureClosingDelay: 15, signatureClosed: false))
                        .environmentObject(metrics)
                }
            }
        }
    }
}
