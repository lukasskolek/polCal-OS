//
//  VoteReportView.swift
//  polCal-v2
//
//  Created by Lukas on 27/10/2024.
//

import SwiftUI

struct VoteReportView: View {
    @Binding var path: NavigationPath
    
    @Environment(\.modelContext) var modelContext
    @Bindable var vote: Vote
    
    var body: some View {
        Text("This is VoteReportView")
    }
}

//#Preview {
//    VoteReportView()
//}
