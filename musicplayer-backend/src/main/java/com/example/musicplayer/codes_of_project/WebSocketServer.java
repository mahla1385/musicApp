package com.example.musicplayer.codes_of_project;

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.*;
import com.google.gson.*;

@ServerEndpoint("/ws")
public class WebSocketServer {
    private static final Set<Session> sessions = Collections.synchronizedSet(new HashSet<>());
    private static final UserService userService = new UserService();
    private static final CommentService commentService = new CommentService();
    private static final LikeService likeService = new LikeService();
    private static final PurchaseService purchaseService = new PurchaseService();

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
        System.out.println("🟢 New connection: " + session.getId());
    }

    @OnMessage
    public void onMessage(String message, Session session) throws IOException {
        JsonObject response = new JsonObject();
        try {
            JsonObject json = JsonParser.parseString(message).getAsJsonObject();

            // چک کن که کلید action هست و مقدارش null نیست
            if (!json.has("action") || json.get("action").isJsonNull()) {
                response.addProperty("status", "error");
                response.addProperty("message", "Missing action field.");
                session.getBasicRemote().sendText(response.toString());
                return;
            }

            String action = json.get("action").getAsString();

            switch (action) {
                case "signup": {
                    if (!json.has("username") || json.get("username").isJsonNull() ||
                            !json.has("email") || json.get("email").isJsonNull() ||
                            !json.has("password") || json.get("password").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing username, email or password.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    String username = json.get("username").getAsString();
                    String email = json.get("email").getAsString();
                    String password = json.get("password").getAsString();
                    boolean created = userService.register(username, email, password);
                    response.addProperty("action", "signup_response");
                    response.addProperty("status", created ? "success" : "username_or_email_or_password_taken");
                    session.getBasicRemote().sendText(response.toString());
                    break;
                }
                case "login": {
                    if (!json.has("username") || json.get("username").isJsonNull() ||
                            !json.has("email") || json.get("email").isJsonNull() ||
                            !json.has("password") || json.get("password").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing username, email or password.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }

                    String username = json.get("username").getAsString();
                    String email = json.get("email").getAsString();
                    String password = json.get("password").getAsString();

                    User user = userService.loginUser(username, password);

                    response.addProperty("action", "login_response");

                    if (user != null && user.getEmail().equalsIgnoreCase(email)) {
                        response.addProperty("status", "success");

                        JsonObject data = new JsonObject();
                        data.addProperty("id", user.getId());
                        data.addProperty("username", user.getUsername());
                        data.addProperty("email", user.getEmail());
                        data.addProperty("isPremium", true);

                        response.add("data", data);
                    } else {
                        response.addProperty("status", "invalid_credentials");
                        response.addProperty("message", "Invalid username/email or password.");
                    }

                    session.getBasicRemote().sendText(response.toString());
                    break;
                }
                case "reset_password": {
                    if (!json.has("email") || json.get("email").isJsonNull() ||
                            !json.has("newPassword") || json.get("newPassword").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing email or newPassword.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    String email = json.get("email").getAsString();
                    String newPassword = json.get("newPassword").getAsString();

                    boolean updated = userService.updatePassword(email, newPassword);
                    response.addProperty("action", "reset_password_response");
                    response.addProperty("status", updated ? "success" : "error");
                    if (!updated) {
                        response.addProperty("message", "Failed to update password.");
                    }
                    session.getBasicRemote().sendText(response.toString());
                    break;
                }
                case "add_comment": {
                    if (!json.has("userId") || json.get("userId").isJsonNull() ||
                            !json.has("songId") || json.get("songId").isJsonNull() ||
                            !json.has("content") || json.get("content").isJsonNull() ||
                            !json.has("username") || json.get("username").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing comment fields.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int userId = json.get("userId").getAsInt();
                    int songId = json.get("songId").getAsInt();
                    String content = json.get("content").getAsString();
                    String username = json.get("username").getAsString();

                    Comment comment = new Comment(userId, songId, content);
                    commentService.addComment(comment);
                    JsonObject ack = new JsonObject();
                    ack.addProperty("action", "comment_added");
                    ack.addProperty("songId", songId);
                    session.getBasicRemote().sendText(ack.toString());
                    broadcastComments(songId);
                    break;
                }
                case "delete_comment": {
                    if (!json.has("commentId") || json.get("commentId").isJsonNull() ||
                            !json.has("songId") || json.get("songId").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing commentId or songId.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int commentId = json.get("commentId").getAsInt();
                    int songId = json.get("songId").getAsInt();
                    boolean deleted = commentService.deleteComment(commentId);
                    if (deleted) {
                        broadcastComments(songId);
                    }
                    break;
                }
                case "get_comments": {
                    if (!json.has("songId") || json.get("songId").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing songId.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int songId = json.get("songId").getAsInt();
                    sendCommentsToSession(songId, session);
                    break;
                }
                case "like_dislike": {
                    if (!json.has("userId") || json.get("userId").isJsonNull() ||
                            !json.has("songId") || json.get("songId").isJsonNull() ||
                            !json.has("type") || json.get("type").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing like/dislike fields.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int userId = json.get("userId").getAsInt();
                    int songId = json.get("songId").getAsInt();
                    String type = json.get("type").getAsString();

                    if (type.equals("like")) {
                        likeService.like(songId, userId);
                    } else {
                        likeService.dislike(songId, userId);
                    }
                    broadcastLikeStatus(songId);
                    break;
                }
                case "get_likes_count": {
                    if (!json.has("songId") || json.get("songId").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing songId.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int songId = json.get("songId").getAsInt();
                    sendLikeStatus(songId, session);
                    break;
                }
                case "purchase_song": {
                    if (!json.has("userId") || json.get("userId").isJsonNull() ||
                            !json.has("songId") || json.get("songId").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing purchase fields.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int userId = json.get("userId").getAsInt();
                    int songId = json.get("songId").getAsInt();

                    Purchase purchase = new Purchase(0, userId, songId, new Date().toString());
                    purchaseService.addPurchase(purchase);

                    JsonObject result = new JsonObject();
                    result.addProperty("action", "purchase_song_response");
                    result.addProperty("status", "success");
                    result.addProperty("message", "Purchase completed.");
                    session.getBasicRemote().sendText(result.toString());
                    break;
                }
                case "check_purchase": {
                    if (!json.has("userId") || json.get("userId").isJsonNull() ||
                            !json.has("songId") || json.get("songId").isJsonNull()) {
                        response.addProperty("status", "error");
                        response.addProperty("message", "Missing check_purchase fields.");
                        session.getBasicRemote().sendText(response.toString());
                        return;
                    }
                    int userId = json.get("userId").getAsInt();
                    int songId = json.get("songId").getAsInt();

                    boolean purchased = purchaseService.hasUserPurchasedSong(userId, songId);
                    JsonObject res = new JsonObject();
                    res.addProperty("action", "check_purchase_response");
                    res.addProperty("userId", userId);
                    res.addProperty("songId", songId);
                    res.addProperty("purchased", purchased);
                    session.getBasicRemote().sendText(res.toString());
                    break;
                }
                default: {
                    response.addProperty("status", "error");
                    response.addProperty("message", "Unknown action: " + action);
                    session.getBasicRemote().sendText(response.toString());
                }
            }
        } catch (Exception e) {
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
            session.getBasicRemote().sendText(response.toString());
            e.printStackTrace();
        }
    }

    private void broadcastComments(int songId) throws IOException {
        List<Comment> comments = commentService.getCommentsBySongId(songId);
        JsonArray arr = new JsonArray();
        for (Comment c : comments) {
            JsonObject obj = new JsonObject();
            obj.addProperty("id", c.getId());
            obj.addProperty("userId", c.getUserId());
            obj.addProperty("content", c.getContent());
            obj.addProperty("timestamp", c.getTimestamp());
            User u = userService.getUserById(c.getUserId());
            obj.addProperty("username", u != null ? u.getUsername() : "User " + c.getUserId());
            arr.add(obj);
        }
        JsonObject res = new JsonObject();
        res.addProperty("action", "get_comments_response");
        res.addProperty("songId", songId);
        res.add("comments", arr);
        broadcast(res.toString());
    }

    private void sendCommentsToSession(int songId, Session session) throws IOException {
        List<Comment> comments = commentService.getCommentsBySongId(songId);
        JsonArray arr = new JsonArray();
        for (Comment c : comments) {
            JsonObject obj = new JsonObject();
            obj.addProperty("id", c.getId());
            obj.addProperty("userId", c.getUserId());
            obj.addProperty("content", c.getContent());
            obj.addProperty("timestamp", c.getTimestamp());
            User u = userService.getUserById(c.getUserId());
            obj.addProperty("username", u != null ? u.getUsername() : "User " + c.getUserId());
            arr.add(obj);
        }
        JsonObject res = new JsonObject();
        res.addProperty("action", "get_comments_response");
        res.addProperty("songId", songId);
        res.add("comments", arr);
        session.getBasicRemote().sendText(res.toString());
    }

    private void broadcastLikeStatus(int songId) throws IOException {
        JsonObject res = new JsonObject();
        res.addProperty("action", "likes_count");
        res.addProperty("songId", songId);
        res.addProperty("likes", likeService.getLikeCount(songId));
        res.addProperty("dislikes", likeService.getDislikeCount(songId));
        broadcast(res.toString());
    }

    private void sendLikeStatus(int songId, Session session) throws IOException {
        JsonObject res = new JsonObject();
        res.addProperty("action", "likes_count");
        res.addProperty("songId", songId);
        res.addProperty("likes", likeService.getLikeCount(songId));
        res.addProperty("dislikes", likeService.getDislikeCount(songId));
        session.getBasicRemote().sendText(res.toString());
    }

    private void broadcast(String message) {
        synchronized (sessions) {
            for (Session s : sessions) {
                try {
                    s.getBasicRemote().sendText(message);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
        System.out.println("🔴 Connection closed: " + session.getId());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("❗ Error: " + throwable.getMessage());
    }
}