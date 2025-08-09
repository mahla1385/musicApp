package com.example.musicplayer.codes_of_project;

import java.util.ArrayList;
import java.util.List;

public class UserService {
    private static final List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
    }

    public User getUserByUsername(String username) {
        for (User user : users) {
            if (user.getUsername().equalsIgnoreCase(username)) {
                return user;
            }
        }
        return null;
    }

    public User getUserByEmail(String email) {
        for (User user : users) {
            if (user.getEmail().equalsIgnoreCase(email)) {
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

    public boolean register(String username, String email, String password) {
        if (getUserByUsername(username) != null || getUserByEmail(email) != null) {
            return false; // username or email already taken
        }

        User user = new User();
        user.setId(generateUniqueId());
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password);
        user.setBalance(100.0);

        addUser(user);
        return true;
    }

    public User loginUser(String usernameOrEmail, String password) {
        User user = getUserByUsername(usernameOrEmail);
        if (user == null) {
            user = getUserByEmail(usernameOrEmail);
        }
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

    private int generateUniqueId() {
        int id;
        do {
            id = (int) (Math.random() * 100000);
        } while (getUserById(id) != null);
        return id;
    }

    // ** اینجا متد آپدیت رمز **
    public boolean updatePassword(String email, String newPassword) {
        User user = getUserByEmail(email);
        if (user != null) {
            user.setPassword(newPassword);
            return true;
        }
        return false;
    }
}