public class User {
    private int id;
    private String username;
    private String email;
    private String password;
    public User() {
    }
    public User(int id, String username, String email, String password) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
    }

    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public boolean isEmailValid() {
        if(email != null && email.contains("@") && email.contains(".")) {
            return true;
        }
        return false;
    }
    public boolean changePassword(String newPassword) {
        if (newPassword != null && newPassword.length() >= 8) {
            this.password = newPassword;
            return true;
        }
        return false;
    }
    @Override
    public String toString() {
        return "User{" +
                "id = " + id +
                ", username = " + username + '\'' +
                ", email = " + email + '\'' +
                '}';
    }
}
