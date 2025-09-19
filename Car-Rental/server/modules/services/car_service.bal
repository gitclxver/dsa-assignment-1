import car_rental.proto;
import car_rental.repository;
import car_rental.models;
import ballerina/time;

public service class CarService {

    public function add_car(proto:AddCarRequest req) returns proto:AddCarResponse|error {
        Car car = {
            plate: req.car.plate,
            make: req.car.make,
            model: req.car.model,
            year: req.car.year,
            daily_price: req.car.daily_price,
            mileage: req.car.mileage,
            status: "AVAILABLE" 
        };
        
        check repository:addCar(car);
        
        return {
            plate: car.plate
        };
    }

    public function update_car(proto:UpdateCarRequest req) returns proto:Car|error {
        Car? existingCar = repository:getCar(req.plate);
        if existingCar is () {
            return error("Car not found: " + req.plate);
        }
        
        Car updatedCar = {
            plate: req.car.plate,
            make: req.car.make,
            model: req.car.model,
            year: req.car.year,
            daily_price: req.car.daily_price,
            mileage: req.car.mileage,
            status: req.car.status.toString()
        };
        
        boolean success = repository:updateCar(req.plate, updatedCar);
        if !success {
            return error("Failed to update car: " + req.plate);
        }
        
        return convertToProtoCar(updatedCar);
    }

    public function remove_car(proto:RemoveCarRequest req) returns proto:CarList|error {
        Car? car = repository:getCar(req.plate);
        if car is () {
            return error("Car not found: " + req.plate);
        }
        
        boolean removed = repository:removeCar(req.plate);
        if !removed {
            return error("Failed to remove car: " + req.plate);
        }
        
        Car[] availableCars = repository:listAvailableCars();
        proto:Car[] protoCars = availableCars.map(convertToProtoCar);
        
        return {
            cars: protoCars
        };
    }

    public function list_available_cars(proto:ListAvailableCarsRequest req) 
        returns stream<proto:Car, error?>|error {
        Car[] availableCars = repository:listAvailableCars();
        proto:Car[] protoCars = availableCars.map(convertToProtoCar);
        return new stream<proto:Car, error?>(protoCars);
    }

    public function search_car(proto:SearchCarRequest req) returns proto:Car|error {
        Car? car = repository:getCar(req.plate);
        if car is () {
            return error("Car not found: " + req.plate);
        }
        
        return convertToProtoCar(car);
    }
    
    function convertToProtoCar(Car car) returns proto:Car {
        proto:CarStatus status = proto:CarStatus.UNAVAILABLE;
        if car.status == "AVAILABLE" {
            status = proto:CarStatus.AVAILABLE;
        }
        
        return {
            plate: car.plate,
            make: car.make,
            model: car.model,
            year: car.year,
            daily_price: car.daily_price,
            mileage: car.mileage,
            status: status
        };
    }
}