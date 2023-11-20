import SwiftUI

struct TaskDetailView: View {
    var task: Task

    var body: some View {
        VStack {
            Text(task.name)
                .font(.title)
            Text("Description: \(task.description ?? "")")
                .foregroundColor(.gray)
            Text("Priorité: \(task.priority?.rawValue ?? "")")
                .foregroundColor(.blue)
                .font(.subheadline)
            Text("Tâche terminée: \(task.isDone ? "Oui" : "Non")")
        }
        .padding()
        .navigationTitle("Détails de la tâche")
    }
}
