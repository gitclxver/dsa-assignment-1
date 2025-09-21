import ballerina/http;
import ballerina/log;

import asset_management.db;

// HTTP listener
listener http:Listener httpListener = new(8081);

// Helper function to initialize repository
function getAssetRepository() returns db:AssetRepository|error {
    return new;
}

// Repository Instance 
final db:AssetRepository repo = check getAssetRepository();

service /api on httpListener {

    // Create a new asset
    resource function post assets(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets - Creating new asset");

        json payload = check req.getJsonPayload();
        db:Asset asset = check payload.cloneWithType();
        db:Asset created = check repo.createAsset(asset);

        json response = {
            "message": "Asset created successfully",
            "asset": created.toJson()
        };

        check caller->respond(response);
    }

    // Get all assets
    resource function get assets(http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets - Fetching all assets");

        db:Asset[] assets = repo.getAllAssets();
        json[] assetJsonArray = from db:Asset asset in assets
                               select asset.toJson();

        check caller->respond(assetJsonArray);
    }

    // Get a Specific Asset by Tag
    resource function get assets/[string assetTag](http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets/" + assetTag + " - Fetching specific asset");

        db:Asset|error assetResult = repo.getAsset(assetTag);

        if assetResult is error {
            json errorResponse = {
                "error": "Asset not found",
                "assetTag": assetTag
            };
            check caller->respond(errorResponse);
            return;
        }

        check caller->respond(assetResult.toJson());
    }

    // Update Asset
    resource function put assets/[string assetTag](http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + " - Updating asset");

        json payload = check req.getJsonPayload();
        db:Asset asset = check payload.cloneWithType();
        db:Asset|error updated = repo.updateAsset(assetTag, asset);

        if updated is error {
            json errorResponse = {
                "error": "Failed to update asset",
                "assetTag": assetTag
            };
            check caller->respond(errorResponse);
            return;
        }

        json response = {
            "message": "Asset updated successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Delete Asset
    resource function delete assets/[string assetTag](http:Caller caller, http:Request req) returns error? {

        log:printInfo("DELETE /api/assets/" + assetTag + " - Deleting asset");

        error? deleteResult = repo.deleteAsset(assetTag);

        http:Response res = new;
        if deleteResult is error {
            log:printError("Failed to delete asset", 'error = deleteResult);
            json errorResponse = {
                "error": deleteResult.message(),
                "assetTag": assetTag
            };
            res.statusCode = 404;
            res.setJsonPayload(errorResponse);
        } else {
            json response = {
                "message": "Asset deleted successfully",
                "assetTag": assetTag
            };
            res.statusCode = 200;
            res.setJsonPayload(response);
        }

        check caller->respond(res);
    }

    // Get Assets by Faculty
    resource function get assets/faculty/[string faculty](http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets/faculty/" + faculty + " - Fetching assets by faculty");

        db:Asset[] assets = repo.getAssetsByFaculty(faculty);
        json[] assetJsonArray = from db:Asset asset in assets
                               select asset.toJson();

        check caller->respond(assetJsonArray);
    }

    // Get Overdue Assets
    resource function get assets/overdue(http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets/overdue - Fetching overdue assets");

        db:Asset[] assets = repo.getAssetsWithOverdueSchedules();
        json[] assetJsonArray = from db:Asset asset in assets
                               select asset.toJson();

        check caller->respond(assetJsonArray);
    }

    // Components

    // Add Components
    resource function post assets/[string assetTag]/components(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/components - Adding component");

        json payload = check req.getJsonPayload();
        db:Component component = check payload.cloneWithType();
        db:Asset updated = check repo.addComponent(assetTag, component);

        json response = {
            "message": "Component added successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Delete Components
    resource function delete assets/[string assetTag]/components/[string componentId](http:Caller caller, http:Request req) returns error? {

        log:printInfo("DELETE /api/assets/" + assetTag + "/components/" + componentId + " - Removing component");

        db:Asset|error result = repo.removeComponent(assetTag, componentId);

        http:Response res = new;
        if result is error {
            log:printError("Failed to remove component", 'error = result);
            json errorResponse = {
                "error": result.message(),
                "assetTag": assetTag,
                "componentId": componentId
            };
            res.statusCode = 404;
            res.setJsonPayload(errorResponse);
        } else {
            json response = {
                "message": "Component removed successfully",
                "asset": result.toJson()
            };
            res.statusCode = 200;
            res.setJsonPayload(response);
        }

        check caller->respond(res);
    }

    // Schedules

    // Add Schedule
    resource function post assets/[string assetTag]/schedules(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/schedules - Adding schedule");

        json payload = check req.getJsonPayload();
        db:Schedule schedule = check payload.cloneWithType();
        db:Asset updated = check repo.addSchedule(assetTag, schedule);

        json response = {
            "message": "Schedule added successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Complete Schedule
    resource function put assets/[string assetTag]/schedules/[string scheduleId]/complete(http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/schedules/" + scheduleId + "/complete - Completing schedule");

        db:Asset updated = check repo.completeSchedule(assetTag, scheduleId);

        json response = {
            "message": "Schedule completed successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Remove Schedule
    resource function delete assets/[string assetTag]/schedules/[string scheduleId](http:Caller caller, http:Request req) returns error? {

        log:printInfo("DELETE /api/assets/" + assetTag + "/schedules/" + scheduleId + " - Removing schedule");

        db:Asset|error result = repo.removeSchedule(assetTag, scheduleId);

        http:Response res = new;
        if result is error {
            log:printError("Failed to remove schedule", 'error = result);
            json errorResponse = {
                "error": result.message(),
                "assetTag": assetTag,
                "scheduleId": scheduleId
            };
            res.statusCode = 404;
            res.setJsonPayload(errorResponse);
        } else {
            json response = {
                "message": "Schedule removed successfully",
                "asset": result.toJson()
            };
            res.statusCode = 200;
            res.setJsonPayload(response);
        }

        check caller->respond(res);
    }

    //  Work Orders 

    // Add Work Order
    resource function post assets/[string assetTag]/workorders(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/workorders - Adding work order");

        json payload = check req.getJsonPayload();
        db:WorkOrder workOrder = check payload.cloneWithType();
        db:Asset updated = check repo.addWorkOrder(assetTag, workOrder);

        json response = {
            "message": "Work order added successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Update Work Order
    resource function put assets/[string assetTag]/workorders/[string workOrderId](http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/workorders/" + workOrderId + " - Updating work order");

        json payload = check req.getJsonPayload();
        db:WorkOrder workOrder = check payload.cloneWithType();
        db:Asset updated = check repo.updateWorkOrder(assetTag, workOrderId, workOrder);

        json response = {
            "message": "Work order updated successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Complete Work Order
    resource function put assets/[string assetTag]/workorders/[string workOrderId]/complete(http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/workorders/" + workOrderId + "/complete - Completing work order");

        db:Asset updated = check repo.completeWorkOrder(assetTag, workOrderId);

        json response = {
            "message": "Work order completed successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    //  Tasks 

    // Add Task
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks - Adding task");

        json payload = check req.getJsonPayload();
        db:Task task = check payload.cloneWithType();
        db:Asset updated = check repo.addTask(assetTag, workOrderId, task);

        json response = {
            "message": "Task added successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Complete Task
    resource function put assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]/complete(http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks/" + taskId + "/complete - Completing task");

        db:Asset updated = check repo.completeTask(assetTag, workOrderId, taskId);

        json response = {
            "message": "Task completed successfully",
            "asset": updated.toJson()
        };

        check caller->respond(response);
    }

    // Remove Task 
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId](http:Caller caller, http:Request req) returns error? {

        log:printInfo("DELETE /api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks/" + taskId + " - Removing task");

        db:Asset|error result = repo.removeTask(assetTag, workOrderId, taskId);

        http:Response res = new;
        if result is error {
            log:printError("Failed to remove task", 'error = result);
            json errorResponse = {
                "error": result.message(),
                "assetTag": assetTag,
                "workOrderId": workOrderId,
                "taskId": taskId
            };
            res.statusCode = 404;
            res.setJsonPayload(errorResponse);
        } else {
            json response = {
                "message": "Task removed successfully",
                "asset": result.toJson()
            };
            res.statusCode = 200;
            res.setJsonPayload(response);
        }

        check caller->respond(res);
    }

   
}

public function main() returns error? {
    log:printInfo("Starting Asset Management API server...");
    log:printInfo("Asset Management API server started on port 8081");
}
