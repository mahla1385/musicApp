package com.example.musicplayer.codes_of_project;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class LikeService {
        private final Map<Integer, Set<Integer>> likes = new HashMap<>();
        private final Map<Integer, Set<Integer>> dislikes = new HashMap<>();

        public void like(int songId, int userId) {
            likes.computeIfAbsent(songId, k -> new HashSet<>()).add(userId);
            dislikes.getOrDefault(songId, new HashSet<>()).remove(userId);
        }

        public void dislike(int songId, int userId) {
            dislikes.computeIfAbsent(songId, k -> new HashSet<>()).add(userId);
            likes.getOrDefault(songId, new HashSet<>()).remove(userId);
        }

        public int getLikeCount(int songId) {
            return likes.getOrDefault(songId, Collections.emptySet()).size();
        }

        public int getDislikeCount(int songId) {
            return dislikes.getOrDefault(songId, Collections.emptySet()).size();
        }
}
