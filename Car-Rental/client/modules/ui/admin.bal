import ballerina/io;
import ballerina/grpc;

// Import the actual generated files
import 'client.client_stub;           
import 'client.handlers;

public function main() returns error? {
   
    carentalservice_client:CarRentalServiceClient client = check new("http://localhost:9090");
    
    io:println("Car Rental System - Admin");
    io:println("=========================");
    
    // Get admin ID
    io:print("Enter your admin ID: ");
    string adminId = io:readln().trim();
    
    while (true) {
        showAdminMenu();
        string choice = io:readln().trim();
        
        if (choice == "1") {
            check addCar(client);
        } else if (choice == "2") {
            check createUsers(client);
        } else if (choice == "3") {
            check updateCar(client);
        } else if (choice == "4") {
            check removeCar(client);
        } else if (choice == "5") {
            io:println("Goodbye!");
            break;
        } else {
            io:println("Invalid choice. Try again.");
        }
        
        io:println("");
        io:print("Press Enter to continue...");
        _ = io:readln();
    }
}

function showAdminMenu() {
    io:println("\n--- Admin Menu ---");
    io:println("1. Add car");
    io:println("2. Create users");
    io:println("3. Update car");
    io:println("4. Remove car");
    io:println("5. Exit");
    io:print("Choose option: ");
}

function addCar(carentalservice_client:CarRentalServiceClient client) returns error? {
    io:println("\n--- Add New Car ---");
    
    io:print("Plate: ");
    string plate = io:readln().trim();
    
    io:print("Make: ");
    string make = io:readln().trim();
    
    io:print("Model: ");
    string model = io:readln().trim();
    
    io:print("Year: ");
    string yearStr = io:readln().trim();
    
    io:print("Daily price: ");
    string priceStr = io:readln().trim();
    
    io:print("Mileage: ");
    string mileageStr = io:readln().trim();
    
    // Validation
    if (plate == "" || make == "" || model == "" || yearStr == "" || priceStr == "" || mileageStr == "") {
        io:println("All fields required!");
        return;
    }
    
    int|error year = int:fromString(yearStr);
    float|error price = float:fromString(priceStr);
    int|error mileage = int:fromString(mileageStr);
    
    if (year is error || price is error || mileage is error) {
        io:println("Invalid number format!");
        return;
    }
    
    // Create Car object using generated types
    car_rental_pb:Car newCar = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: price,
        mileage: mileage,
        status: car_rental_pb:AVAILABLE  // Using generated enum
    };
    
    // Create request using generated types
    car_rental_pb:AddCarRequest request = {car: newCar};
    
    // Call the generated gRPC method
    car_rental_pb:AddCarResponse|grpc:Error response = client->add_car(request);
    
    if (response is car_rental_pb:AddCarResponse) {
        io:println("✓ Car added successfully!");
        io:println("Car plate: " + response.plate);
    } else {
        io:println("✗ Failed to add car.");
    }
}

function createUsers(carentalservice_client:CarRentalServiceClient client) returns error? {
    io:println("\n--- Create Users ---");
    
    io:print("How many users? ");
    string countStr = io:readln().trim();
    
    int|error userCount = int:fromString(countStr);
    if (userCount is error || userCount <= 0) {
        io:println("Invalid number!");
        return;
    }
    
    car_rental_pb:User[] users = [];
    
    int i = 1;
    while (i <= userCount) {
        io:println(string `\nUser ${i}:`);
        
        io:print("User ID: ");
        string userId = io:readln().trim();
        
        io:print("Name: ");
        string name = io:readln().trim();
        
        io:print("Role (1=CUSTOMER, 2=ADMIN): ");
        string roleStr = io:readln().trim();
        
        if (userId == "" || name == "") {
            io:println("User ID and name required!");
            continue;
        }
        
        // Convert role to generated enum (proto uses 0=CUSTOMER, 1=ADMIN)
        car_rental_pb:UserRole role;
        if (roleStr == "1") {
            role = car_rental_pb:CUSTOMER;
        } else if (roleStr == "2") {
            role = car_rental_pb:ADMIN;
        } else {
            io:println("Invalid role! Use 1 for CUSTOMER or 2 for ADMIN.");
            continue;
        }
        
        // Create user using generated types
        car_rental_pb:User user = {
            id: userId,  
            name: name,
            role: role
        };
        
        users.push(user);
        i += 1;
    }
    
    // Create request using generated types
    car_rental_pb:CreateUsersRequest request = {users: users};
    
    // Call the generated gRPC method
    car_rental_pb:CreateUsersResponse|grpc:Error response = client->create_users(request);
    
    if (response is car_rental_pb:CreateUsersResponse) {
        io:println(string `✓ Successfully created ${response.count} users!`);
    } else {
        io:println("✗ Failed to create users.");
    }
}

function updateCar(carentalservice_client:CarRentalServiceClient client) returns error? {
    io:println("\n--- Update Car ---");
    
    io:print("Enter plate of car to update: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate required!");
        return;
    }
    
    io:println("\nEnter new car details:");
    
    io:print("Make: ");
    string make = io:readln().trim();
    
    io:print("Model: ");
    string model = io:readln().trim();
    
    io:print("Year: ");
    string yearStr = io:readln().trim();
    
    io:print("Daily price: ");
    string priceStr = io:readln().trim();
    
    io:print("Mileage: ");
    string mileageStr = io:readln().trim();
    
    io:print("Status (1=AVAILABLE, 2=UNAVAILABLE): ");
    string statusStr = io:readln().trim();
    
    // Validation
    if (make == "" || model == "" || yearStr == "" || priceStr == "" || mileageStr == "" || statusStr == "") {
        io:println("All fields required!");
        return;
    }
    
    int|error year = int:fromString(yearStr);
    float|error price = float:fromString(priceStr);
    int|error mileage = int:fromString(mileageStr);
    
    if (year is error || price is error || mileage is error) {
        io:println("Invalid number format!");
        return;
    }
    
    // Convert status to generated enum
    car_rental_pb:CarStatus status;
    if (statusStr == "1") {
        status = car_rental_pb:AVAILABLE;
    } else if (statusStr == "2") {
        status = car_rental_pb:UNAVAILABLE;
    } else {
        io:println("Invalid status! Use 1 for AVAILABLE or 2 for UNAVAILABLE.");
        return;
    }
    
    // Create updated car using generated types
    car_rental_pb:Car updatedCar = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: price,
        mileage: mileage,
        status: status
    };
    
    // Create request using generated types
    car_rental_pb:UpdateCarRequest request = {
        plate: plate,
        car: updatedCar
    };
    
    // Call the generated gRPC method
    car_rental_pb:Car|grpc:Error response = client->update_car(request);
    
    if (response is car_rental_pb:Car) {
        io:println("✓ Car updated successfully!");
        io:println("Updated car: " + response.make + " " + response.model + " (" + response.plate + ")");
    } else {
        io:println("✗ Failed to update car.");
    }
}

function removeCar(carentalservice_client:CarRentalServiceClient client) returns error? {
    io:println("\n--- Remove Car ---");
    
    io:print("Enter plate to remove: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate required!");
        return;
    }
    
    io:print("Are you sure? (yes/no): ");
    string confirm = io:readln().trim().toLowerAscii();
    
    if (confirm != "yes" && confirm != "y") {
        io:println("Removal cancelled.");
        return;
    }
    
    // Create request using generated types
    car_rental_pb:RemoveCarRequest request = {plate: plate};
    
    // Call the generated gRPC method
    car_rental_pb:CarList|grpc:Error response = client->remove_car(request);
    
    if (response is car_rental_pb:CarList) {
        io:println("✓ Car removed successfully!");
        io:println(string `\nRemaining cars (${response.cars.length()}):`);
        io:println("PLATE      MAKE         MODEL        STATUS");
        io:println("------------------------------------------");
        
        foreach car_rental_pb:Car car in response.cars {
            string status = car.status == car_rental_pb:AVAILABLE ? "AVAILABLE" : "UNAVAILABLE";
            io:println(string `${car.plate:<10} ${car.make:<12} ${car.model:<12} ${status}`);
        }
    } else {
        io:println("✗ Failed to remove car.");
    }
}