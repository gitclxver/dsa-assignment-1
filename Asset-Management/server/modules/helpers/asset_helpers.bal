import asset_management.models;

public isolated function createMutableAsset(models:Asset & readonly asset) returns models:Asset {
    models:Component[]? clonedComponents = ();
    if asset.components is models:Component[] {
        clonedComponents = asset.components.clone();
    }
    
    models:Schedule[]? clonedSchedules = ();
    if asset.schedules is models:Schedule[] {
        clonedSchedules = asset.schedules.clone();
    }
    
    models:WorkOrder[]? clonedWorkOrders = ();
    if asset.workOrders is models:WorkOrder[] {
        clonedWorkOrders = asset.workOrders.clone();
    }
    
    return {
        assetTag: asset.assetTag,
        name: asset.name,
        faculty: asset.faculty,
        department: asset.department,
        status: asset.status,
        acquiredDate: asset.acquiredDate,
        components: clonedComponents,
        schedules: clonedSchedules,
        workOrders: clonedWorkOrders
    };
}

public isolated function createMutableComponent(models:Component & readonly component) returns models:Component {
    return {
        componentId: component.componentId,
        name: component.name,
        description: component.description,
        serialNumber: component.serialNumber,
        status: component.status
    };
}

public isolated function createMutableSchedule(models:Schedule & readonly schedule) returns models:Schedule {
    return {
        scheduleId: schedule.scheduleId,
        scheduleType: schedule.scheduleType,
        frequency: schedule.frequency,
        nextDueDate: schedule.nextDueDate,
        description: schedule.description,
        status: schedule.status
    };
}

public isolated function createMutableWorkOrder(models:WorkOrder & readonly workOrder) returns models:WorkOrder {
    models:Task[]? clonedTasks = ();
    if workOrder.tasks is models:Task[] {
        clonedTasks = workOrder.tasks.clone();
    }
    
    return {
        workOrderId: workOrder.workOrderId,
        title: workOrder.title,
        description: workOrder.description,
        status: workOrder.status,
        openedDate: workOrder.openedDate,
        closedDate: workOrder.closedDate,
        tasks: clonedTasks
    };
}

public isolated function createMutableTask(models:Task & readonly task) returns models:Task {
    return {
        taskId: task.taskId,
        description: task.description,
        status: task.status,
        assignedTo: task.assignedTo,
        dueDate: task.dueDate,
        completedDate: task.completedDate
    };
}
