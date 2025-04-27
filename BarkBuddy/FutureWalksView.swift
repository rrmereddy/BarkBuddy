//
//  FutureWalksView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/12/25.
//

import SwiftUI

struct FutureWalksView: View {
    // MARK: - Properties
    @State private var calendarViewMode: CalendarViewMode = .week
    @State private var selectedDate = Date()
    @State private var walks: [DogWalk] = sampleWalks
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
            Text("Upcoming Walks")
                .font(.headline)
                .padding()
            
            Divider()
            
            if filteredWalks.isEmpty {
                VStack {
                    Text("No walks scheduled")
                        .foregroundColor(.secondary)
                    
                    Button("Book a Walk") {
                        // Navigate to walk booking screen
                        print("Navigate to booking screen")
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
        .padding()
    }
    
    // MARK: - Helper Methods
    private var filteredWalks: [DogWalk] {
        walks.filter { walk in
            switch calendarViewMode {
            case .day:
                return Calendar.current.isDate(walk.startTime, inSameDayAs: selectedDate)
            case .week:
                let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
                let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
                return walk.startTime >= weekStart && walk.startTime < weekEnd
            case .month:
                return Calendar.current.isDate(walk.startTime, equalTo: selectedDate, toGranularity: .month)
            }
        }
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
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            formatter.dateFormat = "MMM d"
            let startString = formatter.string(from: weekStart)
            let endString = formatter.string(from: weekEnd)
            
            formatter.dateFormat = ", yyyy"
            let yearString = formatter.string(from: weekEnd)
            
            return "\(startString) - \(endString)\(yearString)"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        }
    }
}

// MARK: - Day View
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

struct HourSlotView: View {
    let hour: Int
    let walks: [DogWalk]
    
    var hourFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(from: DateComponents(hour: hour))!
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(hourFormatted)
                .font(.caption)
                .frame(width: 50, alignment: .leading)
                .padding(.vertical, 8)
            
            if walks.isEmpty {
                Spacer()
            } else {
                VStack(spacing: 6) {
                    ForEach(walks) { walk in
                        WalkBubbleView(walk: walk)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.horizontal)
        .frame(height: 60)
    }
}

// MARK: - Week View
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
                    DayColumn(
                        date: getDate(for: index),
                        walks: walksForDay(index: index),
                        isSelected: isSelectedDay(index: index),
                        onTap: {
                            selectedDate = getDate(for: index)
                        }
                    )
                    
                    if index < 6 {
                        Divider()
                    }
                }
            }
        }
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Methods
    private func getDate(for index: Int) -> Date {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return calendar.date(byAdding: .day, value: index, to: weekStart)!
    }
    
    private func walksForDay(index: Int) -> [DogWalk] {
        let dayDate = getDate(for: index)
        return walks.filter { walk in
            Calendar.current.isDate(walk.startTime, inSameDayAs: dayDate)
        }
    }
    
    private func isSelectedDay(index: Int) -> Bool {
        let dayDate = getDate(for: index)
        return Calendar.current.isDate(dayDate, inSameDayAs: selectedDate)
    }
}

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
        VStack(spacing: 0) {
            // Day number
            Text(dayNumber)
                .padding(8)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(Circle())
                .onTapGesture(perform: onTap)
            
            // Walks for this day - simple indicator
            if !walks.isEmpty {
                Text("\(walks.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(isToday(date) ? Color.blue.opacity(0.05) : Color.clear)
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Month View
struct MonthView: View {
    @Binding var selectedDate: Date
    let walks: [DogWalk]
    
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
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
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if date == nil {
                        Color.clear
                            .frame(height: 35)
                    } else {
                        CalendarDayCell(
                            date: date!,
                            walks: walksForDay(date: date!),
                            isSelected: isSelected(date: date!),
                            onTap: {
                                selectedDate = date!
                            }
                        )
                    }
                }
            }
        }
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Methods
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // Get start of the month
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        let startOfMonth = calendar.date(from: components)!
        
        // Get the weekday of the first day (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        
        // Get the number of days in the month
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numDays = range.count
        
        // Create the array of dates
        var dates = [Date?](repeating: nil, count: firstWeekday)
        
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Pad to complete the last week if needed
        let remainder = (dates.count % 7 == 0) ? 0 : 7 - (dates.count % 7)
        dates.append(contentsOf: [Date?](repeating: nil, count: remainder))
        
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
}

struct CalendarDayCell: View {
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
        VStack(spacing: 2) {
            // Day number
            Text(dayNumber)
                .font(.callout)
                .padding(4)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(Circle())
            
            // Walk indicator - simple dot
            if !walks.isEmpty {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 35)
        .background(isToday(date) ? Color.blue.opacity(0.05) : Color.clear)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .onTapGesture(perform: onTap)
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Walk Bubble View
struct WalkBubbleView: View {
    let walk: DogWalk
    
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: walk.startTime)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(startTimeString)
                    .font(.caption)
                    .bold()
                
                Text("\(walk.dogName)")
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Walk List Item View
struct WalkListItemView: View {
    let walk: DogWalk
    
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d • h:mm a"
        return formatter.string(from: walk.startTime)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Dog image
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(walk.dogName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(dateTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label("\(walk.duration) min", systemImage: "clock")
                        .font(.subheadline)
                    
                    Label(walk.walkerName, systemImage: "person")
                        .font(.subheadline)
                }
                
                HStack {
                    Text(walk.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(walk.status).opacity(0.1))
                        .foregroundColor(statusColor(walk.status))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", walk.price))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Action to view details
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
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

// MARK: - Models
enum CalendarViewMode {
    case day, week, month
}

struct DogWalk: Identifiable {
    let id = UUID()
    let dogName: String
    let walkerName: String
    let startTime: Date
    let duration: Int  // in minutes
    let price: Double
    let status: WalkStatus
    
    var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: duration, to: startTime)!
    }
}

enum WalkStatus: String {
    case upcoming = "Upcoming"
    case inProgress = "In Progress"
    case completed = "Completed"
    case canceled = "Canceled"
}

// MARK: - Sample Data
let sampleWalks: [DogWalk] = {
    let calendar = Calendar.current
    let now = Date()
    
    // Create dates for today, tomorrow, and next week
    let today = calendar.startOfDay(for: now)
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
    let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
    
    return [
        // Today's walks
        DogWalk(
            dogName: "Max",
            walkerName: "John",
            startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
            duration: 30,
            price: 15.00,
            status: .upcoming
        ),
        DogWalk(
            dogName: "Bella",
            walkerName: "Sarah",
            startTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today)!,
            duration: 45,
            price: 22.50,
            status: .upcoming
        ),
        
        // Tomorrow's walks
        DogWalk(
            dogName: "Charlie",
            walkerName: "Mike",
            startTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow)!,
            duration: 60,
            price: 30.00,
            status: .upcoming
        ),
        DogWalk(
            dogName: "Luna",
            walkerName: "Jessica",
            startTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: tomorrow)!,
            duration: 45,
            price: 22.50,
            status: .upcoming
        ),
        
        // Next week's walks
        DogWalk(
            dogName: "Cooper",
            walkerName: "David",
            startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: nextWeek)!,
            duration: 30,
            price: 15.00,
            status: .upcoming
        ),
        DogWalk(
            dogName: "Daisy",
            walkerName: "Emily",
            startTime: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: nextWeek)!,
            duration: 60,
            price: 30.00,
            status: .upcoming
        )
    ]
}()

// MARK: - Preview
struct FutureWalksView_Previews: PreviewProvider {
    static var previews: some View {
        FutureWalksView()
    }
}
