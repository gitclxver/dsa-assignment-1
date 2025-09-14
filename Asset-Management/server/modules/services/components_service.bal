import ballerina/http;

import asset_management.db;
import asset_management.kafka;
import asset_management.models;

listener http:Listener componentsListener = new (8082);

final db:AssetRepository componentsRepo = new (checkpanic db:getAssetCollection());
service /components on componentsListener {

    isolated resource function post add(http:Caller caller, http:Request req, string assetTag) returns error? {
        json payload = check req.getJsonPayload();
        models:Component component = check payload.cloneWithType();

        models:Asset updated = check componentsRepo.addComponent(assetTag, component);
        check kafka:assetProducer.sendCustomEvent("components", assetTag, {
            eventType: "component.added",
            assetTag,
            component: component.toJson()
        });

        check caller->respond(updated);
    }

    isolated resource function delete remove(http:Caller caller, http:Request req, string assetTag, string componentId) returns error? {
        models:Asset updated = check componentsRepo.removeComponent(assetTag, componentId);
        check kafka:assetProducer.sendCustomEvent("components", assetTag, {
            eventType: "component.removed",
            assetTag,
            componentId
        });

        check caller->respond(updated);
    }
}