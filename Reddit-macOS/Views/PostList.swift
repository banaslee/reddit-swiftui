//
//  PostList.swift
//  Reddit-macOS
//
//  Created by Carson Katri on 7/31/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI
import Request

struct PostList: View {
    let posts: [Post]
    let subreddit: String
    let sortBy: SortBy
    let beforeId: String?
    let afterId: String?
    let loadBefore: () -> Void
    let loadAfter: () -> Void

    @Binding var selectedPostId: String?

    private var selectedPostIds: Binding<Set<String>> {
        Binding(
            get: {
                if let selectedPostId = self.selectedPostId {
                    return Set(arrayLiteral: selectedPostId)
                }
                else {
                    return Set()
                }
        },
            set: {
                self.selectedPostId = $0.first
        }
        )
    }

    private var selectedNavigationLink: Binding<String?> {
        Binding<String?>(
            get: {
                return self.selectedPostId
        },
            set: { selectedPostId in
                // Absorbing any change that NavigationLink does to its selection property
        }
        )
    }
    
    var body: some View {
        List(selection: selectedPostIds) {
            Section(header: Text("\(subreddit) | \(sortBy.rawValue)")) {
                VStack {
                    if self.beforeId != nil {
                        Button("Load previous posts") {
                            self.loadBefore()
                        }
//                        SpinnerView()
//                        .hidden()
//                            .onAppear {
//                                self.shouldLoadBefore = true
//                                self.shouldLoadAfter = false
//                        }
                    }
                    /// List of `PostView`s when loaded
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post), tag: post.id, selection: self.selectedNavigationLink) {
                            PostView(post: post)
                        }
                        .tag(post.id)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .contentShape(Rectangle())
                            /// Double-click to open a new window for the `PostDetailView`
                            .onTapGesture(count: 2) {
                                let detailView = PostDetailView(post: post)

                                let controller = DetailWindowController(rootView: detailView)
                                controller.window?.title = post.title
                                controller.showWindow(nil)
                        }
                            /// Adding after the double tap so that double tap takes precedence
                            .onTapGesture(count: 1) {
                                self.selectedPostId = post.id
                        }
                    }
                    if self.afterId == nil {
                        Text("No more posts")
                    }
                    else {
                        Button("Load next posts") {
                            self.loadAfter()
                        }
//                        SpinnerView()
//                            .onAppear {
//                                self.shouldLoadBefore = false
//                                self.shouldLoadAfter = true
//                        }
                    }
                }
            }
            .collapsible(false)
        }
        .listStyle(SidebarListStyle())
    }
}
