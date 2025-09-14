import ballerina/time;

// Schedule model with validation
public type Schedule record {|
    string scheduleId;
    string scheduleType;
    string frequency;
    string|time:Date nextDueDate;
    string description;
    string status;
|};

// Schedule creation request
public type ScheduleRequest record {|
    string scheduleType;
    string frequency;
    string|time:Date nextDueDate;
    string description;
    string status;
|};
