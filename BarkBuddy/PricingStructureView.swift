//
//  PricingStructureView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/21/25.
//

import SwiftUI

struct PricingStructureView: View {
    // Sample data for walker services
    let services = [
        Service(name: "Quick Walk", duration: "15 min", price: 12.99, description: "A short potty break walk around the block"),
        Service(name: "Standard Walk", duration: "30 min", price: 19.99, description: "Regular walk with moderate exercise"),
        Service(name: "Extended Walk", duration: "45 min", price: 24.99, description: "Longer walk with play time"),
        Service(name: "Adventure Walk", duration: "60 min", price: 29.99, description: "Full exercise with park visit and games")
    ]
    
    // Track the selected service ID
    @State private var selectedServiceID: UUID? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeaderView()
                
                ForEach(services) { service in
                    ServiceCardView(
                        service: service,
                        isSelected: selectedServiceID == service.id,
                        onSelect: {
                            // When a service is tapped, update the selected ID
                            selectedServiceID = service.id
                        }
                    )
                }
                
                BookButton(isServiceSelected: selectedServiceID != nil)
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Sarah's Dog Walking")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "star.fill")
                Text("4.94")
                Text("(128 reviews)")
                    .foregroundColor(.gray)
            }
            
            Text("Available today")
                .font(.subheadline)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ServiceCardView: View {
    let service: Service
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            onSelect()
        }) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(service.name)
                        .font(.headline)
                    
                    Text(service.duration)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("$\(service.price, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BookButton: View {
    let isServiceSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Booking action
            }) {
                Text("Book Walker")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isServiceSelected ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isServiceSelected)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Model
struct Service: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let price: Double
    let description: String
}

// Preview
struct PricingStructureView_Previews: PreviewProvider {
    static var previews: some View {
        PricingStructureView()
    }
}
