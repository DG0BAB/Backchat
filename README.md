# Backchat

Have a chat with back-end web services

Backchat is a small collection of types and protocols helping to make communicating with a REST API provided by a server much easier.

Backchat follows a clean architecture pattern by providing a strict seperation of layers. Every layer works transparently and has no understanding of the data it processes. There are basically three basic types:

## WebServiceEndpoint

An endpoint describes the path to an REST-API endpoint. It holds things like the path, the HTTP-Method, query-parameters, etc. Define you own endpoints by conforming to the `WebServiceEndpoint` protocol and provide values for the required properties. The default implementation for the `request` property provides an `URLRequest` which can used by a NetworkService (see below) or directly being send to the server.

## NetworkService

A `NetworkService` is used to send requets to a given `URL` using a certain `URLSession`, optional additional Header-Fields and authentication token provided by a `TokenHook`. A `NetworkService` does not care about the data it sends or receives. It just tranparently handles the protocol needed to provide a successful comunication with a given service.

Backchat offers a `HTTPNetworkService` as an implementation for communication with HTTP-Servers. It sends `URLRequets` to a given base `URL` checks HTTP status codes, returns errors and/or data received in the response. Optionally it supports token based authentication, which is used by most Server-API these days. `HTTPNetworkService` is sufficient for most Apps and can be used as is.

## WebServiceAdapter

A `WebServiceAdapter` is used to bind a `WebServiceEndpoint` to a certain `NetworkService`. Optionally you can specify a `ResponseDataValidator` that the adapter can use to transparently validate the received data. After a `WebServiceAdapter` is initialised, `invoke` must be called to send the request created from the given `WebServiceEndpoint` using the given `NetworkService`. After a response is received the `ResponseDataValidator`, if given, is called.

The `invoke` method returns a Promise which is fulfilled in case there is no (HTTP) error and the response data was validated successfully. Otherwiese the Promise is rejected with an appropriate error. There is a default implementation for the `invoke` method which should be sufficient for most use cases.

You can implement your own `WebServiceAdapter` and use the default implementation of `invoke` or roll your own. There is also a concrete `WebServiceDefaultAdapter` which fits most needs and can be used as is.

## JSONValidating

Inspite of the rule that this framework handles all data transparently it offers a very tiny protocol used to automatically validate JSON received from the server. Because JSON is a de facto standard, this has been added to the framework.

Letting your models conform to this protocol will provide them with JSON validation and initialisation from JSON Data. You just specify the JSON keys that must be within the JSON Data to be valid and call `isValidJSONData(_ data: Data)` on your model. If true is returned, you can just call `init(jsonData: Data)`, which gets added to your model if it's `Decodable`, to initialise it from the JSON data. If you call `isValidJSONData(_ data: Data)` from within the `ResponseDataValidator` closure of a `WebServiceAdapter` you get JSON validation almost for free.