//
//  CategoriesListView.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina Tung on 2/3/23.
//

import SwiftUI

struct CategoriesListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
    
    @State private var name = ""
    @State private var color = Color.red
    //Set is a container/collectoin for selected ones
    @Binding var selectedCategories:  Set<TransactionCategory>
    
    var body: some View {
        Form {
            Section(header: Text("SELECT A CATEGORY")) {
                ForEach(categories) { category in
                    Button {
                        if selectedCategories.contains(category){
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                        
                    } label: {
                        HStack(spacing: 12) {
                            if let data = category.colorData, let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor)
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                                
                                Text(category.name ?? "")
                                    .foregroundColor(Color(.label))
                                Spacer()
                                
                                if selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                                
                            }
                        }
                    }
                }.onDelete { indexSet in
                    indexSet.forEach { i in
                        let category = categories[i]
                        selectedCategories.remove(category)
                        viewContext.delete(category)
                    }
                    try? viewContext.save()
                }
            }
            
            Section(header: Text("CREATE A CATEGORY")) {
                TextField("Name", text: $name)
                ColorPicker("Color", selection: $color)
                Button {
                    handleCreate()
                } label: {
                    HStack {
                        Spacer()
                        Text("Create")
                        Spacer()
                    }
                    .padding(.vertical, 8)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                }.buttonStyle(PlainButtonStyle())
   
            }
        }
    }
    
    private func handleCreate() {
        let context = PersistenceController.shared.container.viewContext
        let category = TransactionCategory(context: context)
        category.name = self.name
        category.colorData = UIColor(color).encode()
        category.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            //handle err
        }
        self.name = ""
    }
}

struct CategoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        CategoriesListView(selectedCategories: .constant(.init()))
            .environment(\.managedObjectContext, viewContext)
    }
}
