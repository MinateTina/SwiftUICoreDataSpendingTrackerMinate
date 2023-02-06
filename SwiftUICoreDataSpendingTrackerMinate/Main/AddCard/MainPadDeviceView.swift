//
//  MainPadDeviceView.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina Tung on 2/5/23.
//

import SwiftUI

struct MainPadDeviceView: View {
    @State private var shouldShowAddCardFrom = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    @State var selectedCard: Card?
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView (.horizontal){
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 400)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedCard = card
                                    }
                                }.scaleEffect(self.selectedCard == card ? 1.1: 1)
                        }
                    }.frame(height: 250)
                        .onAppear {
                            self.selectedCard = cards.first
                        }.padding(.leading)
            }
                
            if let card = self.selectedCard {
                TransactionGrid(card: card)
            }
                
                
            }.navigationTitle("Money Tracker")
                .navigationBarItems(trailing: addCardButton)
                .sheet(isPresented: $shouldShowAddCardFrom) {
                    addCardForm(card: nil, didAddCard: nil)
                }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var addCardButton: some View {
        Button {
            shouldShowAddCardFrom.toggle()
        } label: {
           Text("+ Card")
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundColor(Color(.systemBackground))
                .background(Color(.label))
            .cornerRadius(5)
    }
    
}

struct TransactionGrid: View {
    
    @State private var shouldShowTransactionForm = false
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        //fetch transactions for a particular card
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext

    var fetchRequest: FetchRequest<CardTransaction>
    
    var body: some View {
        VStack {
            HStack {
                Text("Transaction")
                Spacer()
                Button {
                    shouldShowTransactionForm.toggle()
                } label: {
                    Text("+ Transaction")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(Color(.systemBackground))
                    .background(Color(.label))
                    .cornerRadius(5)
            }.sheet(isPresented: $shouldShowTransactionForm) {
                AddTransactionForm(card: card)
                }
            
            let columns: [GridItem] = [
                .init(.fixed(100),spacing: 16, alignment: .leading),
                .init(.fixed(200),spacing: 16, alignment: .leading),
                .init(.adaptive(minimum: 300, maximum: 800), spacing: 16),
                .init(.flexible(minimum: 100, maximum: 450),spacing: 16, alignment: .trailing),
            ]
            
            LazyVGrid(columns: columns) {
                HStack {
                    Text("Date")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                Text("Photo / Receipt")
                
                HStack {
                    Text("Name")
                    Image(systemName: "arrow.up.arrow.down")
                    Spacer()
                }
                
                HStack {
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }.foregroundColor(Color(.darkGray))
            
            LazyVStack(spacing: 0) {
                ForEach(fetchRequest.wrappedValue) { transaction in
                    VStack(spacing: 0) {
                        Divider()
                        if let index = fetchRequest.wrappedValue.firstIndex(of: transaction) {
                            LazyVGrid(columns: columns) {
                                Group {
                                    if let date = transaction.timestamp {
                                        Text(dateFormatter.string(from: date))
                                    }
                                    
                                    if let data = transaction.photoData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                            .cornerRadius(8)
                                    } else {
                                        Text("No photo available")
                                    }
                                    
                                    HStack {
                                        Text(transaction.name ?? "")
                                        Spacer()
                                    }
                                    
                                    Text(String(format: "%.2f", transaction.amount))
                                        .foregroundColor(.red)
                                        .font(.system(size: 24, weight: .semibold))
                                }
                            }.padding(.vertical)
                                .background(index % 2 == 0 ? Color(.systemBackground) : Color(.init(white: 0, alpha: 0.03)))
                        }
                    }
                }
            }
            
            
        }.font(.system(size: 24, weight: .semibold))
            .padding()
         
    }
    
    @State var shouldPresentActionSheet = false
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MainPadDeviceView().previewDevice(PreviewDevice(rawValue: "ipad pro (11-inch) (10th generation)"))
                .environment(\.horizontalSizeClass, .regular)
                .previewInterfaceOrientation(.portrait)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        } else {
            //Fallback on earlier versions
        }
    }
}
