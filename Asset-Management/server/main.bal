import ballerina/log;

import asset_management.kafka; // brings in producer + consumer

public function main() returns error? {
    log:printInfo("Starting Asset Management API...");

    // Start Kafka consumer
    check kafka:startKafkaConsumer();

    log:printInfo("Asset Management API started successfully");
}
