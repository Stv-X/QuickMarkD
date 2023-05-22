//
//  ContentView.swift
//  QuickMarkD
//
//  Created by 徐嗣苗 on 2023/5/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MarkdownConvertionView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
