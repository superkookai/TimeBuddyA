//
//  ContentView.swift
//  TimeBuddyA
//
//  Created by Weerawut on 7/1/2569 BE.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    @State private var timeZones: [String] = []
    @State private var newTimeZone: String = "GMT"
    @State private var selectedTimeZones = Set<String>()
    @State private var id = UUID()
    @State private var message = ""
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //MARK: - Body/Subviews
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Quit", systemImage: "xmark.circle.fill", action: quit)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            }
            
            if timeZones.isEmpty {
                Text("Please add your first time zone below.")
                    .frame(maxHeight: .infinity)
            } else {
                List(selection: $selectedTimeZones) {
                    ForEach(timeZones, id: \.self) { timeZone in
                        let time = timeData(for: timeZone)
                        HStack {
                            Button("Copy", systemImage: "doc.on.doc") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(time, forType: .string)
                            }
                            .buttonStyle(.borderless)
                            .labelStyle(.iconOnly)
                            
                            Text(time)
                        }
                        .contextMenu {
                            Button {
                                if let index = timeZones.firstIndex(of: timeZone) {
                                    timeZones.remove(at: index)
                                        save()
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                    .onMove(perform: moveItems(from:to:))
                }
                .onDeleteCommand(perform: deleteItems)
                .contextMenu(forSelectionType: String.self, menu: {_ in }) { timeZones in
                    NSPasteboard.general.clearContents()
                    let timeData = timeZones.map(timeData(for:)).sorted().joined(separator: "\n")
                    NSPasteboard.general.setString(timeData, forType: .string)
                }
            }
            
            if !message.isEmpty {
                Text(message)
                    .foregroundStyle(.red)
            }
            
            HStack {
                Picker("Add Time Zone", selection: $newTimeZone) {
                    ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { timeZone in
                        Text(timeZone)
                    }
                }
                
                Button {
                    if timeZones.contains(newTimeZone) == false {
                        message = ""
                        timeZones.append(newTimeZone)
                        save()
                    } else {
                        message = "\(newTimeZone) is already added."
                    }
                } label: {
                    Text("Add")
                }
                .id(id)

            }
        }
        .padding()
        .onAppear(perform: load)
        .frame(height: 300)
        .onReceive(timer) { _ in
            if NSApp.keyWindow?.isVisible == true {
                id = UUID()
            }
        }
    }
    
    
    //MARK: - Functions
    func timeData(for zoneName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = TimeZone(identifier: zoneName) ?? .current
        return "\(zoneName): " + dateFormatter.string(from: Date())
    }
    
    func load() {
        timeZones = UserDefaults.standard.stringArray(forKey: "TimeZones") ?? []
    }
    
    func save() {
        UserDefaults.standard.set(timeZones, forKey: "TimeZones")
    }
    
    func deleteItems() {
        timeZones.removeAll(where: {selectedTimeZones.contains($0)})
        save()
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        timeZones.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
}

#Preview {
    ContentView()
}
