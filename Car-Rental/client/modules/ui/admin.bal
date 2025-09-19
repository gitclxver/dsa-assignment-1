
import ballerina/io;
import ballerina/grpc;


public function main() returns error? {
  
    CarRentalServiceClient client = check new("http://localhost:9090");
    
    io:println("Car Rental System - Admin Portal");
    io:println("=================================");
    
    string adminId = getAdminInfo();
    
    while (true) {
        showAdminMenu();
        string choice = io:readln().trim();
        
        if (choice == "1") {
            addCar(client);
        } else if (choice == "2") {
            createUsers(client);
        } else if (choice == "3") {
            updateCar(client);
        } else if (choice == "4") {
            removeCar(client);
        } else if (choice == "5") {
            listReservations(client, adminId);
        } else if (choice == "6") {
            io:println("Admin session ended.");
            break;
        } else {
            io:println("Invalid option. Try again.");
        }
        
        io:println("");
        io:print("Press Enter to continue...");
        _ = io:readln();
    }
}

function getAdminInfo() returns string {
    io:print("Enter admin ID: ");
    return io:readln().trim();
}

function showAdminMenu() {
    io:println("\n--- Admin Menu ---");
    io:println("1. Add car");
    io:println("2. Create users");
    io:println("3. Update car");
    io:println("4. Remove car");
    io:println("5. List reservations");
    io:println("6. Exit");
    io:print("Choose option: ");
}

function addCar(CarRentalServiceClient client) {
    io:println("\n--- Add New Car ---");
    
    io:print("Plate number: ");
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
    
    // Basic validation
    if (plate == "" || make == "" || model == "" || yearStr == "" || priceStr == "" || mileageStr == "") {
        io:println("All fields required!");
        return;
    }
    
    // Convert strings to numbers
    int|error year = int:fromString(yearStr);
    float|error price = float:fromString(priceStr);
    int|error mileage = int:fromString(mileageStr);
    
    if (year is error || price is error || mileage is error) {
        io:println("Invalid number format!");
        return;
    }
    
    // Create car object
    Car newCar = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: price,
        mileage: mileage,
        status: "AVAILABLE"
    };
    
    // Call gRPC service
    AddCarRequest request = {car: newCar};
    
    // connects to add_car service
    // AddCarResponse response = check client->AddCar(request);
    // 
    // if (response.success) {
    //     io:println("Car added successfully!");
    //     io:println("Car plate: " + response.plate);
    // } else {
    //     io:println("Failed to add car: " + response.message);
    // }
    
    io:println("Calling: add_car service");
    io:println("Adding car: " + make + " " + model + " (" + plate + ")");
}

function createUsers(CarRentalServiceClient client) {
    io:println("\n--- Create Users ---");
    
    io:print("How many users to create? ");
    string countStr = io:readln().trim();
    
    int|error userCount = int:fromString(countStr);
    if (userCount is error || userCount <= 0) {
        io:println("Invalid number!");
        return;
    }
    
    User[] users = [];
    
    int i = 1;
    while (i <= userCount) {
        io:println(string `\nUser ${i}:`);
        
        io:print("User ID: ");
        string userId = io:readln().trim();
        
        io:print("Name: ");
        string name = io:readln().trim();
        
        io:print("Role (CUSTOMER/ADMIN): ");
        string role = io:readln().trim().toUpperAscii();
        
        if (role != "CUSTOMER" && role != "ADMIN") {
            io:println("Invalid role! Use CUSTOMER or ADMIN.");
            continue;
        }
        
        if (userId == "" || name == "") {
            io:println("User ID and name required!");
            continue;
        }
        
        User user = {
            user_id: userId,
            name: name,
            role: role
        };
        
        users.push(user);
        i += 1;
    }
    
    // Call gRPC service
    CreateUsersRequest request = {users: users};
    
    // This connects to create_users service
    // CreateUsersResponse response = check client->CreateUsers(request);
    // 
    // if (response.success) {
    //     io:println("All users created successfully!");
    // } else {
    //     io:println("Failed to create users: " + response.message);
    // }
    
    io:println("Calling: create_users service");
    io:println(string `Creating ${userCount} users`);
}

function updateCar(CarRentalServiceClient client) {
    io:println("\n--- Update Car ---");
    
    io:print("Enter plate number of car to update: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate number required!");
        return;
    }
    
    io:println("What to update?");
    io:println("1. Daily price");
    io:println("2. Status");
    io:println("3. Mileage");
    io:print("Choose: ");
    
    string updateChoice = io:readln().trim();
    
    if (updateChoice == "1") {
        io:print("New daily price: ");
        string priceStr = io:readln().trim();
        float|error newPrice = float:fromString(priceStr);
        
        if (newPrice is error) {
            io:println("Invalid price!");
            return;
        }
        
        io:println("Updating price for " + plate + " to $" + newPrice.toString());
        
    } else if (updateChoice == "2") {
        io:print("New status (AVAILABLE/UNAVAILABLE): ");
        string newStatus = io:readln().trim().toUpperAscii();
        
        if (newStatus != "AVAILABLE" && newStatus != "UNAVAILABLE") {
            io:println("Invalid status!");
            return;
        }
        
        io:println("Updating status for " + plate + " to " + newStatus);
        
    } else if (updateChoice == "3") {
        io:print("New mileage: ");
        string mileageStr = io:readln().trim();
        int|error newMileage = int:fromString(mileageStr);
        
        if (newMileage is error) {
            io:println("Invalid mileage!");
            return;
        }
        
        io:println("Updating mileage for " + plate + " to " + newMileage.toString());
        
    } else {
        io:println("Invalid choice!");
        return;
    }
    
    // Call gRPC service
    // This connects to  update_car service
    // UpdateCarRequest request = {plate: plate, updated_car: updatedCar};
    // UpdateCarResponse response = check client->UpdateCar(request);
    // 
    // if (response.success) {
    //     io:println("Car updated successfully!");
    // } else {
    //     io:println("Update failed: " + response.message);
    // }
    
    io:println("Calling: update_car service");
}

function removeCar(CarRentalServiceClient client) {
    io:println("\n--- Remove Car ---");
    
    io:print("Enter plate number to remove: ");
    string plate = io:readln().trim();
    
    if (plate == "") {
        io:println("Plate number required!");
        return;
    }
    
    io:print("Are you sure you want to remove " + plate + "? (yes/no): ");
    string confirm = io:readln().trim().toLowerAscii();
    
    if (confirm != "yes" && confirm != "y") {
        io:println("Removal cancelled.");
        return;
    }
    
    // Call gRPC service
    RemoveCarRequest request = {plate: plate};
    
    // This connects to remove_car service
    // RemoveCarResponse response = check client->RemoveCar(request);
    // 
    // io:println("Car removed. Remaining inventory:");
    // foreach Car car in response.remaining_cars {
    //     io:println(car.plate + " - " + car.make + " " + car.model);
    // }
    
    io:println("Calling: remove_car service");
    io:println("Removing car: " + plate);
}

function listReservations(CarRentalServiceClient client, string adminId) {
    io:println("\n--- All Reservations ---");
    
    // Call gRPC service
    ListReservationsRequest request = {admin_id: adminId};
    
    // This connects to list_reservations service
    // ListReservationsResponse response = check client->ListReservations(request);
    // 
    // io:println("Reservation ID  Customer    Car       Start Date  End Date    Price     Status");
    // io:println("--------------------------------------------------------------------------");
    // 
    // foreach Reservation res in response.reservations {
    //     io:println(string `${res.reservation_id}  ${res.customer_id}  ${res.car_plate}  ${res.start_date}  ${res.end_date}  $${res.total_price}  ${res.status}`);
    // }
    
    io:println("Calling: list_reservations service");
    io:println("Admin: " + adminId);
}