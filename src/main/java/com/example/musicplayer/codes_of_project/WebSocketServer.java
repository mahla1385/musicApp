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
            String action = json.get("action").getAsString();

            switch (action) {
                case "signup": {
                    String username = json.get("username").getAsString();
                    String email = json.get("email").getAsString();
                    String password = json.get("password").getAsString();
                    boolean created = userService.register(username, email, password);
                    response.addProperty("action", "signup_response");
                    response.addProperty("status", created ? "success" : "username_taken");
                    session.getBasicRemote().sendText(response.toString());
                    break;
                }
                case "login": {
                    String username = json.get("username").getAsString();
                    String password = json.get("password").getAsString();
                    User user = userService.loginUser(username, password);
                    response.addProperty("action", "login_response");
                    if (user != null) {
                        response.addProperty("status", "success");
                        response.addProperty("id", user.getId());
                        response.addProperty("username", user.getUsername());
                        response.addProperty("email", user.getEmail());
                        response.addProperty("balance", user.getBalance());
                    } else {
                        response.addProperty("status", "invalid_credentials");
                    }
                    session.getBasicRemote().sendText(response.toString());
                    break;
                }
                case "add_comment": {
                    int userId = json.get("userId").getAsInt();
                    int songId = json.get("songId").getAsInt();
                    String content = json.get("content").getAsString();
                    String username = json.get("username").getAsString();

                    Comment comment = new Comment(userId, songId, content);
                    commentService.addComment(comment);
                    System.out.println("📝 Comment: " + username + ": " + content);
                    JsonObject ack = new JsonObject();
                    ack.addProperty("action", "comment_added");
                    ack.addProperty("songId", songId);
                    session.getBasicRemote().sendText(ack.toString());
                    broadcastComments(songId);
                    break;
                }
                case "delete_comment": {
                    int commentId = json.get("commentId").getAsInt();
                    int songId = json.get("songId").getAsInt();
                    boolean deleted = commentService.deleteComment(commentId);
                    if (deleted) {
                        broadcastComments(songId);
                    }
                    break;
                }
                case "get_comments": {
                    int songId = json.get("songId").getAsInt();
                    sendCommentsToSession(songId, session);
                    break;
                }
                case "like_dislike": {
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
                    int songId = json.get("songId").getAsInt();
                    sendLikeStatus(songId, session);
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