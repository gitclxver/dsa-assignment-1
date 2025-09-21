import ballerina/io;
import 'client.ui;

public function main() returns error? {
    while true {
        io:println("\n Car Rental System ");
        io:println("1. Admin");
        io:println("2. Customer");
        io:println("3. Exit");
    
        io:print("Enter choice: ");
        string choice = io:readln().trim();

        match choice {
            "1" => {
                io:println("Launching Admin UI...");
                check ui:adminMain();  
            }
            "2" => {
                io:println("Launching Customer UI...");
                check ui:customerMain();  
            }
            "3" => {
                io:println("Goodbye!");
                return; 
            }
            _ => {
                io:println("Invalid choice. Try again.");
            }
        }
    }
}
