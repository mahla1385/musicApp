package com.example.musicplayer.codes_of_project;

import java.util.ArrayList;
import java.util.List;

public class PurchaseService {
    private final List<Purchase> purchases = new ArrayList<>();

    public void addPurchase(Purchase purchase) {
        purchases.add(purchase);
    }

    public boolean hasUserPurchasedSong(int userId, int songId) {
        for (Purchase p : purchases) {
            if (p.getUserId() == userId && p.getSongId() == songId) {
                return true;
            }
        }
        return false;
    }

    public List<Purchase> getPurchasesByUserId(int userId) {
        List<Purchase> result = new ArrayList<>();
        for (Purchase p : purchases) {
            if (p.getUserId() == userId) {
                result.add(p);
            }
        }
        return result;
    }
}
