import ballerina/time;

///----Cal the number of rental days (inclusive)---- ///

public function calculateDays(time:Utc startDate, time:Utc endDate) returns int|error {
    if startDate[0] > endDate[0] {
        return error("Start date cannot be after end date");}

    int seconds = <int>time:utcDiffSeconds(endDate, startDate);
    int days = seconds / (60 * 60 * 24) + 1;
    return days;}



/// ----Cal tot price for a rental---- ///
public function calculatePrice(float dailyRate, int days) returns float { return dailyRate * days;}

/// ----Sums up multiple prices---- ///
public function calculateTotal(float[] prices) returns float {
    float total = 0;
    foreach var price in prices { total += price;}
    return total;}
     
    /// ----Calculate taxes (e.g., VAT, service tax)---- ///

/// ----taxRate: Tax rate (default 10%)---- ///

public function calculateTax(float baseAmount, float taxRate = 0.10) returns float {
    if baseAmount <= 0.0 {
        return 0.0;}
    return baseAmount * taxRate;}
