//
//  MainView.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina Tung on 1/31/23.
//

import SwiftUI

struct TabMainView: View {
    var body: some View {
        VStack {
            TabView {
                MainView().edgesIgnoringSafeArea(.all)
                    .tabItem {
                        Image(systemName: "creditcard")
                        Text("Credit Card")
                }
                
                Text("Graphs").edgesIgnoringSafeArea(.all)
                    .tabItem {
                        Image(systemName: "cellularbars")
                        Text("Graphs")
                }
            }
        }
    }
}

struct MainView: View {
    
    @State var shouldPresentAddCardForm = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    @State private var cardSelectionIndex = 0

    @State private var selectedCardHash = -1
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !cards.isEmpty {
                    TabView(selection: $selectedCardHash) {
                        ForEach(cards) { card in
                             CreditCardView(card: card)
                                .padding(.bottom, 50)
                                .tag(card.hash)
                        }
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 280)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .onAppear {
                            self.selectedCardHash = cards.first?.hash ?? -1
                        }

                    if let firstIndex = cards.firstIndex(where: {$0.hash == selectedCardHash}) {
                        let card = cards[firstIndex]
                        TransactionsListView(card: card)
                    }
                } else {
                    emptyPromptMessage
                }

                Spacer().fullScreenCover(isPresented: $shouldPresentAddCardForm) {
                    addCardForm(card: nil) { card in
                        self.selectedCardHash = card.hash
                    }
                }
            }.navigationBarTitle("Credit Cards")
                .navigationBarItems(trailing: addCardButton)}
    }
    
    private var emptyPromptMessage: some View {
        VStack {
            Text("You currently have no cards in the system.")
                .padding(.horizontal, 48)
                .padding(.vertical)
                .multilineTextAlignment(.center)
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add Your First Card")
                    .foregroundColor(Color(.systemBackground))
                    
            }.padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                .background(Color(.label))
                .cornerRadius(5)

        }.font(.system(size: 22, weight: .semibold))
    }
    
    private var deleteAllButton: some View {
        Button(action: {
            cards.forEach({ card in
                viewContext.delete(card)
            })
            do {
                try viewContext.save()
            } catch {
                
            }  
        }, label: {
            Text("Delete Item")
        })
    }
    
    var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
                
                }
            }
        }, label: {
            Text("Add Item")
        })
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold))
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(Color.black)
            .cornerRadius(5)
                            
        })
    }
}

struct CreditCardView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext

    var fetchRequest: FetchRequest<CardTransaction>
    
    @State private var shouldShowActionSheet = false
    @State private var shouldShowEditForm = false
    
    @State var refreshId = UUID()
    
    private func handleDelete() {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(card)
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete the card: ", error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(card.name ?? "")
                    .font(.system(size: 24, weight: .semibold))
                Spacer()
                Button {
                    shouldShowActionSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 28, weight: .bold))
                }.actionSheet(isPresented: $shouldShowActionSheet) {
                    .init(title: Text("TITLE"), message: Text("MESSAGE"), buttons: [.default(Text("Edit"), action: {
                        shouldShowEditForm.toggle()
                    })
                        ,.destructive(Text("Delete Card"), action: {
                        handleDelete()
                    }), .cancel()
                        ])
                }
                
            }
            
            HStack {
                Image("visa")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                    .clipped()
                    
                Spacer()
                
                if let balance = fetchRequest.wrappedValue.reduce(0, {$0 + $1.amount}) {
                    Text("Balance: $\(String(format: "%.2f", balance))")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            
            Text(card.number ?? "")
            
            HStack {
                let balance = fetchRequest.wrappedValue.reduce(0, {$0 + $1.amount })
                
                Text("Credit Limit: $\(card.limit - Int32(balance))")
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Valid Thru")
                    Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(
            VStack {
                if let colorData = self.card.color, let uiColor = UIColor.color(data: colorData), let actualColor = Color(uiColor) {
                    LinearGradient(colors: [actualColor.opacity(0.6), actualColor], startPoint: .center, endPoint: .bottom)
                } else {
                    Color.purple
                }
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 8).stroke( Color.black.opacity(0.5), lineWidth: 1))
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.top, 8)
        
        .fullScreenCover(isPresented: $shouldShowEditForm) {
            addCardForm(card: self.card)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        TabMainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
