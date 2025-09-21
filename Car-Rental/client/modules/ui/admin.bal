
import ballerina/io;
import 'client.handlers as ah;

public function adminMain() returns error? {
    io:println("=== Car Rental Admin Client ===");
    io:println("Connecting to Car Rental Service...");
    

    ah:AdminHandler adminHandler = check new("http://localhost:9090");
    io:println("Connected to Car Rental Service");
    
    while (true) {
        // Display admin menu
        io:println("\n=== ADMIN OPERATIONS ===");
        io:println("1. Add Car");
        io:println("2. List All Cars");
        io:println("3. Update Car");
        io:println("4. Remove Car");
        io:println("5. Create Users");
        io:println("6. Exit");
      
        
        io:print("Select option (1-6): ");
        string input = io:readln();
        string choice= input.trim();
        
        if (choice == "1") {
            // Add Car
            io:println("\n--- Add New Car ---");
            io:print("Enter car plate: ");
            string plate = io:readln().trim();
            
            io:print("Enter make: ");
            string make = io:readln().trim();
            
            io:print("Enter model: ");
            string model = io:readln().trim();
            
            io:print("Enter year: ");
            string yearStr = io:readln().trim();
            int|error year = int:fromString(yearStr);
            if (year is error) {
                io:println(" Invalid year format");
                continue;
            }
            
            io:print("Enter daily price: ");
            string priceStr = io:readln().trim();
            float|error price = float:fromString(priceStr);
            if (price is error) {
                io:println(" Invalid price format");
                continue;
         }
            
            io:print("Enter mileage: ");
            string mileageStr = io:readln().trim();
            int|error mileage = int:fromString(mileageStr);
            if (mileage is error) {
                io:println(" Invalid mileage format");
                continue;
            }
            
            io:print("Enter status (AVAILABLE/UNAVAILABLE): ");
            string status = io:readln().trim();
            
            ah:CarInfo newCar = {
                plate: plate,
                make: make,
                model: model,
                year: year,
                daily_price: price,
                mileage: mileage,
                status: status
            };
            
            string|error result = adminHandler.addCar(newCar);
            if (result is error) {
                io:println(" Failed to add car: " + result.message());
            } else {
                io:println(" Car added successfully with plate: " + result);
            }
            
        } else if (choice == "2") {
            // List All Cars
            io:println("\n--- All Cars ---");
            io:print("Enter filter (or press Enter for all): ");
            string filter = io:readln().trim();
            
            ah:CarInfo[]|error cars = adminHandler.listAllCars(filter);
            if (cars is error) {
                io:println(" Failed to list cars: " + cars.message());
            } else {
                if (cars.length() == 0) {
                    io:println("No cars found");
                } else {
                    io:println("Found " + cars.length().toString() + " cars:");
                    foreach ah:CarInfo car in cars {
                        io:println("  " + car.plate + " | " + car.make + " " + car.model + 
                                 " | Year: " + car.year.toString() + 
                                 " | Price: $" + car.daily_price.toString() + 
                                 " | Status: " + car.status);
                    }
                }
            }
            
        } else if (choice == "3") {
            // Update Car
            io:println("\n--- Update Car ---");
            io:print("Enter car plate to update: ");
            string plateToUpdate = io:readln().trim();
            
            io:print("Enter new make: ");
            string newMake = io:readln().trim();
            
            io:print("Enter new model: ");
            string newModel = io:readln().trim();
            
            io:print("Enter new year: ");
            string newYearStr = io:readln().trim();
            int|error newYear = int:fromString(newYearStr);
            if (newYear is error) {
                io:println(" Invalid year format");
                continue;
            }
            
            io:print("Enter new daily price: ");
            string newPriceStr = io:readln().trim();
            float|error newPrice = float:fromString(newPriceStr);
            if (newPrice is error) {
                io:println(" Invalid price format");
                continue;
            }
            
            io:print("Enter new mileage: ");
            string newMileageStr = io:readln().trim();
            int|error newMileage = int:fromString(newMileageStr);
            if (newMileage is error) {
                io:println(" Invalid mileage format");
                continue;
            }
            
            io:print("Enter new status (AVAILABLE/UNAVAILABLE): ");
            string newStatus = io:readln().trim();

            if(newStatus !="AVAILABLE" && newStatus !="UNAVAILABLE") {
               io:println("Invalide input");
               io:println("Enter AVAILABLE or UNAVAILABLE in all caps");
              
              continue;
            }

            ah:CarInfo updatedCar = {
                plate: plateToUpdate,
                make: newMake,
                model: newModel,
                year: newYear,
                daily_price: newPrice,
                mileage: newMileage,
                status: newStatus
            };
            
            ah:CarInfo|error result = adminHandler.updateCar(plateToUpdate, updatedCar);
            if (result is error) {
                io:println("Failed to update car: " + result.message());
            } else {
                io:println(" Car updated successfully:");
                io:println("  " + result.plate + " | " + result.make + " " + result.model);
            }
            
        } else if (choice == "4") {
            // Remove Car
            io:println("\n--- Remove Car ---");
            io:print("Enter car plate to remove: ");
            string plateToRemove = io:readln().trim();
            
            io:print("Are you sure you want to remove " + plateToRemove + "? (yes/no): ");
            string confirm = io:readln().trim().toLowerAscii();
            
            if (confirm == "yes" || confirm == "y") {
                ah:CarInfo[]|error result = adminHandler.removeCar(plateToRemove);
                if (result is error) {
                    io:println(" Failed to remove car: " + result.message());
                } else {
                    io:println(" Car removed successfully");
                    io:println("Remaining cars: " + result.length().toString());
                }
            } else {
                io:println("Operation cancelled");
            }
            
        } else if (choice == "5") {
            // Create Users
            io:println("\n--- Create Users ---");
            io:print("How many users to create? ");
            string countStr = io:readln().trim();
            int|error userCount = int:fromString(countStr);
            if (userCount is error || userCount <= 0) {
                io:println(" Invalid user count");
                continue;
            }
            
            ah:UserInfo[] users = [];
            int i = 0;
            while (i < userCount) {
                io:println("User " + (i + 1).toString() + ":");
                io:print("  ID: ");
                string userId = io:readln().trim();
                
                io:print("  Name: ");
                string userName = io:readln().trim();
                
                io:print("  Role (ADMIN/CUSTOMER): ");
                string userRole = io:readln().trim();
                
                users.push({
                    id: userId,
                    name: userName,
                    role: userRole
                });
                i += 1;
            }
            
            int|error result = adminHandler.createUsers(users);
            if (result is error) {
                io:println(" Failed to create users: " + result.message());
            } else {
                io:println(" Created " + result.toString() + " users successfully");
            }
            
        } else if (choice == "6") {
            // Exit
            io:println(" Goodbye, Admin!");
            break;
            
        } else {
            io:println(" Invalid choice. Please select 1-6.");
        }
    }
}
