public type Component record {|
    string componentId;
    string name;
    string description;
    string serialNumber;
    string status;
|};

public type ComponentRequest record {|
    string name;
    string description;
    string serialNumber;
    string status;
|};
