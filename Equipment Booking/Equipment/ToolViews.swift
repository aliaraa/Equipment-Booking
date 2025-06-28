//
//  ToolViews.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/9/25.
//


// ToolViews.swift
import SwiftUI

struct ToolRow: View {
    let tool: Tool
    @EnvironmentObject var cartManager: CartManager
    @StateObject private var equipmentManager = EquipmentManager.shared
    @State private var totalQuantity: Int = 0
    @State private var availableQuantity: Int = 0
    
    var body: some View {
        ZStack(alignment: .center) {
            NavigationLink(destination: Equipment_Details(tool: tool)) {
                EmptyView()
            }
            .opacity(0)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(tool.name)
                    .font(Typography.headline) // Use a consistent font style
//                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                
                ToolImageView(imageURL: tool.imageURL)
                    .padding(.horizontal, 12)
                
                Text(tool.description)
                    .font(Typography.body) // Use a consistent font style
//                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .padding(.horizontal, 12)
                
                HStack(spacing: 12) {
                    Text("Price: \(String(format: "%.2f", tool.price)) SEK/day")
//                        .font(.system(size: 13, weight: .medium))
                        .font(Typography.subheadline) // Use a consistent font style
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Text("Available: \(availableQuantity) of \(totalQuantity)")
//                        .font(.system(size: 13, weight: .medium))
                        .font(Typography.subheadline) // Use a consistent font style
                        .foregroundColor(availableQuantity > 0 ? .green.opacity(0.8) : .red.opacity(0.8))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background((availableQuantity > 0 ? Color.green : Color.red).opacity(0.1))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
            

        }
        .padding(.vertical, 6)
        .task {
            do {
                let today = Date()
                let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
                let (bookings, available) = try await equipmentManager.getToolAvailability(
                    forToolId: tool.id,
                    pickupDate: today,
                    returnDate: nextWeek
                )
                totalQuantity = tool.numberOfItems // Totalt antal från verktyget självt
                availableQuantity = available
            } catch {
                print("Error fetching availability: \(error)")
                totalQuantity = tool.numberOfItems
                availableQuantity = tool.numberOfItems
            }
        }
    }
}

struct ToolImageView: View {
    let imageURL: String?
    
    var body: some View {
        Group {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 200).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    case .empty: ProgressView().frame(maxWidth: .infinity, maxHeight: 200).background(Color.gray.opacity(0.1)).cornerRadius(10)
                    case .failure: Image(systemName: "photo").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 200).foregroundColor(.gray.opacity(0.5)).background(Color.gray.opacity(0.1)).cornerRadius(10)
                    @unknown default: Image(systemName: "exclamationmark.triangle").frame(maxWidth: .infinity, maxHeight: 200).foregroundColor(.orange).background(Color.gray.opacity(0.1)).cornerRadius(10)
                    }
                }
            } else {
                Image(systemName: "photo").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 200).foregroundColor(.gray.opacity(0.5)).background(Color.gray.opacity(0.1)).cornerRadius(10)
            }
        }
    }
}

#Preview {
    ToolRow(tool: Tool(
        id: "LCE-CM-11",
        name: "Petrol-powered mobile cutters",
        category: "Construction",
        mainCategory: "Light construction equipment",
        subCategory: "Cutting machines",
        description: "A mobile petrol cutter with a 500 mm blade.",
        manufacturer: "Ntc",
        imageName: "cutter.webp",
        imageURL: "https://example.com/cutter.webp",
        status: "available",
        price: 100.0,
        numberOfItems: 4,
        isAvailable: true
    ))
    .environmentObject(CartManager())
}
