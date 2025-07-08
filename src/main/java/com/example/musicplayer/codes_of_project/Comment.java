package com.example.musicplayer.codes_of_project;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Comment {
    private int id;
    private int userId;
    private int songId;
    private String content;
    private String timestamp;

    public Comment() {}
    public Comment(int userId, int songId, String content) {
        this.id = generateId();
        this.userId = userId;
        this.songId = songId;
        this.content = content;
        this.timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    private static int idCounter = 1;
    private static int generateId() {
        return idCounter++;
    }


    public Comment(int id, int userId, int songId, String content) {
        this.id = id;
        this.userId = userId;
        this.songId = songId;
        this.content = content;
        this.timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getSongId() { return songId; }
    public void setSongId(int songId) { this.songId = songId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }

    @Override
    public String toString() {
        return "Comment{" +
                "id=" + id +
                ", userId=" + userId +
                ", songId=" + songId +
                ", content='" + content + '\'' +
                ", timestamp='" + timestamp + '\'' +
                '}';
    }
}
