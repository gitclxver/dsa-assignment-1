import ballerina/http;
import ballerina/io;


type Component record {|
    string componentId;
    string name;
    string description;
    string status;
|};

type Schedule record {|
    string scheduleId;
    string scheduleType;
    string nextDueDate;
    string description;
|};

type Task record {|
    string taskId;
    string description;
    string status;
|};

type WorkOrder record {|
    string workOrderId;
    string status;
    string description;
    string openedDate;
    string closedDate?;
    Task[] tasks?;
|};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    Component[] components?;
    Schedule[] schedules?;
    WorkOrder[] workOrders?;
|};

// Response types
type AssetCreateResponse record {|
    string message;
    string assetTag;
|};

type GenericResponse record {|
    string message;
|};


http:Client assetClient = check new("http://localhost:8080");


public function main() returns error? {
    io:println("Asset Management Client Demo\n");

    // Assets
    check createTestAssets();
    check viewAllAssets();
    check viewByFaculty();
    check checkOverdue();
    check viewAsset("LAP-001");    
    check viewAsset("NON-EXIST");  
    check updateAssetStatus("LAP-001", "UNDER REPAIR");
    check removeAsset("PRN-001");

    // Components
    check addComponent("LAP-001", {
        componentId: "RAM-001",
        name: "16GB RAM",
        description: "DDR4 Memory",
        status: "ACTIVE"
    });
    check removeComponent("LAP-001", "RAM-001");

    // Schedules
    check addSchedule("SRV-001", {
        scheduleId: "MAINT-001",
        scheduleType: "QUARTERLY",
        nextDueDate: "2024-08-01",
        description: "Quarterly maintenance check"
    });
    check removeSchedule("SRV-001", "MAINT-001");

    // Work Orders & Tasks
    check openWorkOrder("SRV-001", {
        workOrderId: "WO-001",
        status: "OPEN",
        description: "Server reboot issue",
        openedDate: "2025-09-12",
        tasks: []
    });
    check addTask("SRV-001", "WO-001", {
        taskId: "TASK-001",
        description: "Reboot server",
        status: "PENDING"
    });
    check updateWorkOrderStatus("SRV-001", "WO-001", "CLOSED");
    check removeTask("SRV-001", "WO-001", "TASK-001");

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
            acquiredDate: "2024-01-15",
            components: [],
            schedules: [],
            workOrders: []
        },
        {
            assetTag: "SRV-001",
            name: "Database Server",
            faculty: "Computing & Informatics",
            department: "Software Engineering",
            status: "ACTIVE",
            acquiredDate: "2023-06-20",
            components: [],
            schedules: [],
            workOrders: []
        },
        {
            assetTag: "PRN-001",
            name: "3D Printer",
            faculty: "Engineering",
            department: "Mechanical Engineering",
            status: "UNDER REPAIR",
            acquiredDate: "2024-03-10",
            components: [],
            schedules: [],
            workOrders: []
        }
    ];

    foreach Asset asset in testAssets {
        AssetCreateResponse resp = check assetClient->post("/assets", asset);
        io:println("Created asset: " + resp.assetTag + " - Message: " + resp.message);
    }
}

function viewAllAssets() returns error? {
    io:println("\nViewing all assets...");
    Asset[] assets = check assetClient->get("/assets");
    io:println(assets.toJsonString());
}

function viewByFaculty() returns error? {
    io:println("\nViewing assets by faculty...");
    string facultyName = "Computing & Informatics";
    Asset[] assets = check assetClient->get("/assets/faculty/" + facultyName);
    io:println(facultyName + " assets:\n", assets.toJsonString());
}

function viewAsset(string assetTag) returns error? {
    io:println("\nViewing asset: " + assetTag);
    http:Response resp = check assetClient->get("/assets/" + assetTag);

    if resp.statusCode == 200 {
        json body = check resp.getJsonPayload(); 
        Asset asset = <Asset>body;               
        io:println("Asset found:\n", asset.toJsonString());
    } else if resp.statusCode == 404 {
        io:println("Asset with tag " + assetTag + " does not exist.");
    } else {
        io:println("Error retrieving asset: HTTP " + resp.statusCode.toString());
    }
}


function updateAssetStatus(string assetTag, string newStatus) returns error? {
    GenericResponse resp = check assetClient->put("/assets/" + assetTag + "/status", {status: newStatus});
    io:println("Updated asset status: " + resp.message);
}

function removeAsset(string assetTag) returns error? {
    GenericResponse resp = check assetClient->delete("/assets/" + assetTag);
    io:println("Remove asset response: " + resp.message);
}

//  Component Operations
function addComponent(string assetTag, Component comp) returns error? {
    GenericResponse resp = check assetClient->post("/assets/" + assetTag + "/components", comp);
    io:println("Add component response: " + resp.message);
}

function removeComponent(string assetTag, string componentId) returns error? {
    GenericResponse resp = check assetClient->delete("/assets/" + assetTag + "/components/" + componentId);
    io:println("Remove component response: " + resp.message);
}

//Schedule Operations 
function addSchedule(string assetTag, Schedule sched) returns error? {
    GenericResponse resp = check assetClient->post("/assets/" + assetTag + "/schedules", sched);
    io:println("Add schedule response: " + resp.message);
}

function removeSchedule(string assetTag, string scheduleId) returns error? {
    GenericResponse resp = check assetClient->delete("/assets/" + assetTag + "/schedules/" + scheduleId);
    io:println("Remove schedule response: " + resp.message);
}

// WorkOrder & Task Operations 
function openWorkOrder(string assetTag, WorkOrder wo) returns error? {
    GenericResponse resp = check assetClient->post("/assets/" + assetTag + "/workorders", wo);
    io:println("Open work order response: " + resp.message);
}

function updateWorkOrderStatus(string assetTag, string workOrderId, string newStatus) returns error? {
    GenericResponse resp = check assetClient->put("/assets/" + assetTag + "/workorders/" + workOrderId + "/status", {status: newStatus});
    io:println("Update work order status: " + resp.message);
}

function addTask(string assetTag, string workOrderId, Task task) returns error? {
    GenericResponse resp = check assetClient->post("/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks", task);
    io:println("Add task response: " + resp.message);
}

function removeTask(string assetTag, string workOrderId, string taskId) returns error? {
    GenericResponse resp = check assetClient->delete("/assets/" + assetTag + "/workorders/" + workOrderId + "/tasks/" + taskId);
    io:println("Remove task response: " + resp.message);
}

//  Overdue Maintenance
function checkOverdue() returns error? {
    io:println("\nChecking overdue maintenance...");
    Asset[] overdueAssets = check assetClient->get("/assets/overdue");
    io:println("Overdue assets:\n", overdueAssets.toJsonString());
}
