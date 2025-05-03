//
//  FutureWalksView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/12/25.
//

import SwiftUI
import FirebaseFirestore

struct FutureWalksView: View {
    let userID: String
    // MARK: - Properties
    @State private var calendarViewMode: CalendarViewMode = .week
    @State private var selectedDate = Date()
    @State private var walks: [DogWalk] = []
    @State private var showingScheduleSheet = false // State to control the sheet presentation

    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar view selector
                Picker("Calendar View", selection: $calendarViewMode) {
                    Text("Day").tag(CalendarViewMode.day)
                    Text("Week").tag(CalendarViewMode.week)
                    Text("Month").tag(CalendarViewMode.month)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Calendar header
                calendarHeader
                    .padding(.horizontal)

                // Calendar view
                VStack(spacing: 0) {
                    // Calendar grid (taking approximately 25% of space)
                    switch calendarViewMode {
                    case .day:
                        DayView(date: $selectedDate, walks: filteredWalks)
                            .frame(height: 200) // Reduced height
                    case .week:
                        WeekView(selectedDate: $selectedDate, walks: filteredWalks)
                            .frame(height: 200) // Reduced height
                    case .month:
                        MonthView(selectedDate: $selectedDate, walks: filteredWalks)
                            .frame(height: 200) // Reduced height
                    }

                    // Upcoming walks list (taking approximately 75% of remaining space)
                    ScrollView {
                        upcomingWalksList
                    }
                }
            }
            .navigationTitle("Upcoming Walks")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                },
                trailing: todayButton
            )
            // Add the sheet modifier here
            .sheet(isPresented: $showingScheduleSheet) {
                ScheduleWalkView(userID: self.userID) // Present the ScheduleWalkView
            }
        }
        .onAppear(perform: fetchUpcomingWalks)
    }
    
    private func fetchUpcomingWalks() {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("❌ Error fetching upcoming_walks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            guard let rawWalks = data["upcoming_walks"] as? [[String: Any]] else {
                print("⚠️ No upcoming_walks field found.")
                return
            }
            print(rawWalks)

            var loadedWalks: [DogWalk] = []

            _ = ISO8601DateFormatter()

            for walk in rawWalks {
                guard let dogName = walk["dogName"] as? String,
                      let walkerName = walk["walkerName"] as? String,
                      let timestamp = walk["startTime"] as? Timestamp,
                      let duration = walk["duration"] as? Int,
                      let price = walk["price"] as? Double,
                      let statusString = walk["status"] as? String,
                      let status = WalkStatus(rawValue: statusString.capitalized) else {
                    continue
                }

                let walkItem = DogWalk(
                    dogName: dogName,
                    walkerName: walkerName,
                    startTime: timestamp.dateValue(),
                    duration: duration,
                    price: price,
                    status: status
                )
                print(walkItem)
                loadedWalks.append(walkItem)
                
            }

            self.walks = loadedWalks
            print(self.walks)
        }
    }

    // MARK: - Components
    private var calendarHeader: some View {
        HStack {
            Button(action: {
                adjustDate(by: -1)
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }

            Spacer()

            Text(dateRangeTitle)
                .font(.headline)

            Spacer()

            Button(action: {
                adjustDate(by: 1)
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }

    private var todayButton: some View {
        Button("Today") {
            selectedDate = Date()
        }
    }

    private var upcomingWalksList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- MODIFICATION START ---
            // Put Title and Button in an HStack
            HStack {
                Text("Upcoming Walks")
                    .font(.headline)
                Spacer() // Pushes the button to the right
                Button {
                    showingScheduleSheet = true // Set the state to true to show the sheet
                } label: {
                    Image(systemName: "plus")
                        .font(.headline) // Match font style if desired
                }
            }
            .padding() // Apply padding to the HStack
            // --- MODIFICATION END ---

            Divider()

            if filteredWalks.isEmpty {
                VStack {
                    Text("No walks scheduled")
                        .foregroundColor(.secondary)

                    Button("Book a Walk") {
                        // Navigate to walk booking screen OR show the sheet directly
                         showingScheduleSheet = true // Also trigger sheet here if needed
                        // print("Navigate to booking screen") // Keep old logic if separate
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(filteredWalks) { walk in
                    WalkListItemView(walk: walk)
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding() // Padding for the entire list section
    }

    // MARK: - Helper Methods
    private var filteredWalks: [DogWalk] {
        // Filter logic based on selectedDate and calendarViewMode
        // Ensure this uses the `walks` state variable
        walks.filter { walk in
            switch calendarViewMode {
            case .day:
                return Calendar.current.isDate(walk.startTime, inSameDayAs: selectedDate)
            case .week:
                guard let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)),
                      let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) else {
                    return false
                }
                return walk.startTime >= weekStart && walk.startTime < weekEnd
            case .month:
                return Calendar.current.isDate(walk.startTime, equalTo: selectedDate, toGranularity: .month)
            }
        }.sorted { $0.startTime < $1.startTime } // Sort walks chronologically
    }


    private func adjustDate(by amount: Int) {
        switch calendarViewMode {
        case .day:
            selectedDate = Calendar.current.date(byAdding: .day, value: amount, to: selectedDate)!
        case .week:
            selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: amount, to: selectedDate)!
        case .month:
            selectedDate = Calendar.current.date(byAdding: .month, value: amount, to: selectedDate)!
        }
    }

    private var dateRangeTitle: String {
        let formatter = DateFormatter()

        switch calendarViewMode {
        case .day:
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
            return formatter.string(from: selectedDate)
        case .week:
            let calendar = Calendar.current
            guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)),
                  let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                return "Error calculating week range" // Fallback
            }

            formatter.dateFormat = "MMM d"
            let startString = formatter.string(from: weekStart)
            let endString = formatter.string(from: weekEnd)

            formatter.dateFormat = ", yyyy"
            let yearString = formatter.string(from: weekEnd) // Use weekEnd for the year

            // Check if start and end month are the same
            formatter.dateFormat = "MMMM"
            let startMonthString = formatter.string(from: weekStart)
            let endMonthString = formatter.string(from: weekEnd)

            if startMonthString == endMonthString {
                 formatter.dateFormat = "d"
                 let endDayString = formatter.string(from: weekEnd)
                 return "\(startMonthString) \(startString.split(separator: " ").last ?? "") - \(endDayString)\(yearString)" // e.g., May 26 - 31, 2025
            } else {
                 return "\(startString) - \(endString)\(yearString)" // e.g., Apr 28 - May 4, 2025
            }

        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        }
    }
}

// MARK: - Day View (Keep as is)
struct DayView: View {
    @Binding var date: Date
    let walks: [DogWalk]

    var body: some View {
        VStack(spacing: 0) {
            // Time slots
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HourSlotView(
                            hour: hour,
                            walks: walks.filter { walk in
                                Calendar.current.component(.hour, from: walk.startTime) == hour
                            }
                        )
                        Divider()
                    }
                }
            }
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - Hour Slot View (Keep as is)
struct HourSlotView: View {
    let hour: Int
    let walks: [DogWalk]

    var hourFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a" // e.g., 9 AM, 1 PM
        let date = Calendar.current.date(from: DateComponents(hour: hour))!
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) { // Added spacing
            Text(hourFormatted)
                .font(.caption)
                .frame(width: 50, alignment: .trailing) // Adjusted alignment
                .padding(.top, 8) // Align text better with potential bubbles

            VStack(alignment: .leading, spacing: 4) { // Use VStack for multiple walks per hour
                if walks.isEmpty {
                    Spacer() // Fill space if no walks
                        .frame(height: 1) // Give it minimal height
                } else {
                    ForEach(walks) { walk in
                        WalkBubbleView(walk: walk)
                    }
                     Spacer() // Push content to top if needed
                }
            }
             .frame(maxWidth: .infinity, alignment: .leading) // Expand the VStack


        }
        .padding(.horizontal)
         // Adjust height based on content or set a minimum
        .frame(minHeight: 60, alignment: .top)
    }
}


// MARK: - Week View (Keep as is)
struct WeekView: View {
    @Binding var selectedDate: Date
    let walks: [DogWalk]

    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGray5))

            // Week grid
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    let dateForColumn = getDate(for: index)
                    DayColumn(
                        date: dateForColumn,
                        walks: walksForDay(date: dateForColumn), // Pass correct walks
                        isSelected: isSelectedDay(date: dateForColumn), // Check against correct date
                        onTap: {
                            selectedDate = dateForColumn // Update selectedDate
                        }
                    )

                    if index < 6 {
                         // Use geometry reader or fixed width if columns overlap
                        Rectangle().fill(Color(.systemGray4)).frame(width: 1)
                    }
                }
            }
             .frame(maxHeight: .infinity) // Allow columns to expand vertically
        }
        .background(Color(.systemGray6))
    }

    // MARK: - Helper Methods
    private func getDate(for index: Int) -> Date {
        let calendar = Calendar.current
        // Use the start of the *week* containing the selectedDate
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) else {
            return Date() // Fallback
        }
        return calendar.date(byAdding: .day, value: index, to: weekStart)!
    }

    private func walksForDay(date: Date) -> [DogWalk] {
        // Filter walks for the specific date passed in
        walks.filter { walk in
            Calendar.current.isDate(walk.startTime, inSameDayAs: date)
        }
    }

    private func isSelectedDay(date: Date) -> Bool {
         // Compare the column's date with the main selectedDate
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

// MARK: - Day Column (Keep as is)
struct DayColumn: View {
    let date: Date
    let walks: [DogWalk]
    let isSelected: Bool
    let onTap: () -> Void

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) { // Added spacing
            // Day number
            Text(dayNumber)
                .font(.system(size: 12)) // Make slightly smaller if needed
                .padding(6) // Slightly smaller padding
                 .frame(width: 24, height: 24) // Ensure circle size is consistent
                .background(isSelected ? Color.blue.opacity(0.7) : (isToday(date) ? Color.gray.opacity(0.3) : Color.clear))
                .foregroundColor(isSelected ? .white : (isToday(date) ? .blue : .primary))
                .clipShape(Circle())
                .onTapGesture(perform: onTap)
                 .padding(.top, 5) // Add padding at the top

            // Walks indicator (dots)
             HStack(spacing: 3) { // Horizontal dots
                ForEach(walks.prefix(3)) { _ in // Show max 3 dots
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(minHeight: 10) // Ensure space for dots

            Spacer() // Push content to top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to fill space
        .contentShape(Rectangle()) // Make the whole area tappable
        .onTapGesture(perform: onTap) // Allow tapping whole column
        // Remove background from here if DayColumn itself shouldn't have the Today indicator fill
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}


// MARK: - Month View (Keep as is)
struct MonthView: View {
    @Binding var selectedDate: Date
    let walks: [DogWalk]

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"] // Abbreviated

    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8) // Consistent padding
                }
            }
            .background(Color(.systemGray5)) // Use system color

             // Calendar grid - Ensure spacing between cells if needed
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(daysInMonth(), id: \.self) { dateOptional in
                    if let date = dateOptional {
                        CalendarDayCell(
                            date: date,
                            walks: walksForDay(date: date),
                            isSelected: isSelected(date: date),
                            isCurrentMonth: isCurrentMonth(date: date), // Pass current month info
                            onTap: {
                                selectedDate = date
                            }
                        )
                    } else {
                        // Placeholder for empty cells
                        Rectangle()
                            .fill(Color.clear) // Use clear background
                            .frame(height: 45) // Match approximate cell height
                            .overlay(
                                Rectangle().stroke(Color.gray.opacity(0.2), lineWidth: 0.5) // Keep grid lines consistent
                            )
                    }
                }
            }
        }
        .background(Color(.systemGray6)) // Use system color
        .gesture( // Add swipe gesture for changing months
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 { // Swipe Left
                        changeMonth(by: 1)
                    } else if value.translation.width > 50 { // Swipe Right
                        changeMonth(by: -1)
                    }
                }
        )
    }

    // MARK: - Helper Methods
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current

        // Get start of the month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
              // Get the number of days in the month
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return [] // Return empty if calculation fails
        }
        let numDays = range.count

        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc. adjust to 0-indexed)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - calendar.firstWeekday // Adjust based on locale's first weekday

        // Create the array of dates
        // Add leading empty cells
        var dates: [Date?] = Array(repeating: nil, count: (firstWeekday + 7) % 7) // Ensure correct calculation for week start

        // Add days of the month
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }

         // Pad to complete the grid (usually 6 rows = 42 cells)
        let totalCells = 42 // Common calendar grid size
        let trailingPadding = totalCells - dates.count
        if trailingPadding > 0 {
             dates.append(contentsOf: [Date?](repeating: nil, count: trailingPadding))
        } else {
             // Handle cases where month spans more than 6 weeks if necessary
        }


        return dates
    }

    private func walksForDay(date: Date) -> [DogWalk] {
        walks.filter { walk in
            Calendar.current.isDate(walk.startTime, inSameDayAs: date)
        }
    }

    private func isSelected(date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

     // Helper to check if a date is within the currently displayed month
    private func isCurrentMonth(date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }

    // Helper function to change the month
    private func changeMonth(by amount: Int) {
         if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: selectedDate) {
             selectedDate = newDate
         }
     }
}

// MARK: - Calendar Day Cell (Keep as is)
struct CalendarDayCell: View {
    let date: Date
    let walks: [DogWalk]
    let isSelected: Bool
    let isCurrentMonth: Bool // Added property
    let onTap: () -> Void

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 2) {
            // Day number
            Text(dayNumber)
                .font(.system(size: 12)) // Slightly smaller font
                .padding(4) // Reduced padding
                 .frame(width: 22, height: 22) // Ensure circle size
                 .background(isSelected ? Color.blue.opacity(0.7) : (isToday(date) ? Color.gray.opacity(0.3) : Color.clear))
                .foregroundColor(isSelected ? .white : (isToday(date) ? .blue : (isCurrentMonth ? .primary : .secondary))) // Dim days outside current month
                .clipShape(Circle())
                .opacity(isCurrentMonth ? 1.0 : 0.5) // Visually dim non-current month days


            // Walk indicator - simple dot
            if !walks.isEmpty && isCurrentMonth { // Show indicator only for current month
                Circle()
                    .fill(Color.blue)
                    .frame(width: 5, height: 5) // Smaller dot
            } else {
                 // Placeholder to maintain layout consistency
                Spacer().frame(height: 5)
            }
        }
         .frame(height: 45) // Define cell height
         .frame(maxWidth: .infinity) // Expand horizontally
        .background(Color.clear) // Cell background
        .overlay(
             // Add border for grid lines
            Rectangle().stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .contentShape(Rectangle()) // Make the whole cell tappable
        .onTapGesture {
            if isCurrentMonth { // Only allow selection of days in the current month
                onTap()
            }
        }
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}


// MARK: - Walk Bubble View (Keep as is)
struct WalkBubbleView: View {
    let walk: DogWalk

    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // Use short time style e.g., 9:00 AM
        return formatter.string(from: walk.startTime)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(startTimeString)
                    .font(.caption)
                    .bold()

                Text(walk.dogName)
                    .font(.caption2) // Smaller font for dog name
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 6) // Reduced padding
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6) // Slightly smaller radius
                .fill(Color.blue.opacity(0.2)) // Adjusted opacity
        )
//        .overlay( // Optional: Remove overlay if too noisy
//            RoundedRectangle(cornerRadius: 6)
//                .stroke(Color.blue.opacity(0.4), lineWidth: 0.5) // Thinner stroke
//        )
    }
}

// MARK: - Walk List Item View (Keep as is)
struct WalkListItemView: View {
    let walk: DogWalk

    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d • h:mm a" // Format example: Tue, May 6 • 9:00 AM
        return formatter.string(from: walk.startTime)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) { // Align center vertically
            // Dog image placeholder
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50) // Slightly smaller circle

                Image(systemName: "pawprint.fill") // Or load dog's image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25) // Smaller icon
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) { // Reduced spacing
                Text(walk.dogName)
                    .font(.headline) // Use headline for dog name
                    // .fontWeight(.semibold) // Default headline weight is often sufficient

                Text(dateTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                     Label { Text("\(walk.duration) min") } icon: { Image(systemName: "clock") }
                        .font(.subheadline)

                    Label { Text(walk.walkerName) } icon: { Image(systemName: "person") }
                        .font(.subheadline)
                         .lineLimit(1) // Ensure walker name doesn't wrap excessively
                }
                .foregroundColor(.secondary) // Make icons/text secondary color

                HStack {
                     Text(walk.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(walk.status).opacity(0.15)) // Slightly stronger background
                        .foregroundColor(statusColor(walk.status))
                        .cornerRadius(8)

                    Spacer()

                    Text("$\(String(format: "%.2f", walk.price))")
                        .font(.headline)
                        .foregroundColor(statusColor(walk.status)) // Match status color? Or keep green?
                        // .foregroundColor(.green) // Or keep original green color
                }
            }

            Spacer() // Ensure content pushes left

            Button(action: {
                // TODO: Action to view walk details
                print("View details for walk ID: \(walk.id)")
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5)) // Make chevron less prominent
            }
        }
        .padding()
    }

    func statusColor(_ status: WalkStatus) -> Color {
        switch status {
        case .upcoming:
            return .blue
        case .inProgress:
            return .orange
        case .completed:
            return .green
        case .canceled:
            return .red
        }
    }
}


// MARK: - Models (Keep as is)
enum CalendarViewMode {
    case day, week, month
}

// Make DogWalk Hashable if needed elsewhere, Identifiable is often sufficient
struct DogWalk: Identifiable, Hashable {
    let id = UUID()
    let dogName: String
    let walkerName: String
    let startTime: Date
    let duration: Int  // in minutes
    let price: Double
    var status: WalkStatus // Changed to var if status can change

    var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: duration, to: startTime)!
    }
}

enum WalkStatus: String, CaseIterable { // Added CaseIterable if needed
    case upcoming = "upcoming"
    case inProgress = "In Progress"
    case completed = "completed"
    case canceled = "canceled"
}

// MARK: - Preview
struct FutureWalksView_Previews: PreviewProvider {
    static var previews: some View {
        FutureWalksView(userID: "gwcZGcoKNwa1iS7424utiwzY1G62")
    }
}
