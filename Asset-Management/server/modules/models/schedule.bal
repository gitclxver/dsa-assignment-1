public type Schedule record {|
    string scheduleId;
    string scheduleType;
    string frequency;
    string nextDueDate;
    string description;
    string status;
|};

public type ScheduleRequest record {|
    string scheduleType;
    string frequency;
    string nextDueDate;
    string description;
    string status;
|};
