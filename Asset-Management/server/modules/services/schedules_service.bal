import ballerina/http;

import asset_management.db;
import asset_management.kafka;
import asset_management.models;

listener http:Listener schedulesListener = new (8083);

final db:AssetRepository schedulesRepo = new (checkpanic db:getAssetCollection());

service /schedules on schedulesListener {

    isolated resource function post add(http:Caller caller, http:Request req, string assetTag) returns error? {
        json payload = check req.getJsonPayload();
        models:Schedule schedule = check payload.cloneWithType();

        models:Asset updated = check schedulesRepo.addSchedule(assetTag, schedule);
        check kafka:assetProducer.sendMaintenanceScheduled(updated, schedule);

        check caller->respond(updated);
    }

    isolated resource function put complete(http:Caller caller, http:Request req, string assetTag, string scheduleId) returns error? {
        models:Asset updated = check schedulesRepo.completeSchedule(assetTag, scheduleId);

        models:Schedule? completedSchedule = ();
        models:Schedule[]? schedulesOpt = updated.schedules;
        if schedulesOpt is models:Schedule[] {
            foreach var s in schedulesOpt {
                if s.scheduleId == scheduleId {
                    completedSchedule = s;
                    break;
                }
            }
        }

        if completedSchedule is models:Schedule {
            check kafka:assetProducer.sendMaintenanceCompleted(updated, completedSchedule);
        }

        check caller->respond(updated);
    }

    isolated resource function get overdue(http:Caller caller, http:Request req) returns error? {
        models:Asset[] overdueAssets = check schedulesRepo.getAssetsWithOverdueSchedules();
        check caller->respond(overdueAssets);
    }
}
