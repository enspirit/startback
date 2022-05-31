## Hub

The `Hub:App` provides an opinionated protocol that eases
the handling of real-time, websocket-based, applications.

### Protocol

The protocol is mainly based on JSON-serialized messages containing both a `headers` map and a `body` property.

#### Rooms

Rooms provide an abstraction allowing messages to be broadcasted to a set of `participants`.

Messages are sent/received to/from rooms by providing the special `'room' header`, eg:

```json
{
  "header": {
    "room": "a-room-name"
  },
  "body": {} || "" // can be anything
}
```

#### Commands

Commands provide an abstraction allowing the execution of remote processing that can provide a result.

Commands are executed by providing the special `'command‘ header` and an additional `'reply-to' header`, eg:

```json
{
  "header": {
    "command": "a-command",
    "reply-to": "cc3ce43a-a494-4c38-bb01-654223ee24a5" // uuid v4
  },
  "body": {} || "" // can be anything
}
```

The protocol contract between the Hub-servers and Hub-clients is that the result of a command execution can be sent back to the client by sending a message re-using the uuid provided in the `reply-to header` in the following way:

```json
{
  "header": {
    // same as the reply-to value of the original message
    "in-reply-to": "cc3ce43a-a494-4c38-bb01-654223ee24a5"
  },
  "body": {} || "" // the result of the command run
}
```

#### Combination

The several aspects of the protocol can be combined.

For instance a command can be executed in a specific room:

```json
{
  "header": {
    "command": "a-command",
    "room": "a-certain-room",
    "reply-to": "323b7293-91f4-49ab-b374-006087b56e07"
  },
  "body": {} || "" // can be anything
}
```
