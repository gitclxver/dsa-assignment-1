import ballerina/log;
import ballerina/time;
import ballerinax/kafka;

import asset_management.models;
import asset_management.config;

// Kafka producer for asset events
public isolated class AssetEventProducer {
    private final kafka:Producer producer;
    
    public isolated function init() returns error? {
        kafka:ProducerConfiguration producerConfig = {
            clientId: "asset-producer",
            acks: kafka:ACKS_ALL,
            retryCount: 3
        };
        self.producer = check new (kafka:DEFAULT_URL, producerConfig);
    }
    
    public isolated function sendAssetCreated(models:Asset asset) returns error? {
        json eventPayload = {
            eventType: "asset.created",
            assetTag: asset.assetTag,
            name: asset.name,
            faculty: asset.faculty,
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:ASSET_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent asset.created event for: " + asset.assetTag);
    }
    
    public isolated function sendAssetUpdated(models:Asset asset) returns error? {
        json eventPayload = {
            eventType: "asset.updated",
            assetTag: asset.assetTag,
            name: asset.name,
            status: asset.status,
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:ASSET_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent asset.updated event for: " + asset.assetTag);
    }
    
    public isolated function sendAssetDeleted(string assetTag) returns error? {
        json eventPayload = {
            eventType: "asset.deleted",
            assetTag: assetTag,
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:ASSET_TOPIC, 
            key: assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent asset.deleted event for: " + assetTag);
    }
    
    public isolated function sendMaintenanceOverdue(models:Asset asset, models:Schedule schedule) returns error? {
        json eventPayload = {
            eventType: "maintenance.overdue",
            assetTag: asset.assetTag,
            assetName: asset.name,
            scheduleId: schedule.scheduleId,
            dueDate: schedule.nextDueDate.toJson(),
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:MAINTENANCE_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent maintenance.overdue event for asset: " + asset.assetTag);
    }
    
    public isolated function sendMaintenanceScheduled(models:Asset asset, models:Schedule schedule) returns error? {
        
        json eventPayload = {
            eventType: "maintenance.scheduled",
            assetTag: asset.assetTag,
            assetName: asset.name,
            scheduleId: schedule.scheduleId,
            scheduledDate: schedule.nextDueDate.toJson(),
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:MAINTENANCE_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent maintenance.scheduled event for asset: " + asset.assetTag);
    }
    
    public isolated function sendMaintenanceCompleted(models:Asset asset, models:Schedule schedule) returns error? {
        json eventPayload = {
            eventType: "maintenance.completed",
            assetTag: asset.assetTag,
            assetName: asset.name,
            scheduleId: schedule.scheduleId,
            completedDate: time:utcToString(time:utcNow()),
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:MAINTENANCE_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent maintenance.completed event for asset: " + asset.assetTag);
    }
    
    public isolated function sendWorkOrderCreated(models:Asset asset, models:WorkOrder workOrder) returns error? {
        json eventPayload = {
            eventType: "workorder.created",
            assetTag: asset.assetTag,
            assetName: asset.name,
            workOrderId: workOrder.workOrderId,
            description: workOrder.description,
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:ASSET_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent workorder.created event for asset: " + asset.assetTag);
    }
    
    public isolated function sendWorkOrderCompleted(models:Asset asset, models:WorkOrder workOrder) returns error? {
        json eventPayload = {
            eventType: "workorder.completed",
            assetTag: asset.assetTag,
            assetName: asset.name,
            workOrderId: workOrder.workOrderId,
            description: workOrder.description,
            timestamp: time:utcToString(time:utcNow())
        };
        check self.producer->send({
            topic: config:ASSET_TOPIC, 
            key: asset.assetTag, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent workorder.completed event for asset: " + asset.assetTag);
    }
    
    public isolated function sendCustomEvent(string topic, string key, json eventData) returns error? {

        map<json> baseEvent = eventData is map<json> ? eventData : {};
        map<json> eventPayload = {
            timestamp: time:utcToString(time:utcNow())
        };
 
        foreach var [k, v] in baseEvent.entries() {
            eventPayload[k] = v;
        }
        
        check self.producer->send({
            topic: topic, 
            key: key, 
            value: eventPayload.toJsonString()
        });
        log:printInfo("Sent custom event to topic: " + topic + " with key: " + key);
    }
    
    public isolated function close() returns error? {
        return self.producer->close();
    }

}

// Create an instance, not a listener
public final AssetEventProducer assetProducer = check new ();