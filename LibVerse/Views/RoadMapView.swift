//
//  RoadMapView.swift
//  LibVerse
//

import SwiftUI
import Supabase

struct RoadMapView: View {
    @State private var courseDescription = ""
    @State private var roadmapContent = ""
    @State private var isLoading = false
    @State private var sections: [RoadmapSection] = []
    @State private var selectedSection: String? = nil
    @StateObject private var bookService = BookService()
    @FocusState private var isTextFieldFocused: Bool
    @State private var glowOpacity: Double = 0.6
    @State private var showingRoadmapDropdown = false
    @State private var savedRoadmaps: [SavedRoadmap] = []
    @State private var roadmapName = ""
    @State private var showingSaveDialog = false
    
    let supabaseManager = SupabaseManager.shared
    let sectionTypes = ["All", "Overview", "Setup", "Basics", "Intermediate", "Advanced", "Projects", "Resources"]
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    TextField("Describe your course", text: $courseDescription)
                        .focused($isTextFieldFocused)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isTextFieldFocused ? Color(hex: "EE7741") : Color.gray.opacity(0.3), 
                                        lineWidth: isTextFieldFocused ? 2 : 1)
                        )
                        .shadow(color: isTextFieldFocused && !courseDescription.isEmpty ? 
                                Color(hex: "EE7741").opacity(glowOpacity) : 
                                (isTextFieldFocused ? Color(hex: "EE7741").opacity(0.6) : .clear), 
                                radius: 6, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused)
                        .onChange(of: isTextFieldFocused) { focused in
                            if focused && !courseDescription.isEmpty {
                                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                    glowOpacity = 0.8
                                }
                            } else {
                                withAnimation {
                                    glowOpacity = 0.6
                                }
                            }
                        }
                        .onChange(of: courseDescription) { newValue in
                            if isTextFieldFocused && !newValue.isEmpty {
                                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                    glowOpacity = 0.8
                                }
                            } else if newValue.isEmpty {
                                withAnimation {
                                    glowOpacity = 0.6
                                }
                            }
                        }
                    
                    Button(action: {
                        if !courseDescription.isEmpty {
                            isTextFieldFocused = false
                            generateRoadmap()
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "EE7741"))
                    }
                    .padding(.leading, 8)
                    .disabled(isLoading)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Section filter buttons
                if !sections.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(sectionTypes, id: \.self) { sectionType in
                                Button(action: {
                                    withAnimation {
                                        selectedSection = sectionType == "All" ? nil : sectionType
                                    }
                                }) {
                                    Text(sectionType)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedSection == sectionType || (sectionType == "All" && selectedSection == nil) ?
                                                Color(hex: "EE7741") : Color.white
                                        )
                                        .foregroundColor(
                                            selectedSection == sectionType || (sectionType == "All" && selectedSection == nil) ?
                                                Color.white : Color.black
                                        )
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "EE7741"), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 4)
                }
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Spacer()
                } else if !sections.isEmpty {
                    // Main content including roadmap and book drawer
                    ZStack(alignment: .bottom) {
                        // Roadmap sections
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(filteredSections) { section in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(section.title)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(hex: "EE7741"))
                                            
                                            if let timeframe = extractTimeframe(from: section.title) {
                                                Spacer()
                                                Text(timeframe)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        Text(formatText(section.content))
                                            .font(.system(.body, design: .serif))
                                            .lineSpacing(8)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.bottom, bookService.isExpanded ? 300 : 40)
                        }
                        
                        // Book recommendations drawer
                        VStack(spacing: 0) {
                            // Handle for expanding/collapsing
                            Button(action: {
                                withAnimation(.spring()) {
                                    bookService.isExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Recommended Books")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                        .padding(.leading, 16)
                                    
                                    Spacer()
                                    
                                    Image(systemName: bookService.isExpanded ? "chevron.down" : "chevron.up")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(hex: "EE7741"))
                                        .padding(.trailing, 16)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(hex: "FCEFD5").opacity(0.9))
                                .cornerRadius(12, corners: [.topLeft, .topRight])
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
                            }
                            
                            // Books list
                            if bookService.isExpanded {
                                if bookService.isLoading {
                                    ProgressView()
                                        .frame(height: 150)
                                } else if bookService.recommendedBooks.isEmpty {
                                    Text("No book recommendations found")
                                        .frame(height: 150)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(bookService.recommendedBooks) { book in
                                                VStack(alignment: .leading, spacing: 8) {
                                                    // Book cover
                                                    AsyncImage(url: URL(string: book.imageURL.replacingOccurrences(of: "http:", with: "https:"))) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            Rectangle()
                                                                .fill(Color.gray.opacity(0.3))
                                                                .frame(width: 110, height: 165)
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: 110, height: 165)
                                                                .shadow(radius: 2)
                                                        case .failure:
                                                            Rectangle()
                                                                .fill(Color.gray.opacity(0.3))
                                                                .frame(width: 110, height: 165)
                                                                .overlay(
                                                                    Text("Error")
                                                                        .font(.caption)
                                                                )
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                    
                                                    // Book info
                                                    VStack(alignment: .leading, spacing: 6) {
                                                        Text(book.title)
                                                            .font(.system(size: 16, weight: .medium))
                                                            .lineLimit(2)
                                                            .frame(width: 120)
                                                        
                                                        Text(book.authors.joined(separator: ", "))
                                                            .font(.system(size: 14))
                                                            .foregroundColor(.gray)
                                                            .lineLimit(1)
                                                            .frame(width: 120)
                                                    }
                                                }
                                                .frame(width: 140)
                                                .padding(.vertical, 12)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .frame(height: 270)
                                    .background(Color(hex: "FCEFD5"))
                                }
                            }
                        }
                        .background(Color(hex: "FCEFD5"))
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
                        .frame(maxWidth: .infinity)
                        .offset(y: bookService.isExpanded ? 0 : 40)
                    }
                }
                
                Spacer()
            }
            
            if showingSaveDialog {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Save Roadmap")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Roadmap Name", text: $roadmapName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                        
                        HStack {
                            Button("Cancel") {
                                showingSaveDialog = false
                                roadmapName = ""
                            }
                            .padding()
                            .foregroundColor(.gray)
                            
                            Button("Save") {
                                saveRoadmap()
                                showingSaveDialog = false
                                roadmapName = ""
                            }
                            .padding()
                            .background(Color(hex: "EE7741"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.bottom)
                    }
                    .frame(width: 300)
                    .background(Color(hex: "FCEFD5"))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
                .zIndex(2)
            }
        }
        .navigationTitle("Road Map")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        courseDescription = ""
                        roadmapContent = ""
                        sections = []
                        selectedSection = nil
                        bookService.recommendedBooks = []
                    } label: {
                        Label("New Roadmap", systemImage: "plus")
                    }
                    
                    if !sections.isEmpty {
                        Button {
                            showingSaveDialog = true
                        } label: {
                            Label("Save Current Roadmap", systemImage: "square.and.arrow.down")
                        }
                    }
                    
                    Divider()
                    
                    Menu("My Roadmaps") {
                        if savedRoadmaps.isEmpty {
                            Text("No saved roadmaps")
                        } else {
                            ForEach(savedRoadmaps) { roadmap in
                                Menu(roadmap.title) {
                                    Button("Load") {
                                        loadRoadmap(roadmap)
                                    }
                                    
                                    Divider()
                                    
                                    Button("Delete", role: .destructive) {
                                        deleteRoadmap(roadmap)
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color(hex: "EE7741"))
                }
            }
        }
        .onAppear {
            loadSavedRoadmaps()
        }
    }
    
    var filteredSections: [RoadmapSection] {
        if selectedSection == nil {
            return sections
        } else {
            // Special case for "Overview" since it might not have exact match in title
            if selectedSection == "Overview" {
                let overviewKeywords = ["overview", "introduction", "getting started", "week 1", "beginning"]
                return sections.filter { section in
                    let lowercaseTitle = section.title.lowercased()
                    return overviewKeywords.contains { keyword in
                        lowercaseTitle.contains(keyword)
                    }
                }
            } else {
                return sections.filter { section in
                    section.title.lowercased().contains(selectedSection!.lowercased())
                }
            }
        }
    }
    
    func generateRoadmap() {
        isLoading = true
        sections = []
        selectedSection = nil
        
        // Also fetch book recommendations based on the course
        bookService.fetchRelatedBooks(for: courseDescription)
        
        // Gemini API endpoint
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyA_lmM7Lg782TEWRL6hMILar8hCxCe4szw")!
        
        // Create the request body
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": """
                            Generate a detailed timeline-based roadmap for learning \(courseDescription).
                            Format your response with clear timeframes (weeks/months) for each section:
                            
                            1. Week 1-2: Getting Started and Setup
                            2. Week 3-4: Foundations and Basics
                            3. Month 2: Intermediate Concepts
                            4. Month 3: Advanced Topics
                            5. Month 4: Projects and Applications
                            6. Throughout: Recommended Resources
                            
                            For each timeframe section:
                            - Include what the learner should accomplish in that timeframe
                            - List specific skills to master
                            - Provide concrete tasks and mini-projects
                            - Add time estimates for each major task
                            
                            Make the roadmap realistic and achievement-focused with clear milestones.
                            Format with simple clean text (no markdown or asterisks).
                            """
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "topP": 0.7,
                "topK": 40
            ]
        ]
        
        // Convert request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            isLoading = false
            roadmapContent = "Error: Failed to create request"
            return
        }
        
        // Create and configure the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.roadmapContent = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.roadmapContent = "Error: No data received"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let text = firstPart["text"] as? String {
                        
                        // Store the full roadmap content for reference
                        self.roadmapContent = text
                        
                        // Parse sections
                        self.parseSections(from: text)
                    } else {
                        // Try to get error message if present
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            self.roadmapContent = "API Error: \(message)"
                        } else {
                            self.roadmapContent = "Error: Failed to parse API response"
                        }
                    }
                } catch {
                    self.roadmapContent = "Error parsing response: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
    }
    
    func parseSections(from text: String) {
        var parsedSections: [RoadmapSection] = []
        
        // Split text by common section markers
        let sectionMarkers = ["## ", "# ", "**", "Section ", "1. ", "2. ", "3. ", "4. ", "5. ", "6. ", "7. "]
        
        var lines = text.components(separatedBy: "\n")
        
        var currentTitle = ""
        var currentContent = ""
        
        // Special case: always add an Overview section with the first part of content
        var hasOverview = false
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if this line is a section header
            let isHeader = sectionMarkers.contains { marker in
                trimmedLine.hasPrefix(marker) && trimmedLine.count > marker.count
            } || (sectionTypes.contains { trimmedLine.lowercased().contains($0.lowercased()) } && trimmedLine.count < 50)
            
            // Check for explicit Overview section
            if isHeader && trimmedLine.lowercased().contains("overview") {
                hasOverview = true
            }
            
            if isHeader || index == lines.count - 1 {
                // Save the previous section if it exists
                if !currentTitle.isEmpty && !currentContent.isEmpty {
                    let section = RoadmapSection(
                        id: UUID().uuidString,
                        title: cleanHeaderText(currentTitle),
                        content: currentContent.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    parsedSections.append(section)
                }
                
                // Start a new section
                if isHeader {
                    currentTitle = trimmedLine
                    currentContent = ""
                }
            } else {
                // Add to current content
                if !currentContent.isEmpty {
                    currentContent += "\n"
                }
                currentContent += line
            }
        }
        
        // If no overview section was found, create one with the first few paragraphs
        if !hasOverview && !parsedSections.isEmpty {
            let overviewContent: String
            if let firstSection = parsedSections.first {
                // Use first few lines of the first section
                let firstSectionLines = firstSection.content.components(separatedBy: "\n")
                let introLines = firstSectionLines.prefix(min(8, firstSectionLines.count))
                overviewContent = introLines.joined(separator: "\n")
            } else {
                overviewContent = "No overview available."
            }
            
            parsedSections.insert(
                RoadmapSection(
                    id: UUID().uuidString,
                    title: "Overview",
                    content: overviewContent
                ),
                at: 0
            )
        }
        
        // Check if we need to add sections manually
        if parsedSections.isEmpty && !roadmapContent.isEmpty {
            // Create a fallback "Overview" section with the entire content
            parsedSections.append(
                RoadmapSection(
                    id: UUID().uuidString,
                    title: "Overview",
                    content: roadmapContent
                )
            )
        }
        
        sections = parsedSections
    }
    
    func cleanHeaderText(_ header: String) -> String {
        var result = header
            .replacingOccurrences(of: "# ", with: "")
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
        
        // Remove numbered prefixes like "1. ", "2. ", etc.
        if let range = result.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
            result = String(result[range.upperBound...])
        }
        
        // Remove colons at the end
        if result.hasSuffix(":") {
            result = String(result.dropLast())
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func extractTimeframe(from title: String) -> String? {
        let timePatterns = [
            #"Week \d+(?:-\d+)?"#,         // Week 1, Week 1-2
            #"Month \d+(?:-\d+)?"#,         // Month 1, Month 1-2
            #"Day \d+(?:-\d+)?"#,           // Day 1, Day 1-3
            #"\d+ weeks?"#,                 // 1 week, 2 weeks
            #"\d+ months?"#,                // 1 month, 2 months
            #"\d+ days?"#,                  // 1 day, 5 days
            #"\d+-\d+ weeks?"#,             // 1-2 weeks
            #"\d+-\d+ months?"#,            // 1-2 months
            #"\d+-\d+ days?"#               // 1-3 days
        ]
        
        let lowercaseTitle = title.lowercased()
        
        for pattern in timePatterns {
            if let range = lowercaseTitle.range(of: pattern, options: .regularExpression) {
                let timeframe = String(lowercaseTitle[range])
                return timeframe.prefix(1).capitalized + timeframe.dropFirst()
            }
        }
        
        return nil
    }
    
    func formatText(_ text: String) -> String {
        var formattedText = text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "#", with: "")
        
        // Replace markdown bullet points with proper bullet points
        formattedText = formattedText.replacingOccurrences(of: "- ", with: "• ")
        formattedText = formattedText.replacingOccurrences(of: "• •", with: "•")
        
        // Highlight time references in content
        let timePatterns = [
            #"(\d+ minutes?)"#,
            #"(\d+ hours?)"#,
            #"(\d+ days?)"#,
            #"(\d+ weeks?)"#,
            #"(\d+ months?)"#
        ]
        
        var processedLines: [String] = []
        let lines = formattedText.components(separatedBy: "\n")
        
        for line in lines {
            var processedLine = line
            
            for pattern in timePatterns {
                processedLine = processedLine.replacingOccurrences(
                    of: pattern,
                    with: "[$1]",
                    options: .regularExpression
                )
            }
            
            processedLines.append(processedLine)
        }
        
        formattedText = processedLines.joined(separator: "\n")
        
        // Convert markdown numbered lists to proper numbered lists
        let numberedListPattern = #"^\d+\.\s+"#
        let numberedLines = formattedText.components(separatedBy: "\n")
        var newLines: [String] = []
        
        for line in numberedLines {
            if let range = line.range(of: numberedListPattern, options: .regularExpression) {
                let prefix = String(line[..<range.upperBound])
                let content = String(line[range.upperBound...])
                newLines.append("\(prefix)\(content)")
            } else {
                newLines.append(line)
            }
        }
        
        return newLines.joined(separator: "\n")
    }
    
    func saveRoadmap() {
        guard !roadmapName.isEmpty && !sections.isEmpty, let userId = supabaseManager.currentUser?.id else {
            return
        }
        
        let roadmapId = UUID().uuidString
        
        // Create a serializable dictionary representation of the roadmap
        let roadmapDict: [String: Any] = [
            "id": roadmapId,
            "title": roadmapName,
            "content": roadmapContent,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "sections": sections.map { section in
                return [
                    "id": section.id,
                    "title": section.title,
                    "content": section.content
                ]
            }
        ]
        
        Task {
            do {
                // Fetch current user's roadmaps
                let response: [Member] = try await supabaseManager.client
                    .from("Member")
                    .select()
                    .eq("id", value: userId)
                    .execute()
                    .value
                
                if var member = response.first {
                    // Update or create roadmaps dictionary
                    var roadmaps = member.roadmaps as? [String: Any] ?? [:]
                    roadmaps[roadmapId] = roadmapDict
                    
                    // Convert roadmaps to JSON string for Supabase
                    let jsonData = try JSONSerialization.data(withJSONObject: roadmaps)
                    let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                    
                    // Update Supabase using the JSON string
                    try await supabaseManager.client
                        .from("Member")
                        .update(["roadmaps": jsonString])
                        .eq("id", value: userId)
                        .execute()
                    
                    // Refresh local list
                    await loadSavedRoadmaps()
                }
            } catch {
                print("Error saving roadmap: \(error)")
            }
        }
    }
    
    func loadSavedRoadmaps() {
        Task {
            do {
                guard let userId = supabaseManager.currentUser?.id else {
                    return
                }
                
                let response: [Member] = try await supabaseManager.client
                    .from("Member")
                    .select()
                    .eq("id", value: userId)
                    .execute()
                    .value
                
                if let member = response.first, let roadmapsDict = member.roadmaps as? [String: Any] {
                    // Convert the roadmaps dictionary to SavedRoadmap objects
                    var loadedRoadmaps: [SavedRoadmap] = []
                    
                    for (roadmapId, roadmapValue) in roadmapsDict {
                        if let roadmapInfo = roadmapValue as? [String: Any],
                           let title = roadmapInfo["title"] as? String,
                           let content = roadmapInfo["content"] as? String {
                            
                            // Parse created date
                            let createdAtString = roadmapInfo["createdAt"] as? String ?? ""
                            let createdAt = ISO8601DateFormatter().date(from: createdAtString) ?? Date()
                            
                            // Parse sections
                            var roadmapSections: [RoadmapSection] = []
                            if let sectionsArray = roadmapInfo["sections"] as? [[String: Any]] {
                                for sectionDict in sectionsArray {
                                    if let id = sectionDict["id"] as? String,
                                       let title = sectionDict["title"] as? String,
                                       let content = sectionDict["content"] as? String {
                                        roadmapSections.append(RoadmapSection(
                                            id: id,
                                            title: title,
                                            content: content
                                        ))
                                    }
                                }
                            }
                            
                            let roadmap = SavedRoadmap(
                                id: roadmapId,
                                title: title,
                                content: content,
                                sections: roadmapSections,
                                createdAt: createdAt
                            )
                            
                            loadedRoadmaps.append(roadmap)
                        }
                    }
                    
                    // Sort by most recent first
                    loadedRoadmaps.sort { $0.createdAt > $1.createdAt }
                    
                    DispatchQueue.main.async {
                        self.savedRoadmaps = loadedRoadmaps
                    }
                }
            } catch {
                print("Error loading roadmaps: \(error)")
            }
        }
    }
    
    func loadRoadmap(_ savedRoadmap: SavedRoadmap) {
        courseDescription = savedRoadmap.title
        roadmapContent = savedRoadmap.content
        
        // Convert SavedRoadmapSection to RoadmapSection
        let loadedSections = savedRoadmap.sections
        
        sections = loadedSections
        selectedSection = nil
        
        // Also load book recommendations based on the roadmap title
        bookService.fetchRelatedBooks(for: savedRoadmap.title)
    }
    
    func deleteRoadmap(_ roadmap: SavedRoadmap) {
        guard let userId = supabaseManager.currentUser?.id else {
            return
        }
        
        Task {
            do {
                let response: [Member] = try await supabaseManager.client
                    .from("Member")
                    .select()
                    .eq("id", value: userId)
                    .execute()
                    .value
                
                if var member = response.first, var roadmaps = member.roadmaps as? [String: Any] {
                    roadmaps.removeValue(forKey: roadmap.id)
                    
                    // Convert roadmaps to JSON string for Supabase
                    let jsonData = try JSONSerialization.data(withJSONObject: roadmaps)
                    let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
                    
                    // Update Supabase using the JSON string
                    try await supabaseManager.client
                        .from("Member")
                        .update(["roadmaps": jsonString])
                        .eq("id", value: userId)
                        .execute()
                    
                    // Refresh local list
                    await loadSavedRoadmaps()
                }
            } catch {
                print("Error deleting roadmap: \(error)")
            }
        }
    }
}

struct RoadmapSection: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
}

struct SavedRoadmap: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let sections: [RoadmapSection]
    
    init(id: String = UUID().uuidString, 
         title: String, 
         content: String, 
         sections: [RoadmapSection],
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.sections = sections
    }
    
    // Custom coding keys to match the JSON representation
    enum CodingKeys: String, CodingKey {
        case id, title, content, createdAt, sections
    }
    
    // Custom decoder to handle date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        
        // Handle date decoding - try ISO8601 format first, then fallback
        if let dateString = try? container.decode(String.self, forKey: .createdAt),
           let date = ISO8601DateFormatter().date(from: dateString) {
            createdAt = date
        } else {
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        }
        
        sections = try container.decode([RoadmapSection].self, forKey: .sections)
    }
    
    // Custom encoder to ensure proper date format
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        
        // Encode date in ISO8601 format
        let dateString = ISO8601DateFormatter().string(from: createdAt)
        try container.encode(dateString, forKey: .createdAt)
        
        try container.encode(sections, forKey: .sections)
    }
}

struct BookRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let authors: [String]
    let description: String
    let imageURL: String
    let isbn: String
}

class BookService: ObservableObject {
    @Published var recommendedBooks: [BookRecommendation] = []
    @Published var isLoading = false
    @Published var isExpanded = true
    
    func fetchRelatedBooks(for topic: String) {
        isLoading = true
        
        // Create a search query based on the topic
        let formattedQuery = topic.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(formattedQuery)+subject:programming&maxResults=10"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching books: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let items = json["items"] as? [[String: Any]] {
                        
                        var books: [BookRecommendation] = []
                        
                        for item in items {
                            if let volumeInfo = item["volumeInfo"] as? [String: Any],
                               let title = volumeInfo["title"] as? String {
                                
                                let authors = volumeInfo["authors"] as? [String] ?? ["Unknown Author"]
                                let description = volumeInfo["description"] as? String ?? "No description available"
                                
                                var isbn = "Unknown"
                                if let industryIdentifiers = volumeInfo["industryIdentifiers"] as? [[String: Any]] {
                                    for identifier in industryIdentifiers {
                                        if let type = identifier["type"] as? String,
                                           (type == "ISBN_13" || type == "ISBN_10"),
                                           let identifierValue = identifier["identifier"] as? String {
                                            isbn = identifierValue
                                            break
                                        }
                                    }
                                }
                                
                                var imageURL = "placeholder"
                                if let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
                                   let thumbnail = imageLinks["thumbnail"] as? String {
                                    imageURL = thumbnail
                                }
                                
                                let book = BookRecommendation(
                                    title: title,
                                    authors: authors,
                                    description: description,
                                    imageURL: imageURL,
                                    isbn: isbn
                                )
                                
                                books.append(book)
                            }
                        }
                        
                        self.recommendedBooks = books
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

// Extension to add corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    RoadMapView()
} 
