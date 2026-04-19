import Foundation
import SwiftUI

struct WrappedView: View {
    @Bindable var viewModel: WrappedViewModel
    @State private var currentSlideIndex: Int = 0
    private var totalSlides: Int {
        viewModel.currentYearItems.count + 2
    }

    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    introSlide
                    ForEach(viewModel.currentYearItems.indices, id: \.self) { index in
                        let item = viewModel.currentYearItems[index]
                        achievementSlide(for: item, slideIndex: index)

                    }
                    outroSlide
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
        }

        .safeAreaInset(edge: .top) {
            if totalSlides > 1 {
                progressIndicator
                    .padding(.top, 8)
            }
        }
        .task {
            viewModel.load()
        }
    }

    private var progressIndicator: some View {
        Text("\(currentSlideIndex + 1)/\(totalSlides)")
            .font(.footnote)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }

    private var introSlide: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(Copies.Wrapped.introTitle(year: viewModel.currentYear))
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Text("\(viewModel.currentYear)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
        .onAppear {
            currentSlideIndex = 0
        }
    }

    private func achievementSlide(for item: AccomplishmentItem, slideIndex: Int) -> some View {
        VStack(spacing: 16) {
            Spacer()
            if let photoData = item.photoData,
               let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(16)
            }

            Text(item.text)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(item.date, style: .date)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
        .onAppear {
            currentSlideIndex = slideIndex + 1
        }
    }

    private var outroSlide: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(Copies.Wrapped.outroTitle)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(Copies.Wrapped.outroSubtitle)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()

        }
        .padding()
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
        .onAppear {
            currentSlideIndex = totalSlides - 1
        }
    }
}
