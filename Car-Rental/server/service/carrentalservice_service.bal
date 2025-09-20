import ballerina/grpc;

listener grpc:Listener ep = new (9090);

int reservationCounter = 0;

table<Car> key(plate) carTable = table[];
table<User> key(id) userTable = table[];
table<Reservation> key(id) reservationTable = table[];



@grpc:Descriptor {value: CAR_RENTAL_DESC}
service "CarRentalService" on ep {

    remote function add_car(AddCarRequest value) returns AddCarResponse|error {

        Car car = value.car;

        if carTable.hasKey(car.plate){
            return error("Car with plate " + car.plate + " Already Exists");
        }else{
            carTable.add(car);
            AddCarResponse resp = {plate: car.plate};
            return resp;
        }
    }

    remote function create_users(CreateUsersRequest value) returns CreateUsersResponse|error {

        int successCount =0;
        string[] failureUsers = [];

        foreach User user in value.users {
            if user.id == ""{
                failureUsers.push("User with empty ID");
            } else if userTable.hasKey(user.id){
                failureUsers.push("User " + user.id + " Already Exists");
            } else {
                userTable.add(user);
                successCount += 1;
            }
        }
        return {count: successCount};

    }

    remote function update_car(UpdateCarRequest value) returns Car|error {

        string plate = value.plate;
        Car updatedCar = value.car;

        if carTable.hasKey(plate) {
            Car oldCar = carTable.remove(plate);
            carTable.add(updatedCar);
            return updatedCar;
        }else{
            return error("Car With Plate " + plate + "Not Found");
        }
    }

    remote function remove_car(RemoveCarRequest value) returns CarList|error {

        string plate = value.plate;

        if carTable.hasKey(plate) {
            Car removedCar = carTable.remove(plate);

            CarList response = {
                cars: from Car car in carTable
                select {
                    plate: car.plate,
                    make: car.make,
                    model: car.model,
                    year: car.year,
                    daily_price: car.daily_price,
                    mileage: car.mileage,
                    status: car.status
                }
            };
            return response;
        }else{
            return error("Car With Plate " + plate + " not found");
        }
    }

    remote function search_car(SearchCarRequest value) returns Car|error {

        string plate = value.plate;

        if carTable.hasKey(plate){
            return carTable.get(plate);
        }else{
            return error("Car with Plate " + plate + " Not Found");
        }

    }

    remote function add_to_cart(AddToCartRequest value) returns CartResponse|error {
        string userId = value.user_id;
        string carPlate = value.car_plate;
        int daysToRent = value.days_to_rent;
        
        if daysToRent <= 0 {
            return error("Days to rent must be greater than 0");
        }
        
        if !carTable.hasKey(carPlate) {
            return error("Car with plate " + carPlate + " not found");
        }
        
        Car car = carTable.get(carPlate);
        if car.status != AVAILABLE {
            return error("Car is not available for rental");
        }
        
        if !userTable.hasKey(userId) {
            return error("User " + userId + " not found");
        }
        
        float totalPrice = car.daily_price * daysToRent;

        CartItem item = {
            car_plate: carPlate,
            days_to_rent: daysToRent,
            price: totalPrice
        };

        User user = userTable.get(userId);
        user.cart.push(item);
        userTable.put(user);
        
        return {success: true, message: "Car added to cart successfully"};
    }

    remote function place_reservation(PlaceReservationRequest value) returns ReservationResponse|error {
    
        string userId = value.user_id;

        if !userTable.hasKey(userId) {
            return error("User " + userId + " not found");
        }
        
        User user = userTable.get(userId);
        
        if user.cart.length() == 0 {
            return error("Cart is empty");
        }
        
        float totalPrice = 0.0;
        foreach CartItem item in user.cart {
            totalPrice += item.price;
            
            if carTable.hasKey(item.car_plate) {
                Car car = carTable.get(item.car_plate);
                car.status = UNAVAILABLE;
                carTable.put(car);
            }
        }
        
        reservationCounter += 1;

        Reservation reservation = {
            id: reservationCounter.toString(),
            user_id: userId,
            items: user.cart,
            total_price: totalPrice
        };
        
        // Clear user's cart and update user record
        user.cart = [];
        userTable.put(user);
        
        // Store the reservation
        reservationTable.add(reservation);
        
        return {
            success: true,
            message: "Reservation placed successfully",
            reservation: reservation
        };
    }

    remote function list_available_cars(ListAvailableCarsRequest value) returns stream<Car, error?>|error {

        Car[] availableCars = from Car car in carTable where car.status == AVAILABLE select car;

        return availableCars.toStream();

    }
}
