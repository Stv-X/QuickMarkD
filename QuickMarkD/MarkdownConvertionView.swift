//
//  MarkdownConvertionView.swift
//  QuickMarkD
//
//  Created by 徐嗣苗 on 2023/5/15.
//

import SwiftUI
import OpenAIStreamingCompletions

struct MarkdownConvertionView: View {
    @State private var text = ""
    @State private var convertedText = ""
    @AppStorage("fontSize") var fontSize = 10

    
    @State private var isConverting = false
    @State private var showPreviewMarkdown = false
    @State private var copySucceed = false
    
    @State private var showAISettingsModal = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Raw Text")
                .bold()
            TextEditor(text: $text)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .font(.system(size: CGFloat(fontSize)))
                .frame(minWidth: 360, minHeight: 150)
            
            HStack {
                Text("Markdown")
                    .bold()
                Spacer()
                if copySucceed {
                    Text("Content copied to the clipboard.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                markdownCpoyButton
            }
            
            TextEditor(text: $convertedText)
                .font(.system(size: CGFloat(fontSize), design: .monospaced))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .frame(minWidth: 360, minHeight: 150)
                .overlay {
                    if isConverting && convertedText.isEmpty {
                        ProgressView()
                        #if os(macOS)
                            .scaleEffect(0.5)
                        #endif
                    }
                }
            
            
            HStack {
                Spacer()
                convertButton
                previewButton
            }
        }
        .padding()
        .background(.thinMaterial)
        .navigationTitle("QuickMarkD")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                fontSizeAdjustButtons
            }
            
            ToolbarItem {
                Button {
                    self.showAISettingsModal = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            
        }
        .sheet(isPresented: $showPreviewMarkdown) {
            MarkdownPreviewSheet(isPresented: $showPreviewMarkdown,
                                convertedText: convertedText)
        }
        .sheet(isPresented: $showAISettingsModal) {
            OpenAISettingsModal(isPresented: $showAISettingsModal)
        }
    }
    
    private var markdownCpoyButton: some View {
        Button {
            withAnimation {
                #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(self.convertedText, forType: .string)
                #else
                UIPasteboard.general.string = self.convertedText
                #endif
                copySucceed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    withAnimation {
                        copySucceed = false
                    }
                })
            }
        } label: {
            Image(systemName: "doc.on.doc")
                .imageScale(.small)
        }
        .disabled(convertedText.isEmpty || copySucceed)
        .buttonStyle(.bordered)
    }
    
    private var convertButton: some View {
        Button("Convert") {
            withAnimation {
                isConverting = true
                convertedText = ""
                Task {
                    let promptMessages: [OpenAIAPI.Message] = [
                        .init(role: .system, content: "The following content is a plain text that does not contain any format or comments. Convert it into a markdown statement."),
                        .init(role: .user, content: text)
                    ]
                    
                    let api = OpenAIAPI(apiKey: UserDefaults.standard.string(forKey: "APIKey") ?? "", host: UserDefaults.standard.string(forKey: "APIHost") ?? "api.openai.com")
                    
                    let stream =  try api.completeChatStreaming(.init(messages: promptMessages))
                    for await message in stream {
                        convertedText = message.content
                    }
                    isConverting = false
                }
            }
        }
        .disabled(isConverting)
        .buttonStyle(.bordered)
    }
    
    private var previewButton: some View {
        Button("Preview") {
            showPreviewMarkdown = true
        }
        .disabled(convertedText.isEmpty || isConverting)
        .buttonStyle(.borderedProminent)
    }
    
    private var fontSizeAdjustButtons: some View {
        HStack {
            Button {
                if fontSize - 1 >= 8 {
                    fontSize -= 1
                }
            } label: {
                Image(systemName: "textformat.size.smaller")
            }
            .keyboardShortcut("-")

            Button {
                if fontSize + 1 <= 30 {
                    fontSize += 1
                }
            } label: {
                Image(systemName: "textformat.size.larger")
            }
            .keyboardShortcut("=")
        }
    }
}

struct MarkdownConvertionView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownConvertionView()
    }
}
