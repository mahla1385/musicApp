import java.util.ArrayList;
import java.util.List;

public class PaymentService {
    private final List<Payment> paymentHistory = new ArrayList<>();
        private boolean isValidCard(String cardNumber) {
            if(cardNumber != null && cardNumber.length() == 16 && cardNumber.matches("\\d+")) {
                return true;
            }
        return false;
    }
    private boolean isValidPin(int pin) {
            if(pin >= 1000 && pin <= 9999) {
                return true;
            }
        return false;
    }
    private boolean isValidAmount(int amount) {
            if(amount > 0) {
                return true;
            }
        return false;
    }
    public boolean processPayment(String cardNumber, int pin, int amount) {
        if (!isValidCard(cardNumber)) {
            System.out.println("Invalid credit card number.");
            return false;
        }
        if (!isValidPin(pin)) {
            System.out.println("Invalid PIN. It must be 4 digits.");
            return false;
        }
        if (!isValidAmount(amount)) {
            System.out.println("Invalid payment amount.");
            return false;
        }
        Payment payment = new Payment(cardNumber, pin, amount);
        paymentHistory.add(payment);

        System.out.println("Payment successful!");
        System.out.println("Paid " + amount + " Toman from card " + cardNumber);
        return true;
    }
    public List<Payment> getPaymentHistory() {
        return paymentHistory;
    }
}
