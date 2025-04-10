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
        let postRef = Firebase.db.collection("POSTS").document(feedPosts[0].postId)
        currentFeedPostCommentsListener = postRef.collection("COMMENTS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            DispatchQueue.main.async {
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        print("New comment: \(diff.document.data())")
                        let newCommentDoc = diff.document.data()
                        let id = diff.document.documentID
                        let date = DateConverter.convertStringToDate(newCommentDoc["date"] as? String ?? "") ?? Date()
                        let newComment = Comment(
                            commentType: CommentType.text,  // THIS NEEDS TO BE MODIFIED LATER!!~
                            postId: self.feedPosts[0].postId,
                            userId: newCommentDoc["userId"] as? String ?? "",
                            date: date,
                            commentId: id,
                            likes: newCommentDoc["likes"] as? [String] ?? [],
                            dislikes: newCommentDoc["dislikes"] as? [String] ?? [],
                            content: newCommentDoc["content"] as? String ?? ""
                            )
                        
                        self.feedPosts[0].comments.append(newComment)
                    } else if diff.type == .removed {
                        print("Comment removed: \(diff.document.documentID)")
                        self.feedPosts[0].comments.removeAll { $0.commentId == diff.document.documentID }
                    } else if diff.type == .modified {
                        print("Comment modified: \(diff.document.documentID)")
                        self.feedPosts[0].comments.removeAll { $0.commentId == diff.document.documentID }
                        let newCommentDoc = diff.document.data()
                        let id = diff.document.documentID
                        let date = DateConverter.convertStringToDate(newCommentDoc["date"] as? String ?? "") ?? Date()
                        let newComment = Comment(
                            commentType: CommentType.text,  // THIS NEEDS TO BE MODIFIED LATER!!~
                            postId: self.feedPosts[0].postId,
                            userId: newCommentDoc["userId"] as? String ?? "",
                            date: date,
                            commentId: id,
                            likes: newCommentDoc["likes"] as? [String] ?? [],
                            dislikes: newCommentDoc["dislikes"] as? [String] ?? [],
                            content: newCommentDoc["content"] as? String ?? ""
                            )
                        
                        self.feedPosts[0].comments.append(newComment)
                    }
//                    self.objectWillChange.send()
                    self.feedPosts = self.feedPosts
                }
            }
        }
    }
    
    func setUpResponsesListener() {
        currentFeedPostResponsesListener?.remove()
        
        let postRef = Firebase.db.collection("POSTS").document(feedPosts[0].postId)
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
                        
                        self.feedPosts[0].responses.append(newResponse)
                        self.feedPosts = self.feedPosts
                    }
                }
            }
        }
    }
    
    func setUpViewsListener() {
        currentFeedPostViewsListener?.remove()

        let postRef = Firebase.db.collection("POSTS").document(feedPosts[0].postId)
        currentFeedPostViewsListener = postRef.collection("VIEWS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            DispatchQueue.main.async {
                self.objectWillChange.send()
                let viewCount = snapshot.documents.count
                self.feedPosts[0].viewCounter = viewCount
                
                self.feedPosts = self.feedPosts
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
                            let categoryStrings = data["categories"] as? [String] ?? []
                            let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                            let post = BinaryPost(
                                postId: postId,
                                userId: data["userId"] as? String ?? "",
                                categories: categories,
                                topics: data["topics"] as? [String] ?? [],
                                postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                                    ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "")
                                    ?? Date(),
                                question: data["question"] as? String ?? "",
                                responseOption1: data["responseOption1"] as? String ?? "",
                                responseOption2: data["responseOption2"] as? String ?? "",
                                sublabel1: data["sublabel1"] as? String ?? "",
                                sublabel2: data["sublabel2"] as? String ?? "",
                                favoritedBy: data["favoritedBy"] as? [String] ?? []
                            )
                            
                            print("post categories: \(post.categories)")
                            return (postId, post)


                        case PostType.SliderPost.rawValue:
                            let categoryStrings = data["categories"] as? [String] ?? []
                            let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                            let post = SliderPost(
                                postId: postId,
                                userId: data["userId"] as? String ?? "",
                                categories: categories,
                                topics: data["topics"] as? [String] ?? [],
                                postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                                    ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "")
                                    ?? Date(),
                                question: data["question"] as? String ?? "",
                                lowerBoundLabel: data["lowerBoundLabel"] as? String ?? "",
                                upperBoundLabel: data["upperBoundLabel"] as? String ?? "",
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
//                            let categoryStrings = newPostData["categories"] as? [String] ?? []
//                            let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                            
                            let post = BinaryPost(postId: newPostData["postId"] as? String ?? "",
                                                  userId: newPostData["userId"] as? String ?? "",
                                                  categories: Category.mapStringsToCategories(returnedStrings: newPostData["categories"] as? [String] ?? []),
                                                  topics: newPostData["topics"] as? [String] ?? [],
                                                  postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                                                  ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                                                  ?? Date(),
                                                  question: newPostData["question"] as? String ?? "",
                                                  responseOption1: newPostData["responseOption1"] as? String ?? "",
                                                  responseOption2: newPostData["responseOption2"] as? String ?? "",
                                                  sublabel1: newPostData["sublabel1"] as? String ?? "",
                                                  sublabel2: newPostData["sublabel2"] as? String ?? "",
                                                  favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                            
                            self.allQueriedPosts.append(post)
                            self.allQueriedPosts = self.allQueriedPosts
                        } else if (newPostData["type"] as? String == PostType.SliderPost.rawValue) {
                            let categoryStrings = newPostData["categories"] as? [String] ?? []
                            let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                            let post = SliderPost(postId: newPostData["postId"] as? String ?? "",
                                                  userId: newPostData["userId"] as? String ?? "",
                                                  categories: Category.mapStringsToCategories(returnedStrings: newPostData["categories"] as? [String] ?? []),
                                                  topics: newPostData["topics"] as? [String] ?? [],
                                                  postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                                                      ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                                                      ?? Date(),
                                                  question: newPostData["question"] as? String ?? "",
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
                                
                                let categoryStrings = newPostData["categories"] as? [String] ?? []
                                let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                                
                                self.allQueriedPosts[index] = BinaryPost(
                                    postId: newPostData["postId"] as? String ?? "",
                                    userId: newPostData["userId"] as? String ?? "",
                                    categories: Category.mapStringsToCategories(returnedStrings: newPostData["categories"] as? [String] ?? []),
                                    topics: newPostData["topics"] as? [String] ?? [],
                                    postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                    question: newPostData["question"] as? String ?? "",
                                    responseOption1: newPostData["responseOption1"] as? String ?? "",
                                    responseOption2: newPostData["responseOption2"] as? String ?? "",
                                    sublabel1: newPostData["sublabel1"] as? String ?? "",
                                    sublabel2: newPostData["sublabel2"] as? String ?? "",
                                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])

                                self.allQueriedPosts = self.allQueriedPosts
                                
                            } else if (newPostData["type"] as? String == PostType.SliderPost.rawValue) {
                                print("updating slider post")
//                                let categoryStrings = newPostData["categories"] as? [String] ?? []
//                                let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                                self.allQueriedPosts[index] = SliderPost(
                                    postId: newPostData["postId"] as? String ?? "",
                                    userId: newPostData["userId"] as? String ?? "",
                                    categories: Category.mapStringsToCategories(returnedStrings: newPostData["categories"] as? [String] ?? []),
                                    topics: newPostData["topics"] as? [String] ?? [],
                                    postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                    question: newPostData["question"] as? String ?? "",
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
//                let categoryStrings = newPostData["categories"] as? [String] ?? []
//                let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                let post = BinaryPost(
                    postId: postId,
                    userId: newPostData["userId"] as? String ?? "",
                    categories: Category.mapStringsToCategories(returnedStrings: newPostData["categories"] as? [String] ?? []),
                    topics: newPostData["topics"] as? [String] ?? [],
                    postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                        ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                        ?? Date(),
                    question: newPostData["question"] as? String ?? "",
                    responseOption1: newPostData["responseOption1"] as? String ?? "",
                    responseOption2: newPostData["responseOption2"] as? String ?? "",
                    sublabel1: newPostData["sublabel1"] as? String ?? "",
                    sublabel2: newPostData["sublabel2"] as? String ?? "",
                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? []
                )
                DispatchQueue.main.async {
                    self.allQueriedPosts.append(post)
                }
            } else if newPostData["type"] as? String == PostType.SliderPost.rawValue {
                let categoryStrings = newPostData["categories"] as? [String] ?? []
                let categories = Category.mapStringsToCategories(returnedStrings: categoryStrings);
                let post = SliderPost(
                    postId: postId,
                    userId: newPostData["userId"] as? String ?? "",
                    categories: categories,
                    topics: newPostData["topics"] as? [String] ?? [],
                    postDateAndTime: (newPostData["postDateAndTime"] as? Timestamp)?.dateValue()
                        ?? DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "")
                        ?? Date(),
                    question: newPostData["question"] as? String ?? "",
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
  
    func createBinaryPost(userId: String, categories: [Category], question: String, responseOption1: String, responseOption2: String, sublabel1: String, sublabel2: String) async {
        // Create post instance
        let post = BinaryPost(
            postId: UUID().uuidString,
            userId: userId,
            categories: categories,
            postDateAndTime: Date(),
            question: question,
            responseOption1: responseOption1,
            responseOption2: responseOption2,
            sublabel1: sublabel1,
            sublabel2: sublabel2
        )
        
        // Create document in Firebase
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)
        let categoryStrings = post.categories.map{$0.rawValue}
        
        let topics = await generatePostKeywords(post: post)

        documentRef.setData([
            "type": PostType.BinaryPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "categories": categoryStrings,
            "topics": topics,
            "postDateAndTime": DateConverter.convertDateToString(post.postDateAndTime),
            "question": post.question,
            "responseOption1": post.responseOption1,
            "responseOption2": post.responseOption2,
            "sublabel1": post.sublabel1,
            "sublabel2": post.sublabel2,
            "favoritedBy": post.favoritedBy
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new post to POSTS with topics \(topics)")
            }
        }
    }
    
    func createSliderPost(userId: String, categories: [Category], question: String, lowerBoundLabel: String, upperBoundLabel: String) async {
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
            upperBoundLabel: upperBoundLabel
        )
        
        let topics = await generatePostKeywords(post: post)
        
        // Create document in Firebase
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)

        documentRef.setData([
            "type": PostType.SliderPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "categories": categoryString,
            "topics": topics,
            "postDateAndTime": DateConverter.convertDateToString(post.postDateAndTime),
            "question": post.question,
            "lowerBoundLabel": post.lowerBoundLabel,
            "upperBoundLabel": post.upperBoundLabel,
            "favoritedBy": post.favoritedBy
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new slider post to POSTS")
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
    
//    func createRankPost(userId: String, categories: [Category], question: String, responseOptions: [String]) {
//        let post = RankPost(
//            postId: UUID().uuidString,
//            userId: userId,
//            categories: categories,
//            postDateAndTime: Date(),
//            question: question,
//            responseOptions: responseOptions
//        )
//        
//        let documentRef = Firebase.db.collection("POSTS").document(post.postId)
//        
//        // Main post document data
//        documentRef.setData([
//            "type": PostType.RankPost.rawValue,
//            "postId": post.postId,
//            "userId": post.userId,
//            "categories": post.categories,
//            "postDateAndTime": Timestamp(date: post.postDateAndTime),
//            "question": post.question,
//            "responseOptions": post.responseOptions,
//            "viewCounter": 0,
//            "responseCounter": 0,
//            "favoritedBy": post.favoritedBy,
//        ]) { error in
//            if let error = error {
//                print("Error writing RankPost document: \(error)")
//            } else {
//                print("Added new ranked post to POSTS \(documentRef.documentID)")
//            }
//        }
//    }
    
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
    
    func getUserResponseForComment(postId: String, userId: String, completion: @escaping (String?) -> Void) {
        print("Method Called")
        print(userId)
        print(postId)
        Firebase.db.collection("POSTS").document(postId).collection("RESPONSES")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting user response: \(error)")
                    completion(nil)
                    return
                }
                
                if let document = snapshot?.documents.first,
                   let responseOption = document.data()["responseOption"] as? String {
                    print("BACKEND RESPONSE OPTION", responseOption)
                    completion(responseOption)
                } else {
                    print("Number of documents found: \(snapshot?.documents.count ?? 0)")
                    completion(nil)
                }
            }
    }
    
    func suggestPostCategories(question: String, captions: [String], completion: @escaping (([Category]) -> Void)) {
        let categories: [String] = Category.allCategoryStrings
        
        let systemPrompt = """
            You are a classifier that assigns categories to a post based on 
            a post's question and its captions. 
            Only respond with valid categories from the provided list. 
            Do not create new categories. Return the answer as a JSON array.
            """
        
        let userPrompt = """
            Question: \(question)
            Captions: \(captions.joined(separator: ", "))
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
            if (user.friends).contains(post.userId) {
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
            score += DateConverter.calcDateScore(postDate: post.postDateAndTime)
            
            //Call topics function for topic mathcing score
            score += topicRanker(user_topics: user.myTopics, post_topics: post.topics)
            
            //Call cateogries function for category matching score
            score += categoryRanker(user_categories: user.myCategories, post_categories: post.categories)
            
            if score > bestScore {
                bestScore = score
                bestIndex = i
            }
            
        }
        
        if allQueriedPosts.count > 0 {
            let bestPost = allQueriedPosts[bestIndex]
            print("Next feed post is " + bestPost.postId + " with a score of " + String(bestScore))
            allQueriedPosts.remove(at: bestIndex)
            allQueriedPosts.insert(bestPost, at: 0)
        } else {
            print("No more posts available")
        }
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
    
    func generatePostKeywords(post: any Post) async -> [String] {
        var responseText = ""
        
        if let binaryPost = post as? BinaryPost {
            responseText = "\(binaryPost.responseOption1) \(binaryPost.responseOption2)"
        } else if let sliderPost = post as? SliderPost {
            responseText = "\(sliderPost.lowerBoundLabel) \(sliderPost.upperBoundLabel)"
        }
        
        let categoryStrings = post.categories.map { $0.rawValue }
        
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
        Question: "\(post.question)"
        Category: "\(categoryStrings)"
        Response Options: "\(responseText)"
        Output:
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are an AI trained to extract the 20 most relevant keywords from a post based on its question, category, and response options. Respond ONLY with a JSON list of keywords."],
                ["role": "user", "content": examplePrompt]
            ],
            "temperature": 0.7
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ Invalid URL")
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Keys.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String,
               let contentData = content.data(using: .utf8),
               let keywords = try JSONSerialization.jsonObject(with: contentData, options: []) as? [String] {
                let cleanedKeywords = keywords.map {
                    $0.lowercased()
                      .components(separatedBy: .punctuationCharacters).joined()
                      .replacingOccurrences(of: " ", with: "")
                }
                return cleanedKeywords
            } else {
                print("❌ Unexpected response format from OpenAI")
            }
        } catch {
            print("❌ Error during OpenAI request: \(error.localizedDescription)")
        }
        
        return []
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
    
    func findNextPost(user: User) -> Bool {
        // load the next post in the feed
        if allQueriedPosts.isEmpty {
            return false
        }
        
        if feedPosts.count < 5 && !allQueriedPosts.isEmpty {
            getNextBestPost(user: user)
            feedPosts.append(allQueriedPosts[0])
            allQueriedPosts.remove(at: 0)
        }

        // listen for changes in the new post
        watchForCurrentFeedPostChanges()
        
        return true
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
        watchForCurrentFeedPostChanges()
        
        print("Restored skipped post: \(skipped.postId)")
    }
    
    func categoryRanker(user_categories: [String], post_categories: [Category]) -> Int {
        let point_distribution = [30, 25, 20, 18, 18, 15, 15, 12, 12, 10, 10, 10, 8, 8, 8, 5, 5, 5, 5, 5]
        var total_points = 0
        for (ind, cat) in user_categories.enumerated() {
            if let cat_object = Category.stringToCategory(cat) {
                if post_categories.contains(cat_object) {
                    total_points += point_distribution[ind]
                }
            }
        }
        return total_points
    }
    
    func topicRanker(user_topics: [String], post_topics: [String]) -> Int {
        let point_distribution = [30, 25, 20, 18, 18, 15, 15, 12, 12, 10, 10, 10, 8, 8, 8, 5, 5, 5, 5, 5]
        var total_points = 0
        for (ind, cat) in user_topics.enumerated() {
            if post_topics.contains(cat) {
                total_points += point_distribution[ind]
            }
        }
        return total_points
    }

    func getUserResponseForCurrentPost(userId: String) -> String? {
        let current_post = feedPosts[0]
//        var post_responses : [String: Int] = [:]
//        getResponses(postId: current_post.postId) { result in
//            post_responses = result
//            print("RESULTS")
//            print(result)
//        }
        //        for user in post_responses {
        //            if user.userId == userId {
        //                return user.responseOption
        //            }
        //        }
        //        return nil
        
        
//        Firebase.db.collection("POSTS").document(current_post.postId).collection("RESPONSES").getDocuments { (snapshot, error) in
//            if let error = error{
//                print("Error getting Post data: \(error)")
//            } else {
//                for document in snapshot!.documents {
//                    let data = document.data()
//                    print("DATA")
//                    print(data)
//                    let data_user = data["userId"] as? String ?? "CANT GET USERID"
////                    print("\(data_user) is a \(type(of: data_user))")
//                    if String(data_user) == userId {
//                        response = data["responseOption"] as? String ?? "CANT GET RESPONSE"
//                    }
//                }
//            }
//        
        var response: String = ""
        let responses = current_post.responses
        print("Responses within the method: \n\(responses)")
        for res in responses {
            if res.userId == userId {
                response = res.responseOption
            }
        }
        
        return response
    }


}
