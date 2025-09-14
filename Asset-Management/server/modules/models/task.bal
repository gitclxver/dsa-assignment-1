import ballerina/time;

// Task model with validation
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
