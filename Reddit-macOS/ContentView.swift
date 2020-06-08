//
//  ContentView.swift
//  Reddit-macOS
//
//  Created by Carson Katri on 7/20/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import SwiftUI
import Request

struct ContentView : View {
    @State private var sortBy: SortBy = .hot
    
    @State private var showSortSheet: Bool = false
    @State private var showSubredditSheet: Bool = false
    
    @State private var selectedPostId: String? = nil
    
    @EnvironmentObject private var state: ContentViewState

    @State private var query: Dictionary<String, String> = ["raw_json":"1"]
    let pageSize: Int = 25
    private func previousPageLoader(for listing: Listing) -> (() -> Void) {
        return {
            var mutableQuery = self.query
            var count = (Int(mutableQuery["count"] ?? "0") ?? 0)

            if mutableQuery["before"] != nil {
                count -= self.pageSize
            }
            else if mutableQuery["after"] != nil {
                count += 1
            }
            mutableQuery["count"] = String(count)
            mutableQuery["before"] = listing.data.before
            mutableQuery.removeValue(forKey: "after")

            self.query = mutableQuery
        }
    }
    
    private func nextPageLoader(for listing: Listing) -> (() -> Void) {
        return {
            var mutableQuery = self.query
            var count = (Int(mutableQuery["count"] ?? "0") ?? 0)

            if mutableQuery["before"] != nil {
                count -= 1
            }
            else {
                count += self.pageSize
            }

            mutableQuery["count"] = String(count)
            mutableQuery.removeValue(forKey: "before")
            mutableQuery["after"] = listing.data.after

            self.query = mutableQuery
        }
    }
    
    var body: some View {
        NavigationView {
            /// Load the posts
            RequestView(Listing.self, Request {
                Url(API.subredditURL(state.subreddit, sortBy))
                Query(self.$query.wrappedValue)
            }) { listing in
                if listing != nil {
                    PostList(posts: listing!.posts,
                             subreddit: self.state.subreddit,
                             sortBy: self.state.sortBy,
                             beforeId: listing!.data.before,
                             afterId: listing!.data.after,
                             loadBefore: self.previousPageLoader(for: listing!),
                             loadAfter: self.nextPageLoader(for: listing!),
                             selectedPostId: self.$selectedPostId)
                        .frame(minWidth: 300)
                }
                else {
                    Text("Error while loading posts")
                        .frame(minWidth: 300, minHeight: 300)
                }
                /// Spinner when loading
                SpinnerView()
                    .frame(minWidth: 300, minHeight: 300)
            }
            Text("Select a post")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .touchBar {
            /*Picker("Sort By", selection: $state.sortBy) {
             ForEach(SortBy.allCases, id: \.rawValue) { sort in
             Text(sort.rawValue)
             }
             }*/
            Text("Hello, World!")
        }
    }
}
