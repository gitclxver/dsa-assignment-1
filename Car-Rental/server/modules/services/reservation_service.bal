import car_rental.proto;
import car_rental.repository;
import car_rental.models;
import ballerina/time;
import ballerina/uuid;

public service class ReservationService {

    public function add_to_cart(proto:AddToCartRequest req) returns proto:CartResponse|error {
        // Validate user exists
        User? user = repository:getUser(req.user_id);
        if user is () {
            return error("User not found: " + req.user_id);
        }
        
        // Validate dates
        time:Date startDate = check time:dateFromString(req.start_date);
        time:Date endDate = check time:dateFromString(req.end_date);
        
        if startDate.after(endDate) {
            return error("Start date must be before end date");
        }
        
        // Calculate number of days
        time:DateDiff diff = time:diff(startDate, endDate);
        int days = diff.days + 1; // Inclusive
        
        // Get car and calculate price
        Car? car = repository:getCar(req.car_plate);
        if car is () {
            return error("Car not found: " + req.car_plate);
        }
        
        float price = car.daily_price * days;
        
        CartItem item = {
            car_plate: req.car_plate,
            start_date: req.start_date,
            end_date: req.end_date,
            price: price
        };
        
        check repository:addToCart(req.user_id, item);
        
        return {
            success: true,
            message: "Car added to cart successfully"
        };
    }

    public function place_reservation(proto:PlaceReservationRequest req) 
        returns proto:ReservationResponse|error {
        
        // Validate user exists
        User? user = repository:getUser(req.user_id);
        if user is () {
            return error("User not found: " + req.user_id);
        }
        
        // Get cart items
        CartItem[]? cartItems = repository:getCart(req.user_id);
        if cartItems is () || cartItems.length() == 0 {
            return error("Cart is empty for user: " + req.user_id);
        }
        
        // Calculate total price
        float totalPrice = 0.0;
        foreach var item in cartItems {
            totalPrice += item.price;
        }
        
        // Create reservation
        string reservationId = uuid:createType1AsString();
        Reservation reservation = {
            id: reservationId,
            user_id: req.user_id,
            items: cartItems.clone(),
            total_price: totalPrice
        };
        
        check repository:placeReservation(reservation);
        repository:clearCart(req.user_id);
        
        return {
            success: true,
            message: "Reservation placed successfully",
            reservation: convertToProtoReservation(reservation)
        };
    }
    
    function convertToProtoReservation(Reservation res) returns carrental:Reservation {
        proto:CartItem[] protoItems = [];
        foreach var item in res.items {
            protoItems.push({
                car_plate: item.car_plate,
                start_date: item.start_date,
                end_date: item.end_date,
                price: item.price
            });
        }
        
        return {
            id: res.id,
            user_id: res.user_id,
            items: protoItems,
            total_price: res.total_price
        };
    }
}