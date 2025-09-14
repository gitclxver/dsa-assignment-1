import ballerinax/mongodb;

// Configurable variables that match Config.toml
public configurable string dbUri = "mongodb://localhost:27017";
public configurable string dbName = "AssetDB";

// Get MongoDB client
public isolated function getMongoClient() returns mongodb:Client|error {
    mongodb:ConnectionConfig config = {
        connection: dbUri
    };
    return new (config);
}

// Get assets collection
public isolated function getAssetCollection() returns mongodb:Collection|error {
    mongodb:Client mongoClient = check getMongoClient();
    mongodb:Database database = check mongoClient->getDatabase(dbName);
    return check database->getCollection("assets");
}