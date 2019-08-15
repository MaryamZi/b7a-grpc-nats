import ballerina/grpc;
import ballerina/io;

public type EventStoreBlockingClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config);
        grpc:Error? result = c.initStub(self, "blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is grpc:Error) {
            error err = result;
            panic err;
        } else {
            self.grpcClient = c;
        }
    }


    public remote function GetEvents(EventFilter req, grpc:Headers? headers = ()) returns ([EventResponse, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("pb.EventStore/GetEvents", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        var value = typedesc<EventResponse>.constructFrom(result);
        if (value is EventResponse) {
            return [value, resHeaders];
        } else {
            return grpc:prepareError(grpc:INTERNAL_ERROR, "Error while constructing the message", value);
        }
    }

    public remote function CreateEvent(Event req, grpc:Headers? headers = ()) returns ([Response, grpc:Headers]|grpc:Error) {
        
        var payload = check self.grpcClient->blockingExecute("pb.EventStore/CreateEvent", req, headers);
        grpc:Headers resHeaders = new;
        anydata result = ();
        [result, resHeaders] = payload;
        var value = typedesc<Response>.constructFrom(result);
        if (value is Response) {
            return [value, resHeaders];
        } else {
            return grpc:prepareError(grpc:INTERNAL_ERROR, "Error while constructing the message", value);
        }
    }

};

public type EventStoreClient client object {

    *grpc:AbstractClientEndpoint;

    private grpc:Client grpcClient;

    public function __init(string url, grpc:ClientEndpointConfig? config = ()) {
        // initialize client endpoint.
        grpc:Client c = new(url, config);
        grpc:Error? result = c.initStub(self, "non-blocking", ROOT_DESCRIPTOR, getDescriptorMap());
        if (result is grpc:Error) {
            error err = result;
            panic err;
        } else {
            self.grpcClient = c;
        }
    }


    public remote function GetEvents(EventFilter req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("pb.EventStore/GetEvents", req, msgListener, headers);
    }

    public remote function CreateEvent(Event req, service msgListener, grpc:Headers? headers = ()) returns (grpc:Error?) {
        
        return self.grpcClient->nonBlockingExecute("pb.EventStore/CreateEvent", req, msgListener, headers);
    }

};

public type Event record {|
    string event_id;
    string event_type;
    string aggregate_id;
    string aggregate_type;
    string event_data;
    string 'channel; // manually changed

|};


public type Response record {|
    boolean is_success;
    string string_error;
    
|};


type EventFilter record {|
    string event_id;
    string aggregate_id;
    
|};


type EventResponse record {|
    Event[] event_events;
    
|};



const string ROOT_DESCRIPTOR = "0A116576656E745F73746F72652E70726F746F1202706222C4010A054576656E7412190A086576656E745F696418012001280952076576656E744964121D0A0A6576656E745F7479706518022001280952096576656E745479706512210A0C6167677265676174655F6964180320012809520B616767726567617465496412250A0E6167677265676174655F74797065180420012809520D61676772656761746554797065121D0A0A6576656E745F6461746118052001280952096576656E744461746112180A076368616E6E656C18062001280952076368616E6E656C223F0A08526573706F6E7365121D0A0A69735F73756363657373180120012808520969735375636365737312140A056572726F7218022001280952056572726F72224B0A0B4576656E7446696C74657212190A086576656E745F696418012001280952076576656E74496412210A0C6167677265676174655F6964180220012809520B616767726567617465496422320A0D4576656E74526573706F6E736512210A066576656E747318012003280B32092E70622E4576656E7452066576656E747332690A0A4576656E7453746F726512310A094765744576656E7473120F2E70622E4576656E7446696C7465721A112E70622E4576656E74526573706F6E7365220012280A0B4372656174654576656E7412092E70622E4576656E741A0C2E70622E526573706F6E73652200620670726F746F33";
function getDescriptorMap() returns map<string> {
    return {
        "event_store.proto":"0A116576656E745F73746F72652E70726F746F1202706222C4010A054576656E7412190A086576656E745F696418012001280952076576656E744964121D0A0A6576656E745F7479706518022001280952096576656E745479706512210A0C6167677265676174655F6964180320012809520B616767726567617465496412250A0E6167677265676174655F74797065180420012809520D61676772656761746554797065121D0A0A6576656E745F6461746118052001280952096576656E744461746112180A076368616E6E656C18062001280952076368616E6E656C223F0A08526573706F6E7365121D0A0A69735F73756363657373180120012808520969735375636365737312140A056572726F7218022001280952056572726F72224B0A0B4576656E7446696C74657212190A086576656E745F696418012001280952076576656E74496412210A0C6167677265676174655F6964180220012809520B616767726567617465496422320A0D4576656E74526573706F6E736512210A066576656E747318012003280B32092E70622E4576656E7452066576656E747332690A0A4576656E7453746F726512310A094765744576656E7473120F2E70622E4576656E7446696C7465721A112E70622E4576656E74526573706F6E7365220012280A0B4372656174654576656E7412092E70622E4576656E741A0C2E70622E526573706F6E73652200620670726F746F33"
        
    };
}

