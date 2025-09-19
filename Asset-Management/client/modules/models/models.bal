import ballerina/time;

public type Asset record {|
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

public type Component record {|
    string componentId;
    string name;
    string description;
    string serialNumber;
    string status;
|};

// Component creation request
public type ComponentRequest record {|
    string name;
    string description;
    string serialNumber;
    string status;
|};

public type Schedule record {|
    string scheduleId;
    string scheduleType;
    string frequency;
    string nextDueDate;
    string description;
    string status;
|};

// Schedule creation request
public type ScheduleRequest record {|
    string scheduleType;
    string frequency;
    string nextDueDate;
    string description;
    string status;
|};

public type Task record {|
    string taskId;
    string description;
    string status;
    string assignedTo;
    time:Date? dueDate;
    time:Date? completedDate;
|};

// Task creation request
public type TaskRequest record {|
    string description;
    string assignedTo;
    time:Date? dueDate;
|};

public type WorkOrder record {|
    string workOrderId;
    string title;
    string description;
    string status;
    time:Date openedDate;
    time:Date? closedDate;
    Task[] tasks?;
|};

// WorkOrder creation request
public type WorkOrderRequest record {|
    string title;
    string description;
    string status;
|};

// Response types
public type AssetCreateResponse record {|
    string message;
    Asset asset;
|};

public type GenericResponse record {|
    string message;
|};