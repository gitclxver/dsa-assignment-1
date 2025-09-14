// Constants for the application
public const string ASSET_TOPIC = "asset.events";
public const string MAINTENANCE_TOPIC = "maintenance.events";
public const string KAFKA_BROKERS = "localhost:9092";
public const string TOPIC_ASSET_CREATED = "asset.created";
public const string TOPIC_ASSET_UPDATED = "asset.updated";
public const string TOPIC_ASSET_DELETED = "asset.deleted";

// Asset status constants
public const string ACTIVE = "ACTIVE";
public const string UNDER_REPAIR = "UNDER_REPAIR";
public const string DISPOSED = "DISPOSED";

// Work order status constants
public const string OPEN = "OPEN";
public const string IN_PROGRESS = "IN_PROGRESS";
public const string COMPLETED = "COMPLETED";
public const string CLOSED = "CLOSED";

// Task status constants
public const string PENDING = "PENDING";
public const string DONE = "DONE";

// Schedule status constants
public const string SCHEDULE_ACTIVE = "ACTIVE";
public const string SCHEDULE_INACTIVE = "INACTIVE";

// Error messages
public const string ASSET_NOT_FOUND = "Asset not found";
public const string COMPONENT_NOT_FOUND = "Component not found";
public const string SCHEDULE_NOT_FOUND = "Schedule not found";
public const string WORKORDER_NOT_FOUND = "Work order not found";
public const string TASK_NOT_FOUND = "Task not found";
public const string INVALID_STATUS = "Invalid status";