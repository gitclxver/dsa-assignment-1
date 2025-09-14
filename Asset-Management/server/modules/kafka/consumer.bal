import ballerinax/kafka;
import ballerina/log;
import ballerina/lang.'string as strings;

import asset_management.config;

// Kafka consumer service for asset events
kafka:ConsumerConfiguration consumerConfig = {
    topics: [config:ASSET_TOPIC, config:MAINTENANCE_TOPIC],
    groupId: "asset-consumer-group",
    offsetReset: kafka:OFFSET_RESET_EARLIEST,
    autoCommit: true
};

service kafka:Service on new kafka:Listener(kafka:DEFAULT_URL, consumerConfig) {
    
    remote function onConsumerRecord(kafka:BytesConsumerRecord[] records) returns error? {
        foreach kafka:BytesConsumerRecord 'record in records {
            string messageValue = check strings:fromBytes('record.value);
            // Access topic through the offset field's partition
            string topic = 'record.offset.partition.topic;
            
            match topic {
                config:ASSET_TOPIC => {
                    log:printInfo("Received asset event: " + messageValue);
                    // Process asset events
                    json|error eventDataResult = messageValue.fromJsonString();
                    if eventDataResult is json {
                        self.processAssetEvent(eventDataResult);
                    } else {
                        log:printError("Failed to parse asset event JSON: " + eventDataResult.message());
                    }
                }
                config:MAINTENANCE_TOPIC => {
                    log:printInfo("Received maintenance event: " + messageValue);
                    // Process maintenance events
                    json|error eventDataResult = messageValue.fromJsonString();
                    if eventDataResult is json {
                        self.processMaintenanceEvent(eventDataResult);
                    } else {
                        log:printError("Failed to parse maintenance event JSON: " + eventDataResult.message());
                    }
                }
                _ => {
                    log:printWarn("Unknown topic: " + topic);
                }
            }
        }
    }
    
    function processAssetEvent(json eventData) {
        // Implement asset event processing logic
        log:printInfo("Processing asset event: " + eventData.toString());
        
        // Extract event type and handle accordingly
        json|error eventTypeResult = eventData.eventType;
        if eventTypeResult is json && eventTypeResult is string {
            match eventTypeResult {
                "asset.created" => {
                    log:printInfo("Processing asset creation event");
                    // Handle asset creation logic
                }
                "asset.updated" => {
                    log:printInfo("Processing asset update event");
                    // Handle asset update logic
                }
                "asset.deleted" => {
                    log:printInfo("Processing asset deletion event");
                    // Handle asset deletion logic
                }
                _ => {
                    log:printWarn("Unknown asset event type: " + eventTypeResult.toString());
                }
            }
        } else {
            log:printWarn("No valid event type found in asset event");
        }
    }
    
    function processMaintenanceEvent(json eventData) {
        // Implement maintenance event processing logic
        log:printInfo("Processing maintenance event: " + eventData.toString());
        
        // Extract event type and handle accordingly
        json|error eventTypeResult = eventData.eventType;
        if eventTypeResult is json && eventTypeResult is string {
            match eventTypeResult {
                "maintenance.overdue" => {
                    log:printInfo("Processing maintenance overdue event");
                    // Handle maintenance overdue logic
                }
                "maintenance.scheduled" => {
                    log:printInfo("Processing maintenance scheduled event");
                    // Handle maintenance scheduled logic
                }
                "maintenance.completed" => {
                    log:printInfo("Processing maintenance completed event");
                    // Handle maintenance completed logic
                }
                _ => {
                    log:printWarn("Unknown maintenance event type: " + eventTypeResult.toString());
                }
            }
        } else {
            log:printWarn("No valid event type found in maintenance event");
        }
    }
}

// Function to start the Kafka consumer
public function startKafkaConsumer() returns error? {
    log:printInfo("Kafka consumer started successfully");
    return ();
}