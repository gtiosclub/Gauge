//
//  PostFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation
import Firebase

class PostFirebase: ObservableObject {
    @Published var feedPosts: [Post] = []
    @Published var allQueriedPosts: [Post] = []
    @Published var skippedPost: Post? = nil
    private var currentFeedPostsListener: ListenerRegistration? = nil
    
    init() {
        Keys.fetchKeys()
    }

    // Remove a user to "VIEWS" collection within a post
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

    
    func getLiveFeedPosts(user: User) {
        let allPosts: [String] = user.myViews + user.myResponses
        Firebase.db.collection("POSTS").whereField("postId", notIn: allPosts.isEmpty ? [""] : allPosts).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching post updates: \(error!)")
                return
            }
    
            for change in snapshot.documentChanges {
                if change.type == .added {
                    
                } else if change.type == .modified {

                } else if change.type == .removed {
                    
                }
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
            "responseCounter": post.responseCounter,
            "postDateAndTime": post.postDateAndTime,
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
            "categories": post.categories,
            "viewCounter": post.viewCounter,
            "responseCounter": post.responseCounter,
            "postDateAndTime": post.postDateAndTime,
            "question": post.question,
            "lowerBoundValue": post.lowerBoundValue,
            "upperBoundValue": post.upperBoundValue,
            "lowerBoundLabel": post.lowerBoundLabel,
            "upperBoundLabel": post.upperBoundLabel,
            "responseResults": post.responseResults,
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
            "responseResults": post.responseResults
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
    
    func deleteComment(postId: String, commentId: String){
        Firebase.db.collection("POSTS").document(postId).collection("COMMENTS").document(commentId).delete(){ error in
            if let error = error{
                print("Error deleting Comment: \(error)")
            } else {
                print("deleted comment from COMMENTS")
            }
        }
    }
}
