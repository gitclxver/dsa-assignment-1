import ballerina/io;
import ballerina/grpc;

// Import gRPC client ( come from the .proto file)
// Assuming the generated client is named CarRentalServiceClient

public function main() returns error? {
    // Connect to server
    CarRentalServiceClient client = check new("http://localhost:9090");
    
    io:println("Car Rental System - Customer Portal");
    io:println("===================================");
    
    string customerId = getCustomerInfo();
    
    while (true) {
        showMenu();
        string choice = io:readln().trim();
        
        if (choice == "1") {
            listCars(client);
        } else if (choice == "2") {
            searchCar(client);
        } else if (choice == "3") {
            addToCart(client, customerId);
        } else if (choice == "4") {
            makeReservation(client, customerId);
        } else if (choice == "5") {
            io:println("Thank you for using our service!");
            break;
        } else {
            io:println("Invalid option. Try again.");
        }
        
        io:println("");
        io:print("Press Enter to continue...");
        _ = io:readln();
    }
}

function getCustomerInfo() returns string {
    io:print("Enter your customer ID: ");
    return io:readln().trim();
}

function showMenu() {
    io:println("\n--- Main Menu ---");
    io:println("1. View available cars");
    io:println("2. Search for a car");
    io:println("3. Add car to cart");
    io:println("4. Make reservation");
    io:println("5. Exit");
    io:print("Choose option: ");
}

function listCars(CarRentalServiceClient client) {
    io:println("\n--- Available Cars ---");
    
    io:print("Filter by make/model (or press Enter for all): ");
    string filter = io:readln().trim();
    
    // Call the gRPC service
    // This connects to the service layer your teammates are building
    ListAvailableCarsRequest request = {filter: filter};
    
    io:println("Fetching cars...");
    
    // Display format
    io:println("Plate     Make      Model     Year  Price/Day  Mileage");
    io:println("------------------------------------------------------");
    
    // This is where the actual gRPC streaming call would happen
    // stream<Car, grpc:Error?> carStream = check client->ListAvailableCars(request);
    // 
    // check carStream.forEach(function(Car car) {
    //     io:println(string `${car.plate}  ${car.make}  ${car.model}  ${car.year}  $${car.daily_price}  ${car.mileage}`);
    // });
    
    // For now, showing the structure that  may be implemented
    io:println("Calling: list_available_cars service");
    io:println("Filter: " + filter);
}

function searchCar(CarRentalServiceClient client) {
    io:println("\n--- Search Car ---");
    
    io:print("Enter car plate number: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate number required!");
        return;
    }
    
    // Call gRPC service
    SearchCarRequest request = {plate: plate};
    
    io:println("Searching for car: " + plate);
    
    // This connects to your search_car service
    // SearchCarResponse response = check client->SearchCar(request);
    // 
    // if (response.found) {
    //     if (response.available) {
    //         Car car = response.car;
    //         io:println("Car found:");
    //         io:println("Make: " + car.make);
    //         io:println("Model: " + car.model);
    //         io:println("Year: " + car.year.toString());
    //         io:println("Price: $" + car.daily_price.toString());
    //         io:println("Status: " + car.status);
    //     } else {
    //         io:println("Car exists but not available");
    //     }
    // } else {
    //     io:println("Car not found");
    // }
    
    io:println("Calling: search_car service");
    io:println("Plate: " + plate);
}

function addToCart(CarRentalServiceClient client, string customerId) {
    io:println("\n--- Add to Cart ---");
    
    io:print("Car plate: ");
    string plate = io:readln().trim();
    
    io:print("Start date (YYYY-MM-DD): ");
    string startDate = io:readln().trim();
    
    io:print("End date (YYYY-MM-DD): ");
    string endDate = io:readln().trim();
    
   
    if (plate == "" || startDate == "" || endDate == "") {
        io:println("All fields required!");
        return;
    }
   
    AddToCartRequest request = {
        customer_id: customerId,
        car_plate: plate,
        start_date: startDate,
        end_date: endDate
    };
    
    // This connects to add_to_cart service
    // AddToCartResponse response = check client->AddToCart(request);
    // 
    // if (response.success) {
    //     io:println("Added to cart successfully!");
    // } else {
    //     io:println("Failed: " + response.message);
    // }
    
    io:println("Calling: add_to_cart service");
    io:println("Customer: " + customerId);
    io:println("Car: " + plate);
    io:println("Dates: " + startDate + " to " + endDate);
}

function makeReservation(CarRentalServiceClient client, string customerId) {
    io:println("\n--- Make Reservation ---");
    io:println("Processing cart items for customer: " + customerId);
    
    // Call gRPC service
    PlaceReservationRequest request = {customer_id: customerId};
    
    // This connects to  place_reservation service
    // PlaceReservationResponse response = check client->PlaceReservation(request);
    // 
    // if (response.success) {
    //     io:println("Reservation successful!");
    //     io:println("Total cost: $" + response.total_cost.toString());
    //     
    //     foreach Reservation reservation in response.reservations {
    //         io:println("Reservation ID: " + reservation.reservation_id);
    //         io:println("Car: " + reservation.car_plate);
    //         io:println("Dates: " + reservation.start_date + " to " + reservation.end_date);
    //         io:println("Cost: $" + reservation.total_price.toString());
    //         io:println("---");
    //     }
    // } else {
    //     io:println("Reservation failed: " + response.message);
    // }
    
    io:println("Calling: place_reservation service");
    io:println("Customer: " + customerId);
}