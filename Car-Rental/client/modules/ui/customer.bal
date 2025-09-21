import ballerina/io;
import 'client.handlers as handlers;

const string SERVER_URL = "http://localhost:9090";

// Customer UI Main Function
public function customerMain() returns error? {
    handlers:CustomerHandler customerHandler = check new (SERVER_URL);
    
    while true {
        io:println("\n CUSTOMER PORTAL ");
        io:println("1. Browse Available Cars");
        io:println("2. Search Car by License Plate");
        io:println("3. Add Car to Cart");
        io:println("4. Place Reservation");
        io:println("5. Exit");
        
        string choice = io:readln("Select option: ").trim();
        
        match choice {
            "1" => { check browseAvailableCarsUI(customerHandler); }
            "2" => { check searchCarUI(customerHandler); }
            "3" => { check addToCartUI(customerHandler); }
            "4" => { check placeReservationUI(customerHandler); }
            "5" => { 
                io:println("Thank you for using Car Rental System!");
                break;
            }
            _ => { io:println("Invalid option. Please try again."); }
        }
    }
}

//CUSTOMER UI IMPLEMENTATIONS

function browseAvailableCarsUI(handlers:CustomerHandler customerHandler) returns error? {
    io:println("\n Browse Available Cars ");
    
    string filter = io:readln("Enter search filter (or press Enter for all): ").trim();
    
    handlers:CarDetails[]|error result = customerHandler.listAvailableCars(filter);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        if result.length() == 0 {
            io:println("No available cars found.");
        } else {
            io:println(string `Found ${result.length()} available car(s):`);
            foreach handlers:CarDetails car in result {
                printCarDetails(car);
            }
        }
    }
}

function searchCarUI(handlers:CustomerHandler customerHandler) returns error? {
    io:println("\n Search Car ");
    
    string plate = io:readln("Enter license plate: ").trim();
    
    handlers:CarDetails|error result = customerHandler.searchCar(plate);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        io:println("Car found:");
        printCarDetails(result);
    }
}

function addToCartUI(handlers:CustomerHandler customerHandler) returns error? {
    io:println("\n Add Car to Cart ");
    
    string userId = io:readln("Enter your user ID: ").trim();
    string carPlate = io:readln("Enter car license plate: ").trim();
    
    string daysStr = io:readln("Enter number of days to rent: ").trim();
    int days = check int:fromString(daysStr);
    
    handlers:CartOperationResult|error result = customerHandler.addToCart(userId, carPlate, days);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        if result.success {
            io:println( result.message);
        } else {
            io:println(result.message);
        }
    }
}

function placeReservationUI(handlers:CustomerHandler customerHandler) returns error? {
    io:println("\n Place Reservation ");
    
    string userId = io:readln("Enter your user ID: ").trim();
    
    handlers:ReservationResult|error result = customerHandler.placeReservation(userId);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        if result.success {
            io:println(result.message);
            if result.reservation is handlers:ReservationDetails {
                handlers:ReservationDetails reservation = <handlers:ReservationDetails>result.reservation;
                printReservationDetails(reservation);
            }
        } else {
            io:println(result.message);
        }
    }
}

// UTILITY FUNCTIONS

function printCarDetails(handlers:CarDetails car) {
    io:println(string `  [${car.plate}] ${car.make} ${car.model} (${car.year}) - $${car.daily_price}/day - ${car.mileage} miles - ${car.status}`);
}

function printReservationDetails(handlers:ReservationDetails reservation) {
    io:println(string `\n Reservation Details `);
    io:println(string `Reservation ID: ${reservation.id}`);
    io:println(string `User ID: ${reservation.user_id}`);
    io:println(string `Total Price: $${reservation.total_price}`);
    io:println("Items:");
    foreach handlers:CartItemDetails item in reservation.items {
        io:println(string `  - ${item.car_plate}: ${item.days_to_rent} days @ $${item.price}`);
    }
}