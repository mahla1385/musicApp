public class Comment {
    private int id;
    private int userId;
    private int songId;
    private String content;
    private String timestamp;
    public Comment() {
    }
    public Comment(int id, int userId, int songId, String content, String timestamp) {
        this.id = id;
        this.userId = userId;
        this.songId = songId;
        this.content = content;
        this.timestamp = timestamp;
    }
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }
    public int getSongId() {
        return songId;
    }
    public void setSongId(int songId) {
        this.songId = songId;
    }
    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }
    public String getTimestamp() {
        return timestamp;
    }
    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
    @Override
    public String toString() {
        return "Comment{" +
                "id = " + id +
                ", userId = " + userId +
                ", songId = " + songId +
                ", content = " + content + '\'' +
                ", timestamp = " + timestamp + '\'' +
                '}';
    }
}