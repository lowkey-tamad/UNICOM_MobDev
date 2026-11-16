//
//  EditProfileView.swift
//  EucomCampusFeed
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @State private var fullName = ""
    @State private var department = ""
    @State private var yearLevel = ""
    @State private var birthdayDate: Date? = nil
    @State private var legacyBirthday = ""   // old free-text value we could not parse; kept unless a date is picked
    @State private var editingField: Field? = nil
    @FocusState private var focusedField: Field?

    @State private var pickedPhoto: PhotosPickerItem? = nil
    @State private var isUploading = false
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    enum Field: Hashable { case fullName, birthday, department, yearLevel }

    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.white)
                        }
                        Text("Edit Profile")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(url: appState.account.avatarURL, size: 90)
                            Image(systemName: isUploading ? "hourglass" : "camera.fill")
                                .foregroundStyle(.white)
                                .padding(6)
                                .glassTint(.appRed, in: Circle())
                        }
                    }

                    VStack(spacing: 12) {
                        readOnlyRow("Student ID", value: appState.account.studentId)
                        readOnlyRow("Email", value: appState.account.email)

                        row("Full Name", text: $fullName, field: .fullName)
                        birthdayRow
                        departmentRow
                        row(appState.account.isEmployee ? "Position" : "Course & Year", text: $yearLevel, field: .yearLevel)
                    }
                    .padding(.horizontal)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(Color.appPink)
                    }

                    Button(action: save) {
                        PrimaryGlassButton(title: isSaving ? "Saving..." : "Save Changes")
                    }
                    .disabled(isSaving)
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden)
        .onAppear(perform: load)
        .onChange(of: pickedPhoto) { _, item in
            guard let item else { return }
            Task {
                isUploading = true
                if let data = await item.loadJPEG(maxDimension: 512) {
                    do {
                        try await appState.uploadAvatar(data)
                        errorMessage = nil
                    } catch {
                        errorMessage = "Couldn't upload your photo."
                        print("avatar:", error)
                    }
                }
                isUploading = false
                pickedPhoto = nil
            }
        }
    }

    // MARK: - Actions
    func load() {
        fullName = appState.account.fullName
        if let date = Self.isoFormatter.date(from: appState.account.birthday) {
            birthdayDate = date
        } else {
            legacyBirthday = appState.account.birthday
        }
        department = appState.account.department
        yearLevel = appState.account.yearLevel
    }

    func save() {
        editingField = nil
        isSaving = true
        Task {
            do {
                let birthday = birthdayDate.map { Self.isoFormatter.string(from: $0) } ?? legacyBirthday
                try await appState.saveProfile(fullName: fullName, department: department,
                                               yearLevel: yearLevel, birthday: birthday)
                dismiss()
            } catch {
                errorMessage = "Couldn't save your changes."
                print("Save failed:", error)
            }
            isSaving = false
        }
    }

    // MARK: - Pickers
    static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // The current value stays selectable even if it is not in the official list.
    var departmentOptions: [String] {
        var list = Departments.list(for: appState.account.isEmployee ? .employee : .student)
        if !department.isEmpty && !list.contains(department) { list.insert(department, at: 0) }
        return list
    }

    var departmentRow: some View {
        Menu {
            ForEach(departmentOptions, id: \.self) { name in
                Button(name) { department = name }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Department")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(department.isEmpty ? "Select department" : department)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(department.isEmpty ? .white.opacity(0.4) : .white)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(Color.appRed)
            }
            .padding()
            .glassCard(cornerRadius: 14)
        }
    }

    var birthdayRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Birthday")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                if let date = birthdayDate {
                    DatePicker(
                        "",
                        selection: Binding(get: { date }, set: { birthdayDate = $0 }),
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .environment(\.colorScheme, .dark)
                } else {
                    Button {
                        birthdayDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
                    } label: {
                        Text(legacyBirthday.isEmpty ? "Select your birthday" : legacyBirthday)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            Spacer()
            Image(systemName: "calendar")
                .foregroundStyle(Color.appRed)
        }
        .padding()
        .glassCard(cornerRadius: 14)
    }

    // MARK: - Rows
    func readOnlyRow(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassCard(cornerRadius: 14)
    }

    func row(_ title: String, text: Binding<String>, field: Field) -> some View {
        EditableRow(
            title: title,
            text: text,
            isEditing: editingField == field,
            focus: $focusedField,
            field: field
        ) {
            if editingField == field {
                editingField = nil
                focusedField = nil
            } else {
                editingField = field
                focusedField = field
            }
        }
    }
}

// MARK: - Row
struct EditableRow: View {
    let title: String
    @Binding var text: String
    let isEditing: Bool
    var focus: FocusState<EditProfileView.Field?>.Binding
    let field: EditProfileView.Field
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                TextField(title, text: $text)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white)
                    .focused(focus, equals: field)
                    .allowsHitTesting(isEditing)
            }
            Spacer()
            Button(action: onToggle) {
                Image(systemName: isEditing ? "checkmark" : "pencil")
                    .foregroundStyle(Color.appRed)
            }
        }
        .padding()
        .glassCard(cornerRadius: 14)
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(AppState())
    }
}
