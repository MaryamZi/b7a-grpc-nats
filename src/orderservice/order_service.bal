import ballerina/grpc;
import ballerina/http;
import ballerina/log;
import ballerina/system;
import ballerina/time;
import eventstore;

type OrderDetails record {
    string customer_id;
    string restaurant_id;
    float amount;
    OrderItem[] order_items;
};

service orderService on new http:Listener(8080) {
	resource function createOrder(http:Caller caller, http:Request request) {
        json|error payload = request.getJsonPayload();

        if (payload is error) {
            respondInvalidOrderData(caller, <@untainted> payload);
            return;
		}

		OrderDetails|error result = OrderDetails.constructFrom(<json> payload);
        if (result is error) {
            respondInvalidOrderData(caller, <@untainted> result);
            return;
        }

        OrderDetails orderDetails = <OrderDetails> result;

		OrderCreateCommand orderCC = {
		    order_id: system:uuid(),
		    status: "Pending",
		    created_on: time:currentTime().time,
		    customer_id: orderDetails.customer_id,
		    restaurant_id: orderDetails.restaurant_id,
		    amount: orderDetails.amount,
		    order_items: orderDetails.order_items
		};

        error? createOrderResp = createOrderRpc(orderCC);
        error? respStatus = ();
        if (createOrderResp is error) {
            http:Response response = new;
            response.statusCode = 400;
            response.setJsonPayload("Error creating order: " + <@untainted> createOrderResp.toString());
            respStatus = caller->respond(response);
        } else {
            respStatus = caller->ok();
        }

        if (respStatus is error) {
            log:printError("Error notifying status", respStatus);
        }
	}
}

const event = "order-created";
const aggregate = "order";

function createOrderRpc(OrderCreateCommand occ) returns error? {
    eventstore:EventStoreBlockingClient esClient = new("http://localhost:9000");

    json|error result = json.constructFrom(occ);
    if (result is error) {
        return error("Error converting record to JSON");
    }

    json jsonResult = <json> result;
    eventstore:Event eventRec = {
        event_id: system:uuid(),
        event_type: event,
        aggregate_id: occ.order_id,
        aggregate_type: aggregate,
        event_data: jsonResult.toJsonString(),
        'channel: event
    };
    [eventstore:Response, grpc:Headers]|grpc:Error res = esClient->CreateEvent(eventRec);
    if (res is [eventstore:Response, grpc:Headers]) {
        [eventstore:Response, grpc:Headers] [resp, headers] = res;
		if (resp.is_success) {
		    log:printInfo("CreateEvent successful");
		} else {
		    log:printInfo("CreateEvent error: " + resp.string_error);
		}
	} else {
		return res;
	}
}

function respondInvalidOrderData(http:Caller caller, error errVal) {
    http:Response response = new;
    response.statusCode = 500;
    response.setJsonPayload("Error extracting order data: " + errVal.toString());
    error? err = caller->respond(response);
    if (err is error) {
        log:printError("Error notifying invalid order data", err);
    }
}



