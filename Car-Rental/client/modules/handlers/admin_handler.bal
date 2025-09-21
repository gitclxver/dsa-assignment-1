import ballerina/grpc;
import 'client.client_stub as crpb;

public isolated client class AdminHandler {
    private final crpb:CarRentalServiceClient grpcClient;

    public isolated function init(string serverUrl) returns error? {
        self.grpcClient = check new (serverUrl);
    }

    // Add a new car to the system
    public isolated function addCar(CarInfo carInfo) returns string|error {
        crpb:Car car = {
            plate: carInfo.plate,
            make: carInfo.make,
            model: carInfo.model,
            year: carInfo.year,
            daily_price: carInfo.daily_price,
            mileage: carInfo.mileage,
            status: carInfo.status == "AVAILABLE" ? crpb:AVAILABLE : crpb:UNAVAILABLE
        };
        
        crpb:AddCarRequest req = { car: car };
        crpb:AddCarResponse|grpc:Error result = self.grpcClient->add_car(req);
        
        if result is grpc:Error {
            return error("Failed to add car: " + result.message());
        }
        return result.plate;
    }

    // Create multiple users
    public isolated function createUsers(UserInfo[] userInfos) returns int|error {
        crpb:User[] users = [];
        
        foreach UserInfo userInfo in userInfos {
            crpb:User user = {
                id: userInfo.id,
                name: userInfo.name,
                role: userInfo.role == "ADMIN" ? crpb:ADMIN : crpb:CUSTOMER
            };
            users.push(user);
        }
        
        crpb:CreateUsersRequest req = { users: users };
        crpb:CreateUsersResponse|grpc:Error result = self.grpcClient->create_users(req);
        
        if result is grpc:Error {
            return error("Failed to create users: " + result.message());
        }
        return result.count;
    }

    // Update car details
    public isolated function updateCar(string plate, CarInfo carInfo) returns CarInfo|error {
        crpb:Car car = {
            plate: carInfo.plate,
            make: carInfo.make,
            model: carInfo.model,
            year: carInfo.year,
            daily_price: carInfo.daily_price,
            mileage: carInfo.mileage,
            status: carInfo.status == "AVAILABLE" ? crpb:AVAILABLE : crpb:UNAVAILABLE
        };
        
        crpb:UpdateCarRequest req = { plate: plate, car: car };
        crpb:Car|grpc:Error result = self.grpcClient->update_car(req);
        
        if result is grpc:Error {
            return error("Failed to update car: " + result.message());
        }
        
        return {
            plate: result.plate,
            make: result.make,
            model: result.model,
            year: result.year,
            daily_price: result.daily_price,
            mileage: result.mileage,
            status: result.status.toString()
        };
    }

    // Remove car from system
    public isolated function removeCar(string plate) returns CarInfo[]|error {
        crpb:RemoveCarRequest req = { plate: plate };
        crpb:CarList|grpc:Error result = self.grpcClient->remove_car(req);
        
        if result is grpc:Error {
            return error("Failed to remove car: " + result.message());
        }
        
        CarInfo[] cars = [];
        foreach crpb:Car car in result.cars {
            cars.push({
                plate: car.plate,
                make: car.make,
                model: car.model,
                year: car.year,
                daily_price: car.daily_price,
                mileage: car.mileage,
                status: car.status.toString()
            });
        }
        return cars;
    }

    // List all available cars
    public isolated function listAllCars(string filter = "") returns CarInfo[]|error {
        crpb:ListAvailableCarsRequest req = { filter: filter };
        stream<crpb:Car, grpc:Error?> carStream = check self.grpcClient->list_available_cars(req);
        
        CarInfo[] cars = [];
        while true {
    var next = carStream.next();
    if next is grpc:Error {
        return error("Error while streaming cars: " + next.message());
    } else if next is () {
        // Stream ended
        break;
    } else {
        // Unwrap the value from the record
        crpb:Car car = next.value;  
        cars.push({
            plate: car.plate,
            make: car.make,
            model: car.model,
            year: car.year,
            daily_price: car.daily_price,
            mileage: car.mileage,
            status: car.status.toString()
        });
    }
}
           
        return cars;
    }
}

// Data transfer types for admin operations
public type CarInfo record {|
    string plate;
    string make;
    string model;
    int year;
    float daily_price;
    int mileage;
    string status; // "AVAILABLE" or "UNAVAILABLE"
|};

public type UserInfo record {|
    string id;
    string name;
    string role; // "CUSTOMER" or "ADMIN"
|};