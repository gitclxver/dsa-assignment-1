import car_rental.models;

public final map<models:Car> cars = {};
public final map<models:User> users = {};
public final map<models:Reservation> reservations = {};
public final map<models:CartItem[]> carts = {};

// ----------------- Car Functions -----------------

public function addCar(models:Car car) returns error? {
    if cars.hasKey(car.plate) {
        return error("Car with plate " + car.plate + " already exists");
    }
    cars[car.plate] = car;
}

public function getCar(string plate) returns models:Car? {
    return cars[plate];
}

public function updateCar(string plate, models:Car car) returns boolean {
    if cars.hasKey(plate) {
        cars[plate] = car;
        return true;
    }
    return false;
}

public function removeCar(string plate) returns boolean {
    return cars.remove(plate) is models:Car;
}

public function listAvailableCars() returns models:Car[] {
    models:Car[] available = [];
    foreach var car in cars {
        if car.status == "AVAILABLE" {
            available.push(car);
        }
    }
    return available;
}

public function searchCars(string? make, string? model, int? minYear, int? maxYear,
                          float? maxDailyPrice) returns models:Car[] {
    models:Car[] results = [];
    foreach var car in cars {
        boolean matches = true;

        if make is string && car.make != make {
            matches = false;
        }
        if model is string && car.model != model {
            matches = false;
        }
        if minYear is int && car.year < minYear {
            matches = false;
        }
        if maxYear is int && car.year > maxYear {
            matches = false;
        }
        if maxDailyPrice is float && car.daily_price > maxDailyPrice {
            matches = false;
        }

        if matches {
            results.push(car);
        }
    }
    return results;
}

// ----------------- User Functions -----------------

public function addUser(models:User user) returns error? {
    if users.hasKey(user.id) {
        return error("User already exists: " + user.id);
    }
    users[user.id] = user;
}

public function getUser(string id) returns models:User? {
    return users[id];
}

public function listUsers() returns models:User[] {
    models:User[] userList = [];
    foreach var user in users {
        userList.push(user);
    }
    return userList;
}

public function isAdmin(string userId) returns boolean {
    models:User? user = users[userId];
    if user is () {
        return false;
    }
    return user.role == "ADMIN";
}

// ----------------- Cart & Reservation Functions -----------------

public function addToCart(string userId, models:CartItem item) returns error? {
    models:Car? car = getCar(item.car_plate);
    if car is () {
        return error("Car not found: " + item.car_plate);
    }
    if car.status != "AVAILABLE" {
        return error("Car is not available: " + item.car_plate);
    }

    models:CartItem[]? cartItems = carts[userId];
    if cartItems is models:CartItem[] {
        foreach var existingItem in cartItems {
            if existingItem.car_plate == item.car_plate {
                return error("Car already in cart: " + item.car_plate);
            }
        }
        cartItems.push(item);
        carts[userId] = cartItems;
    } else {
        carts[userId] = [item];
    }
}

public function getCart(string userId) returns models:CartItem[]? {
    return carts[userId];
}

public function clearCart(string userId) {
    _ = carts.remove(userId);
}

public function placeReservation(models:Reservation res) returns error? {
    foreach var item in res.items {
        models:Car? car = getCar(item.car_plate);
        if car is () {
            return error("Car not found: " + item.car_plate);
        }
        if car.status != "AVAILABLE" {
            return error("Car is not available: " + item.car_plate);
        }
    }

    foreach var item in res.items {
        models:Car? car = getCar(item.car_plate);
        if car is models:Car {
            car.status = "UNAVAILABLE";
            _ = updateCar(item.car_plate, car);
        }
    }

    reservations[res.id] = res;
}

public function getReservationsByUser(string userId) returns models:Reservation[] {
    models:Reservation[] userReservations = [];
    foreach var reservation in reservations {
        if reservation.user_id == userId {
            userReservations.push(reservation);
        }
    }
    return userReservations;
}

public function getAllReservations() returns models:Reservation[] {
    models:Reservation[] allReservations = [];
    foreach var res in reservations {
        allReservations.push(res);
    }
    return allReservations;
}
