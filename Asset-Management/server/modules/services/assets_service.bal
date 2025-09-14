import ballerina/http;

import asset_management.db;
import asset_management.kafka;
import asset_management.models;

listener http:Listener assetsListener = new (8081);

final db:AssetRepository assetsRepo = new (checkpanic db:getAssetCollection());

service /assets on assetsListener {

    isolated resource function post create(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        models:Asset asset = check payload.cloneWithType();
        models:Asset created = check assetsRepo.createAsset(asset);

        check kafka:assetProducer.sendAssetCreated(created);
        check caller->respond({ message: "Asset created", asset: created });
    }

    isolated resource function get list(http:Caller caller, http:Request req) returns error? {
        models:Asset[] assets = check assetsRepo.getAllAssets();
        check caller->respond(assets);
    }

    isolated resource function get byFaculty(http:Caller caller, http:Request req, string faculty) returns error? {
        models:Asset[] assets = check assetsRepo.getAssetsByFaculty(faculty);
        check caller->respond(assets);
    }

    isolated resource function get overdue(http:Caller caller, http:Request req) returns error? {
        models:Asset[] assets = check assetsRepo.getAssetsWithOverdueSchedules();
        check caller->respond(assets);
    }
}