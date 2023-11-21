import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var taskStore: TaskStore
    var task: Task
    @State private var isEditing = false
    @State private var editedTask: Task

    init(task: Task, taskStore: TaskStore) {
        self.task = task
        self.taskStore = taskStore
        self._editedTask = State(initialValue: task)
    }

    var body: some View {
        if isEditing {
            EditTaskForm(taskStore: taskStore, editedTask: $editedTask, isEditing: $isEditing)
        } else {
            VStack {
                Text(task.name)
                    .font(.title)
                Text("Description: \(task.description ?? "")")
                    .foregroundColor(.gray)
                Text("Priorité: \(task.priority?.rawValue ?? "")")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                Text("Tâche terminée: \(task.isDone ? "Oui" : "Non")")

                Button("Modifier") {
                    isEditing.toggle()
                }
            }
            .padding()
            .navigationTitle("Détails de la tâche")
        }
    }
}

struct EditTaskForm: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var editedTask: Task
    @Binding var isEditing: Bool

    var body: some View {
        Form {
            Section(header: Text("Détails de la tâche")) {
                TextField("Nom de la tâche", text: $editedTask.name)
                TextField("Description de la tâche", text: Binding(
                    get: { editedTask.description ?? "" },
                    set: { editedTask.description = $0.isEmpty ? nil : $0 }
                ))
            }

            Section(header: Text("Priorité")) {
                Picker("Priorité", selection: $editedTask.priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }

            Section(header: Text("État de la tâche")) {
                Toggle("Tâche terminée", isOn: $editedTask.isDone)
            }

            Section {
                Button(action: {
                    taskStore.updateTask(task: editedTask)
                    isEditing = false
                }) {
                    Text("Enregistrer les modifications")
                }
            }
        }
        .navigationTitle("Détails de la tâche")
    }
}
