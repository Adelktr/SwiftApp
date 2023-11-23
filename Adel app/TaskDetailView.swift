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
            EditTaskForm(taskStore: taskStore, editedTask: editedTask, isEditing: $isEditing)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nom")
                        .bold()
                    Text(task.name)
                    
                    Text("Description")
                        .bold()
                    Text(task.description ?? "Pas de description")
                    
                    Text("Priorité")
                        .bold()
                    Text(task.priority.rawValue)
                    
                    Text("Tâche terminée")
                        .bold()
                    Text(task.isDone ? "Oui" : "Non")
                    
                    Text("Pays")
                        .bold()
                    Text(task.country)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationBarTitle("Détails de la tâche", displayMode: .inline)
                .navigationBarItems(trailing: Button("Modifier") {
                    isEditing = true
                })
            }
            .padding()
        }
    }
    @ViewBuilder
    private func cardView(title: String, detail: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(detail)
                .font(.title2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct EditTaskForm: View {
    @ObservedObject var taskStore: TaskStore
    @ObservedObject var editedTask: Task
    @Binding var isEditing: Bool
    @State private var isLoading = false
    @State private var countryNames: [String] = []
    
    var body: some View {
        NavigationView {
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
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                
                Section(header: Text("État de la tâche")) {
                    Toggle("Tâche terminée", isOn: $editedTask.isDone)
                }
                
                Section(header: Text("Pays")) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Picker("Pays", selection: $editedTask.country) {
                            ForEach(countryNames, id: \.self) {
                                Text($0)
                            }
                        }
                    }
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
            .navigationTitle("Modifier la tâche")
            .onAppear {
                fetchData()
            }
        }
    }
    func fetchData() {
        isLoading = true
        
        
        guard let url = URL(string: "https://happyapi.fr/api/getLands") else {
            print("URL invalide")
            return
        }
        
        
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Erreur de requête API : \(error)")
                return
            }
            
            
            guard let data = data else {
                print("Aucune donnée reçue de l'API")
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                let result = try decoder.decode(APIResult.self, from: data)
                
                
                DispatchQueue.main.async {
                    self.countryNames = result.result.result.values.map { $0 }
                }
                
                print("MON RESULTAT DE MORT", self.countryNames)
                isLoading = false
                
            } catch {
                print("Erreur de décodage JSON : \(error)")
            }
        }
        
        
        task.resume()
    }
    
    
}


