//
//  FilterSheetView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var filter: PostFilter
    @Namespace private var sortNamespace
    @Namespace private var timeNamespace
    @State private var sortBy = "Latest"
    @State private var timeRange = "All"

    let sortOptions = PostFilter.Sort.allCases.map(\.rawValue)
    let timeOptions = PostFilter.Range.allCases.map(\.rawValue)

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Filter Post")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Sort by")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    PillTabBar(titles: sortOptions, selected: $sortBy, namespace: sortNamespace)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Time range")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    PillTabBar(titles: timeOptions, selected: $timeRange, namespace: timeNamespace)
                }

                Spacer()

                Button {
                    filter = PostFilter(
                        sort: PostFilter.Sort(rawValue: sortBy) ?? .latest,
                        range: PostFilter.Range(rawValue: timeRange) ?? .all,
                        isApplied: true
                    )
                    dismiss()
                } label: {
                    PrimaryGlassButton(title: "Apply filter")
                }

                Button {
                    sortBy = PostFilter.Sort.latest.rawValue
                    timeRange = PostFilter.Range.all.rawValue
                    filter = PostFilter()
                } label: {
                    Text("Reset")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.appRed)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .onAppear {
            sortBy = filter.sort.rawValue
            timeRange = filter.range.rawValue
        }
    }
}

#Preview {
    FilterSheetView(filter: .constant(PostFilter()))
}
