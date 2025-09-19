import ballerina/time;
import ballerina/log;

import asset_management.models;
import asset_management.config;
import asset_management.helpers;

public isolated class AssetRepository {

    private final map<models:Asset & readonly> assets = {};

    public isolated function init() {
    }

    // Create an Asset
    public isolated function createAsset(models:Asset asset) returns models:Asset|error {
        models:Asset & readonly readonlyAsset = asset.cloneReadOnly();
        lock {
            self.assets[asset.assetTag] = readonlyAsset;
        }
        log:printInfo("Asset created: " + asset.assetTag);
        return readonlyAsset.clone();
    }

    // Get All Assets
    public isolated function getAllAssets() returns models:Asset[]|error {

        map<models:Asset & readonly> assetsCopy;
        lock {
            assetsCopy = self.assets.cloneReadOnly();
        }

        models:Asset[] result = [];
        foreach var [_, asset] in assetsCopy.entries() {
            result.push(asset.clone());
            
        }

        return result;
    }

    // Get One Asset
    public isolated function getAsset(string assetTag) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }
            return a.clone();
        }
    }

    // Update an Asset
    public isolated function updateAsset(string assetTag, models:Asset asset) returns models:Asset|error {
        models:Asset & readonly readonlyAsset = asset.cloneReadOnly();
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            self.assets[assetTag] = readonlyAsset;
        }
        log:printInfo("Asset updated: " + assetTag);
        return readonlyAsset.clone();
    }

    public isolated function deleteAsset(string assetTag) returns error? {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            _ = self.assets.remove(assetTag);
        }
        log:printInfo("Asset deleted: " + assetTag);
        return ();
    }

    // Get an Asset By Specific Faculty
    public isolated function getAssetsByFaculty(string faculty) returns models:Asset[]|error {

        map<models:Asset & readonly> assetsCopy;
        lock {
            assetsCopy = self.assets.cloneReadOnly();
        }

        models:Asset[] result = [];
        foreach var [_, asset] in assetsCopy.entries() {
            result.push(asset.clone());
        }

        return result;
    }

    // Get Assets with Overdue Schedules
    public isolated function getAssetsWithOverdueSchedules() returns models:Asset[]|error {
        time:Utc nowUtc = time:utcNow();

        map<models:Asset & readonly> assetsCopy;
        lock {
            assetsCopy = self.assets.cloneReadOnly();
        }

        models:Asset[] result = [];

        foreach var [_, asset] in assetsCopy.entries() {
        
            models:Schedule[] schedules = asset.schedules ?: [];
            boolean assetHasOverdue = false;

            foreach models:Schedule s in schedules {
                if s.status != config:SCHEDULE_ACTIVE {
                    continue;
                }

                time:Utc? dueUtc = ();

                
                time:Utc|error parsed = time:utcFromString(s.nextDueDate);
                if parsed is time:Utc {
                    dueUtc = parsed;
                } else {
                    continue;
                }
                

                if dueUtc is time:Utc {
                    time:Seconds diff = time:utcDiffSeconds(dueUtc, nowUtc);
                    if diff < 0.0d {
                        assetHasOverdue = true;
                        break;
                    }
                }
            }

            if assetHasOverdue {
                result.push(asset.clone());
                }
        }

        return result;
    }

    // Add a Component
    public isolated function addComponent(string assetTag, models:Component component) returns models:Asset|error {

        models:Asset & readonly roAsset;
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            models:Asset & readonly|() maybeAsset = self.assets[assetTag];
            if maybeAsset is () {
                return error(config:ASSET_NOT_FOUND);
            }
            roAsset = maybeAsset;
        }

        models:Asset mutableAsset = helpers:createMutableAsset(roAsset);

        models:Component[] oldComponents = mutableAsset.components ?: [];
        models:Component[] newComponents = oldComponents.clone();
        newComponents.push(component);
        mutableAsset.components = newComponents;

        models:Asset & readonly updatedAsset;
        lock {
            updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
        }

        return updatedAsset.clone();
    }

    // Remove a Component
    public isolated function removeComponent(string assetTag, string componentId) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }

            models:Asset mutableAsset = helpers:createMutableAsset(a);
            models:Component[] components = mutableAsset.components ?: [];
            models:Component[] newComps = [];
            boolean removed = false;
            
            foreach models:Component c in components {
                if c.componentId != componentId {
                    newComps.push(c);
                } else {
                    removed = true;
                }
            }
            
            if !removed {
                return error(config:COMPONENT_NOT_FOUND);
            }
            
            mutableAsset.components = newComps;
            models:Asset & readonly updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
            return updatedAsset.clone();
        }
    }
    
    // Add a Schedule
    public isolated function addSchedule(string assetTag, models:Schedule schedule) returns models:Asset|error {

        models:Asset & readonly roAsset;
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            models:Asset & readonly|() maybeAsset = self.assets[assetTag];
            if maybeAsset is () {
                return error(config:ASSET_NOT_FOUND);
            }
            roAsset = maybeAsset;
        }

        models:Asset mutableAsset = helpers:createMutableAsset(roAsset);

        models:Schedule[] oldSchedules = mutableAsset.schedules ?: [];
        models:Schedule[] newSchedules = oldSchedules.clone();
        newSchedules.push(schedule);
        mutableAsset.schedules = newSchedules;

        models:Asset & readonly updatedAsset;
        lock {
            updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
        }

        return updatedAsset.clone();
    }


    // Remove a Schedule
    public isolated function removeSchedule(string assetTag, string scheduleId) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }

            models:Asset mutableAsset = helpers:createMutableAsset(a);
            models:Schedule[] schedules = mutableAsset.schedules ?: [];
            models:Schedule[] newScheds = [];
            boolean removed = false;
            
            foreach models:Schedule s in schedules {
                if s.scheduleId != scheduleId {
                    newScheds.push(s);
                } else {
                    removed = true;
                }
            }
            
            if !removed {
                return error(config:SCHEDULE_NOT_FOUND);
            }
            
            mutableAsset.schedules = newScheds;
            models:Asset & readonly updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
            return updatedAsset.clone();
        }
    }


    // Complete a Schedule
    public isolated function completeSchedule(string assetTag, string scheduleId) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }

            models:Asset mutableAsset = helpers:createMutableAsset(a);
            models:Schedule[] schedules = mutableAsset.schedules ?: [];
            boolean updated = false;
            models:Schedule[] newScheds = [];
            
            foreach models:Schedule s in schedules {
                models:Schedule mutableSchedule = {
                    scheduleId: s.scheduleId,
                    scheduleType: s.scheduleType,
                    frequency: s.frequency,
                    nextDueDate: s.nextDueDate,
                    description: s.description,
                    status: s.scheduleId == scheduleId ? config:COMPLETED : s.status
                };
                
                if s.scheduleId == scheduleId {
                    updated = true;
                }
                newScheds.push(mutableSchedule);
            }
            
            if !updated {
                return error(config:SCHEDULE_NOT_FOUND);
            }
            
            mutableAsset.schedules = newScheds;
            models:Asset & readonly updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
            return updatedAsset.clone();
        }
    }

    // Add a Work Order
    public isolated function addWorkOrder(string assetTag, models:WorkOrder workOrder) returns models:Asset|error {
        models:Asset & readonly roAsset;
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            models:Asset & readonly|() maybeAsset = self.assets[assetTag];
            if maybeAsset is () {
                return error(config:ASSET_NOT_FOUND);
            }
            roAsset = maybeAsset;
        }

        models:Asset mutableAsset = helpers:createMutableAsset(roAsset);

        models:WorkOrder[] oldWorkOrders = mutableAsset.workOrders ?: [];
        models:WorkOrder[] newWorkOrders = oldWorkOrders.clone();
        newWorkOrders.push(workOrder);
        mutableAsset.workOrders = newWorkOrders;

        models:Asset & readonly updatedAsset;
        lock {
            updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
        }

        return updatedAsset.clone();
    }

    // Update a Work Order
    public isolated function updateWorkOrder(string assetTag, string workOrderId, models:WorkOrder workOrder) returns models:Asset|error {
        models:Asset & readonly roAsset;
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            models:Asset & readonly|() maybeAsset = self.assets[assetTag];
            if maybeAsset is () {
                return error(config:ASSET_NOT_FOUND);
            }
            roAsset = maybeAsset;
        }

        models:Asset mutableAsset = helpers:createMutableAsset(roAsset);

        models:WorkOrder[] oldWorkOrders = mutableAsset.workOrders ?: [];
        models:WorkOrder[] newWorkOrders = [];
        boolean found = false;

        foreach models:WorkOrder wo in oldWorkOrders {
            if wo.workOrderId == workOrderId {
                newWorkOrders.push(workOrder);
                found = true;
            } else {
                newWorkOrders.push(wo);
            }
        }

        if !found {
            return error(config:WORKORDER_NOT_FOUND);
        }

        mutableAsset.workOrders = newWorkOrders;

        models:Asset & readonly updatedAsset;
        lock {
            updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
        }

        return updatedAsset.clone();
    }

    //Complete a Work Order
    public isolated function completeWorkOrder(string assetTag, string workOrderId) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }

            models:Asset mutableAsset = helpers:createMutableAsset(a);
            models:WorkOrder[] workOrders = mutableAsset.workOrders ?: [];
            boolean updated = false;
            models:WorkOrder[] newWos = [];
            
            foreach models:WorkOrder wo in workOrders {
                models:Task[]? clonedTasks = ();
                if wo.tasks is models:Task[] {
                    clonedTasks = wo.tasks.clone();
                }

                models:WorkOrder mutableWo = {
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: wo.workOrderId == workOrderId ? config:COMPLETED : wo.status,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: clonedTasks
                };
                
                if wo.workOrderId == workOrderId {
                    updated = true;
                }
                newWos.push(mutableWo);
            }
            
            if !updated {
                return error(config:WORKORDER_NOT_FOUND);
            }
            
            mutableAsset.workOrders = newWos;
            models:Asset & readonly updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
            return updatedAsset.clone();
        }
    }

    // Create a Task
    public isolated function addTask(string assetTag, string workOrderId, models:Task task) returns models:Asset|error {
        models:Asset & readonly roAsset;
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            models:Asset & readonly|() maybeAsset = self.assets[assetTag];
            if maybeAsset is () {
                return error(config:ASSET_NOT_FOUND);
            }
            roAsset = maybeAsset;
        }

        models:Asset mutableAsset = helpers:createMutableAsset(roAsset);

        models:WorkOrder[] oldWorkOrders = mutableAsset.workOrders ?: [];
        models:WorkOrder[] newWorkOrders = [];
        boolean found = false;

        foreach models:WorkOrder wo in oldWorkOrders {
            models:Task[]? clonedTasks = ();
            if wo.tasks is models:Task[] {
                clonedTasks = wo.tasks.clone();
            }
            
            models:WorkOrder mutableWo = {
                workOrderId: wo.workOrderId,
                title: wo.title,
                description: wo.description,
                status: wo.status,
                openedDate: wo.openedDate,
                closedDate: wo.closedDate,
                tasks: clonedTasks
            };
            
            if wo.workOrderId == workOrderId {
                models:Task[] oldTasks = mutableWo.tasks ?: [];
                models:Task[] newTasks = oldTasks.clone();
                newTasks.push(task);
                mutableWo.tasks = newTasks;
                found = true;
            }
            newWorkOrders.push(mutableWo);
        }

        if !found {
            return error(config:WORKORDER_NOT_FOUND);
        }

        mutableAsset.workOrders = newWorkOrders;

        models:Asset & readonly updatedAsset;
        lock {
            updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
        }

        return updatedAsset.clone();
    }

    // Remove a Task
    public isolated function removeTask(string assetTag, string workOrderId, string taskId) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }

            models:Asset mutableAsset = helpers:createMutableAsset(a);
            models:WorkOrder[] workOrders = mutableAsset.workOrders ?: [];
            boolean updatedWo = false;
            models:WorkOrder[] newWos = [];
            
            foreach models:WorkOrder wo in workOrders {

                models:Task[]? clonedTasks = ();
                if wo.tasks is models:Task[] {
                    clonedTasks = wo.tasks.clone();
                }
                
                models:WorkOrder mutableWo = {
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: wo.status,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: clonedTasks
                };
                
                if wo.workOrderId == workOrderId {
                    models:Task[] tasks = mutableWo.tasks ?: [];
                    models:Task[] newTasks = [];
                    boolean removed = false;
                    
                    foreach models:Task t in tasks {
                        if t.taskId != taskId {
                            newTasks.push(t);
                        } else {
                            removed = true;
                        }
                    }
                    
                    if !removed {
                        return error(config:TASK_NOT_FOUND);
                    }
                    
                    mutableWo.tasks = newTasks;
                    updatedWo = true;
                }
                newWos.push(mutableWo);
            }
            
            if !updatedWo {
                return error(config:WORKORDER_NOT_FOUND);
            }
            
            mutableAsset.workOrders = newWos;
            models:Asset & readonly updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
            return updatedAsset.clone();
        }
    }

    // Complete a Task
    public isolated function completeTask(string assetTag, string workOrderId, string taskId) returns models:Asset|error {
        lock {
            if !self.assets.hasKey(assetTag) {
                return error(config:ASSET_NOT_FOUND);
            }
            
            models:Asset & readonly|() a = self.assets[assetTag];
            if a is () {
                return error(config:ASSET_NOT_FOUND);
            }

            models:Asset mutableAsset = helpers:createMutableAsset(a);
            models:WorkOrder[] workOrders = mutableAsset.workOrders ?: [];
            boolean updated = false;
            models:WorkOrder[] newWos = [];
            
            foreach models:WorkOrder wo in workOrders {
                models:Task[]? clonedTasks = ();
                if wo.tasks is models:Task[] {
                    clonedTasks = wo.tasks.clone();
                }
                
                models:WorkOrder mutableWo = {
                    workOrderId: wo.workOrderId,
                    title: wo.title,
                    description: wo.description,
                    status: wo.status,
                    openedDate: wo.openedDate,
                    closedDate: wo.closedDate,
                    tasks: clonedTasks
                };
                
                if wo.workOrderId == workOrderId {
                    models:Task[] tasks = mutableWo.tasks ?: [];
                    models:Task[] newTasks = [];
                    boolean foundTask = false;
                    
                    foreach models:Task t in tasks {
                        models:Task mutableTask = {
                            taskId: t.taskId,
                            description: t.description,
                            status: t.taskId == taskId ? config:COMPLETED : t.status,
                            assignedTo: t.assignedTo,
                            dueDate: t.dueDate,
                            completedDate: t.completedDate
                        };
                        
                        if t.taskId == taskId {
                            foundTask = true;
                        }
                        newTasks.push(mutableTask);
                    }
                    
                    if !foundTask {
                        return error(config:TASK_NOT_FOUND);
                    }
                    
                    mutableWo.tasks = newTasks;
                    updated = true;
                }
                newWos.push(mutableWo);
            }
            
            if !updated {
                return error(config:WORKORDER_NOT_FOUND);
            }
            
            mutableAsset.workOrders = newWos;
            models:Asset & readonly updatedAsset = mutableAsset.cloneReadOnly();
            self.assets[assetTag] = updatedAsset;
            return updatedAsset.clone();
        }
    }
}