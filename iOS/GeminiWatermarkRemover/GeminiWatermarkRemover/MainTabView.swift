import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case gallery
    }

    var body: some View {
        ZStack {
            // Content
                ZStack {
                    HomeView()
                        .opacity(selectedTab == .home ? 1 : 0)
                        .allowsHitTesting(selectedTab == .home)

                    GalleryView()
                        .opacity(selectedTab == .gallery ? 1 : 0)
                        .allowsHitTesting(selectedTab == .gallery)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    // Home Tab
                    Button {
                        withAnimation { selectedTab = .home }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 24))
                            Text("Remove")
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedTab == .home ? .white : .white.opacity(0.5))
                        .padding()
                    }

                    Spacer()

                    // Gallery Tab
                    Button {
                        withAnimation { selectedTab = .gallery }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 24))
                            Text("Gallery")
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedTab == .gallery ? .white : .white.opacity(0.5))
                        .padding()
                    }

                    Spacer()
                }
                .padding(.bottom, 20)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.horizontal, 60)
                .padding(.bottom, 10)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
}
