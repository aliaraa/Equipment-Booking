//
//  ToolViews.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/9/25.
//

import SwiftUI

struct ToolRow: View {
    let tool: Tool
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        ZStack(alignment: .center) {
            // NavigationLink as an invisible overlay
            NavigationLink(destination: Equipment_Details(tool: tool)) {
                EmptyView()
            }
            .opacity(0)
            
            // Centered content with modern styling
            VStack(alignment: .leading, spacing: 10) {
                Text(tool.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                
                ToolImageView(imageURL: tool.imageURL)
                    .padding(.horizontal, 12)
                
                Text(tool.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .padding(.horizontal, 12)
                
                HStack(spacing: 12) {
                    Text("Price: \(tool.price) SEK/day")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    Text("\(tool.numberOfItems) available")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(tool.isAvailable ? .green.opacity(0.8) : .red.opacity(0.8))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background((tool.isAvailable ? Color.green : Color.red).opacity(0.1))
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
            
            // Chevron overlay, center-right
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 12)
                .alignmentGuide(VerticalAlignment.center) { d in d[VerticalAlignment.center] }
        }
        .padding(.vertical, 6)
    }
}

struct ToolImageView: View {
    let imageURL: String?
    
    var body: some View {
        Group {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit() // Bytt till scaledToFit för att visa hela bilden
                            .frame(maxWidth: .infinity, maxHeight: 200) // Behåller maxHeight för konsistens
                            .cornerRadius(10) // Använder cornerRadius istället för clipShape
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .foregroundColor(.gray.opacity(0.5))
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    @unknown default:
                        Image(systemName: "exclamationmark.triangle")
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .foregroundColor(.orange)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .foregroundColor(.gray.opacity(0.5))
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}
// Reusable ToolRow (same as SearchResultsView)

//struct ToolRow: View {
//    let tool: Tool
//    @EnvironmentObject var cartManager: CartManager
//    
//    var body: some View {
//        ZStack { // to allow the chevron inside box. use 0 opacity to make the button clickable
//            NavigationLink(destination: Equipment_Details(tool: tool)) {
//                EmptyView()
//            }
//            .opacity(0)
//            
//            HStack(alignment: .center, spacing: 10) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(tool.name)
//                        .font(.headline)
//                        .foregroundColor(.black)
//                        .padding(.horizontal, 10) // Padding for title
//                    
//                    ToolImageView(imageURL: tool.imageURL)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                    
//                    Text(tool.description)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .lineLimit(3)
//                        .truncationMode(.tail)
//                        .padding(.horizontal, 10) // Padding for description
//                    
//                    HStack(spacing: 10) {
//                        Text("Price: \(tool.price) SEK/day")
//                            .font(.caption)
//                            .foregroundColor(.red)
//                        
//                        Spacer()
//                        
//                        Text("\(tool.numberOfItems) available")
//                            .font(.caption)
//                            .foregroundColor(tool.isAvailable ? .green : .red)
//                    }
//                    .padding(.horizontal, 10) // Padding for price and availability
//                }
//                .frame(maxWidth: .infinity)
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .padding(.trailing, 10) // Padding for chevron
//            }
//            .padding(.vertical, 8)
//            .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
//            .shadow(radius: 2)
//            
//        }
//    }
//}
//
//struct ToolImageView: View {
//    let imageURL: String?
//    
//    var body: some View {
//        Group {
//            if let imageURL = imageURL, let url = URL(string: imageURL) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
//                            .clipped()
//                            .cornerRadius(8)
//                    case .empty:
//                        ProgressView()
//                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
//                    case .failure:
//                        Image(systemName: "photo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
//                            .foregroundColor(.gray)
//                    @unknown default:
//                        Image(systemName: "exclamationmark.triangle")
//                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
//                            .foregroundColor(.red)
//                    }
//                }
//            } else {
//                Image(systemName: "photo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//}

