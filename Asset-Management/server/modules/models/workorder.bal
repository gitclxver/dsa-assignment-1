import ballerina/time;
// WorkOrder model with validation
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