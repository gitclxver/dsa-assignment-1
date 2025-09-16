import ballerina/http;
import ballerina/io;
import ballerina/time;

type Component record {|
    string componentId;
    string name;
    string description;
    string serialNumber;
    string status;
|};

type ComponentRequest record {|
    string name;
    string description;
    string serialNumber;
    string status;
|};

type Schedule record {|
    string scheduleId;
    string scheduleType;
    string frequency;
    string|time:Date nextDueDate;
    string description;
    string status;
|};

type ScheduleRequest record {|
    string scheduleType;
    string frequency;
    string|time:Date nextDueDate;
    string description;
    string status;
|};

type Task record {|
    string taskId;
    string description;
    string status;
    string assignedTo;
    time:Date? dueDate;
    time:Date? completedDate;
|};

type TaskRequest record {|
    string description;
    string assignedTo;
    time:Date? dueDate;
|};

type WorkOrder record {|
    string workOrderId;
    string title;
    string description;
    string status;
    time:Date openedDate;
    time:Date? closedDate;
    Task[] tasks?;
|};

type WorkOrderRequest record {|
    string title;
    string description;
    string status;
|};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    time:Date acquiredDate;
    Component[] components?;
    Schedule[] schedules?;
    WorkOrder[] workOrders?;
|};

// Response types
type AssetCreateResponse record {|
    string message;
    Asset asset;
|};

type GenericResponse record {|
    string message;
|};

// HTTP Clients for different services
http:Client assetsClient = check new("http://localhost:8081");
http:Client componentsClient = check new("http://localhost:8082");
http:Client schedulesClient = check new("http://localhost:8083");
http:Client tasksClient = check new("http://localhost:8084");
http:Client workOrdersClient = check new("http://localhost:8085");

public function main() returns error? {
    io:println("Asset Management Client Demo\n");

    // Test Assets
    check createTestAssets();
    check viewAllAssets();
    check viewByFaculty();
    check viewOverdueAssets();

    // Test Components
    check addComponentToAsset("LAP-001");
    check removeComponentFromAsset("LAP-001", "COMP-001");

    // Test Schedules
    check addScheduleToAsset("LAP-001");
    check completeSchedule("LAP-001", "SCHED-001");

    // Test Work Orders and Tasks
    check createWorkOrder("LAP-001");
    check addTaskToWorkOrder("LAP-001", "WO-001");
    check completeTask("LAP-001", "WO-001", "TASK-001");
    check completeWorkOrder("LAP-001", "WO-001");

    // Test overdue schedules
    check viewOverdueSchedules();

    io:println("\nDemo completed!");
}

//Asset Operations 
function createTestAssets() returns error? {
    io:println("1. Creating test assets...");
    
    Asset[] testAssets = [
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
        },
        {
            assetTag: "PRN-001",
            name: "3D Printer",
            faculty: "Engineering",
            department: "Mechanical Engineering",
            status: "UNDER REPAIR",
            acquiredDate: {year: 2024, month: 3, day: 10}
        }
    ];

    foreach Asset asset in testAssets {
        http:Response response = check assetsClient->post("/assets/create", asset);
        if (response.statusCode == 200) {
            json responseBody = check response.getJsonPayload();
            AssetCreateResponse createResponse = <AssetCreateResponse>responseBody;
            io:println("✓ Created asset: " + asset.assetTag + " - " + createResponse.message);
        } else {
            io:println("✗ Failed to create asset: " + asset.assetTag);
        }
    }
    io:println();
}

function viewAllAssets() returns error? {
    io:println("2. Viewing all assets...");
    http:Response response = check assetsClient->get("/assets/list");
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        Asset[] assets = <Asset[]>responseBody;
        io:println("Found " + assets.length().toString() + " assets:");
        foreach Asset asset in assets {
            io:println("  - " + asset.assetTag + ": " + asset.name + " (" + asset.status + ")");
        }
    } else {
        io:println("✗ Failed to retrieve assets");
    }
    io:println();
}

function viewByFaculty() returns error? {
    io:println("3. Viewing assets by faculty...");
    string facultyName = "Computing & Informatics";
    
    http:Response response = check assetsClient->get("/assets/byFaculty/" + facultyName);
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        Asset[] assets = <Asset[]>responseBody;
        io:println("Assets in " + facultyName + ":");
        foreach Asset asset in assets {
            io:println("  - " + asset.assetTag + ": " + asset.name);
        }
    } else {
        io:println("✗ Failed to retrieve assets by faculty");
    }
    io:println();
}

function viewOverdueAssets() returns error? {
    io:println("4. Viewing overdue assets...");
    http:Response response = check assetsClient->get("/assets/overdue");
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        Asset[] assets = <Asset[]>responseBody;
        io:println("Found " + assets.length().toString() + " overdue assets:");
        foreach Asset asset in assets {
            io:println("  - " + asset.assetTag + ": " + asset.name);
        }
    } else {
        io:println("✗ Failed to retrieve overdue assets");
    }
    io:println();
}

// Component Operations
function addComponentToAsset(string assetTag) returns error? {
    io:println("5. Adding component to asset: " + assetTag);
    
    ComponentRequest componentReq = {
        name: "16GB RAM Module",
        description: "DDR4 16GB RAM for laptop upgrade",
        serialNumber: "RAM16GB001",
        status: "ACTIVE"
    };
    
    Component component = {
        componentId: "COMP-001",
        name: componentReq.name,
        description: componentReq.description,
        serialNumber: componentReq.serialNumber,
        status: componentReq.status
    };
    
    http:Response response = check componentsClient->post("/components/add/" + assetTag, component);
    
    if (response.statusCode == 200) {
        io:println("✓ Component added successfully to " + assetTag);
    } else {
        io:println("✗ Failed to add component to " + assetTag);
    }
    io:println();
}

function removeComponentFromAsset(string assetTag, string componentId) returns error? {
    io:println("6. Removing component from asset: " + assetTag);
    
    http:Response response = check componentsClient->delete("/components/remove/" + assetTag + "/" + componentId);
    
    if (response.statusCode == 200) {
        io:println("✓ Component removed successfully from " + assetTag);
    } else {
        io:println("✗ Failed to remove component from " + assetTag);
    }
    io:println();
}

//Schedule Operations
function addScheduleToAsset(string assetTag) returns error? {
    io:println("7. Adding schedule to asset: " + assetTag);
    
    Schedule schedule = {
        scheduleId: "SCHED-001",
        scheduleType: "MAINTENANCE",
        frequency: "MONTHLY",
        nextDueDate: {year: 2024, month: 12, day: 15},
        description: "Monthly maintenance check",
        status: "ACTIVE"
    };
    
    http:Response response = check schedulesClient->post("/schedules/add/" + assetTag, schedule);
    
    if (response.statusCode == 200) {
        io:println("✓ Schedule added successfully to " + assetTag);
    } else {
        io:println("✗ Failed to add schedule to " + assetTag);
    }
    io:println();
}

function completeSchedule(string assetTag, string scheduleId) returns error? {
    io:println("8. Completing schedule: " + scheduleId + " for asset: " + assetTag);
    
    http:Response response = check schedulesClient->put("/schedules/complete/" + assetTag + "/" + scheduleId, {});
    
    if (response.statusCode == 200) {
        io:println("✓ Schedule completed successfully");
    } else {
        io:println("✗ Failed to complete schedule");
    }
    io:println();
}

function viewOverdueSchedules() returns error? {
    io:println("9. Viewing overdue schedules...");
    
    http:Response response = check schedulesClient->get("/schedules/overdue");
    
    if (response.statusCode == 200) {
        json responseBody = check response.getJsonPayload();
        Asset[] assets = <Asset[]>responseBody;
        io:println("Assets with overdue schedules:");
        foreach Asset asset in assets {
            io:println("  - " + asset.assetTag + ": " + asset.name);
        }
    } else {
        io:println("✗ Failed to retrieve overdue schedules");
    }
    io:println();
}

//Work Order Operations
function createWorkOrder(string assetTag) returns error? {
    io:println("10. Creating work order for asset: " + assetTag);
    
    WorkOrder workOrder = {
        workOrderId: "WO-001",
        title: "Laptop Screen Repair",
        description: "Replace cracked laptop screen",
        status: "OPEN",
        openedDate: {year: 2024, month: 9, day: 15},
        closedDate: ()
    };
    
    http:Response response = check workOrdersClient->post("/workorders/create/" + assetTag, workOrder);
    
    if (response.statusCode == 200) {
        io:println("✓ Work order created successfully for " + assetTag);
    } else {
        io:println("✗ Failed to create work order for " + assetTag);
    }
    io:println();
}

function completeWorkOrder(string assetTag, string workOrderId) returns error? {
    io:println("11. Completing work order: " + workOrderId + " for asset: " + assetTag);
    
    http:Response response = check workOrdersClient->put("/workorders/complete/" + assetTag + "/" + workOrderId, {});
    
    if (response.statusCode == 200) {
        io:println("✓ Work order completed successfully");
    } else {
        io:println("✗ Failed to complete work order");
    }
    io:println();
}

//Task Operations
function addTaskToWorkOrder(string assetTag, string workOrderId) returns error? {
    io:println("12. Adding task to work order: " + workOrderId + " for asset: " + assetTag);
    
    Task task = {
        taskId: "TASK-001",
        description: "Remove old screen and install new one",
        status: "PENDING",
        assignedTo: "Pandu Technician",
        dueDate: {year: 2024, month: 9, day: 20},
        completedDate: () 
    };
    
    http:Response response = check tasksClient->post("/tasks/add/" + assetTag + "/" + workOrderId, task);
    
    if (response.statusCode == 200) {
        io:println("✓ Task added successfully to work order");
    } else {
        io:println("✗ Failed to add task to work order");
    }
    io:println();
}

function completeTask(string assetTag, string workOrderId, string taskId) returns error? {
    io:println("13. Completing task: " + taskId + " for work order: " + workOrderId);
    
    http:Response response = check tasksClient->put("/tasks/complete/" + assetTag + "/" + workOrderId + "/" + taskId, {});
    
    if (response.statusCode == 200) {
        io:println("✓ Task completed successfully");
    } else {
        io:println("✗ Failed to complete task");
    }
    io:println();
}