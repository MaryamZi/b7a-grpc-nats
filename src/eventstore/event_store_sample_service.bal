import ballerina/grpc;
import ballerina/log;
import ballerina/nats;

listener grpc:Listener ep = new (9000);

map<Event> eventMap = {};

service EventStore on ep {

    resource function GetEvents(grpc:Caller caller, EventFilter value) {
        // Implementation goes here.

        // You should return a EventResponse
    }

    resource function CreateEvent(grpc:Caller caller, Event value) {
        // Implementation goes here.

        // Persist data .
        persistEvent(value);

        // Publish event on NATS Streaming Server
        publishEventToNatsServer(value);

        Response response = { is_success: true, string_error: "" };
        error? err = caller->send(response);
        if (err is error) {
		    log:printError("Error sending response: ", err);
		}

		err = caller->complete();
        if (err is error) {
            log:printError("Error informing completion: ", err);
        }
    }
}

function persistEvent(Event event) {
    eventMap[event.event_id] = event;
    log:printInfo("`.persistEvent()` called for event" + event.event_id);
}

function publishEventToNatsServer(Event event) {
    log:printInfo("`.publishEventToNatsServer()` called for event" + event.event_id);

    // To Do - Improve to not do this per event.
    nats:Connection connection = new("nats://localhost:4222");
    nats:Producer producer = new(connection);
    nats:Error? result = producer->publish(event.'channel, <@untainted json> json.constructFrom(event));
    if (result is nats:Error) {
        log:printError("Error occurred while producing the message.", result);
    } else {
        log:printInfo("Message published successfully.");
    }

    result = producer.close();
    if (result is nats:Error) {
        log:printError("Error occurred while closing the logical connection", result);
    }

    result = connection.close();
    if (result is nats:Error) {
        log:printError("Error occurred while closing the connection", result);
    }
}
