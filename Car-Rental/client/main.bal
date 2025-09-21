import ballerina/io;
import 'client.ui;


public function main() returns error? {
    io:println(" Car Rental System ");
    io:println("1. Admin");
    io:println("2. Customer");
    
    string choice = io:readln("Enter choice (1 or 2): ").trim();

    if choice == "1" {
        io:println("Launching Admin UI...");
        check ui:adminMain();  // Calls the admin UI main function
    } else if choice == "2" {
        io:println("Launching Customer UI...");
        check ui:customerMain();  // Calls the customer UI main function
    } else {
        io:println("Invalid choice. Exiting.");
    }
}
