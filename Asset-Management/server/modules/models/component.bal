// Component model with validation
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
