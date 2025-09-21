import ballerina/io;
import ballerina/grpc;
import 'client.client_stub;


public function customerMain() returns error? {

     client_stub:CarRentalServiceClient ep = check new("http://localhost:9090");

    io:println("Car Rental System - Customer");
    io:println("=============================");
    
    // Get customer ID
    io:print("Enter your customer ID: ");
    string customerId = io:readln().trim();
    
    while (true) {
        showCustomerMenu();
        string choice = io:readln().trim();
        
        if (choice == "1") {
            check listAvailableCars(ep);
        } else if (choice == "2") {
            check searchCar(ep);
        } else if (choice == "3") {
            check addToCart(ep, customerId);
        } else if (choice == "4") {
            check placeReservation(ep, customerId);
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

function listAvailableCars(client_stub:CarRentalServiceClient ep) returns error? {
    io:println("\n--- Available Cars ---");
    
    io:print("Filter (make/model/year, or press Enter for all): ");
    string filter = io:readln().trim();
    
    // Create request using generated types
    client_stub:ListAvailableCarsRequest request = {filter: filter};
    
    io:println("Getting available cars...\n");
    
    // Call the generated gRPC method
    stream<client_stub:Car, grpc:Error?> carStream = check ep->list_available_cars(request);
    
    io:println("PLATE      MAKE         MODEL        YEAR   PRICE/DAY   MILEAGE    STATUS");
    io:println("------------------------------------------------------------------------");
    
    check carStream.forEach(function(client_stub:Car car) {
        string status = car.status == client_stub:AVAILABLE ? "AVAILABLE" : "UNAVAILABLE";
        io:println(string `${car.plate} ${car.make} ${car.model} ${car.year} $${car.daily_price} ${car.mileage} ${status}`);
    });
}


function searchCar(client_stub:CarRentalServiceClient ep) returns error? {
    io:println("\n--- Search Car ---");
    
    io:print("Enter car plate: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate number required!");
        return;
    }
    
    // Create request using generated types
    client_stub:SearchCarRequest request = {plate: plate};
    
    // Call the generated gRPC method
    client_stub:Car|grpc:Error response = ep->search_car(request);
    
    if (response is client_stub:Car){
        io:println("\nCar found:");
        io:println("Plate: " + response.plate);
        io:println("Make: " + response.make);
        io:println("Model: " + response.model);
        io:println("Year: " + response.year.toString());
        io:println("Daily Price: $" + response.daily_price.toString());
        io:println("Mileage: " + response.mileage.toString());
        
        string status = response.status == client_stub:AVAILABLE ? "AVAILABLE" : "UNAVAILABLE";
        io:println("Status: " + status);
        
        if (response.status != client_stub:AVAILABLE) {
            io:println("Note: This car is currently not available for rental.");
        }
    } else {
        io:println("Car not found or error occurred.");
    }
}
function addToCart(client_stub:CarRentalServiceClient ep, string customerId) returns error? {
    io:println("\n--- Add to Cart ---");
    
    io:print("Car plate: ");
    string plate = io:readln().trim();
    
    io:print("Enter number of days to rent: ");
    string daysStr = io:readln().trim();
    int|error daysParsed = int:fromString(daysStr);

    if (daysParsed is error || daysParsed <= 0) {
        io:println(" Invalid number of days");
        return;
    }
    int days = daysParsed;

    if (plate == "") {
        io:println(" Car plate is required!");
        return;
    }

    // Create request
    client_stub:AddToCartRequest request = {
        user_id: customerId,
        car_plate: plate,
        days_to_rent: days
    };

    // Call the generated gRPC method
    client_stub:CartResponse|grpc:Error response = ep->add_to_cart(request);
    
    if (response is client_stub:CartResponse) {
        if (response.success) {
            io:println("Response successful: " + response.message);
        } else {
            io:println("Response unsuccessful:" + response.message);
        }
    } else {
        io:println("Error adding to cart.");
    }
}


function placeReservation(client_stub:CarRentalServiceClient ep, string customerId) returns error? {
    io:println("\n--- Place Reservation ---");
    io:println("Processing your cart...");
    
    // Create request using generated types
    client_stub:PlaceReservationRequest request = {user_id: customerId};
    
    // Call the generated gRPC method
    client_stub:ReservationResponse|grpc:Error response = ep->place_reservation(request);
    
    if (response is client_stub:ReservationResponse) {
        if (response.success) {
            io:println("Response successful: "+ response.message);
            
            // Display reservation details using generated types
            client_stub:Reservation reservation = response.reservation;
            io:println("\n--- Reservation Details ---");
            io:println("Reservation ID: " + reservation.id);
            io:println("Customer ID: " + reservation.user_id);
            io:println("Total Price: $" + reservation.total_price.toString());
            
            io:println("\nItems:");
            foreach client_stub:CartItem item in reservation.items {
                io:println("- Car: " + item.car_plate);
                io:println("  Number of days to rent: " + item.days_to_rent.toString());
                io:println("  Price: $" + item.price.toString());
                io:println("");
            }
        } else {
            io:println("Response unsuccessful: " + response.message);
        }
    } else {
        io:println("Error placing reservation.");
    }
}