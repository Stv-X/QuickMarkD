//
//  MarkdownPreviewSheet.swift
//  QuickMarkD
//
//  Created by Stv.X on 2023/5/15.
//

import SwiftUI

import SwiftUI
import MarkdownText

struct MarkdownPreviewSheet: View {
    @Binding var isPresented: Bool
    @State var convertedText: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                MarkdownText(convertedText)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresented = false
                            }
                        }
                    }
                    .padding()
            }
            .navigationTitle("Preview")
            
            #if os(macOS)
            .frame(minWidth: 400, maxWidth: 600, minHeight: 300, maxHeight: 600)
            #else
            .navigationBarTitleDisplayMode(.inline)
            #endif
            
        }
    }
}
