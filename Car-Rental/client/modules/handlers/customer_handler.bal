import ballerina/grpc;
import 'client.client_stub as crpb;

public isolated client class CustomerHandler {
    private final crpb:CarRentalServiceClient grpcClient;

    public isolated function init(string serverUrl) returns error? {
        self.grpcClient = check new (serverUrl);
    }

  // List available cars (streaming)
public isolated function listAvailableCars(string filter = "") returns CarDetails[]|error {
    crpb:ListAvailableCarsRequest req = {
        filter: filter
    };

    stream<crpb:Car, grpc:Error?> carStream = check self.grpcClient->list_available_cars(req);

    
    CarDetails[] cars = check from var car in carStream
        select {
            plate: car.plate,
            make: car.make,
            model: car.model,
            year: car.year,
            daily_price: car.daily_price,
            mileage: car.mileage,
            status: car.status.toString()
        };

    return cars;
}

    // Search specific car
    public isolated function searchCar(string plate) returns CarDetails|error {
        crpb:SearchCarRequest req = { plate: plate };
        crpb:Car|grpc:Error result = self.grpcClient->search_car(req);

        if result is grpc:Error {
            return error("Failed to search: " + result.message());
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

    // Add to cart
    public isolated function addToCart(string userId, string carPlate, int daysToRent)
        returns CartOperationResult|error {

        crpb:AddToCartRequest req = {
            user_id: userId,
            car_plate: carPlate,
           days_to_rent: daysToRent
        };

        crpb:CartResponse|grpc:Error result = self.grpcClient->add_to_cart(req);
        if result is grpc:Error {
            return error("Add to cart failed: " + result.message());
        }
        return { success: result.success, message: result.message };
    }

    // Place reservation
    public isolated function placeReservation(string userId) returns ReservationResult|error {
        crpb:PlaceReservationRequest req = { user_id: userId };
        crpb:ReservationResponse|grpc:Error result = self.grpcClient->place_reservation(req);

        if result is grpc:Error {
            return error("Reservation failed: " + result.message());
        }

        ReservationDetails? reservation = ();
        if result.reservation.items.length() > 0 {
            CartItemDetails[] items = [];
            foreach crpb:CartItem item in result.reservation.items {
                items.push({
                    car_plate: item.car_plate,
                     days_to_rent: item.days_to_rent,
                    price: item.price
                });
            }
            reservation = {
                id: result.reservation.id,
                user_id: result.reservation.user_id,
                items: items,
                total_price: result.reservation.total_price
            };
        }

        return { success: result.success, message: result.message, reservation: reservation };
    }
}

// DTOs
public type CarDetails record {|
    string plate;
    string make;
    string model;
    int year;
    float daily_price;
    int mileage;
    string status;
|};

public type CartOperationResult record {|
    boolean success;
    string message;
|};

public type CartItemDetails record {|
    string car_plate;
    int days_to_rent;
    float price;
|};

public type ReservationDetails record {|
    string id;
    string user_id;
    CartItemDetails[] items;
    float total_price;
|};

public type ReservationResult record {|
    boolean success;
    string message;
    ReservationDetails? reservation;
|};
