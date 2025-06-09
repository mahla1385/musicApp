import java.util.StringJoiner;

public class Payment {
    private String creaditCard;
    private int password;
    private double paymentAmount;
    public Payment() {
    }
    public  Payment(String creaditCard, int password, int paymentAmount) {
        this.creaditCard = creaditCard;
        this.password = password;
        this.paymentAmount = paymentAmount;
    }
    public String getCreaditCard() {
        return  creaditCard;
    }
    public int getPassword() {
        return password;
    }
    public double getPaymentAmount() {
        return paymentAmount;
    }
    public void setPassword(int password) {
        this.password = password;
    }
    public void setCreaditCard(String creaditCard) {
        this.creaditCard = creaditCard;
    }
    public  void setPaymentAmount(double paymentAmount) {
        this.paymentAmount = paymentAmount;
    }
}
