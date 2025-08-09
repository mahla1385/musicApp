package com.example.musicplayer.codes_of_project;

public class Song {
    private int id;
    private String title;
    private String artist;
    private int duration; // seconds
    private String genre;

    public Song() {}

    public Song(int id, String title, String artist, int duration, String genre) {
        this.id = id;
        this.title = title;
        this.artist = artist;
        this.duration = duration;
        this.genre = genre;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getArtist() { return artist; }
    public void setArtist(String artist) { this.artist = artist; }
    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }
    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public String getFormattedDuration() {
        int minutes = duration / 60;
        int seconds = duration % 60;
        return String.format("%02d:%02d", minutes, seconds);
    }

    @Override
    public String toString() {
        return "Song{" +
                "id = " + id +
                ", title = " + title + '\'' +
                ", artist = " + artist + '\'' +
                ", duration = " + getFormattedDuration() +
                ", genre = " + genre + '\'' +
                '}';
    }
}
