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
    
    func addDummyPosts() {
        feedPosts.append(BinaryPost(postId: "834729384", userId: "myman", categories: [.lifestyle(.homeDecor), .other(.funny)], postDateAndTime: Date(), question: "Is it gross to have carpet in your bedroom", responseOption1: "TF no", responseOption2: "Yeah..."))
        
        feedPosts.append(BinaryPost(postId: "21341234", userId: "anotherone", categories: [.entertainment(.tvShows), .other(.funny), .news(.politics)], postDateAndTime: Date(), question: "Jimmy Kimmel is the best talk show host", responseOption1: "Nah", responseOption2: "Yupppp"))
        
        feedPosts.append(BinaryPost(postId: "903885747", userId: "coolguy", categories: [.sports(.nfl), .sports(.soccer), .entertainment(.tvShows), .entertainment(.movies)], postDateAndTime: Date(), question: "Insert controversial binary take right here in this box; yeah, incite some intereseting discourse", responseOption1: "bad", responseOption2: "good"))
    }
    
    func getNextFeedPost() {
        // Pop index 0 of feedPosts
        feedPosts.remove(at: 0)
        feedPosts.append(allQueriedPosts[0])
        // Append a new post from allQueriedPosts (just index 0 for now)
    }
    
    func watchForCurrentFeedPostChanges() {
        setUpCommentsListener()
        setUpResponsesListener()
        setUpViewsListener()
        // Makes changes to the Post's (Binary) responses, viewCounter, comments, responseResult1, responseResult2

    }
    
    func setUpCommentsListener() {
        // Cancel current listeners (if there are ones)
        currentFeedPostCommentsListener?.remove()
//        currentFeedPostResponsesListener?.remove()
//        currentFeedPostViewsListener?.remove()

        // Setup listener for new index 0 subcollections
        var currentPost = feedPosts[0]
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
        
        var currentPost = feedPosts[0]
        let postRef = Firebase.db.collection("POSTS").document(currentPost.postId)
        currentFeedPostCommentsListener = postRef.collection("RESPONSES").addSnapshotListener { snapshot, error in
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
        var currentPost = feedPosts[0]
        let postRef = Firebase.db.collection("POSTS").document(currentPost.postId)
        currentFeedPostCommentsListener = postRef.collection("VIEWS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            DispatchQueue.main.async {
                self.objectWillChange.send()
                let viewCount = snapshot.documents.count
                currentPost.viewCounter = viewCount
            }
        }
                
    }

        
    
    func watchForNewPosts(user: User) {
        let allPosts: [String] = user.myViews + user.myResponses
        Firebase.db.collection("POSTS").whereField("postId", notIn: allPosts.isEmpty ? [""] : allPosts).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching post updates: \(error!)")
                return
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
                for change in snapshot.documentChanges {
                    if change.type == .added {
                        print(change.document.documentID)
                        let newPostData = change.document.data()
                        if (newPostData["type"] as? String == PostType.BinaryPost.rawValue) {
                            let post = BinaryPost(postId: newPostData["postId"] as? String ?? "",
                                                  userId: newPostData["userId"] as? String ?? "",
                                                  categories: newPostData["categories"] as? [Category] ?? [],
                                                  postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
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
                                                  postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                                  question: newPostData["question"] as? String ?? "",
                                                  lowerBoundValue: newPostData["lowerBoundValue"] as? Double ?? 0,
                                                  upperBoundValue: newPostData["upperBoundValue"] as? Double ?? 1,
                                                  lowerBoundLabel: newPostData["lowerBoundLabel"] as? String ?? "",
                                                  upperBoundLabel: newPostData["upperBoundLabel"] as? String ?? "",
                                                  favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                            
                            self.allQueriedPosts.append(post)
                            self.allQueriedPosts = self.allQueriedPosts
                        } else if (newPostData["type"] as? String == PostType.RankPost.rawValue){
                            let post = RankPost(postId: newPostData["postId"] as? String ?? "",
                                                  userId: newPostData["userId"] as? String ?? "",
                                                  categories: newPostData["categories"] as? [Category] ?? [],
                                                  postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                                  question: newPostData["question"] as? String ?? "",
                                                  responseOptions: newPostData["responseOptions"] as? [String] ?? [],
                                                  favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                            
                            self.allQueriedPosts.append(post)
                            self.allQueriedPosts = self.allQueriedPosts
                        }
                        
                    } else if change.type == .modified {
                        //finds index of modified data in Queue
                        if let index = self.allQueriedPosts.firstIndex(where: { $0.postId == change.document.documentID }) {
                            let newPostData = change.document.data()
                            
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
                            } else if (newPostData["type"] as? String == PostType.RankPost.rawValue){
                                print("adding rank")
                                
                                self.allQueriedPosts[index] = RankPost(
                                    postId: newPostData["postId"] as? String ?? "",
                                    userId: newPostData["userId"] as? String ?? "",
                                    categories: newPostData["categories"] as? [Category] ?? [],
                                    postDateAndTime: DateConverter.convertStringToDate(newPostData["postDateAndTime"] as? String ?? "") ?? Date(),
                                    question: newPostData["question"] as? String ?? "",
                                    responseOptions: newPostData["responseOptions"] as? [String] ?? [],
                                    favoritedBy: newPostData["favoritedBy"] as? [String] ?? [])
                                
                                self.allQueriedPosts = self.allQueriedPosts
                            }
                        }
                                                

                    } else if change.type == .removed {
                        self.allQueriedPosts = self.allQueriedPosts.filter { $0.postId != change.document.documentID }
                    }
                }
                
            }
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
                print("Successfully disliked the comment.")
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

        documentRef.setData([
            "type": PostType.BinaryPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "categories": post.categories,
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
                           userId: data["userId"] as? String ?? "",
                           username:"",
                           profilePhoto: "",
                           date: DateConverter.convertStringToDate(data["date"] as? String ?? "") ?? Date(),
                           commentId: data["commentId"] as? String ??  "",
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
    
    func getUserNumResponses(postIds: [String]) async -> Int? {
        do {
            var totalResponses = 0
            
            for postId in postIds {
                let documentRef = Firebase.db.collection("POSTS").document(postId).collection("RESPONSES")
                let querySnapshot = try await documentRef.getDocuments()
                let count = querySnapshot.documents.count
                print("Number of responses under \(postId): \(count)")
                totalResponses += count
            }
            
            return totalResponses
        } catch {
            print("Error getting responses: \(error)")
            return nil
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

