import SwiftUI

struct CategoriesView: View {
    @State var columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    @State var categoryInput = ""
    @State var categories: [Category] = []
    @State var descriptionInput = ""
    
    var body: some View {
        VStack {
           
            HStack {
                VStack {
                    TextField("Category", text: $categoryInput)
                        .border(Color.black)
                        .padding()
                        .foregroundColor(Color.black)
                        .cornerRadius(10)
                    
                    TextField("Description", text: $descriptionInput)
                        .border(Color.black)
                        .padding()
                        .foregroundColor(Color.black)
                        .cornerRadius(10)
                }
                Button(action: {
                    addCategory()
                }) {
                    Text("Add")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(categories) { category in
                        CategoryBoxView(category: category)
                            .frame(height: 200)
                    }
                }
                .padding()
            }
        }
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
}
