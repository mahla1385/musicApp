import java.util.ArrayList;
import java.util.List;

public class CommentService {
    private List<Comment> comments = new ArrayList<>();
    public void addComment(Comment comment) {
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
    public boolean deleteComment(int commentId) {
        for (int i = 0; i < comments.size(); i++) {
            Comment c = comments.get(i);
            if (c.getId() == commentId) {
                comments.remove(i);
                return true;
            }
        }
        return false;
    }
}
