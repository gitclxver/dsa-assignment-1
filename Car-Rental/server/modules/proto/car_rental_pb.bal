import ballerina/grpc;
import ballerina/protobuf;

public const string CAR_RENTAL_DESC = "0A1670726F746F2F6361725F72656E74616C2E70726F746F120963617272656E74616C22C2010A0343617212140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121F0A0B6461696C795F7072696365180520012802520A6461696C79507269636512180A076D696C6561676518062001280552076D696C65616765122C0A0673746174757318072001280E32142E63617272656E74616C2E436172537461747573520673746174757322530A0455736572120E0A0269641801200128095202696412120A046E616D6518022001280952046E616D6512270A04726F6C6518032001280E32132E63617272656E74616C2E55736572526F6C655204726F6C652282010A0B5265736572766174696F6E120E0A0269641801200128095202696412170A07757365725F6964180220012809520675736572496412290A056974656D7318032003280B32132E63617272656E74616C2E436172744974656D52056974656D73121F0A0B746F74616C5F7072696365180420012802520A746F74616C507269636522770A08436172744974656D121B0A096361725F706C6174651801200128095208636172506C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E644461746512140A0570726963651804200128025205707269636522310A0D4164644361725265717565737412200A0363617218012001280B320E2E63617272656E74616C2E436172520363617222260A0E416464436172526573706F6E736512140A05706C6174651801200128095205706C617465224A0A105570646174654361725265717565737412140A05706C6174651801200128095205706C61746512200A0363617218022001280B320E2E63617272656E74616C2E436172520363617222280A1052656D6F76654361725265717565737412140A05706C6174651801200128095205706C61746522320A184C697374417661696C61626C65436172735265717565737412160A0666696C746572180120012809520666696C74657222280A105365617263684361725265717565737412140A05706C6174651801200128095205706C6174652282010A10416464546F436172745265717565737412170A07757365725F69641801200128095206757365724964121B0A096361725F706C6174651802200128095208636172506C617465121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E644461746522320A17506C6163655265736572766174696F6E5265717565737412170A07757365725F69641801200128095206757365724964223B0A1243726561746555736572735265717565737412250A05757365727318012003280B320F2E63617272656E74616C2E5573657252057573657273222B0A134372656174655573657273526573706F6E736512140A05636F756E741801200128055205636F756E74222D0A074361724C69737412220A046361727318012003280B320E2E63617272656E74616C2E43617252046361727322420A0C43617274526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D6573736167652283010A135265736572766174696F6E526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512380A0B7265736572766174696F6E18032001280B32162E63617272656E74616C2E5265736572766174696F6E520B7265736572766174696F6E2A230A0855736572526F6C65120C0A08435553544F4D4552100012090A0541444D494E10012A2B0A09436172537461747573120D0A09415641494C41424C451000120F0A0B554E415641494C41424C45100132C2040A1043617252656E74616C53657276696365123E0A076164645F63617212182E63617272656E74616C2E416464436172526571756573741A192E63617272656E74616C2E416464436172526573706F6E7365124D0A0C6372656174655F7573657273121D2E63617272656E74616C2E4372656174655573657273526571756573741A1E2E63617272656E74616C2E4372656174655573657273526573706F6E736512390A0A7570646174655F636172121B2E63617272656E74616C2E557064617465436172526571756573741A0E2E63617272656E74616C2E436172123D0A0A72656D6F76655F636172121B2E63617272656E74616C2E52656D6F7665436172526571756573741A122E63617272656E74616C2E4361724C697374124C0A136C6973745F617661696C61626C655F6361727312232E63617272656E74616C2E4C697374417661696C61626C6543617273526571756573741A0E2E63617272656E74616C2E436172300112390A0A7365617263685F636172121B2E63617272656E74616C2E536561726368436172526571756573741A0E2E63617272656E74616C2E43617212430A0B6164645F746F5F63617274121B2E63617272656E74616C2E416464546F43617274526571756573741A172E63617272656E74616C2E43617274526573706F6E736512570A11706C6163655F7265736572766174696F6E12222E63617272656E74616C2E506C6163655265736572766174696F6E526571756573741A1E2E63617272656E74616C2E5265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CAR_RENTAL_DESC);
    }

    isolated remote function add_car(AddCarRequest|ContextAddCarRequest req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/add_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function add_carContext(AddCarRequest|ContextAddCarRequest req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddCarRequest message;
        if req is ContextAddCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/add_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function create_users(CreateUsersRequest|ContextCreateUsersRequest req) returns CreateUsersResponse|grpc:Error {
        map<string|string[]> headers = {};
        CreateUsersRequest message;
        if req is ContextCreateUsersRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/create_users", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CreateUsersResponse>result;
    }

    isolated remote function create_usersContext(CreateUsersRequest|ContextCreateUsersRequest req) returns ContextCreateUsersResponse|grpc:Error {
        map<string|string[]> headers = {};
        CreateUsersRequest message;
        if req is ContextCreateUsersRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/create_users", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CreateUsersResponse>result, headers: respHeaders};
    }

    isolated remote function update_car(UpdateCarRequest|ContextUpdateCarRequest req) returns Car|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/update_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <Car>result;
    }

    isolated remote function update_carContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextCar|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/update_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <Car>result, headers: respHeaders};
    }

    isolated remote function remove_car(RemoveCarRequest|ContextRemoveCarRequest req) returns CarList|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/remove_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CarList>result;
    }

    isolated remote function remove_carContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextCarList|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/remove_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CarList>result, headers: respHeaders};
    }

    isolated remote function search_car(SearchCarRequest|ContextSearchCarRequest req) returns Car|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/search_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <Car>result;
    }

    isolated remote function search_carContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextCar|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/search_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <Car>result, headers: respHeaders};
    }

    isolated remote function add_to_cart(AddToCartRequest|ContextAddToCartRequest req) returns CartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/add_to_cart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CartResponse>result;
    }

    isolated remote function add_to_cartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/add_to_cart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CartResponse>result, headers: respHeaders};
    }

    isolated remote function place_reservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/place_reservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ReservationResponse>result;
    }

    isolated remote function place_reservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrental.CarRentalService/place_reservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ReservationResponse>result, headers: respHeaders};
    }

    isolated remote function list_available_cars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrental.CarRentalService/list_available_cars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_carsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrental.CarRentalService/list_available_cars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class CarRentalServiceReservationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendReservationResponse(ReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextReservationResponse(ContextReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceAddCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddCarResponse(AddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddCarResponse(ContextAddCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCarListCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCarList(CarList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCarList(ContextCarList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCarCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCar(Car response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCar(ContextCar response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCreateUsersResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersResponse(CreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersResponse(ContextCreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCartResponse(CartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCartResponse(ContextCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextCarList record {|
    CarList content;
    map<string|string[]> headers;
|};

public type ContextReservationResponse record {|
    ReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersRequest record {|
    CreateUsersRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarRequest record {|
    AddCarRequest content;
    map<string|string[]> headers;
|};

public type ContextCartResponse record {|
    CartResponse content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CarList record {|
    Car[] cars = [];
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type ReservationResponse record {|
    boolean success = false;
    string message = "";
    Reservation reservation = {};
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type User record {|
    string id = "";
    string name = "";
    UserRole role = CUSTOMER;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type RemoveCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type UpdateCarRequest record {|
    string plate = "";
    Car car = {};
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type AddCarResponse record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CartItem record {|
    string car_plate = "";
    string start_date = "";
    string end_date = "";
    float price = 0.0;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type AddToCartRequest record {|
    string user_id = "";
    string car_plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type ListAvailableCarsRequest record {|
    string filter = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type SearchCarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CreateUsersRequest record {|
    User[] users = [];
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type AddCarRequest record {|
    Car car = {};
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CartResponse record {|
    boolean success = false;
    string message = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type Reservation record {|
    string id = "";
    string user_id = "";
    CartItem[] items = [];
    float total_price = 0.0;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type Car record {|
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    int mileage = 0;
    CarStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type PlaceReservationRequest record {|
    string user_id = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CreateUsersResponse record {|
    int count = 0;
|};

public enum UserRole {
    CUSTOMER, ADMIN
}

public enum CarStatus {
    AVAILABLE, UNAVAILABLE
}
