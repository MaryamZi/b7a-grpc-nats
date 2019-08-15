# b7a-grpc-nats

This project consists of the initial attempt to write a part of https://medium.com/@shijuvar/building-microservices-with-event-sourcing-cqrs-in-go-using-grpc-nats-streaming-and-cockroachdb-983f650452aa in Ballerina.

### How to run

```cmd
grpc-nats$ ballerina run paymentservice
[ballerina/nats] Connection established with server nats://localhost:4222
[ballerina/nats] Client subscribed for subject order-created
[ballerina/grpc] started HTTP/WS listener 0.0.0.0:9000
[ballerina/http] started HTTP/WS listener 0.0.0.0:8080

```

Invoke the order service
```cmd
$ curl -X POST -d '{ "customer_id": "cust1", "restaurant_id": "ASD11", "amount": 100.0, "order_items": [{"code":
"C1", "name": "rice", "unit_price": 10.0, "quantity": 10}] }' "http://localhost:8080/orderService/createOrder" -H
"Content-Type:application/json"
```
