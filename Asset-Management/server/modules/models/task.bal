import ballerina/time;

public type Task record {|
    string taskId;
    string description;
    string status;
    string assignedTo;
    time:Date? dueDate;
    time:Date? completedDate;
|};

public type TaskRequest record {|
    string description;
    string assignedTo;
    time:Date? dueDate;
|};
