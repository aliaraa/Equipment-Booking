import SwiftUI

struct ContentView: View {
    @State var selectPickupDate: Date = Date()
    @State var selectReturnDate: Date = Date()
    @State var isShowingDatePicker = false
    @State var isPickingDate = true
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = date
            if selectReturnDate < selectPickupDate {
                selectReturnDate = selectPickupDate
            }
        } else {
            selectReturnDate = date
            if selectPickupDate > selectReturnDate {
                selectPickupDate = selectReturnDate
            }
        }
        isShowingDatePicker = false
    }

    var body: some View {
        ZStack {
            VStack {
                Text("Equipment Details")
                    .font(.largeTitle)
                    .padding()

                Image(systemName: "globe")
                    .frame(width: 400.0, height: 300.0)
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .background(Color.black)

                HStack {
                    VStack {
                        Text("Equipment")
                            .font(.title)
                    }
                    
                    Spacer()
                    VStack {
                        HStack {
                            Button("-") {
                                
                            }
                            Text("1")
                                .font(.headline)
                                .padding(10)
                            Button("+") {
                                
                            }
                        }
                    }.padding(.trailing)
                }
                        VStack{
                            HStack {
                                Button("Pick Pickup Date") {
                                    isPickingDate = true
                                    isShowingDatePicker.toggle()
                                }
                                .padding(10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                Spacer()
                                Text(dateFormatter.string(from: selectPickupDate))
                                    .padding(.horizontal)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            
                            HStack{
                                Button("Pick Return Date") {
                                    isPickingDate = false
                                    isShowingDatePicker.toggle()
                                }
                                .padding(10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                Spacer()
                                Text(dateFormatter.string(from: selectReturnDate))
                                    .padding(.horizontal)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                Spacer()
                HStack{
                    Text("Description")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .padding()
                    Spacer()
                }
                Spacer()
                Button("Add to cart") {
                   
                }
                .frame(width: 200.0, height: 50.0)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
            .padding()
            
            if isShowingDatePicker {
                VStack {
                    DatePicker(
                    "Select Date",
                    selection: isPickingDate ? $selectPickupDate : $selectReturnDate,
                    in: Date.now...,
                displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                
                    Button("Done") {
                        handleDateSelection(isPickingDate ? selectPickupDate : selectReturnDate)
                            }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        }
                .padding(.horizontal, 20.0)
                .frame(maxWidth: .infinity , maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                
                    }
                }
        
            }
        
        }
    


#Preview {
    ContentView()
}
