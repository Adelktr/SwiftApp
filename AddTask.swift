//
//  AddTask.swift
//  Adel app
//
//  Created by Adel Khiter on 22/11/2023.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var isPresented: Bool
    @State private var newTaskName = ""
    @State private var newTaskDescription = ""
    @State private var newTaskIsDone = false
    @State private var newTaskPriority: Priority = .low

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ajouter une tâche")) {
                    TextField("Nom de la tâche", text: $newTaskName)
                    TextField("Description de la tâche", text: $newTaskDescription)
                    Toggle("Tâche terminée", isOn: $newTaskIsDone)
                    Picker("Priorité", selection: $newTaskPriority) {
                        ForEach(Priority.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                Section(header: Text("Pays")) {
                    Picker("Pays", selection: $newTaskCountry) {
                        ForEach(countryViewModel.countries) { country in
                            Text(country.name)
                                .tag(country.alpha2Code)
                        }
                    }
                }
                Button(action: {
                    addTask()
                    isPresented = false
                }) {
                    Text("Ajouter")
                }
            }
            .navigationTitle("Nouvelle tâche")
            .navigationBarItems(trailing: Button("Fermer") {
                isPresented = false
            })
        }
    }

    func addTask() {
        let newTask = Task(name: newTaskName, description: newTaskDescription, isDone: newTaskIsDone, priority: newTaskPriority, country: newTaskCountry)
        taskStore.tasks.append(newTask)

        newTaskName = ""
        newTaskDescription = ""
        newTaskIsDone = false
        newTaskPriority = .low
        newTaskCountry = ""
    }
}
