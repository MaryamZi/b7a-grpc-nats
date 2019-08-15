import ballerina/lang.'string;
import ballerina/log;
import ballerina/nats;
import eventstore;
import orderservice;

nats:Connection connection = new("nats://localhost:4222");

listener nats:Listener subscription = new(connection);

@nats:SubscriptionConfig {
    subject: "order-created"
}
service paymentService on subscription {

    resource function onMessage(nats:Message msg, string data) {
        string content = <string> 'string:fromBytes(msg.getData());
        json|error jsonVal = content.fromJsonString();

        if !(jsonVal is map<json>) {
            log:printError("Payload is not a JSON object");
            return;
        }

        eventstore:Event|error eventVal = eventstore:Event.constructFrom(<json> jsonVal);
        if !(eventVal is eventstore:Event) {
            log:printError("Payload does not correspond to an Event");
            return;
        }

        eventstore:Event e = <eventstore:Event> eventVal;
        string s = e.event_data;
        orderservice:OrderCreateCommand occ = <orderservice:OrderCreateCommand>
                                            orderservice:OrderCreateCommand.constructFrom(<json> s.fromJsonString());
        orderservice:OrderPaymentDebitedCommand opdc = {
            order_id: occ.order_id,
            customer_id: occ.customer_id,
            amount: occ.amount
        };
        debitPayment(opdc);
    }

    resource function onError(nats:Message msg, nats:Error err) {
        log:printError("Error occurred in data binding", err);
    }
}

function debitPayment(orderservice:OrderPaymentDebitedCommand opdc) {
    log:printInfo("`.debitPayment()` called for order ID " + opdc.order_id);
}
