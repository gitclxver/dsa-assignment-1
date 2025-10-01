import ballerina/time;
import ballerina/log;

// Records Basically How Our data is Stored within the Local Database
public type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    time:Date acquiredDate;
    Component[] components?;
    Schedule[] schedules?;
    WorkOrder[] workOrders?;
};

public type Component record {
    string componentId;
    string name;
    string description;
    string serialNumber;
    string status;
};

public type ComponentRequest record {
    string name;
    string description;
    string serialNumber;
    string status;
};

public type Schedule record {
    string scheduleId;
    string scheduleType;
    string frequency;
    string nextDueDate;
    string description;
    string status;
};

public type ScheduleRequest record {
    string scheduleType;
    string frequency;
    string nextDueDate;
    string description;
    string status;
};

public type Task record {
    string taskId;
    string description;
    string status;
    string assignedTo;
    time:Date? dueDate;
    time:Date? completedDate;
};

public type TaskRequest record {
    string description;
    string assignedTo;
    time:Date? dueDate;
};

public type WorkOrder record {
    string workOrderId;
    string title;
    string description;
    string status;
    time:Date openedDate;
    time:Date? closedDate;
    Task[] tasks?;
};

public type WorkOrderRequest record {
    string title;
    string description;
    string status;
};



public const ASSET_NOT_FOUND = "AssetNotFound";
public const ASSET_ALREADY_EXISTS = "AssetAlreadyExists";
public const COMPONENT_NOT_FOUND = "ComponentNotFound";
public const SCHEDULE_NOT_FOUND = "ScheduleNotFound";
public const WORKORDER_NOT_FOUND = "WorkOrderNotFound";
public const TASK_NOT_FOUND = "TaskNotFound";
public const ASSET_TAG_MISMATCH = "AssetTagMismatch";

public const SCHEDULE_ACTIVE = "ACTIVE";
public const COMPLETED = "COMPLETED";

public class AssetRepository {

    private final map<Asset> assets = {};

    public function init() {
    }

    // Create an Asset
    //Takes in Asset Object 

    public function createAsset(Asset asset) returns Asset|error{

        // Check if the assetTag exists
        if self.assets.hasKey(asset.assetTag) {
            // Throw Error
            return error(ASSET_ALREADY_EXISTS);
        }
        
        // If Not Exist this will add the asset object to the self.assets map by cloning it using the .clone() method
        self.assets[asset.assetTag] = asset.clone();
        log:printInfo("Asset created: " + asset.assetTag);
        // Returns a copy of the asset object
        return asset.clone();
    }


    // Get All Assets
    // Returns an Array of Asset objects
    public function getAllAssets() returns Asset[] {
        Asset[] result = [];
        // Foreach loop to iterate over all entries of the self.assets map
        foreach var [_, asset] in self.assets.entries() {
            // For each entry it clones the asset Object and adds it to the result array
            result.push(asset.clone());
        }
        // Returns the result array
        return result;
    }

    // Get One Asset
    public function getAsset(string assetTag) returns Asset|error {
        //Try to retrieve an asset from the map using the assetTag 
        Asset? maybeAsset = self.assets[assetTag];

        //If not found then an error is printed 
        if maybeAsset is (){
            return error(ASSET_NOT_FOUND);
        }
        
        //If the asset is found the asset object is cloned and that is returned

        return maybeAsset.clone();
    }

    // Update an Asset
    public function updateAsset(string assetTag, Asset asset) returns Asset|error {
        //
        Asset? maybeAsset = self.assets[assetTag];

        //Check if exists    
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        //Check if assetTags Match
        if assetTag != asset.assetTag {
            return error(ASSET_TAG_MISMATCH);
        }

        // Clone existing asset to preserve components, schedules, workOrders
        Asset existingAsset = maybeAsset.clone();

        // Update only top-level fields
        existingAsset.name = asset.name;
        existingAsset.faculty = asset.faculty;
        existingAsset.department = asset.department;
        existingAsset.status = asset.status;
        existingAsset.acquiredDate = asset.acquiredDate;

        // Update the self.assets with the updated existingAsset object
        self.assets[assetTag] = existingAsset;
        log:printInfo("Asset updated: " + assetTag);
        return existingAsset.clone();
    }

    public function deleteAsset(string assetTag) returns error? {
        // Check if asset exists
        if !self.assets.hasKey(assetTag) {
            return error(ASSET_NOT_FOUND);
        }
        // Remove asset from self.assets map using the remove method '_' used to discard the return value 
        _ = self.assets.remove(assetTag);
        log:printInfo("Asset deleted: " + assetTag);
        return;
    }

    // Get an Asset By Specific Faculty
    public function getAssetsByFaculty(string faculty) returns Asset[] {
        // Empty results array to store entries
        Asset[] result = [];
        foreach var [_, asset] in self.assets.entries() {
            //Checks if the faculty property of the asset object matches the provided parameter
            if asset.faculty == faculty {
                //if there is a match then a clone is added to the result array
                result.push(asset.clone());
            }
        }
        return result;
    }

    // Get Assets with Overdue Schedules
    public function getAssetsWithOverdueSchedules() returns Asset[] {
        
        string currentUtcString = time:utcNow().toString();
        string currentDateStr = currentUtcString.substring(0, 10);

        Asset[] result = [];

        foreach var [_, asset] in self.assets.entries() {
            Schedule[] schedules = asset.schedules ?: [];
            boolean hasOverdue = false;
            //Time comparison 
            foreach Schedule s in schedules {
                if s.status == SCHEDULE_ACTIVE && s.nextDueDate < currentDateStr {
                    hasOverdue = true;
                    break;
                }
            }
            // If hasOverDue is true then the asset is cloned and pushed to the results array
            if hasOverdue {
                result.push(asset.clone());
            }
        }
        return result;
    }

    // Add a Component
    public function addComponent(string assetTag, Component component) returns Asset|error {
        Asset? maybeAsset = self.assets[assetTag];

        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        Component[] components = asset.components ?: [];
    
        components.push(component);
        asset.components = components;

        self.assets[assetTag] = asset;
        return asset.clone();
    }


    // Remove a Component
    public function removeComponent(string assetTag, string componentId) returns Asset|error {
        Asset? maybeAsset = self.assets[assetTag];

        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        Component[] components = asset.components ?: [];
        
        Component[] newComponents = components.filter(component => component.componentId != componentId);
        
        if newComponents.length() == components.length() {
            return error(COMPONENT_NOT_FOUND);
        }

        asset.components = newComponents;
        self.assets[assetTag] = asset;
        return asset.clone();
    }
    
    // Add a Schedule
    public function addSchedule(string assetTag, Schedule schedule) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        Schedule[] schedules = asset.schedules ?: [];
        schedules.push(schedule);
        asset.schedules = schedules;

        self.assets[assetTag] = asset;
        return asset.clone();
    }



    // Remove a Schedule
    public function removeSchedule(string assetTag, string scheduleId) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];

        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        Schedule[] schedules = asset.schedules ?: [];
     

        Schedule[] newSchedules = schedules.filter(schedule => schedule.scheduleId != scheduleId);
        
        if newSchedules.length() == schedules.length() {
            return error(SCHEDULE_NOT_FOUND);
        }

        asset.schedules = newSchedules;
        self.assets[assetTag] = asset;
        return asset.clone();
    }


    // Complete a Schedule
    public function completeSchedule(string assetTag, string scheduleId) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];

        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        Schedule[] schedules = asset.schedules ?: [];
        
        boolean found = false;
        Schedule[] newSchedules = [];
        
        foreach var schedule in schedules {
            if schedule.scheduleId == scheduleId {
                newSchedules.push({
                    scheduleId: schedule.scheduleId,
                    scheduleType: schedule.scheduleType,
                    frequency: schedule.frequency,
                    nextDueDate: schedule.nextDueDate,
                    description: schedule.description,
                    status: COMPLETED
                });
                found = true;
            } else {
                newSchedules.push(schedule);
            }
        }

        if !found {
            return error(SCHEDULE_NOT_FOUND);
        }

        asset.schedules = newSchedules;
        self.assets[assetTag] = asset;
        return asset.clone();
    }

    // Add a Work Order
    public function addWorkOrder(string assetTag, WorkOrder workOrder) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];

        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        WorkOrder[] workOrders = asset.workOrders ?: [];
        workOrders.push(workOrder);
        asset.workOrders = workOrders;

        self.assets[assetTag] = asset;
        return asset.clone();
    }

    // Update a Work Order
    public function updateWorkOrder(string assetTag, string workOrderId, WorkOrder workOrder) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];
        
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        WorkOrder[] workOrders = asset.workOrders ?: [];
        
        boolean found = false;
        WorkOrder[] newWorkOrders = [];
        
        foreach var wo in workOrders {
            if wo.workOrderId == workOrderId {
                newWorkOrders.push(workOrder);
                found = true;
            } else {
                newWorkOrders.push(wo);
            }
        }

        if !found {
            return error(WORKORDER_NOT_FOUND);
        }

        asset.workOrders = newWorkOrders;
        self.assets[assetTag] = asset;
        return asset.clone();
    }

    //Complete a Work Order
    public function completeWorkOrder(string assetTag, string workOrderId) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];
        
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        WorkOrder[] workOrders = asset.workOrders ?: [];
        
        boolean found = false;
        WorkOrder[] newWorkOrders = [];
        
        foreach var wo in workOrders {
            if wo.workOrderId == workOrderId {
                newWorkOrders.push({
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: COMPLETED,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: wo.tasks
                });
                found = true;
            } else {
                newWorkOrders.push(wo);
            }
        }

        if !found {
            return error(WORKORDER_NOT_FOUND);
        }

        asset.workOrders = newWorkOrders;
        self.assets[assetTag] = asset;
        return asset.clone();
    }

    // Create a Task
    public function addTask(string assetTag, string workOrderId, Task task) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];
        
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        WorkOrder[] workOrders = asset.workOrders ?: [];
        
        boolean found = false;
        WorkOrder[] newWorkOrders = [];
        
        foreach var wo in workOrders {
            if wo.workOrderId == workOrderId {
                Task[] tasks = wo.tasks ?: [];
                tasks.push(task);
                newWorkOrders.push({
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: wo.status,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: tasks
                });
                found = true;
            } else {
                newWorkOrders.push(wo);
            }
        }

        if !found {
            return error(WORKORDER_NOT_FOUND);
        }

        asset.workOrders = newWorkOrders;
        self.assets[assetTag] = asset;
        return asset.clone();
    }

    // Remove a Task
    public function removeTask(string assetTag, string workOrderId, string taskId) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];
        
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        WorkOrder[] workOrders = asset.workOrders ?: [];
        
        boolean foundWo = false;
        boolean foundTask = false;
        WorkOrder[] newWorkOrders = [];
        
        foreach var wo in workOrders {
            if wo.workOrderId == workOrderId {
                foundWo = true;
                Task[] tasks = wo.tasks ?: [];
                Task[] newTasks = tasks.filter(task => task.taskId != taskId);
                
                if newTasks.length() < tasks.length() {
                    foundTask = true;
                }
                
                newWorkOrders.push({
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: wo.status,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: newTasks
                    });
            } else {
                newWorkOrders.push(wo);
            }
        }

        if !foundWo {
            return error(WORKORDER_NOT_FOUND);
        }
        if !foundTask {
            return error(TASK_NOT_FOUND);
        }

        asset.workOrders = newWorkOrders;
        self.assets[assetTag] = asset;
        return asset.clone();
    }

    // Complete a Task
    public function completeTask(string assetTag, string workOrderId, string taskId) returns Asset|error {
        
        Asset? maybeAsset = self.assets[assetTag];
        
        if maybeAsset is () {
            return error(ASSET_NOT_FOUND);
        }

        Asset asset = maybeAsset.clone();
        WorkOrder[] workOrders = asset.workOrders ?: [];
        
        boolean foundWo = false;
        boolean foundTask = false;
        WorkOrder[] newWorkOrders = [];
        
        foreach var wo in workOrders {
            if wo.workOrderId == workOrderId {
                foundWo = true;
                Task[] tasks = wo.tasks ?: [];
                Task[] newTasks = [];
                
                foreach var task in tasks {
                    if task.taskId == taskId {
                        newTasks.push({
                            taskId: task.taskId,
                            description: task.description,
                            status: COMPLETED,
                            assignedTo: task.assignedTo,
                            dueDate: task.dueDate,
                            completedDate: task.completedDate
                        });
                        foundTask = true;
                    } else {
                        newTasks.push(task);
                        }
                }
                
                newWorkOrders.push({
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: wo.status,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: newTasks
                });
            } else {
                newWorkOrders.push(wo);
            }
        }

        if !foundWo {
            return error(WORKORDER_NOT_FOUND);
        }
        if !foundTask {
            return error(TASK_NOT_FOUND);
        }

        asset.workOrders = newWorkOrders;
        self.assets[assetTag] = asset;
        return asset.clone();
    }
}