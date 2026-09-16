import SwiftUI

struct FoodSearchView: View {
    let profile: UserProfile
    let mealType: MealType
    let recordedAt: Date
    let mealRecordStore: MealRecordStore
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selectedFood: FoodCatalogItem?
    @State private var shouldDismissAfterSaving = false
    @FocusState private var isSearchFocused: Bool

    private let catalog = FoodCatalogService()

    var body: some View {
        VStack(spacing: 0) {
            searchHeader

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(searchResults) { food in
                        foodRow(food)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.gray01)
        .preferredColorScheme(.light)
        .sheet(item: $selectedFood, onDismiss: finishQuantitySelection) { food in
            FoodQuantityView(
                food: food,
                onCancel: {
                    shouldDismissAfterSaving = false
                    selectedFood = nil
                },
                onComplete: { servingCount in
                    save(food: food, servingCount: servingCount)
                }
            )
            .presentationDetents([.height(262)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(20)
        }
    }

    private var searchHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.gray03)

                TextField("음식 검색", text: $query)
                    .font(.pretendardMedium(16))
                    .foregroundStyle(Color.black01)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.gray02.opacity(0.3), in: Capsule())

            Button("취소") {
                dismiss()
            }
            .font(.pretendardMedium(16))
            .foregroundStyle(Color.black01)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray02.opacity(0.55))
                .frame(height: 1)
        }
    }

    private func foodRow(_ food: FoodCatalogItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                highlightedName(food.name)
                    .font(.pretendardMedium(16))

                Text(food.servingDescription(for: 1))
                    .font(.pretendardMedium(12))
                    .foregroundStyle(Color.gray03)
            }

            Spacer()

            Text(food.nutrition.calories, format: .number.precision(.fractionLength(0)))
                .font(.pretendardMedium(16))
            + Text("kcal")
                .font(.pretendardMedium(16))

            Button {
                selectedFood = food
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 20, height: 20)
                    .background(Color.green03, in: Circle())
                    .frame(width: 32, height: 48)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(food.name) 추가")
        }
        .foregroundStyle(Color.black01)
        .frame(height: 77)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray02.opacity(0.7))
                .frame(height: 1)
        }
    }

    private func highlightedName(_ name: String) -> Text {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty,
              let range = name.range(of: trimmedQuery, options: .caseInsensitive)
        else {
            return Text(name).foregroundColor(Color.black01)
        }

        return Text(String(name[..<range.lowerBound])).foregroundColor(Color.black01)
            + Text(String(name[range])).foregroundColor(Color.green03)
            + Text(String(name[range.upperBound...])).foregroundColor(Color.black01)
    }

    private var searchResults: [FoodCatalogItem] {
        catalog.search(query: query)
    }

    private func save(food: FoodCatalogItem, servingCount: Double) {
        do {
            try mealRecordStore.insert(
                food: food,
                servingCount: servingCount,
                mealType: mealType,
                recordedAt: recordedAt,
                kakaoUserID: profile.kakaoUserID
            )
            shouldDismissAfterSaving = true
            selectedFood = nil
        } catch {
            return
        }
    }

    private func finishQuantitySelection() {
        guard shouldDismissAfterSaving else { return }

        shouldDismissAfterSaving = false
        onSaved()
        dismiss()
    }
}
