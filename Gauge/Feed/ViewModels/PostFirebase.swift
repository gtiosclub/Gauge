//
//  PostFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation
import Firebase

class PostFirebase: ObservableObject {
    @Published var feedPosts: [any Post] = []
    @Published var allQueriedPosts: [any Post] = []
    @Published var skippedPost: (any Post)? = nil
    private var currentFeedPostCommentsListener: ListenerRegistration? = nil
    private var currentFeedPostResponsesListener: ListenerRegistration? = nil
    private var currentFeedPostViewsListener: ListenerRegistration? = nil
    
    init() {
        Keys.fetchKeys()
    }
    
    func watchForCurrentFeedPostChanges() {
        if !feedPosts.isEmpty {
            setUpCommentsListener()
            setUpResponsesListener()
            setUpViewsListener()
        }
        // Makes changes to the Post's (Binary) responses, viewCounter, comments, responseResult1, responseResult2

    }
    
    func setUpCommentsListener() {
        // Cancel current listeners (if there are ones)
        currentFeedPostCommentsListener?.remove()

        // Setup listener for new index 0 subcollections
        let currentPost = feedPosts[0]
        let postRef = Firebase.db.collection("POSTS").document(currentPost.postId)
        currentFeedPostCommentsListener = postRef.collection("COMMENTS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        print("New comment: \(diff.document.data())")
                        let newCommentDoc = diff.document.data()
                        let id = diff.document.documentID
                        let date = DateConverter.convertStringToDate(newCommentDoc["date"] as? String ?? "") ?? Date()
                        let newComment = Comment(
                            commentType: CommentType.text,  // THIS NEEDS TO BE MODIFIED LATER!!~
                            postId: currentPost.postId,
                            userId: id,
                            date: date,
                            commentId: id,
                            likes: newCommentDoc["likes"] as? [String] ?? [],
                            dislikes: newCommentDoc["dislikes"] as? [String] ?? [],
                            content: newCommentDoc["content"] as? String ?? ""
                            )
                            currentPost.comments.append(newComment)

                    } else if diff.type == .removed {
                        print("Comment removed: \(diff.document.documentID)")
                        currentPost.comments.removeAll { $0.commentId == diff.document.documentID }
                    } else if diff.type == .modified {
                        print("Comment modified: \(diff.document.documentID)")
                        currentPost.comments.removeAll { $0.commentId == diff.document.documentID }
                        let newCommentDoc = diff.document.data()
                        let id = diff.document.documentID
                        let date = DateConverter.convertStringToDate(newCommentDoc["date"] as? String ?? "") ?? Date()
                        let newComment = Comment(
                            commentType: CommentType.text,  // THIS NEEDS TO BE MODIFIED LATER!!~
                            postId: currentPost.postId,
                            userId: id,
                            date: date,
                            commentId: id,
                            likes: newCommentDoc["likes"] as? [String] ?? [],
                            dislikes: newCommentDoc["dislikes"] as? [String] ?? [],
                            content: newCommentDoc["content"] as? String ?? ""
                            )
                            currentPost.comments.append(newComment)
                    }
                }
            }
        }
        // Save the comment listener in the variables
        // Makes changes to the Post's comments
    }
    
    func setUpResponsesListener() {
        currentFeedPostResponsesListener?.remove()
        
        let currentPost = feedPosts[0]
        let postRef = Firebase.db.collection("POSTS").document(currentPost.postId)
        currentFeedPostResponsesListener = postRef.collection("RESPONSES").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            DispatchQueue.main.async {
                self.objectWillChange.send()
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        print("New Response: \(diff.document.data())")
                        let newResponseDoc = diff.document.data()
                        let id = diff.document.documentID
                        let newResponse = Response(
                            responseId: id,
                            userId: newResponseDoc["userId"] as? String ?? "",
                            responseOption: newResponseDoc["responseOption"] as? String ?? ""
                        )
                        currentPost.responses.append(newResponse)
                        if let binaryPost = currentPost as? BinaryPost {
                            if newResponse.responseOption == binaryPost.responseOption1 {
                                binaryPost.responseResult1 = binaryPost.responseResult1 + 1
                            } else if newResponse.responseOption == binaryPost.responseOption2 {
                                binaryPost.responseResult2 = binaryPost.responseResult2 + 1
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setUpViewsListener() {
        currentFeedPostViewsListener?.remove()
        let currentPost = feedPosts[0]
        let postRef = Firebase.db.collection("POSTS").document(currentPost.postId)
        currentFeedPostViewsListener = postRef.collection("VIEWS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            DispatchQueue.main.async {
                self.objectWillChange.send()
                let viewCount = snapshot.documents.count
                currentPost.viewCounter = viewCount
            }
        }
    }
    
    func loadFeedPosts(for postIds: [String]) async {
        await MainActor.run {
            self.feedPosts = [] // clear current feedPosts
        }

        // Run fetches in parallel
        let posts: [(any Post)?] = await withTaskGroup(of: (String, (any Post)?).self) { group in
            for postId in postIds {
                group.addTask {
                    do {
                        let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
                        guard let data = document.data() else { return (postId, nil) }

                        let type = data["type"] as? String ?? ""

                        switch type {
                        case PostType.BinaryPost.rawValue:
                            let post = BinaryPost(
                                postId: postId,
                                userId: data["userId"] as? String ?? "",
                                categories: data["categories"] as? [Category] ?? [],
                                postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                                    ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "")
                                    ?? Date(),
                                question: data["question"] as? String ?? "",
                                responseOption1: data["responseOption1"] as? String ?? "",
                                responseOption2: data["responseOption2"] as? String ?? "",
                                favoritedBy: data["favoritedBy"] as? [String] ?? []
                            )
                            return (postId, post)

                        case PostType.SliderPost.rawValue:
                            let post = SliderPost(
                                postId: postId,
                                userId: data["userId"] as? String ?? "",
                                categories: data["categories"] as? [Category] ?? [],
                                postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                                    ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "")
                                    ?? Date(),
                                question: data["question"] as? String ?? "",
                                lowerBoundValue: data["lowerBoundValue"] as? Double ?? 0,
                                upperBoundValue: data["upperBoundValue"] as? Double ?? 1,
                                lowerBoundLabel: data["lowerBoundLabel"] as? String ?? "",
                                upperBoundLabel: data["upperBoundLabel"] as? String ?? "",
                                favoritedBy: data["favoritedBy"] as? [String] ?? []
                            )
                            return (postId, post)

                        case PostType.RankPost.rawValue:
                            let post = RankPost(
                                postId: postId,
                                userId: data["userId"] as? String ?? "",
                                categories: data["categories"] as? [Category] ?? [],
                                postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                                    ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "")
                                    ?? Date(),
                                question: data["question"] as? String ?? "",
                                responseOptions: data["responseOptions"] as? [String] ?? [],
                                favoritedBy: data["favoritedBy"] as? [String] ?? []
                            )
                            return (postId, post)

                        default:
                            return (postId, nil)
                        }
                    } catch {
                        print("❌ Error loading post \(postId): \(error)")
                        return (postId, nil)
                    }
                }
            }

            var tempMap: [String: any Post] = [:]

            for await (postId, post) in group {
                if let post = post {
                    tempMap[postId] = post
                }
            }

            // Reconstruct in original order
            return postIds.map { tempMap[$0] }
        }

        await MainActor.run {
            self.feedPosts = posts.compactMap { $0 }
        }
    }
    
    func watchForNewPosts(user: User) {
        let allFilteredPosts: [String] = user.myViews + user.myResponses + user.myNextPosts + user.myPosts
        Firebase.db.collection("POSTS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching post updates: \(error!)")
                return
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
                for change in snapshot.documentChanges {
                    let newPostData = change.document.data()
                    guard let postId = newPostData["postId"] as? String else { return }

                    if allFilteredPosts.contains(where: { $0 == postId }) {
                        return
                    }
                    
                    if change.type == .added {
                        if self.allQueriedPosts.contains(where: { $0.postId == postId }) {
                            return
                        }
                        
                        if (newPostData["type"] as? String == PostType.BinaryPost.rawValue) {
                            let post = BinaryPost(postId: newPostData["postId"] as? String ?? "",
                                                  userId: newPostData["userId"] as? String ?? "",
                                                  categories: newPostData["categories"] as? [Category] ?? [],
                                                  postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                                                      ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                                                      ?? Date(),
                                                  question: newPostData["question"] as? String ?? "",
                                                  responseOption1: newPostData["responseOption1"] as? String ?? "",
                                                  responseOption2: newPostData["responseOption2"] as? String ?? "",
                                                  favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                            
                            self.allQueriedPosts.append(post)
                            self.allQueriedPosts = self.allQueriedPosts
                        } else if (newPostData["type"] as? String == PostType.SliderPost.rawValue) {
                            let post = SliderPost(postId: newPostData["postId"] as? String ?? "",
                                                  userId: newPostData["userId"] as? String ?? "",
                                                  categories: newPostData["categories"] as? [Category] ?? [],
                                                  postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                                                      ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                                                      ?? Date(),
                                                  question: newPostData["question"] as? String ?? "",
                                                  lowerBoundValue: newPostData["lowerBoundValue"] as? Double ?? 0,
                                                  upperBoundValue: newPostData["upperBoundValue"] as? Double ?? 1,
                                                  lowerBoundLabel: newPostData["lowerBoundLabel"] as? String ?? "",
                                                  upperBoundLabel: newPostData["upperBoundLabel"] as? String ?? "",
                                                  favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                            
                            self.allQueriedPosts.append(post)
                            self.allQueriedPosts = self.allQueriedPosts
                        }
                    } else if change.type == .modified {
                        if let index = self.allQueriedPosts.firstIndex(where: { $0.postId == change.document.documentID }) {
                            //replaces data at index
                            if (newPostData["type"] as? String == PostType.BinaryPost.rawValue) {
                                print("updating binary post")
                                
                                self.allQueriedPosts[index] = BinaryPost(
                                    postId: newPostData["postId"] as? String ?? "",
                                    userId: newPostData["userId"] as? String ?? "",
                                    categories: newPostData["categories"] as? [Category] ?? [],
                                    postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                    question: newPostData["question"] as? String ?? "",
                                    responseOption1: newPostData["responseOption1"] as? String ?? "",
                                    responseOption2: newPostData["responseOption2"] as? String ?? "",
                                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])

                                self.allQueriedPosts = self.allQueriedPosts
                                
                            } else if (newPostData["type"] as? String == PostType.SliderPost.rawValue) {
                                print("updating slider post")
                                self.allQueriedPosts[index] = SliderPost(
                                    postId: newPostData["postId"] as? String ?? "",
                                    userId: newPostData["userId"] as? String ?? "",
                                    categories: newPostData["categories"] as? [Category] ?? [],
                                    postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                    question: newPostData["question"] as? String ?? "",
                                    lowerBoundValue: newPostData["lowerBoundValue"] as? Double ?? 0,
                                    upperBoundValue: newPostData["upperBoundValue"] as? Double ?? 1,
                                    lowerBoundLabel: newPostData["lowerBoundLabel"] as? String ?? "",
                                    upperBoundLabel: newPostData["upperBoundLabel"] as? String ?? "",
                                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                                
                                self.allQueriedPosts = self.allQueriedPosts
                            }
                        }
                    } else if change.type == .removed {
                        self.allQueriedPosts = self.allQueriedPosts.filter { $0.postId != change.document.documentID }
                        self.feedPosts = self.feedPosts.filter { $0.postId != change.document.documentID }
                    }
                }
                
            }
        }
    }
  
    func loadInitialNewPosts(user: User) async {
        let allFilteredPosts = user.myViews + user.myResponses + user.myNextPosts + user.myPosts
        let snapshot: QuerySnapshot

        do {
            snapshot = try await Firebase.db.collection("POSTS").getDocuments()
        } catch {
            print("❌ Error fetching initial posts: \(error)")
            return
        }

        let addedDocs = snapshot.documents.filter { doc in
            let postId = doc.data()["postId"] as? String ?? ""
            return !allFilteredPosts.contains(postId)
        }

        for doc in addedDocs {
            let newPostData = doc.data()
            guard let postId = newPostData["postId"] as? String else { continue }

            if allQueriedPosts.contains(where: { $0.postId == postId }) {
                continue
            }

            if newPostData["type"] as? String == PostType.BinaryPost.rawValue {
                let post = BinaryPost(
                    postId: postId,
                    userId: newPostData["userId"] as? String ?? "",
                    categories: newPostData["categories"] as? [Category] ?? [],
                    postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                        ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                        ?? Date(),
                    question: newPostData["question"] as? String ?? "",
                    responseOption1: newPostData["responseOption1"] as? String ?? "",
                    responseOption2: newPostData["responseOption2"] as? String ?? "",
                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? []
                )
                DispatchQueue.main.async {
                    self.allQueriedPosts.append(post)
                }
            } else if newPostData["type"] as? String == PostType.SliderPost.rawValue {
                let post = SliderPost(
                    postId: postId,
                    userId: newPostData["userId"] as? String ?? "",
                    categories: newPostData["categories"] as? [Category] ?? [],
                    postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                        ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                        ?? Date(),
                    question: newPostData["question"] as? String ?? "",
                    lowerBoundValue: newPostData["lowerBoundValue"] as? Double ?? 0,
                    upperBoundValue: newPostData["upperBoundValue"] as? Double ?? 1,
                    lowerBoundLabel: newPostData["lowerBoundLabel"] as? String ?? "",
                    upperBoundLabel: newPostData["upperBoundLabel"] as? String ?? "",
                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? []
                )
                DispatchQueue.main.async {
                    self.allQueriedPosts.append(post)
                }
            }
        }
        DispatchQueue.main.async {
            self.allQueriedPosts = self.allQueriedPosts // triggers UI update if needed
        }
    }
    
    func loadInitialNewPosts(user: User) async {
        let allFilteredPosts = user.myViews + user.myResponses + user.myNextPosts + user.myPosts
        let snapshot: QuerySnapshot

        do {
            snapshot = try await Firebase.db.collection("POSTS").getDocuments()
        } catch {
            print("❌ Error fetching initial posts: \(error)")
            return
        }

        let addedDocs = snapshot.documents.filter { doc in
            let postId = doc.data()["postId"] as? String ?? ""
            return !allFilteredPosts.contains(postId)
        }

        for doc in addedDocs {
            let newPostData = doc.data()
            guard let postId = newPostData["postId"] as? String else { continue }

            if allQueriedPosts.contains(where: { $0.postId == postId }) {
                continue
            }

            if newPostData["type"] as? String == PostType.BinaryPost.rawValue {
                let post = BinaryPost(
                    postId: postId,
                    userId: newPostData["userId"] as? String ?? "",
                    categories: newPostData["categories"] as? [Category] ?? [],
                    postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                        ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                        ?? Date(),
                    question: newPostData["question"] as? String ?? "",
                    responseOption1: newPostData["responseOption1"] as? String ?? "",
                    responseOption2: newPostData["responseOption2"] as? String ?? "",
                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? []
                )
                DispatchQueue.main.async {
                    self.allQueriedPosts.append(post)
                }
            } else if newPostData["type"] as? String == PostType.SliderPost.rawValue {
                let post = SliderPost(
                    postId: postId,
                    userId: newPostData["userId"] as? String ?? "",
                    categories: newPostData["categories"] as? [Category] ?? [],
                    postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                        ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                        ?? Date(),
                    question: newPostData["question"] as? String ?? "",
                    lowerBoundValue: newPostData["lowerBoundValue"] as? Double ?? 0,
                    upperBoundValue: newPostData["upperBoundValue"] as? Double ?? 1,
                    lowerBoundLabel: newPostData["lowerBoundLabel"] as? String ?? "",
                    upperBoundLabel: newPostData["upperBoundLabel"] as? String ?? "",
                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? []
                )
                DispatchQueue.main.async {
                    self.allQueriedPosts.append(post)
                }
            }
        }
        DispatchQueue.main.async {
            self.allQueriedPosts = self.allQueriedPosts // triggers UI update if needed
        }
    }
    
    func addView(responseOption: Int) {
        if let post = feedPosts.first as? BinaryPost {
            if responseOption == 1 {
                post.responseResult1 += 1
            } else if responseOption == 2 {
                post.responseResult2 += 1
            }
        }
    }
    
    func likeComment(postId: String, commentId: String, userId: String){
        let commentRef = Firebase.db.collection("POSTS")
            .document(postId)
            .collection("COMMENTS")
            .document(commentId)
      
        commentRef.updateData([
            "likes": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("error in liking comment: \(error.localizedDescription)")
            } else {
                print("Successfully liked the comment.")
            }
        }
    }
    
    func removeLike(postId: String, commentId: String, userId: String) {
        let commentRef = Firebase.db.collection("POSTS")
            .document(postId)
            .collection("COMMENTS")
            .document(commentId)
      
        commentRef.updateData([
            "likes": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("error in liking comment: \(error.localizedDescription)")
            } else {
                print("Successfully liked the comment.")
            }
        }
    }
    
    func dislikeComment(postId: String, commentId: String, userId: String) {
        // Reference a specific comment in the "COMMENTS" collection
        // of a specific post in the "POSTS" collection
        // from firebase database
        let commentRef = Firebase.db
            .collection("POSTS")
            .document(postId)
            .collection("COMMENTS")
            .document(commentId)
        
        // use arrayUnion() to add userId to the dislikes field
        // of the specific comment referenced aboved
        commentRef.updateData([
            "dislikes": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("Error disliking comment: \(error.localizedDescription)")
            } else {
                print("Successfully removed like.")
            }
        }
    }
    
    func removeDislike(postId: String, commentId: String, userId: String) {
        let commentRef = Firebase.db.collection("POSTS")
            .document(postId)
            .collection("COMMENTS")
            .document(commentId)
      
        commentRef.updateData([
            "dislikes": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("error in liking comment: \(error.localizedDescription)")
            } else {
                print("Successfully removed dislike.")
            }
        }
    }
  
    func createBinaryPost(userId: String, categories: [Category], question: String, responseOption1: String, responseOption2: String) {
        // Create post instance
        let post = BinaryPost(
            postId: UUID().uuidString,
            userId: userId,
            categories: categories,
            postDateAndTime: Date(),
            question: question,
            responseOption1: responseOption1,
            responseOption2: responseOption2
        )
        
        // Create document in Firebase
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)
        let categoryStrings = post.categories.map{$0.rawValue}

        documentRef.setData([
            "type": PostType.BinaryPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "categories": categoryStrings,
            "viewCounter": post.viewCounter,
            "postDateAndTime": DateConverter.convertDateToString(post.postDateAndTime),
            "question": post.question,
            "responseOption1": post.responseOption1,
            "responseOption2": post.responseOption2,
            "responseResult1": post.responseResult1,
            "responseResult2": post.responseResult2,
            "favoritedBy": post.favoritedBy
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new post to POSTS")
            }
        }
    }
    
    func createSliderPost(userId: String, categories: [Category], question: String, lowerBoundValue: Double, upperBoundValue: Double, lowerBoundLabel: String, upperBoundLabel: String) {
        var categoryString: [String] = []
        for cat in categories {
            categoryString.append(cat.rawValue)
        }

        
        // Create post instance
        let post = SliderPost(
            postId: UUID().uuidString,
            userId: userId,
            categories: categories,
            postDateAndTime: Date(),
            question: question,
            lowerBoundLabel: lowerBoundLabel,
            upperBoundLabel: upperBoundLabel,
            lowerBoundValue: lowerBoundValue,
            upperBoundValue: upperBoundValue
        )
        
        // Create document in Firebase
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)

        documentRef.setData([
            "type": PostType.SliderPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "categories": categoryString,
            "postDateAndTime": DateConverter.convertDateToString(post.postDateAndTime),
            "question": post.question,
            "lowerBoundValue": post.lowerBoundValue,
            "upperBoundValue": post.upperBoundValue,
            "lowerBoundLabel": post.lowerBoundLabel,
            "upperBoundLabel": post.upperBoundLabel,
            "favoritedBy": post.favoritedBy
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new post to POSTS")
            }
        }
    }
    
    func deletePost(postId: String){
        Firebase.db.collection("POSTS").document(postId).delete() { error in
            if let error = error {
                print("Error removing post: \(error)")
            } else {
                print("post successfully removed!")
            }
        }
    }
    
    func createRankPost(userId: String, categories: [Category], question: String, responseOptions: [String]) {
        let post = RankPost(
            postId: UUID().uuidString,
            userId: userId,
            categories: categories,
            postDateAndTime: Date(),
            question: question,
            responseOptions: responseOptions
        )
        
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)
        
        // Main post document data
        documentRef.setData([
            "type": PostType.RankPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "categories": post.categories,
            "postDateAndTime": Timestamp(date: post.postDateAndTime),
            "question": post.question,
            "responseOptions": post.responseOptions,
            "viewCounter": 0,
            "responseCounter": 0,
            "favoritedBy": post.favoritedBy,
        ]) { error in
            if let error = error {
                print("Error writing RankPost document: \(error)")
            } else {
                print("Added new ranked post to POSTS \(documentRef.documentID)")
            }
        }
    }
    
    func addResponse(postId: String, userId: String, responseOption: String) {
        let responseId = UUID().uuidString
        
        //The postId is used to query the correct document in the POST collection.
        let correctPost = Firebase.db.collection("POSTS").document(postId)
        
        //The Response should be added to a POST's RESPONSE collection.
        let responseLocation = Firebase.db.collection("POSTS").document(postId).collection("RESPONSES").document(responseId)
        
 
        //The two attributes are the userId and responseOption. Both strings
        let response = ["userId": userId, "responseOption": responseOption]
        
        responseLocation.setData(response) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Response added succesfully")
            }
        }
    }
    
    func addUserToFavoritedBy(postId: String, userId: String) {
        let documentRef = Firebase.db.collection("POSTS").document(postId)
        
        documentRef.updateData([
            "favoritedBy": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("Error adding user to favoritedBy array: \(error)")
            } else {
                print("Added \(userId) to favoritedBy array of post \(postId).")
            }
        }
    }
    
    func addComment(postId: String, commentType: CommentType, userId: String, content: String){
        let commentId = UUID().uuidString
        let newCommentRef = Firebase.db.collection("POSTS")
            .document(postId).collection("COMMENTS").document(commentId)
        
        newCommentRef.setData([
            "postId" : postId,
            "commentId" : commentId,
            "commentType": String(describing: commentType),
            "date": DateConverter.convertDateToString(Date()),
            "userId": userId ,
            "content": content,
            "likes" : [],
            "dislikes" : [],
        ]) { error in
            if let error = error{
                print("Error adding Comment: \(error)")
            } else {
                print("added new comment to COMMENTS")
            }
        }
    }
    
    func getComments(postId: String, completion: @escaping ([Comment]) -> Void) {
           var comments: [Comment] = []
           
           Firebase.db.collection("POSTS").document(postId).collection("COMMENTS").getDocuments() { snapshot, error in
               if let error = error {
                   print("Error getting Comments: \(error)")
                   completion([])
                   return
               } else {
                   for document in snapshot!.documents {
                       let data = document.data()
                       //let commentTypeString = data["commentType"] as? CommentType
                       let commentTypeString = data["commentType"] as? String ?? ""
                       
                       let commentType = CommentType(rawValue: commentTypeString) ?? .text
                       
                       let commentObj = Comment (
                           commentType: commentType,
                           postId: postId,
                           userId: data["userId"] as? String ?? "",
                           username:"",
                           profilePhoto: "",
                           date: DateConverter.convertStringToDate(data["date"] as? String ?? "") ?? Date(),
                           commentId: document.documentID,
                           likes: data["likes"] as? [String] ?? [],
                           dislikes: data["dislikes"] as? [String] ?? [],
                           content: data["content"] as? String ?? ""
                       )
                       comments.append(commentObj)
                       
                       
                   }
                   completion(comments)
               }
               
           }
       }
    
    // Currently only works for Binary & Slider posts
    func getResponses(postId: String, completion: @escaping ([String: Int]) -> Void){
        var responses: [String: Int] = [:]
        
        Firebase.db.collection("POSTS").document(postId).collection("RESPONSES").getDocuments { (snapshot, error) in
            if let error = error{
                print("Error getting Post data: \(error)")
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    
                    if responses.keys.contains(data["responseOption"] as! String){
                        responses[data["responseOption"] as! String]! += 1
                    } else {
                        responses[data["responseOption"] as! String] = 1
                    }
                }
                
                completion(responses)
            }
        }
    }
    
    func suggestPostCategories(question: String, responseOptions: [String], completion: @escaping (([Category]) -> Void)) {
        let categories: [String] = Category.allCategoryStrings
        
        let systemPrompt = """
            You are a classifier that assigns categories to a post based on 
            a post's question and its responses. 
            Only respond with valid categories from the provided list. 
            Do not create new categories. Return the answer as a JSON array.
            """
        
        let userPrompt = """
            Question: \(question)
            Response Options: \(responseOptions.joined(separator: ", "))
            Valid Categories: \(categories.joined(separator: ", "))

            Provide the category list as a JSON array without using any
            markdown or coding blocks, just the raw string value.
            """
        
        let parameters: [String: Any] = [
           "model": "gpt-4o-mini",
           "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
           ],
           "temperature": 0.2
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Keys.openAIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            print("body created")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error querying OpenAI: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received from OpenAI")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices[0]["message"] as? [String : Any],
                   let content = message["content"] as? String,
                   let jsonData = content.data(using: .utf8),
                   let rawCategories = try? JSONDecoder().decode([String].self, from: jsonData).filter({ categories.contains($0) }) {
                    let suggestedCategories = Category.mapStringsToCategories(returnedStrings: rawCategories)
                    completion(suggestedCategories)
                } else {
                    print("Incorrect response formatting")
                }
            } catch {
                print("Error parsing OpenAI response: \(error)")
            }
        }.resume()
    }
    
    
    func deleteComment(postId: String, commentId: String) {
        Firebase.db.collection("POSTS").document(postId).collection("COMMENTS").document(commentId).delete(){ error in
            if let error = error{
                print("Error deleting Comment: \(error)")
            } else {
                print("deleted comment from COMMENTS")
            }
        }
    }
    
    
    func addViewToPost(postId: String, userId: String) {
        let documentRef = Firebase.db.collection("POSTS").document(postId).collection("VIEWS").document(userId)
        
        documentRef.setData(["userId": userId]) { error in
            if let error = error {
                print("Error adding view to post: \(error)")
            } else {
                print("Added view to post \(postId).")
            }
        }
    }
    
    func getNextBestPost(user: User)  {
        var bestScore = 0
        var bestIndex = 0
        
        for i in 0 ..< allQueriedPosts.count {
            let post  = allQueriedPosts[i]
            var score = 0;
            //Friends
            if (user.friends.keys).contains(post.userId) {
                score += 20;
            }
            //Accessed Profiles
            if(user.myAccessedProfiles.contains(post.userId)) {
                score+=10;
            }
            
            //Searches
            if(user.myProfileSearches.contains(post.username)) {
                score+=20;
            }
            
            //Response Ratio
            if post.viewCounter > 0 {
                let ratioScore = ((Float(post.responses.count))  / Float(post.viewCounter)) * 20
                score = score +  Int(ceil(ratioScore))
            }
            
            //Hot Take
            if let binaryPost = post as? BinaryPost {
                let respose1Ratio = ((Float(binaryPost.responseOption1.count))  / Float(binaryPost.responses.count))
                if(respose1Ratio < 60 && respose1Ratio > 40) {
                    score+=100
                }
            } else if let sliderPost = post as? SliderPost {
                //Get sd of responses??
            }
            //Call Date Function for date score
            
            //Call topics function for topic mathcing score
            
            //Call cateogries function for category matching score
            
            
            if score > bestScore {
                bestScore = score
                bestIndex = i
            }
            
        }
        
        let bestPost = allQueriedPosts[bestIndex]
        print("Next feed post is " + bestPost.postId + " with a score of " + String(bestScore))
        allQueriedPosts.remove(at: bestIndex)
        allQueriedPosts.insert(bestPost, at: 0)
    }

    func removeView(postId: String, userId: String) {
        let viewRef = Firebase.db.collection("POSTS")
            .document(postId)
            .collection("VIEWS")
            .document(userId)
        
        viewRef.delete() { error in
            if let error = error {
                print("Error removing view to post: \(error)")
            } else {
                print("Removed view to post \(postId)")
            }
        }
    }
    
    func generatePostKeywords(postId: String) {
        let db = Firestore.firestore()
        let postRef = db.collection("POSTS").document(postId)
        
        postRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let question = document.data()?["question"] as? String,
                  let category = document.data()?["category"] as? String,
                  let responseOptions = document.data()?["responseOptions"] as? [String] else {
                print("Invalid post data")
                return
            }
            
            let responseText = responseOptions.joined(separator: ", ")
            
            let examplePrompt = """
                    Here are some examples of generating keywords for different posts:
                    Input:
                    Question: "Did the Chiefs deserve to be in the game?"
                    Category: "NFL"
                    Response Options: "Nah they were trash", "Absolutely, no one else was better"
                    Output:
                    ["Football", "Chiefs", "Eagles", "NFL", "Super", "Bowl", "Game", "Playoffs", "Sports", "Referees", "Team", "Coach", "Defense", "Offense", "Quarterback", "Kansas", "Missouri", "Fans", "Stadium", "Victory"]
                    Input:
                    Question: "Is AI going to replace software engineers?"
                    Category: "Technology"
                    Response Options: "No, but it will change how they work", "Yes, it's inevitable"
                    Output:
                    ["AI", "Artificial Intelligence", "Machine Learning", "Software Engineers", "Programming", "Automation", "Jobs", "Future", "Tech", "Code", "Development", "GPT", "Deep Learning", "Innovation", "Industry", "Algorithms", "Computers", "Workforce", "Engineering", "Career"]
                    Now, generate 20 keywords based on the following input:
                    Question: "\(question)"
                    Category: "\(category)"
                    Response Options: "\(responseText)"
                    Output:
                    """
            
            let openAIRequest: [String: Any] = [
                "model": "gpt-4o-mini",
                "messages": [
                    ["role": "system", "content": "You are an AI trained to extract the 20 most relevant keywords from a post based on its question, category, and response options. Respond ONLY with a JSON list of keywords."],
                    ["role": "user", "content": examplePrompt]
                ],
                "temperature": 0.7
            ]
            
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Keys.openAIKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: openAIRequest, options: [])
            } catch {
                print("Failed to encode request")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error calling OpenAI API: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = jsonResponse["choices"] as? [[String: Any]],
                       let text = choices.first?["message"] as? [String: Any],
                       let content = text["content"] as? String {
                        
                        // Try to parse the content as JSON list
                        let keywordsData = content.data(using: .utf8)
                        if let keywords = try JSONSerialization.jsonObject(with: keywordsData!, options: []) as? [String] {
                            
                            // Store the keywords back in Firestore
                            postRef.updateData(["keyword": keywords]) { error in
                                if let error = error {
                                    print("Error updating Firestore: \(error.localizedDescription)")
                                } else {
                                    print("Keywords successfully updated for post \(postId)")
                                }
                            }
                        } else {
                            print("Failed to parse OpenAI response")
                        }
                    } else {
                        print("Unexpected response format from OpenAI")
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }
    }
    
    func skipPost(user: User) -> (any Post)? {
        guard !feedPosts.isEmpty else {
            print("No posts in feed to skip.")
            return nil
        }
        
        // add the post view to Firestore
        addViewToPost(postId: feedPosts.first!.postId, userId: user.userId)
        
        // Move the post at index 0 to skippedPost
        skippedPost = feedPosts.removeFirst()
        
        print("Skipped post: \(skippedPost?.postId ?? "None")")

        findNextPost(user: user)
        
        return skippedPost
    }
    
    func findNextPost(user: User) {
        // load the next post in the feed
        getNextBestPost(user: user)
        feedPosts.append(allQueriedPosts[0])
        allQueriedPosts.remove(at: 0)

        // listen for changes in the new post
        watchForCurrentFeedPostChanges()
    }
    
    func undoSkipPost(userId: String) {
        guard let skipped = skippedPost else {
            print("No post to undo skip.")
            return
        }

        // add back the skipped post to the front of feedPosts
        feedPosts.insert(skipped, at: 0)
        skippedPost = nil
        
        removeView(postId: feedPosts.first!.postId, userId: userId)
        
        print("Restored skipped post: \(skipped.postId)")
    }
    
    
    func addDummyPosts() {
        feedPosts.append(BinaryPost(
            postId: "555555555",
            userId: "conspiracy_theorist",
            username: "MoonShotDebunker",
            comments: [
                Comment(
                    commentType: .text,
                    postId: "555555555",
                    userId: "user101",
                    username: "ApolloCritic",
                    profilePhoto: "",
                    date: Date(),
                    commentId: "comm001",
                    likes: ["user202", "user404", "user777"],
                    dislikes: ["user303", "user888"],
                    content: "I’ve watched every frame of the footage in slow motion. Totally staged!"
                ),
                Comment(
                    commentType: .text,
                    postId: "555555555",
                    userId: "user202",
                    username: "Rover4Real",
                    profilePhoto: "",
                    date: Date(),
                    commentId: "comm002",
                    likes: ["user101", "user404", "user777", "user999"],
                    dislikes: ["user303", "user101"],
                    content: "But what about the laser reflectors they left on the Moon? That can’t be fake, right?"
                ),
                Comment(
                    commentType: .text,
                    postId: "555555555",
                    userId: "user303",
                    username: "EarthboundFella",
                    profilePhoto: "",
                    date: Date(),
                    commentId: "comm003",
                    likes: ["user888"],
                    dislikes: ["user101", "user202", "user404"],
                    content: "I don’t trust NASA. All that money and they send grainy footage? Suspicious."
                ),
                Comment(
                    commentType: .text,
                    postId: "555555555",
                    userId: "user404",
                    username: "SpaceCadet",
                    profilePhoto: "",
                    date: Date(),
                    commentId: "comm004",
                    likes: ["user101", "user777", "user888", "user999"],
                    dislikes: ["user202"],
                    content: "How do you explain the Moon rocks that were studied worldwide?"
                ),
                Comment(
                    commentType: .text,
                    postId: "555555555",
                    userId: "user555",
                    username: "LunarLegacy",
                    profilePhoto: "",
                    date: Date(),
                    commentId: "comm005",
                    likes: ["user101", "user202", "user404", "user888"],
                    dislikes: ["user303", "user777"],
                    content: "Come on, it’s 2023. People still think it was a hoax?"
                )
            ],
            responses: [
                Response(
                    responseId: "resp001",
                    userId: "user777",
                    responseOption: "Yes, obviously"
                ),
                Response(
                    responseId: "resp002",
                    userId: "user888",
                    responseOption: "Touch grass"
                )
            ],
            categories: [.other(.conspiraryTheories), .other(.funny)],
            viewCounter: 257,
            postDateAndTime: Date(),
            question: "Was the moon landing fake? 🌕🚀",
            responseOption1: "Yes, obviously",
            responseOption2: "Touch grass",
            responseResult1: 152,
            responseResult2: 89,
            favoritedBy: ["user404", "user999"]
        ))
        
        feedPosts.append(BinaryPost(
            postId: "21341234",
            userId: "anotherone",
            username: "TalkShowConnoisseur",
            comments: [
                Comment(commentType: .text,  postId: "21341234", userId: "user005", username: "KimmelFan", profilePhoto: "", date: Date(), commentId: "comm015", likes: ["user012", "user016"], dislikes: ["user017"], content: "Kimmel is a legend. Every show feels like a casual conversation, dude’s a natural. I also love his content covering recent events in the White House. He has no filter and it is the best way to wind down for the day."),
                Comment(commentType: .text,  postId: "21341234", userId: "user006", username: "ConanCultist", profilePhoto: "", date: Date(), commentId: "comm016", likes: ["user013"], dislikes: ["user005"], content: "Jimmy Kimmel is okay, but Conan O’Brien carried late-night TV on his back."),
                Comment(commentType: .text,  postId: "21341234", userId: "user007", username: "LettermanLoyalist", profilePhoto: "", date: Date(), commentId: "comm017", likes: ["user014"], dislikes: [], content: "Kimmel is good, but no one will ever top Letterman. The man had no filter."),
                Comment(commentType: .text,  postId: "21341234", userId: "user008", username: "ColbertConvert", profilePhoto: "", date: Date(), commentId: "comm018", likes: ["user015"], dislikes: ["user006"], content: "Kimmel’s great, but if we’re being honest, Stephen Colbert is running the game right now."),
                Comment(commentType: .text,  postId: "21341234", userId: "user009", username: "CordenCritic", profilePhoto: "", date: Date(), commentId: "comm019", likes: [], dislikes: ["user010", "user011"], content: "Honestly, I’d rather listen to static than watch another Carpool Karaoke segment."),
                Comment(commentType: .text,  postId: "21341234", userId: "user010", username: "MyMom", profilePhoto: "", date: Date(), commentId: "comm020", likes: ["user010", "user011", "user010", "user011", "user010", "user011"], dislikes: [], content: "MY FAVVVV!"),
                Comment(commentType: .text,  postId: "21341234", userId: "user011", username: "YourMom", profilePhoto: "", date: Date(), commentId: "comm021", likes: [], dislikes: ["user010", "user011", "user010", "user011"], content: "Man sucks.")
            ],
            responses: [
                Response(responseId: "resp013", userId: "user012", responseOption: "Nah"),
                Response(responseId: "resp014", userId: "user013", responseOption: "Yupppp")
            ],
            categories: [.entertainment(.tvShows), .other(.funny), .news(.politics)],
            viewCounter: 1_020,
            postDateAndTime: Date(),
            question: "Jimmy Kimmel is the best talk show host",
            responseOption1: "Nah",
            responseOption2: "Yupppp",
            responseResult1: 575,
            responseResult2: 445,
            favoritedBy: ["user006", "user007", "user008"]
        ))
        
        feedPosts.append(BinaryPost(
            postId: "777123999",
            userId: "starbucksoverlord",
            username: "CaffeineAddict",
            comments: [
                Comment(commentType: .text, postId: "777123999", userId: "user321", username: "NetflixJunkie", profilePhoto: "", date: Date(), commentId: "comm009", likes: ["user654"], dislikes: [], content: "I need my shows. Coffee is replaceable."),
                Comment(commentType: .text, postId: "777123999", userId: "user654", username: "JavaFiend", profilePhoto: "", date: Date(), commentId: "comm010", likes: ["user321"], dislikes: [], content: "If you think I can function without coffee, you’ve never met me.")
            ],
            responses: [
                Response(responseId: "resp009", userId: "user111", responseOption: "Goodbye Netflix"),
                Response(responseId: "resp010", userId: "user333", responseOption: "I'd rather perish")
            ],
            categories: [.lifestyle(.finances), .other(.funny)],
            viewCounter: 612,
            postDateAndTime: Date(),
            question: "Would you rather give up coffee or streaming services? ☕📺",
            responseOption1: "Goodbye Netflix",
            responseOption2: "I'd rather perish",
            responseResult1: 300,
            responseResult2: 312,
            favoritedBy: ["user321", "user654"]
        ))
        
        feedPosts.append(BinaryPost(
            postId: "834729384",
            userId: "myman",
            username: "CozyKing",
            comments: [
                Comment(commentType: .text, postId: "834729384", userId: "user001", username: "CarpetDefender", profilePhoto: "", date: Date(), commentId: "comm011", likes: ["user005", "user009"], dislikes: ["user007"], content: "Carpet in the bedroom is elite. Y’all sleeping on hardwood like cavemen."),
                Comment(commentType: .text, postId: "834729384", userId: "user002", username: "HardwoodPurist", profilePhoto: "", date: Date(), commentId: "comm012", likes: ["user003", "user008"], dislikes: ["user001"], content: "Carpet is just a bacteria sponge. You ever seen what's in that thing after a year?"),
                Comment(commentType: .text, postId: "834729384", userId: "user003", username: "RugLife", profilePhoto: "", date: Date(), commentId: "comm013", likes: ["user006"], dislikes: [], content: "Carpet is great until you drop something. Finding a contact lens on it is a spiritual experience. Or cleaning up spilled Dr. Pepper. That is a real bummer when you have carpet."),
                Comment(commentType: .text, postId: "834729384", userId: "user004", username: "BarefootBandit", profilePhoto: "", date: Date(), commentId: "comm014", likes: ["user009"], dislikes: [], content: "If you walk on carpet with socks, you’re living life on easy mode. Hardwood is for risk takers.")
            ],
            responses: [
                Response(responseId: "resp011", userId: "user010", responseOption: "TF no"),
                Response(responseId: "resp012", userId: "user011", responseOption: "Yeah...")
            ],
            categories: [.lifestyle(.homeDecor), .other(.funny)],
            viewCounter: 825,
            postDateAndTime: Date(),
            question: "Is it gross to have carpet in your bedroom?",
            responseOption1: "TF no",
            responseOption2: "Yeah...",
            responseResult1: 467,
            responseResult2: 35,
            favoritedBy: ["user001", "user004", "user008"]
        ))
        
        feedPosts.append(BinaryPost(
            postId: "123456789",
            userId: "roommateFromHell",
            username: "LandlordHater69",
            comments: [
                Comment(commentType: .text, postId: "123456789", userId: "user123", username: "CarpetHater", profilePhoto: "", date: Date(), commentId: "comm001", likes: ["user789"], dislikes: [], content: "Carpet in the bathroom should be a felony."),
                Comment(commentType: .text, postId: "123456789", userId: "user456", username: "VinylTile4Life", profilePhoto: "", date: Date(), commentId: "comm002", likes: ["user123", "user999"], dislikes: ["user555"], content: "If I see a carpeted bathroom, I'm calling the cops.")
            ],
            responses: [
                Response(responseId: "resp001", userId: "user789", responseOption: "Absolutely 🚔"),
                Response(responseId: "resp002", userId: "user555", responseOption: "Nah, just a fine")
            ],
            categories: [.lifestyle(.homeDecor), .other(.funny)],
            viewCounter: 305,
            postDateAndTime: Date(),
            question: "Should landlords go to prison for putting carpet in bathrooms?",
            responseOption1: "Absolutely 🚔",
            responseOption2: "Nah, just a fine",
            responseResult1: 184,
            responseResult2: 121,
            favoritedBy: ["user789", "user456"]))

        feedPosts.append(BinaryPost(
            postId: "987654321",
            userId: "toasterfanatic",
            username: "HotDogDebater",
            comments: [
                Comment(commentType: .text, postId: "987654321", userId: "user777", username: "BreadDefender", profilePhoto: "", date: Date(), commentId: "comm003", likes: ["user222"], dislikes: [], content: "A hot dog is NOT a sandwich. Don't start this."),
                Comment(commentType: .text, postId: "987654321", userId: "user222", username: "MeatIsMeat", profilePhoto: "", date: Date(), commentId: "comm004", likes: ["user777", "user999"], dislikes: [], content: "If a sub is a sandwich, then so is a hot dog. Wake up, sheeple.")
            ],
            responses: [
                Response(responseId: "resp003", userId: "user111", responseOption: "Yes, it's meat between bread"),
                Response(responseId: "resp004", userId: "user333", responseOption: "NO. Don't start this again.")
            ],
            categories: [.lifestyle(.cooking), .other(.funny)],
            viewCounter: 520,
            postDateAndTime: Date(),
            question: "Is a hot dog a sandwich? 🌭",
            responseOption1: "Yes, it's meat between bread",
            responseOption2: "NO. Don't start this again.",
            responseResult1: 258,
            responseResult2: 262,
            favoritedBy: ["user111", "user999"]
        ))

        feedPosts.append(BinaryPost(
            postId: "246813579",
            userId: "midnightmunchies",
            username: "ChristmasMovieGatekeeper",
            comments: [
                Comment(commentType: .text, postId: "246813579", userId: "user555", username: "YippeeKiYay", profilePhoto: "", date: Date(), commentId: "comm005", likes: ["user777"], dislikes: [], content: "If Home Alone counts, so does Die Hard."),
                Comment(commentType: .text, postId: "246813579", userId: "user999", username: "HolidayPurist", profilePhoto: "", date: Date(), commentId: "comm006", likes: [], dislikes: ["user555"], content: "Christmas movies need Santa, end of discussion.")
            ],
            responses: [
                Response(responseId: "resp005", userId: "user111", responseOption: "Yes, obviously"),
                Response(responseId: "resp006", userId: "user333", responseOption: "No, grow up")
            ],
            categories: [.entertainment(.movies), .other(.funny)],
            viewCounter: 790,
            postDateAndTime: Date(),
            question: "Is Die Hard a Christmas movie? 🎄🔫",
            responseOption1: "Yes, obviously",
            responseOption2: "No, grow up",
            responseResult1: 432,
            responseResult2: 358,
            favoritedBy: ["user555", "user777"]
        ))

        feedPosts.append(BinaryPost(
            postId: "135792468",
            userId: "toiletphilosopher",
            categories: [.other(.funny), .lifestyle(.minimalism)],
            postDateAndTime: Date(),
            question: "Do you wet the toothbrush before or after putting toothpaste? 🪥",
            responseOption1: "Before 🧐",
            responseOption2: "After, obviously"
        ))

        feedPosts.append(BinaryPost(
            postId: "192837465",
            userId: "theAIoverlords",
            username: "AI_Groom",
            comments: [
                Comment(commentType: .text, postId: "192837465", userId: "user888", username: "TechLover", profilePhoto: "", date: Date(), commentId: "comm007", likes: ["user111"], dislikes: [], content: "AI can probably write better vows than me tbh."),
                Comment(commentType: .text, postId: "192837465", userId: "user333", username: "FutureDivorcee", profilePhoto: "", date: Date(), commentId: "comm008", likes: [], dislikes: ["user888"], content: "If my spouse uses AI for our vows, I’m filing papers immediately.")
            ],
            responses: [
                Response(responseId: "resp007", userId: "user444", responseOption: "Yes, AI is poetic"),
                Response(responseId: "resp008", userId: "user999", responseOption: "No, I want a divorce already")
            ],
            categories: [.educational(.cs), .news(.worldEvents), .other(.funny)],
            viewCounter: 400,
            postDateAndTime: Date(),
            question: "Would you let AI write your wedding vows? 💍🤖",
            responseOption1: "Yes, AI is poetic",
            responseOption2: "No, I want a divorce already",
            responseResult1: 180,
            responseResult2: 220,
            favoritedBy: ["user888", "user111"]
        ))

        feedPosts.append(BinaryPost(
            postId: "666777888",
            userId: "gymbro69",
            categories: [.lifestyle(.fitness), .other(.funny)],
            postDateAndTime: Date(),
            question: "Do you skip leg day? 🏋️‍♂️",
            responseOption1: "Never, bro",
            responseOption2: "Only on days ending in 'y'"
        ))

        feedPosts.append(BinaryPost(
            postId: "314159265",
            userId: "mathnerd",
            categories: [.educational(.math), .other(.funny)],
            postDateAndTime: Date(),
            question: "Is 0.999... equal to 1? 🤯",
            responseOption1: "Yes, mathematically",
            responseOption2: "No, that's a scam"
        ))

        feedPosts.append(BinaryPost(
            postId: "888444222",
            userId: "socialmediaman",
            categories: [.entertainment(.socialMedia), .other(.funny)],
            postDateAndTime: Date(),
            question: "Would you delete social media for $10,000? 📱💰",
            responseOption1: "Easy money",
            responseOption2: "No, I'm addicted"
        ))
        
        
//        for post in feedPosts {
//            if let binarypost = post as? BinaryPost {
//                createBinaryPost(userId: binarypost.userId, categories: binarypost.categories, question: binarypost.question, responseOption1: binarypost.responseOption1, responseOption2: binarypost.responseOption2)
//            }
//        }

    }
    
    func getNextFeedPost() {
        // Pop index 0 of feedPosts
        feedPosts.remove(at: 0)
        feedPosts.append(allQueriedPosts[0])
        allQueriedPosts.remove(at: 0)
        // Append a new post from allQueriedPosts (just index 0 for now)
    }
    
    
    func skipPost(postId: String, userId: String) {
        guard !feedPosts.isEmpty else {
            print("No posts in feed to skip.")
            return
        }
        
        // Move the post at index 0 to skippedPost
        skippedPost = feedPosts.removeFirst()
        
        print("Skipped post: \(skippedPost?.postId ?? "None")")

        // add the post view to Firestore
        addViewToPost(postId: postId, userId: userId)

        // load the next post in the feed
        getNextFeedPost()

        // listen for changes in the new post
        watchForCurrentFeedPostChanges()
    }
    
    func undoSkipPost(postId: String, userId: String) {
        guard let skipped = skippedPost else {
            print("No post to undo skip.")
            return
        }

        // add back the skipped post to the front of feedPosts
        feedPosts.insert(skipped, at: 0)
        skippedPost = nil
        
        print("Restored skipped post: \(skipped.postId)")
    }
}
