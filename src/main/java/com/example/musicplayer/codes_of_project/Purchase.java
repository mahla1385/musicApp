package com.example.musicplayer.codes_of_project;

public class Purchase {
    private int id;
    private int userId;
    private int songId;
    private String purchaseDate;

    public Purchase() {}

    public Purchase(int id, int userId, int songId, String purchaseDate) {
        this.id = id;
        this.userId = userId;
        this.songId = songId;
        this.purchaseDate = purchaseDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getSongId() { return songId; }
    public void setSongId(int songId) { this.songId = songId; }
    public String getPurchaseDate() { return purchaseDate; }
    public void setPurchaseDate(String purchaseDate) { this.purchaseDate = purchaseDate; }

    @Override
    public String toString() {
        return "Purchase{" +
                "id = " + id +
                ", userId = " + userId +
                ", songId = " + songId +
                ", purchaseDate = " + purchaseDate + '\'' +
                '}';
    }
}
