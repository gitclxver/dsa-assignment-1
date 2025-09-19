import car_rental.proto;
import car_rental.repository;
import car_rental.models;

public service class UserService {

    public function create_users(proto:CreateUsersRequest req) returns proto:CreateUsersResponse|error {
        int count = 0;
        foreach var protoUser in req.users {
            User user = {
                id: protoUser.id,
                name: protoUser.name,
                role: protoUser.role.toString()
            };
            
            check repository:addUser(user);
            count += 1;
        }
        
        return {
            count: count
        };
    }
}