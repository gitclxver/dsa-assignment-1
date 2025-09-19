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
