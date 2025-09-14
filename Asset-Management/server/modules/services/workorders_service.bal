import ballerina/http;

import asset_management.db;
import asset_management.kafka;
import asset_management.models;

listener http:Listener workOrdersListener = new (8085);

final db:AssetRepository workOrdersRepo = new (checkpanic db:getAssetCollection());
service /workorders on workOrdersListener {

    isolated resource function post create(http:Caller caller, http:Request req, string assetTag) returns error? {
        json payload = check req.getJsonPayload();
        models:WorkOrder workOrder = check payload.cloneWithType();

        models:Asset updated = check workOrdersRepo.addWorkOrder(assetTag, workOrder);
        check kafka:assetProducer.sendWorkOrderCreated(updated, workOrder);

        check caller->respond(updated);
    }

    isolated resource function put complete(http:Caller caller, http:Request req, string assetTag, string workOrderId) returns error? {
        models:Asset updated = check workOrdersRepo.completeWorkOrder(assetTag, workOrderId);

        models:WorkOrder? completedWorkOrder = ();
        models:WorkOrder[]? workOrdersOpt = updated.workOrders;
        if workOrdersOpt is models:WorkOrder[] {
            foreach var w in workOrdersOpt {
                if w.workOrderId == workOrderId {
                    completedWorkOrder = w;
                    break;
                }
            }
        }

        if completedWorkOrder is models:WorkOrder {
            check kafka:assetProducer.sendWorkOrderCompleted(updated, completedWorkOrder);
        }

        check caller->respond(updated);
    }
}