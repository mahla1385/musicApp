package com.example.musicplayer.codes_of_project;

import java.util.ArrayList;
import java.util.List;

public class PaymentService {
    private final List<Payment> paymentHistory = new ArrayList<>();

    private boolean isValidCard(String cardNumber) {
        return cardNumber != null && cardNumber.length() == 16 && cardNumber.matches("\\d+");
    }

    private boolean isValidPin(int pin) {
        return pin >= 1000 && pin <= 9999;
    }

    private boolean isValidAmount(double amount) {
        return amount > 0;
    }

    public boolean processPayment(Payment payment) {
        if (!isValidCard(payment.getCardNumber())) return false;
        if (!isValidPin(payment.getPin())) return false;
        if (!isValidAmount(payment.getAmount())) return false;
        paymentHistory.add(payment);
        return true;
    }

    public List<Payment> getPaymentHistory() {
        return new ArrayList<>(paymentHistory);
    }
}
