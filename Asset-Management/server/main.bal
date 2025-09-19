import ballerina/http;
import ballerina/log;
import ballerina/time;
import asset_management.db;
import asset_management.models;

// Global HTTP listener
listener http:Listener httpListener = new(8081);

// Global repository instance (initialized in main)
final db:AssetRepository repo = check getAssetRepository();

// Service definition
service /api on httpListener {

    // ------------------- Assets -------------------

    // Create a new asset
    isolated resource function post assets(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets - Creating new asset");
        
        json payload = check req.getJsonPayload();
        models:Asset asset = check payload.cloneWithType();
        models:Asset created = check repo.createAsset(asset);
        
        json response = {
            "message": "Asset created successfully",
            "asset": created.toJson()
        };
        
        check caller->respond(response);
    }

    // Get all assets
    isolated resource function get assets(http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets - Fetching all assets");
        
        models:Asset[] assets = check repo.getAllAssets();
        json[] assetJsonArray = from models:Asset asset in assets
                               select asset.toJson();
        
        check caller->respond(assetJsonArray);
    }

    // Get specific asset by tag
    isolated resource function get assets/[string assetTag](http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets/" + assetTag + " - Fetching specific asset");
        
        models:Asset|error assetResult = repo.getAsset(assetTag);
        
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

    // Update asset
    isolated resource function put assets/[string assetTag](http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + " - Updating asset");
        
        json payload = check req.getJsonPayload();
        models:Asset asset = check payload.cloneWithType();
        models:Asset|error updated = repo.updateAsset(assetTag, asset);
        
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

    // Delete asset
    isolated resource function delete assets/[string assetTag](http:Caller caller, http:Request req) returns error? {
        log:printInfo("DELETE /api/assets/" + assetTag + " - Deleting asset");
        
        error? deleteResult = repo.deleteAsset(assetTag);
        
        if deleteResult is error {
            json errorResponse = {
                "error": "Failed to delete asset",
                "assetTag": assetTag
            };
            check caller->respond(errorResponse);
            return;
        }
        
        json response = {
            "message": "Asset deleted successfully",
            "assetTag": assetTag
        };
        
        check caller->respond(response);
    }

    // Get assets by faculty
    isolated resource function get assets/faculty/[string faculty](http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets/faculty/" + faculty + " - Fetching assets by faculty");
        
        models:Asset[] assets = check repo.getAssetsByFaculty(faculty);
        json[] assetJsonArray = from models:Asset asset in assets
                               select asset.toJson();
        
        check caller->respond(assetJsonArray);
    }

    // Get overdue assets
    isolated resource function get assets/overdue(http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/assets/overdue - Fetching overdue assets");
        
        models:Asset[] assets = check repo.getAssetsWithOverdueSchedules();
        json[] assetJsonArray = from models:Asset asset in assets
                               select asset.toJson();
        
        check caller->respond(assetJsonArray);
    }

    // ------------------- Components -------------------

    isolated resource function post assets/[string assetTag]/components(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/components - Adding component");
        
        json payload = check req.getJsonPayload();
        models:Component component = check payload.cloneWithType();
        models:Asset updated = check repo.addComponent(assetTag, component);
        
        json response = {
            "message": "Component added successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function delete assets/[string assetTag]/components/[string componentId](http:Caller caller, http:Request req) returns error? {
        log:printInfo("DELETE /api/assets/" + assetTag + "/components/" + componentId + " - Removing component");
        
        models:Asset updated = check repo.removeComponent(assetTag, componentId);
        
        json response = {
            "message": "Component removed successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    // ------------------- Schedules -------------------

    isolated resource function post assets/[string assetTag]/schedules(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/schedules - Adding schedule");
        
        json payload = check req.getJsonPayload();
        models:Schedule schedule = check payload.cloneWithType();
        models:Asset updated = check repo.addSchedule(assetTag, schedule);
        
        json response = {
            "message": "Schedule added successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function put assets/[string assetTag]/schedules/[string scheduleId]/complete(http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/schedules/" + scheduleId + "/complete - Completing schedule");
        
        models:Asset updated = check repo.completeSchedule(assetTag, scheduleId);
        
        json response = {
            "message": "Schedule completed successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function delete assets/[string assetTag]/schedules/[string scheduleId](http:Caller caller, http:Request req) returns error? {
        log:printInfo("DELETE /api/assets/" + assetTag + "/schedules/" + scheduleId + " - Removing schedule");
        
        models:Asset updated = check repo.removeSchedule(assetTag, scheduleId);
        
        json response = {
            "message": "Schedule removed successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    // ------------------- Work Orders -------------------

    isolated resource function post assets/[string assetTag]/workorders(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/workorders - Adding work order");
        
        json payload = check req.getJsonPayload();
        models:WorkOrder workOrder = check payload.cloneWithType();
        models:Asset updated = check repo.addWorkOrder(assetTag, workOrder);
        
        json response = {
            "message": "Work order added successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function put assets/[string assetTag]/workorders/[string workOrderId](http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/workorders/" + workOrderId + " - Updating work order");
        
        json payload = check req.getJsonPayload();
        models:WorkOrder workOrder = check payload.cloneWithType();
        models:Asset updated = check repo.updateWorkOrder(assetTag, workOrderId, workOrder);
        
        json response = {
            "message": "Work order updated successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function put assets/[string assetTag]/workorders/[string workOrderId]/complete(http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/workorders/" + workOrderId + "/complete - Completing work order");
        
        models:Asset updated = check repo.completeWorkOrder(assetTag, workOrderId);
        
        json response = {
            "message": "Work order completed successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    // ------------------- Tasks -------------------

    isolated resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(http:Caller caller, http:Request req) returns error? {
        log:printInfo("POST /api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks - Adding task");
        
        json payload = check req.getJsonPayload();
        models:Task task = check payload.cloneWithType();
        models:Asset updated = check repo.addTask(assetTag, workOrderId, task);
        
        json response = {
            "message": "Task added successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function put assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]/complete(http:Caller caller, http:Request req) returns error? {
        log:printInfo("PUT /api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks/" + taskId + "/complete - Completing task");
        
        models:Asset updated = check repo.completeTask(assetTag, workOrderId, taskId);
        
        json response = {
            "message": "Task completed successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    isolated resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId](http:Caller caller, http:Request req) returns error? {
        log:printInfo("DELETE /api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks/" + taskId + " - Removing task");
        
        models:Asset updated = check repo.removeTask(assetTag, workOrderId, taskId);
        
        json response = {
            "message": "Task removed successfully",
            "asset": updated.toJson()
        };
        
        check caller->respond(response);
    }

    // ------------------- Health -------------------

    isolated resource function get health(http:Caller caller, http:Request req) returns error? {
        log:printInfo("GET /api/health - Health check");
        
        json response = {
            "status": "healthy",
            "service": "Asset Management API",
            "timestamp": time:utcNow()
        };
        
        check caller->respond(response);
    }
}

// Helper function to initialize repository
isolated function getAssetRepository() returns db:AssetRepository|error {
    return new(check db:getAssetCollection());
}

public function main() returns error? {
    log:printInfo("Starting Asset Management API server...");    

    log:printInfo("Asset Management API server started on port 8081");
}
