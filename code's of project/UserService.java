import java.util.ArrayList;
import java.util.List;

public class UserService {
    private List<User> users = new ArrayList<>();
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
    public boolean deleteUserById(int userId) {
        for (int i = 0; i < users.size(); i++) {
            User user = users.get(i);
            if (user.getId() == userId) {
                users.remove(i);
                return true;
            }
        }
        return false;
    }
}
