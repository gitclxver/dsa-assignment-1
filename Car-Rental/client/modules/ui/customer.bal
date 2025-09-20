import ballerina/io;
import ballerina/grpc;


import car_rental_pb;              

public function main() returns error? {

    carentalservice_client:CarRentalServiceClient client = check new("http://localhost:9090");
    
    io:println("Car Rental System - Customer");
    io:println("=============================");
    
    // Get customer ID
    io:print("Enter your customer ID: ");
    string customerId = io:readln().trim();
    
    while (true) {
        showCustomerMenu();
        string choice = io:readln().trim();
        
        if (choice == "1") {
            check listAvailableCars(client);
        } else if (choice == "2") {
            check searchCar(client);
        } else if (choice == "3") {
            check addToCart(client, customerId);
        } else if (choice == "4") {
            check placeReservation(client, customerId);
        } else if (choice == "5") {
            io:println("Thank you!");
            break;
        } else {
            io:println("Invalid choice. Try again.");
        }
        
        io:println("");
        io:print("Press Enter to continue...");
        _ = io:readln();
    }
}

function showCustomerMenu() {
    io:println("\n--- Customer Menu ---");
    io:println("1. List available cars");
    io:println("2. Search car by plate");
    io:println("3. Add car to cart");
    io:println("4. Place reservation");
    io:println("5. Exit");
    io:print("Choose option: ");
}

function listAvailableCars(carentalservice_client:CarRentalServiceClient client) returns error? {
    io:println("\n--- Available Cars ---");
    
    io:print("Filter (make/model/year, or press Enter for all): ");
    string filter = io:readln().trim();
    
    // Create request using generated types
    car_rental_pb:ListAvailableCarsRequest request = {filter: filter};
    
    io:println("Getting available cars...\n");
    
    // Call the generated gRPC method
    stream<car_rental_pb:Car, grpc:Error?> carStream = check client->list_available_cars(request);
    
    io:println("PLATE      MAKE         MODEL        YEAR   PRICE/DAY   MILEAGE    STATUS");
    io:println("------------------------------------------------------------------------");
    
    check carStream.forEach(function(car_rental_pb:Car car) {
        string status = car.status == car_rental_pb:AVAILABLE ? "AVAILABLE" : "UNAVAILABLE";
        io:println(string `${car.plate:<10} ${car.make:<12} ${car.model:<12} ${car.year:<6} $${car.daily_price:<8.2f} ${car.mileage:<10} ${status}`);
    });
}

function searchCar(carentalservice_client:CarRentalServiceClient client) returns error? {
    io:println("\n--- Search Car ---");
    
    io:print("Enter car plate: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate number required!");
        return;
    }
    
    // Create request using generated types
    car_rental_pb:SearchCarRequest request = {plate: plate};
    
    // Call the generated gRPC method
    car_rental_pb:Car|grpc:Error response = client->search_car(request);
    
    if (response is car_rental_pb:Car) {
        io:println("\nCar found:");
        io:println("Plate: " + response.plate);
        io:println("Make: " + response.make);
        io:println("Model: " + response.model);
        io:println("Year: " + response.year.toString());
        io:println("Daily Price: $" + response.daily_price.toString());
        io:println("Mileage: " + response.mileage.toString());
        
        string status = response.status == car_rental_pb:AVAILABLE ? "AVAILABLE" : "UNAVAILABLE";
        io:println("Status: " + status);
        
        if (response.status != car_rental_pb:AVAILABLE) {
            io:println("Note: This car is currently not available for rental.");
        }
    } else {
        io:println("Car not found or error occurred.");
    }
}

function addToCart(carentalservice_client:CarRentalServiceClient client, string customerId) returns error? {
    io:println("\n--- Add to Cart ---");
    
    io:print("Car plate: ");
    string plate = io:readln().trim();
    
    io:print("Start date (YYYY-MM-DD): ");
    string startDate = io:readln().trim();
    
    io:print("End date (YYYY-MM-DD): ");
    string endDate = io:readln().trim();
    
    if (plate == "" || startDate == "" || endDate == "") {
        io:println("All fields are required!");
        return;
    }
    
    // Create request using generated types (note: uses user_id not customer_id)
    car_rental_pb:AddToCartRequest request = {
        user_id: customerId,
        car_plate: plate,
        start_date: startDate,
        end_date: endDate
    };
    
    // Call the generated gRPC method
    car_rental_pb:CartResponse|grpc:Error response = client->add_to_cart(request);
    
    if (response is car_rental_pb:CartResponse) {
        if (response.success) {
            io:println("✓ " + response.message);
        } else {
            io:println("✗ " + response.message);
        }
    } else {
        io:println("Error adding to cart.");
    }
}

function placeReservation(carentalservice_client:CarRentalServiceClient client, string customerId) returns error? {
    io:println("\n--- Place Reservation ---");
    io:println("Processing your cart...");
    
    // Create request using generated types
    car_rental_pb:PlaceReservationRequest request = {user_id: customerId};
    
    // Call the generated gRPC method
    car_rental_pb:ReservationResponse|grpc:Error response = client->place_reservation(request);
    
    if (response is car_rental_pb:ReservationResponse) {
        if (response.success) {
            io:println("✓ " + response.message);
            
            // Display reservation details using generated types
            car_rental_pb:Reservation reservation = response.reservation;
            io:println("\n--- Reservation Details ---");
            io:println("Reservation ID: " + reservation.id);
            io:println("Customer ID: " + reservation.user_id);
            io:println("Total Price: $" + reservation.total_price.toString());
            
            io:println("\nItems:");
            foreach car_rental_pb:CartItem item in reservation.items {
                io:println("- Car: " + item.car_plate);
                io:println("  Dates: " + item.start_date + " to " + item.end_date);
                io:println("  Price: $" + item.price.toString());
                io:println("");
            }
        } else {
            io:println("✗ " + response.message);
        }
    } else {
        io:println("Error placing reservation.");
    }
}