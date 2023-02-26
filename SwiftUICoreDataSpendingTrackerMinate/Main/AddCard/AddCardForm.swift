//
//  AddCardForm.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina Tung on 1/31/23.
//

import SwiftUI

struct addCardForm: View {
    
    let card: Card?
    var didAddCard: ((Card) -> ())? = nil
    
    init(card: Card? = nil, didAddCard: ((Card) -> ())? = nil) {
        self.card = card
        self.didAddCard = didAddCard
        
        
        _name = State(initialValue: self.card?.name ?? "")
        
        _cardNumber = State(initialValue: self.card?.number ?? "")
        
        _cardType = State(initialValue: self.card?.type ?? "")
        
        if let limit = self.card?.limit {
            _limit = State(initialValue: String(limit))
        }
        
        _month = State(initialValue: Int(self.card?.expMonth ?? 1))
        
        _year = State(initialValue: Int(self.card?.expYear ?? 2020))
        
        if let data = self.card?.color, let uiColor = UIColor.color(data: data) {
            let c = Color(uiColor)
            _color = State(initialValue: c)
        }
    }
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var cardNumber = ""
    @State private var limit = ""
    
    @State private var cardType = "Visa"
    
    @State private var month = 1
    @State private var year = Calendar.current.component(.year, from: Date())
    
    @State private var color = Color.blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("CARD INFORMATION")) {
                    TextField("Name", text: $name)
                    TextField("Credit Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    TextField("Credit Limit", text: $limit)
                        .keyboardType(.numberPad)
                    Picker("Type", selection: $cardType) {
                        ForEach(["Visa", "MasterCard", "Discover", "CitiBank"], id: \.self) { cardType in
                            Text(String(cardType)).tag(String(cardType))
                        }
                        
                    }
                }
                
                Section(header: Text("EXPIRATTION")) {
                    Picker("Month", selection: $month) {
                        ForEach(1..<13, id: \.self) { num in
                            Text(String(num)).tag(String(num))
                        }
                    }
                    Picker("Year", selection: $year) {
                        ForEach(year..<year + 10, id: \.self) { num in
                            Text(String(num)).tag(String(num))
                        }
                    }
                }
                
                Section(header: Text("COLOR")) {
                    ColorPicker("Color", selection: $color)
                }
            }
            .navigationTitle(self.card != nil ? self.card?.name ?? "" : "Add credit card")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            
        }
    }
    
    private var saveButton: some View {
        Button {
            let viewContext = PersistenceController.shared.container.viewContext
            
            let card = self.card != nil ? self.card! : Card(context: viewContext)
            
            
            card.name = self.name
            card.number = self.cardNumber
            card.limit = Int32(self.limit) ?? 0
            
            card.expMonth = Int16(self.month)
            card.expYear = Int16(self.year)
            card.timestamp = Date()
            card.color = UIColor(self.color).encode()
            card.type = cardType
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
                didAddCard?(card)
            } catch {
                print("Failed to persist new card: \(error)")
            }
            
        } label: {
            Text("Save")
        }
    }
    
    private var cancelButton: some View {
        Button(action:{
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
}


extension UIColor {

     class func color(data: Data) -> UIColor? {
          return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
     }

     func encode() -> Data? {
          return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
     }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, context)
//        addCardForm()
    }
}

