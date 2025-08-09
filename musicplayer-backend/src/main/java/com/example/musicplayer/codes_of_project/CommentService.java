package com.example.musicplayer.codes_of_project;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class CommentService {
    private final List<Comment> comments = new ArrayList<>();
    private final AtomicInteger commentIdCounter = new AtomicInteger(1);

    public void addComment(Comment comment) {
        comment.setId(commentIdCounter.getAndIncrement());
        comments.add(comment);
    }

    public List<Comment> getCommentsBySongId(int songId) {
        List<Comment> result = new ArrayList<>();
        for (Comment c : comments) {
            if (c.getSongId() == songId) {
                result.add(c);
            }
        }
        return result;
    }

    public int getCommentCountForSong(int songId) {
        int count = 0;
        for (Comment c : comments) {
            if (c.getSongId() == songId) {
                count++;
            }
        }
        return count;
    }

    public boolean deleteComment(int commentId) {
        return comments.removeIf(c -> c.getId() == commentId);
    }

    public List<Comment> getAllComments() {
        return new ArrayList<>(comments);
    }
}
