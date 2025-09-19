
import ballerina/time;

/// ----Validates car plate format----
public function validatePlate(string plate) returns boolean {
    return plate.length() >= 4;}

/// ----Validates user role----
public function validateUserRole(string role) returns boolean {
    return role == "CUSTOMER" || role == "ADMIN";}

/// ----Validates car details before adding/updating----
public function validateCarDetails(string make, string model, int year, float dailyRate) returns boolean {
    if make == "" || model == "" {
        return false;  }
    if year < 1980 || year > 2035 {
        return false;}
    if dailyRate <= 0.0 {
        return false;}
    return true;}

/// ----Validates rental date range----

  

/// ----Validates rental date range using Civil time-----
public function validateDates(time:Civil startDate, time:Civil endDate) returns boolean {
    time:Utc|error startUtc = time:utcFromCivil(startDate);
    time:Utc|error endUtc = time:utcFromCivil(endDate); 

    if startUtc is error || endUtc is error {
        return false; }
return startUtc[0] <= endUtc[0];}
