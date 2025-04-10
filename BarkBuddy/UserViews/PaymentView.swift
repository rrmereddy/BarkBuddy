//
//  PaymentView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/10/25.
//

import SwiftUI

struct PaymentView: View {
    // Walker and walk details
    let walkerName = "Alex"
    let dogName = "Buddy"
    let walkDuration = "30 min"
    let walkDistance = "1.2 miles"
    let basePrice = 15.00
    
    // State variables
    @State private var rating: Int = 0
    @State private var review: String = ""
    @State private var tipAmount: Double = 0.0
    @State private var selectedTipIndex: Int? = nil
    @State private var customTipString: String = ""
    @State private var showPaymentSuccess = false
    @State private var showPaymentMethodSheet = false
    @State private var selectedPaymentMethod: PaymentMethod = .visa
    
    // Computed properties
    var tipOptions: [(percent: Int, amount: Double)] {
        [
            (15, basePrice * 0.15),
            (20, basePrice * 0.20),
            (25, basePrice * 0.25)
        ]
    }
    
    var totalAmount: Double {
        basePrice + tipAmount
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Walk Summary Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Walk Summary")
                            .font(.headline)
                        Spacer()
                        Text("View details")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Text(String(walkerName.prefix(1)))
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(walkerName) walked \(dogName)")
                                .fontWeight(.medium)
                            Text("\(walkDuration) • \(walkDistance)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Rating Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rate your walker (optional)")
                        .font(.headline)
                    
                    // Star Rating
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(star <= rating ? .yellow : .gray)
                                .font(.title3)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                    
                    // Review Text Area
                    TextField("Write a review (optional)", text: $review, axis: .vertical)
                        .lineLimit(5...8)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Tip Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add a tip (optional)")
                        .font(.headline)
                    
                    // Tip preset options
                    HStack(spacing: 8) {
                        ForEach(0..<tipOptions.count, id: \.self) { index in
                            Button(action: {
                                selectedTipIndex = index
                                tipAmount = tipOptions[index].amount
                                customTipString = ""
                            }) {
                                VStack {
                                    Text("\(tipOptions[index].percent)%")
                                    Text("$\(String(format: "%.2f", tipOptions[index].amount))")
                                        .font(.footnote)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTipIndex == index ? Color.blue : Color.gray.opacity(0.15))
                                .foregroundColor(selectedTipIndex == index ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                        
                        // No tip option
                        Button(action: {
                            selectedTipIndex = nil
                            tipAmount = 0
                            customTipString = ""
                        }) {
                            Text("No tip")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTipIndex == nil && tipAmount == 0 ? Color.blue : Color.gray.opacity(0.15))
                                .foregroundColor(selectedTipIndex == nil && tipAmount == 0 ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Custom tip input
                    HStack {
                        Text("$")
                            .foregroundColor(.gray)
                        
                        TextField("Enter custom amount", text: $customTipString)
                            .keyboardType(.decimalPad)
                            .onChange(of: customTipString) { newValue in
                                if let amount = Double(newValue) {
                                    tipAmount = amount
                                    selectedTipIndex = nil
                                } else if newValue.isEmpty {
                                    tipAmount = 0
                                }
                            }
                    }
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Payment Method Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Payment Method")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showPaymentMethodSheet = true
                        }) {
                            HStack {
                                Text("Change")
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                            }
                        }
                    }
                    
                    HStack {
                        selectedPaymentMethod.icon
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(selectedPaymentMethod.displayTitle)
                                .fontWeight(.medium)
                            if selectedPaymentMethod.hasExpiration {
                                Text("Expires \(selectedPaymentMethod.expirationDate)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Price breakdown
                VStack(spacing: 10) {
                    HStack {
                        Text("Walk Fee")
                        Spacer()
                        Text("$\(String(format: "%.2f", basePrice))")
                    }
                    
                    HStack {
                        Text("Tip")
                        Spacer()
                        Text("$\(String(format: "%.2f", tipAmount))")
                    }
                    
                    Divider()
                        .padding(.vertical, 6)
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", totalAmount))")
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Payment")
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showPaymentSuccess = true
            }) {
                HStack {
                    Text("Pay $\(String(format: "%.2f", totalAmount))")
                        .fontWeight(.bold)
                    Image(systemName: "paperplane.fill")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color.white.shadow(radius: 2))
        }
        .alert("Payment Successful", isPresented: $showPaymentSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for using our service!")
        }
        .sheet(isPresented: $showPaymentMethodSheet) {
            PaymentMethodSelectionView(
                selectedMethod: $selectedPaymentMethod,
                isPresented: $showPaymentMethodSheet
            )
        }
    }
}

// Payment Method Selection Sheet
struct PaymentMethodSelectionView: View {
    @Binding var selectedMethod: PaymentMethod
    @Binding var isPresented: Bool
    @State private var tempSelection: PaymentMethod?
    
    let availableMethods: [PaymentMethod] = [.visa, .mastercard, .applePay, .paypal, .addNew]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableMethods, id: \.self) { method in
                    Button(action: {
                        if method == .addNew {
                            // Handle adding new payment method
                            // This would typically navigate to a new card entry form
                        } else {
                            tempSelection = method
                        }
                    }) {
                        HStack {
                            method.icon
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(method.displayTitle)
                                if method.hasExpiration && method != .addNew {
                                    Text("Expires \(method.expirationDate)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            if tempSelection == method || (tempSelection == nil && selectedMethod == method) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Payment Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let selection = tempSelection {
                            selectedMethod = selection
                        }
                        isPresented = false
                    }
                    .disabled(tempSelection == .addNew)
                }
            }
            .onAppear {
                tempSelection = selectedMethod
            }
        }
    }
}

// Payment Method Enum
enum PaymentMethod: Hashable {
    case visa
    case mastercard
    case applePay
    case paypal
    case addNew
    
    var displayTitle: String {
        switch self {
        case .visa: return "Visa •••• 4242"
        case .mastercard: return "Mastercard •••• 5555"
        case .applePay: return "Apple Pay"
        case .paypal: return "PayPal"
        case .addNew: return "Add Payment Method"
        }
    }
    
    var icon: some View {
        switch self {
        case .visa:
            return Image(systemName: "creditcard")
        case .mastercard:
            return Image(systemName: "creditcard")
        case .applePay:
            return Image(systemName: "applepay")
        case .paypal:
            return Image(systemName: "p.circle")
        case .addNew:
            return Image(systemName: "plus.circle")
        }
    }
    
    var hasExpiration: Bool {
        switch self {
        case .visa, .mastercard:
            return true
        case .applePay, .paypal, .addNew:
            return false
        }
    }
    
    var expirationDate: String {
        switch self {
        case .visa:
            return "12/25"
        case .mastercard:
            return "10/26"
        default:
            return ""
        }
    }
}

struct PaymentScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PaymentView()
        }
    }
}
