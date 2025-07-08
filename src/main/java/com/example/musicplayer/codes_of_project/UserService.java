package com.example.musicplayer.codes_of_project;

import java.util.ArrayList;
import java.util.List;

public class UserService {
    private final List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
    }

    public User getUserByUsername(String username) {
        for (User user : users) {
            if (user.getUsername().equals(username)) {
                return user;
            }
        }
        return null;
    }

    public User getUserById(int id) {
        for (User user : users) {
            if (user.getId() == id) return user;
        }
        return null;
    }

    public String getUsernameById(int userId) {
        User user = getUserById(userId);
        return user != null ? user.getUsername() : "Unknown";
    }

    public boolean register(String username, String email, String password) {
        if (getUserByUsername(username) != null) return false;
        User user = new User();
        user.setId((int)(Math.random() * 100000));
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password);
        addUser(user);
        return true;
    }

    public User loginUser(String username, String password) {
        User user = getUserByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            return user;
        }
        return null;
    }

    public boolean deductBalance(int userId, double amount) {
        User user = getUserById(userId);
        if (user != null) {
            return user.deduct(amount);
        }
        return false;
    }
}