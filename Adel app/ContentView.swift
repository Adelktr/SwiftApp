import SwiftUI

enum Priority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct Task: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String?
    var isDone: Bool
    var priority: Priority?

    init(name: String, description: String?, isDone: Bool = false, priority: Priority?) {
        self.name = name
        self.description = description
        self.isDone = isDone
        self.priority = priority
    }
}

struct AddTaskView: View {
    @Binding var isPresented: Bool
    @Binding var tasks: [Task]
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
        let newTask = Task(name: newTaskName, description: newTaskDescription, isDone: newTaskIsDone, priority: newTaskPriority)
        tasks.append(newTask)

        // Réinitialiser les champs après l'ajout
        newTaskName = ""
        newTaskDescription = ""
        newTaskIsDone = false
        newTaskPriority = .low
    }
}

struct ContentView: View {
    @State private var selectedTask: Task?
    @State private var tasks: [Task] = [
        Task(name: "Tâche 1", description: "Description de la tâche 1", isDone: false, priority: .low),
        Task(name: "Tâche 2", description: "Description de la tâche 2", isDone: true, priority: .medium),
        Task(name: "Tâche 3", description: "Description de la tâche 3", isDone: false, priority: .high)
    ]

    @State private var isAddTaskViewPresented: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    NavigationLink(
                            destination: TaskDetailView(task: task))
                        {VStack(alignment: .leading) {
                            Text(task.name)
                                .font(.headline)
                            Text(task.description ?? "")
                                .foregroundColor(.gray)
                            Text("Priorité: \(task.priority?.rawValue ?? "")")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                            Text("Tâche terminée: \(task.isDone ? "Oui" : "Non")")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                        }
                        .onTapGesture {
                            selectedTask = task
                        }
                    }
                }

                Section(header: Text("Ajouter une tâche")) {
                    Button(action: {
                        isAddTaskViewPresented = true
                    }) {
                        Text("Ajouter une tâche")
                    }
                }
            }
            .navigationTitle("ToDoList")
            .sheet(isPresented: $isAddTaskViewPresented) {
                AddTaskView(isPresented: $isAddTaskViewPresented, tasks: $tasks)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
