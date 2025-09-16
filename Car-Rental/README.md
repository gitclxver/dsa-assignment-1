# 🚗 Car Rental System (gRPC + Ballerina + MongoDB)

This project is a **Car Rental System** implemented in **Ballerina** using **gRPC** and **MongoDB**.  
It supports two user roles: **Customer** and **Admin**.

- **Customers** can: browse available cars, search by plate, add cars to cart with rental dates, and place reservations.
- **Admins** can: add new cars, update car details, remove cars, and list all reservations.

The system is divided into **two independent projects**:
1. `car_rental_server` → gRPC server, business logic, and database (MongoDB).
2. `car_rental_client` → CLI client app for Customers and Admins.

The contract between them is defined in **Protocol Buffers** (`proto/car_rental.proto`).

---
## 🛠️ Layers & Responsibilities

### 1. **Proto Contract (`proto/car_rental.proto`)**
- Defines **messages**, **enums**, and **services**.
- Example RPCs:
  - `add_car`
  - `update_car`
  - `remove_car`
  - `list_available_cars`
  - `search_car`
  - `add_to_cart`
  - `place_reservation`
- This file is the **source of truth**.  
  Both **server** and **client** generate gRPC stubs from it.

---

### 2. **Server Project (`car_rental_server/`)**

#### 🔹 `main.bal`
- Starts the gRPC server.
- Registers the services implemented in `modules/services`.

#### 🔹 `modules/services/`
- **Business logic** for each gRPC call.
- Talks to the `repository` layer for database access.
- Validates inputs with `utils`.
- Example:
  - `car_service.bal` → `add_car`, `update_car`, `remove_car`
  - `reservation_service.bal` → `add_to_cart`, `place_reservation`

#### 🔹 `modules/repository/`
- Handles **MongoDB access** (CRUD).
- Encapsulates queries so service layer doesn’t know DB details.
- Example:
  - `car_repository.bal` → `insertCar()`, `findCarByPlate()`, `listAvailableCars()`

#### 🔹 `modules/models/`
- Defines record types representing domain objects.
- Example:
  - `Car`, `User`, `Reservation`.

#### 🔹 `modules/utils/`
- Helper functions.
- Example:
  - `validators.bal` → check rental date ranges.
  - `price_calculator.bal` → compute total rental cost.

#### 🔹 `resources/`
- JSON/YAML files for **seed data** or initial config.

---

### 3. **Client Project (`car_rental_client/`)**

#### 🔹 `main.bal`
- CLI entry point.
- Prompts the user to log in as **Customer** or **Admin**.
- Routes requests to `ui` modules.

#### 🔹 `modules/ui/`
- Handles **user interaction** (menus, prompts).
- Example:
  - `customer_ui.bal` → "1. View Cars, 2. Add to Cart, 3. Place Reservation"
  - `admin_ui.bal` → "1. Add Car, 2. Update Car, 3. Remove Car"

#### 🔹 `modules/handlers/`
- Calls the **gRPC stubs**.
- Converts CLI input into requests to the server.
- Example:
  - `customer_handler.bal` → calls `list_available_cars` RPC.
  - `admin_handler.bal` → calls `add_car` RPC.

#### 🔹 `modules/utils/`
- Formatting and validation helpers.
- Example:
  - Pretty print car details.
  - Validate dates and user input.