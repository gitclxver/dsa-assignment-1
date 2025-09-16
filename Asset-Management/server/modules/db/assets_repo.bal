import ballerinax/mongodb;
import ballerina/time;
import ballerina/log;

import asset_management.models;
import asset_management.config;

// Asset repository for MongoDB operations

public isolated class AssetRepository {
    private final mongodb:Collection assets;

    public isolated function init(mongodb:Collection assets) {
        self.assets = assets;
    }

    // ---------------- Asset Operations ----------------
    public isolated function createAsset(models:Asset asset) returns models:Asset|error {
        check self.assets->insertOne(asset);
        log:printInfo("Asset created: " + asset.assetTag);
        return asset;
    }

    public isolated function getAllAssets() returns models:Asset[]|error {
        stream<models:Asset, error?> resultStream = check self.assets->find();
        models:Asset[] assets = [];
        record {| models:Asset value; |}|error? next = resultStream.next();
        while next is record {| models:Asset value; |} {
            assets.push(next.value);
            next = resultStream.next();
        }
        check resultStream.close();
        return assets;
    }

    public isolated function getAsset(string assetTag) returns models:Asset|error {
        models:Asset? result = check self.assets->findOne({assetTag: assetTag});
        if result is () {
            return error(config:ASSET_NOT_FOUND);
        }
        return result;
    }

    public isolated function updateAsset(string assetTag, models:Asset asset) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag},
            {"$set": <map<json>>asset.toJson()}
        );
        if result.matchedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        log:printInfo("Asset updated: " + assetTag);
        return asset;
    }

    public isolated function deleteAsset(string assetTag) returns error? {
        mongodb:DeleteResult result = check self.assets->deleteOne({assetTag: assetTag});
        if result.deletedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        log:printInfo("Asset deleted: " + assetTag);
    }

    public isolated function getAssetsByFaculty(string faculty) returns models:Asset[]|error {
        stream<models:Asset, error?> resultStream = check self.assets->find({faculty: faculty});
        models:Asset[] assets = [];
        record {| models:Asset value; |}|error? next = resultStream.next();
        while next is record {| models:Asset value; |} {
            assets.push(next.value);
            next = resultStream.next();
        }
        check resultStream.close();
        return assets;
    }

    public isolated function getAssetsWithOverdueSchedules() returns models:Asset[]|error {
        time:Utc currentTime = time:utcNow();
        string currentDateStr = time:utcToString(currentTime);

        stream<models:Asset, error?> resultStream = check self.assets->find({
            "schedules.nextDueDate": {"$lt": currentDateStr},
            "schedules.status": config:SCHEDULE_ACTIVE
        });

        models:Asset[] assets = [];
        record {| models:Asset value; |}|error? next = resultStream.next();
        while next is record {| models:Asset value; |} {
            assets.push(next.value);
            next = resultStream.next();
        }
        check resultStream.close();
        return assets;
    }

    // ---------------- Component Operations ----------------
    public isolated function addComponent(string assetTag, models:Component component) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag},
            {"$push": {components: <json>component}}
        );
        if result.matchedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    public isolated function removeComponent(string assetTag, string componentId) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag},
            {"$pull": {components: {componentId: componentId}}}
        );
        if result.matchedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    // ---------------- Schedule Operations ----------------
    public isolated function addSchedule(string assetTag, models:Schedule schedule) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag},
            {"$push": {schedules: <json>schedule}}
        );
        if result.matchedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    public isolated function removeSchedule(string assetTag, string scheduleId) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag},
            {"$pull": {schedules: {scheduleId: scheduleId}}}
        );
        if result.matchedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    public isolated function completeSchedule(string assetTag, string scheduleId) returns models:Asset|error {
        // mark schedule as completed
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag, "schedules.scheduleId": scheduleId},
            {"$set": {"schedules.$.status": config:COMPLETED}}
        );
        if result.matchedCount == 0 {
            return error(config:SCHEDULE_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    // ---------------- WorkOrder Operations ----------------
    public isolated function addWorkOrder(string assetTag, models:WorkOrder workOrder) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag},
            {"$push": {workOrders: <json>workOrder}}
        );
        if result.matchedCount == 0 {
            return error(config:ASSET_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    public isolated function updateWorkOrder(string assetTag, string workOrderId, models:WorkOrder workOrder) returns models:Asset|error {
    mongodb:UpdateResult removeResult = check self.assets->updateOne(
        {assetTag: assetTag},
        {"$pull": {workOrders: {workOrderId: workOrderId}}}
    );
    if removeResult.matchedCount == 0 {
        return error(config:WORKORDER_NOT_FOUND);
    }
    mongodb:UpdateResult addResult = check self.assets->updateOne(
        {assetTag: assetTag},
        {"$push": {workOrders: <json>workOrder}}
    );

    // Check if the add operation was successful
    if addResult.matchedCount == 0 {
        return error(config:ASSET_NOT_FOUND);
    }

    return self.getAsset(assetTag);
}

    public isolated function completeWorkOrder(string assetTag, string workOrderId) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag, "workOrders.workOrderId": workOrderId},
            {"$set": {"workOrders.$.status": config:COMPLETED}}
        );
        if result.matchedCount == 0 {
            return error(config:WORKORDER_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    // Task Operations
    public isolated function addTask(string assetTag, string workOrderId, models:Task task) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag, "workOrders.workOrderId": workOrderId},
            {"$push": {"workOrders.$.tasks": <json>task}}
        );
        if result.matchedCount == 0 {
            return error(config:WORKORDER_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    public isolated function removeTask(string assetTag, string workOrderId, string taskId) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag, "workOrders.workOrderId": workOrderId},
            {"$pull": {"workOrders.$.tasks": {taskId: taskId}}}
        );
        if result.matchedCount == 0 {
            return error(config:TASK_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }

    public isolated function completeTask(string assetTag, string workOrderId, string taskId) returns models:Asset|error {
        mongodb:UpdateResult result = check self.assets->updateOne(
            {assetTag: assetTag, "workOrders.workOrderId": workOrderId, "workOrders.$.tasks.taskId": taskId},
            {"$set": {"workOrders.$.tasks.$.status": config:COMPLETED}}
        );
        if result.matchedCount == 0 {
            return error(config:TASK_NOT_FOUND);
        }
        return self.getAsset(assetTag);
    }
}
