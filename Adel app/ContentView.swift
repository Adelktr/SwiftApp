import SwiftUI
import Combine

enum Priority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}


class Task: Identifiable, ObservableObject, Hashable {
    var id = UUID()
    @Published var name: String
    @Published var description: String?
    @Published var isDone: Bool
    @Published var priority: Priority?

    init(name: String, description: String?, isDone: Bool, priority: Priority?) {
        self.name = name
        self.description = description
        self.isDone = isDone
        self.priority = priority
    }

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [
        Task(name: "Tâche 1", description: "Description de la tâche 1", isDone: false, priority: .low),
        Task(name: "Tâche 2", description: "Description de la tâche 2", isDone: true, priority: .medium),
        Task(name: "Tâche 3", description: "Description de la tâche 3", isDone: false, priority: .high)
    ]
    
    func updateTask(task: Task) {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
            }
        }
}

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
        taskStore.tasks.append(newTask)

    
        newTaskName = ""
        newTaskDescription = ""
        newTaskIsDone = false
        newTaskPriority = .low
    }
}

struct ContentView: View {
    @ObservedObject private var taskStore = TaskStore()
    @State private var isAddTaskViewPresented: Bool = false
    @State private var selectedTask: Task?

    var body: some View {
        NavigationView {
            List {
                ForEach(taskStore.tasks) { task in
                    NavigationLink(
                            destination: TaskDetailView(task: task, taskStore: taskStore), 
                            tag: task,
                            selection: $selectedTask
                        ) {
                            TaskRow(task: task)
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                }
                .onDelete { indexSet in
                    taskStore.tasks.remove(atOffsets: indexSet)
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
                AddTaskView(taskStore: taskStore, isPresented: $isAddTaskViewPresented)
            }
        }
    }
}

struct TaskRow: View {
    @ObservedObject var task: Task

    var body: some View {
        VStack(alignment: .leading) {
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
            Spacer()
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
