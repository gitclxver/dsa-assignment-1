public type CartItem record {
    string car_plate;
    string start_date;
    string end_date;
    float price;
};

public type Reservation record {
    string id;
    string user_id;
    CartItem[] items;
    float total_price;
};
