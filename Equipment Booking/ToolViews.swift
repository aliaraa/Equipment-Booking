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
            
            // Centered content
            VStack(alignment: .leading, spacing: 8) {
                Text(tool.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                
                ToolImageView(imageURL: tool.imageURL)
                    .padding(.horizontal, 10) // Padding for image
                
                Text(tool.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .padding(.horizontal, 10)
                
                HStack(spacing: 10) {
                    Text("Price: \(tool.price) SEK/day")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text("\(tool.numberOfItems) available")
                        .font(.caption)
                        .foregroundColor(tool.isAvailable ? .green : .red)
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, alignment: .center) // Center the VStack
            
            // Chevron overlay, center-right
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing) // Push to right
                .padding(.trailing, 10) // Additional padding from right edge
                .alignmentGuide(VerticalAlignment.center) { d in d[VerticalAlignment.center] } // Vertically centered
        }
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
        .shadow(radius: 2)
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
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
                            .foregroundColor(.gray)
                    @unknown default:
                        Image(systemName: "exclamationmark.triangle")
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
                            .foregroundColor(.red)
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300, alignment: .center)
                    .foregroundColor(.gray)
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

