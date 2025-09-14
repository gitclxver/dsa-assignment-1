import ballerina/http;

import asset_management.db;
import asset_management.kafka;
import asset_management.models;

listener http:Listener tasksListener = new (8084);

final db:AssetRepository tasksRepo = new (checkpanic db:getAssetCollection());

service /tasks on tasksListener {

    isolated resource function post add(http:Caller caller, http:Request req, string assetTag, string workOrderId) returns error? {
        json payload = check req.getJsonPayload();
        models:Task task = check payload.cloneWithType();

        models:Asset updated = check tasksRepo.addTask(assetTag, workOrderId, task);

        check kafka:assetProducer.sendCustomEvent("tasks", assetTag, {
            eventType: "task.added",
            assetTag,
            task: task.toJson()
        });

        check caller->respond(updated);
    }

    isolated resource function put complete(http:Caller caller, http:Request req, string assetTag, string workOrderId, string taskId) returns error? {
        
        models:Asset updated = check tasksRepo.completeTask(assetTag, workOrderId, taskId);

        models:Task? completedTask = ();
        models:WorkOrder[]? workOrdersOpt = updated.workOrders;
        if workOrdersOpt is models:WorkOrder[] {
            foreach var w in workOrdersOpt {
                if w.workOrderId == workOrderId {
                    models:Task[]? tasksOpt = w.tasks;
                    if tasksOpt is models:Task[] {
                        foreach var t in tasksOpt {
                            if t.taskId == taskId {
                                completedTask = t;
                                break;
                            }
                        }
                    }
                }
            }
        }

        if completedTask is models:Task {
            check kafka:assetProducer.sendCustomEvent("tasks", assetTag, {
                eventType: "task.completed",
                assetTag,
                completedTask: completedTask.toJson()
            });
        }

        check caller->respond(updated);
    }
}