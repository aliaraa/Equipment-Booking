import SwiftUI

struct CategoriesView: View {
    @State var columns = [
        GridItem(.flexible(), spacing: 24), // Increased spacing
        GridItem(.flexible(), spacing: 24)
    ]
    @State var categoryInput = ""
    @State var categories: [Category] = []
    @State var descriptionInput = ""
    
    var body: some View {
        VStack(spacing: 20) { // Added spacing
            VStack(spacing: 12) { // Stack TextFields vertically
                TextField("Category", text: $categoryInput)
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    .padding(.horizontal)
                
                TextField("Description", text: $descriptionInput)
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    .padding(.horizontal)
            }
            
            Button(action: { addCategory() }) {
                Text("Add")
                    .frame(minWidth: 100, minHeight: 44) // Ensure touch target size
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) { // Increased spacing
                    ForEach(categories) { category in
                        CategoryBoxView(category: category)
                            .frame(maxHeight: 200) // Allow dynamic height
                    }
                }
                .padding()
            }
        }
        .padding(.top) // Respect safe area
        .background(Color(.systemBackground))
    }
    
    func addCategory() {
        guard !categoryInput.isEmpty, !descriptionInput.isEmpty else { return }
        let newCategory = Category(title: categoryInput, description: descriptionInput)
        categories.append(newCategory)
        categoryInput = ""
        descriptionInput = ""
    }
}

#Preview {
    CategoriesView()
        .environmentObject(CartManager())
}

//struct CategoriesView: View {
//    @State var columns = [
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16)
//    ]
//    @State var categoryInput = ""
//    @State var categories: [Category] = []
//    @State var descriptionInput = ""
//    
//    var body: some View {
//        VStack {
//           
//            HStack {
//                VStack {
//                    TextField("Category", text: $categoryInput)
//                        .border(Color.black)
//                        .padding()
//                        .foregroundColor(Color.black)
//                        .cornerRadius(10)
//                    
//                    TextField("Description", text: $descriptionInput)
//                        .border(Color.black)
//                        .padding()
//                        .foregroundColor(Color.black)
//                        .cornerRadius(10)
//                }
//                Button(action: {
//                    addCategory()
//                }) {
//                    Text("Add")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            ScrollView {
//                LazyVGrid(columns: columns) {
//                    ForEach(categories) { category in
//                        CategoryBoxView(category: category)
//                            .frame(height: 200)
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//    
//    func addCategory() {
//        guard !categoryInput.isEmpty, !descriptionInput.isEmpty else { return }
//        
//        let newCategory = Category(title: categoryInput, description: descriptionInput)
//        categories.append(newCategory)
//        
//        categoryInput = ""
//        descriptionInput = ""
//    }
//}


