import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var isPresented: Bool
    @State private var newTaskName = ""
    @State private var newTaskDescription = ""
    @State private var newTaskIsDone = false
    @State private var newTaskPriority: Priority = .low
    @State private var countryNames: [String] = []
    @State private var newCountry = "France"
    @State private var isLoading = false

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
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                Picker("Pays", selection: $newCountry) {
                                    ForEach(countryNames, id: \.self) {
                                        Text($0)
                                    }
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
                    .onAppear {
                    
                        fetchData()
                    }
                }
            }

    func addTask() {
        let newTask = Task(name: newTaskName, description: newTaskDescription, isDone: newTaskIsDone, priority: newTaskPriority, country: newCountry)
        taskStore.tasks.append(newTask)
        
        newTaskName = ""
        newTaskDescription = ""
        newTaskIsDone = false
        newTaskPriority = .low
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

struct APIResult: Codable {
    let errorCode: Int
    let execTime: Int
    let happyApiStatus: String
    let happyApiVersion: String
    let nbRequestPerAPI: Int
    let result: Result
}

struct Result: Codable {
    let errorCode: Int
    let result: [String: String]
}
