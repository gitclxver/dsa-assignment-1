import ballerina/http;
import ballerina/io;
import ballerina/lang.'value;
import asset_management.models;

http:Client apiClient = check new("http://localhost:8081");

public function main() returns error? {
    io:println("Asset Management Client Demo");
    
    // Test all functionality with error handling
    check createTestAssets();
    check viewAllAssets();
    check viewByFaculty();
    check viewOverdueAssets();

    
    var result = addComponentToAsset("LAP-001");
    if (result is error) {
        io:println("Component addition failed: " + result.message());
    }
    
    result = addScheduleToAsset("LAP-001");
    if (result is error) {
        io:println("Schedule addition failed: " + result.message());
    }
    
    result = createWorkOrder("LAP-001");
    if (result is error) {
        io:println("Work order creation failed: " + result.message());
    }
    
    result = addTaskToWorkOrder("LAP-001", "WO-001");
    if (result is error) {
        io:println(" Task addition failed: " + result.message());
    }

    // Update operation 
    result = updateAsset("LAP-001");
    if (result is error) {
        io:println("Asset update failed: " + result.message());
    }
    
    // Remove operations 
    result = removeComponent("LAP-001", "COMP-001");
    if (result is error) {
        io:println("Component removal failed: " + result.message());
    }
    
    result = removeSchedule("LAP-001", "SCHED-001");
    if (result is error) {
        io:println("Schedule removal failed: " + result.message());
    }
    
    // Delete operation 
    result = deleteAsset("SRV-001");
    if (result is error) {
        io:println("Asset deletion failed: " + result.message());
    }
    
    io:println("Demo completed!");
}
  

function createTestAssets() returns error? {
    io:println("1. Creating test assets...");
    
    models:Asset[] testAssets = [
        {
            assetTag: "LAP-001",
            name: "Dell Laptop",
            faculty: "Computing & Informatics",
            department: "Cyber Security",
            status: "ACTIVE",
            acquiredDate: {year: 2024, month: 1, day: 15}
        },
        {
            assetTag: "SRV-001",
            name: "Database Server",
            faculty: "Computing & Informatics",
            department: "Software Engineering",
            status: "ACTIVE",
            acquiredDate: {year: 2023, month: 6, day: 20}
        }
    ];

    foreach models:Asset asset in testAssets {
        // Convert to JSON before sending
        json assetJson = 'value:toJson(asset);
        http:Response response = check apiClient->post("/api/assets", assetJson);
      
        if (response.statusCode >= 200 && response.statusCode < 300) {
            io:println("✓ Created: " + asset.assetTag);
        } else {
            io:println("✗ Failed to create asset " + asset.assetTag + ": Status " + response.statusCode.toString());
        }
    }
    io:println();
}

function viewAllAssets() returns error? {
    io:println("2. Viewing all assets...");
    http:Response response = check apiClient->get("/api/assets");
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        if (responseBody is json[]) {
            io:println("Found " + responseBody.length().toString() + " assets:");
            foreach var asset in responseBody {
                string tag = getStringFromJson(asset, "assetTag", "N/A");
                string name = getStringFromJson(asset, "name", "N/A");
                io:println("  - " + tag + ": " + name);
            }
        }
    } else {
        io:println("Failed to view assets: Status " + response.statusCode.toString());
    }
    io:println();
}

function viewByFaculty() returns error? {
    io:println("3. Viewing assets by faculty...");
    http:Response response = check apiClient->get("/api/assets/faculty/Computing & Informatics");
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        if (responseBody is json[]) {
            io:println("Found " + responseBody.length().toString() + " assets in Computing & Informatics:");
            foreach var asset in responseBody {
                string tag = getStringFromJson(asset, "assetTag", "N/A");
                io:println("  - " + tag);
            }
        }
    } else {
        io:println("Failed to view by faculty: Status " + response.statusCode.toString());
    }
    io:println();
}

function viewOverdueAssets() returns error? {
    io:println("4. Viewing overdue assets...");
    http:Response response = check apiClient->get("/api/assets/overdue");
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        if (responseBody is json[]) {
            io:println("Found " + responseBody.length().toString() + " overdue assets");
        }
    } else {
        io:println("Failed to view overdue assets: Status " + response.statusCode.toString());
    }
    io:println();
}

function addComponentToAsset(string assetTag) returns error? {
    io:println("5. Adding component to " + assetTag);
    
    models:Component component = {
        componentId: "COMP-001",
        name: "16GB RAM Module",
        description: "DDR4 16GB RAM",
        serialNumber: "RAM001",
        status: "ACTIVE"
    };
    
    // Convert to JSON before sending
    json componentJson = 'value:toJson(component);
    http:Response response = check apiClient->post("/api/assets/" + assetTag + "/components", componentJson);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Component added successfully");
    } else {
        io:println("✗ Failed to add component: Status " + response.statusCode.toString());
        // Try to get error message from response
        json|error errorBody = response.getJsonPayload();
        if errorBody is json {
            string errorMsg = getStringFromJson(errorBody, "message", "Unknown error");
            io:println("Error: " + errorMsg);
        }
        return error("Component addition failed");
    }
    io:println();
}

function addScheduleToAsset(string assetTag) returns error? {
    io:println("6. Adding schedule to " + assetTag);
    
    models:Schedule schedule = {
        scheduleId: "SCHED-001",
        scheduleType: "MAINTENANCE",
        frequency: "MONTHLY",
        nextDueDate: "2024-12-15",
        description: "Monthly maintenance",
        status: "ACTIVE"
    };
    
    // Convert to JSON before sending
    json scheduleJson = 'value:toJson(schedule);
    http:Response response = check apiClient->post("/api/assets/" + assetTag + "/schedules", scheduleJson);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Schedule added successfully");
    } else {
        io:println("✗ Failed to add schedule: Status " + response.statusCode.toString());
        json|error errorBody = response.getJsonPayload();
        if errorBody is json {
            string errorMsg = getStringFromJson(errorBody, "message", "Unknown error");
            io:println("Error: " + errorMsg);
        }
        return error("Schedule addition failed");
    }
    io:println();
}

function createWorkOrder(string assetTag) returns error? {
    io:println("7. Creating work order for " + assetTag);
    
    models:WorkOrder workOrder = {
        workOrderId: "WO-001",
        title: "Screen Repair",
        description: "Replace screen",
        status: "OPEN",
        openedDate: {year: 2024, month: 9, day: 17},
        closedDate: ()
    };
    
    // Convert to JSON before sending
    json workOrderJson = 'value:toJson(workOrder);
    http:Response response = check apiClient->post("/api/assets/" + assetTag + "/workorders", workOrderJson);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Work order created successfully");
    } else {
        io:println("✗ Failed to create work order: Status " + response.statusCode.toString());
        json|error errorBody = response.getJsonPayload();
        if errorBody is json {
            string errorMsg = getStringFromJson(errorBody, "message", "Unknown error");
            io:println("Error: " + errorMsg);
        }
        return error("Work order creation failed");
    }
    io:println();
}

function addTaskToWorkOrder(string assetTag, string workOrderId) returns error? {
    io:println("8. Adding task to work order");
    
    models:Task task = {
        taskId: "TASK-001",
        description: "Remove old screen",
        status: "PENDING",
        assignedTo: "Pandu Technician",
        dueDate: {year: 2024, month: 9, day: 20},
        completedDate: ()
    };
    
    // Convert to JSON before sending
    json taskJson = 'value:toJson(task);
    http:Response response = check apiClient->post("/api/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks", taskJson);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Task added successfully");
    } else {
        io:println("✗ Failed to add task: Status " + response.statusCode.toString());
        json|error errorBody = response.getJsonPayload();
        if errorBody is json {
            string errorMsg = getStringFromJson(errorBody, "message", "Unknown error");
            io:println("Error: " + errorMsg);
        }
        return error("Task addition failed");
    }
    io:println();
}

// Helper function to safely extract string values from JSON
function getStringFromJson(json jsonData, string fieldName, string defaultValue) returns string {
    if jsonData is map<json> {
        json fieldValue = jsonData[fieldName];
        if fieldValue is string {
            return fieldValue;
        }
    }
    return defaultValue;
}

// Update an asset
function updateAsset(string assetTag) returns error? {
    io:println("9. Updating asset: " + assetTag);
    
    // First get the existing asset
    http:Response getResponse = check apiClient->get("/api/assets/" + assetTag);
    if (getResponse.statusCode != 200) {
        io:println("✗ Cannot update - asset not found: " + assetTag);
        return;
    }
    
    // Create updated asset data
    models:Asset updatedAsset = {
        assetTag: assetTag,
        name: "Updated Dell Laptop Pro",
        faculty: "Computing & Informatics", 
        department: "Cyber Security",
        status: "UNDER_REPAIR", 
        acquiredDate: {year: 2024, month: 1, day: 15}
    };
    
    json assetJson = 'value:toJson(updatedAsset);
    http:Response response = check apiClient->put("/api/assets/" + assetTag, assetJson);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Asset updated successfully");
    } else {
        io:println("✗ Failed to update asset: Status " + response.statusCode.toString());
    }
    io:println();
}

// Remove a component
function removeComponent(string assetTag, string componentId) returns error? {
    io:println("10. Removing component " + componentId + " from " + assetTag);
    
    http:Response response = check apiClient->delete("/api/assets/" + assetTag + "/components/" + componentId);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Component removed successfully");
    } else {
        io:println("✗ Failed to remove component: Status " + response.statusCode.toString());
    }
    io:println();
}

// Remove a schedule
function removeSchedule(string assetTag, string scheduleId) returns error? {
    io:println("11. Removing schedule " + scheduleId + " from " + assetTag);
    
    http:Response response = check apiClient->delete("/api/assets/" + assetTag + "/schedules/" + scheduleId);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Schedule removed successfully");
    } else {
        io:println("✗ Failed to remove schedule: Status " + response.statusCode.toString());
    }
    io:println();
}

// Delete an asset
function deleteAsset(string assetTag) returns error? {
    io:println("12. Deleting asset: " + assetTag);
    
    http:Response response = check apiClient->delete("/api/assets/" + assetTag);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
        io:println("✓ Asset deleted successfully");
    } else {
        io:println("✗ Failed to delete asset: Status " + response.statusCode.toString());
    }
    io:println();
}
