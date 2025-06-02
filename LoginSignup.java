public class LoginSignup {
    private final UserService userService;
    public LoginSignup(UserService userService) {
        this.userService = userService;
    }
    public boolean signup(String username, String email, String password) {
        if (userService.getUserByUsername(username) != null) {
            System.out.println("Username already taken.");
            return false;
        }
        User newUser = new User();
        newUser.setId((int) (Math.random() * 10000));
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPassword(password);

        userService.addUser(newUser);
        System.out.println("User signed up successfully.");
        return true;
    }
    public boolean login(String username, String password) {
        User user = userService.getUserByUsername(username);
        if (user == null) {
            System.out.println("User not found.");
            return false;
        }
        if (!user.getPassword().equals(password)) {
            System.out.println("Invalid password.");
            return false;
        }
        System.out.println("Login successful!");
        return true;
    }
}
