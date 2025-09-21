import ballerina/io;
import 'client.handlers as handlers;

const string SERVER_URL = "http://localhost:9090";

// Admin UI Main Function
public function adminMain() returns error? {
    handlers:AdminHandler adminHandler = check new (SERVER_URL);
    
    while true {
        io:println("\n ADMIN PANEL ");
        io:println("1. Add Car");
        io:println("2. Create Users");
        io:println("3. Update Car");
        io:println("4. Remove Car");
        io:println("5. List All Cars");
        io:println("6. Exit");
        
        string choice = io:readln("Select option: ").trim();
        
        match choice {
            "1" => { check addCarUI(adminHandler); }
            "2" => { check createUsersUI(adminHandler); }
            "3" => { check updateCarUI(adminHandler); }
            "4" => { check removeCarUI(adminHandler); }
            "5" => { check listCarsUI(adminHandler); }
            "6" => { 
                io:println("Exiting admin panel...");
                break;
            }
            _ => { io:println("Invalid option. Please try again."); }
        }
    }
}

//ADMIN UI IMPLEMENTATIONS

function addCarUI(handlers:AdminHandler adminHandler) returns error? {
    io:println("\n Add New Car ");
    
    string plate = io:readln("Enter license plate: ").trim();
    string make = io:readln("Enter car make: ").trim();
    string model = io:readln("Enter car model: ").trim();
    
    string yearStr = io:readln("Enter year: ").trim();
    int year = check int:fromString(yearStr);
    
    string priceStr = io:readln("Enter daily price: ").trim();
    float dailyPrice = check float:fromString(priceStr);
    
    string mileageStr = io:readln("Enter mileage: ").trim();
    int mileage = check int:fromString(mileageStr);
    
    io:println("Car Status: 1. AVAILABLE  2. UNAVAILABLE");
    string statusChoice = io:readln("Select status (1 or 2): ").trim();
    string status = statusChoice == "1" ? "AVAILABLE" : "UNAVAILABLE";
    
    handlers:CarInfo carInfo = {
        plate: plate,
        make: make,
        model: model,
        year: year,
        daily_price: dailyPrice,
        mileage: mileage,
        status: status
    };
    
    string|error result = adminHandler.addCar(carInfo);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        io:println("Car added successfully! License plate: " + result);
    }
}

function createUsersUI(handlers:AdminHandler adminHandler) returns error? {
    io:println("\n Create Users ");
    
    string countStr = io:readln("How many users to create? ").trim();
    int userCount = check int:fromString(countStr);
    
    handlers:UserInfo[] users = [];
    
    foreach int i in 0..<userCount {
        io:println(string `\n User ${i + 1} --`);
        string id = io:readln("Enter user ID: ").trim();
        string name = io:readln("Enter user name: ").trim();
        
        io:println("User Role: 1. CUSTOMER  2. ADMIN");
        string roleChoice = io:readln("Select role (1 or 2): ").trim();
        string role = roleChoice == "2" ? "ADMIN" : "CUSTOMER";
        
        users.push({
            id: id,
            name: name,
            role: role
        });
    }
    
    int|error result = adminHandler.createUsers(users);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        io:println(string ` ${result} users created successfully!`);
    }
}

function updateCarUI(handlers:AdminHandler adminHandler) returns error? {
    io:println("\n Update Car ");
    
    string plate = io:readln("Enter license plate to update: ").trim();
    
    io:println("Enter new car details:");
    string newPlate = io:readln("New license plate: ").trim();
    string make = io:readln("New make: ").trim();
    string model = io:readln("New model: ").trim();
    
    string yearStr = io:readln("New year: ").trim();
    int year = check int:fromString(yearStr);
    
    string priceStr = io:readln("New daily price: ").trim();
    float dailyPrice = check float:fromString(priceStr);
    
    string mileageStr = io:readln("New mileage: ").trim();
    int mileage = check int:fromString(mileageStr);
    
    io:println("Car Status: 1. AVAILABLE  2. UNAVAILABLE");
    string statusChoice = io:readln("Select status (1 or 2): ").trim();
    string status = statusChoice == "1" ? "AVAILABLE" : "UNAVAILABLE";
    
    handlers:CarInfo carInfo = {
        plate: newPlate,
        make: make,
        model: model,
        year: year,
        daily_price: dailyPrice,
        mileage: mileage,
        status: status
    };
    
    handlers:CarInfo|error result = adminHandler.updateCar(plate, carInfo);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        io:println(" Car updated successfully!");
        printCarInfo(result);
    }
}

function removeCarUI(handlers:AdminHandler adminHandler) returns error? {
    io:println("\n Remove Car ");
    
    string plate = io:readln("Enter license plate to remove: ").trim();
    
    string confirm = io:readln(string `Are you sure you want to remove car ${plate}? (y/N): `).trim();
    if confirm.toLowerAscii() != "y" {
        io:println("Operation cancelled.");
        return;
    }
    
    handlers:CarInfo[]|error result = adminHandler.removeCar(plate);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        io:println("Car removed successfully!");
        io:println(string `Remaining cars in system: ${result.length()}`);
        foreach handlers:CarInfo car in result {
            printCarInfo(car);
        }
    }
}

function listCarsUI(handlers:AdminHandler adminHandler) returns error? {
    io:println("\n List All Cars ");
    
    string filter = io:readln("Enter filter (or press Enter for all): ").trim();
    
    handlers:CarInfo[]|error result = adminHandler.listAllCars(filter);
    if result is error {
        io:println("Error: " + result.message());
    } else {
        if result.length() == 0 {
            io:println("No cars found.");
        } else {
            io:println(string `Found ${result.length()} car(s):`);
            foreach handlers:CarInfo car in result {
                printCarInfo(car);
            }
        }
    }
}

//UTILITY FUNCTIONS

function printCarInfo(handlers:CarInfo car) {
    io:println(string `  [${car.plate}] ${car.make} ${car.model} (${car.year}) - $${car.daily_price}/day - ${car.mileage} miles - ${car.status}`);
}