export default class Room {

  #name
  #client
  #handlers

  constructor(name, client) {
    this.#name = name;
    this.#client = client;
    this.#handlers = {};
  }

  send(body, headers = {}) {
    this.#client.send(body, {
      ...headers,
      room: this.#name,
    });
  }

  on(event, cb) {
    if (['message'].indexOf(event) < 0) {
      throw new Error('You can only subscribe to the \'message\' event on rooms');
    }
    this.#handlers[event] ||= [];
    this.#handlers[event].push(cb);
  }

  unsubscribe(event, cb) {
    this.#handlers[event] ||= [];
    this.#handlers[event] = this.#handlers[event].filter(elm => elm !== cb);
  }

  execute(command, body, headers = {}) {
    return this.#client.execute(command, body, {
      ...headers,
      room: this.#name,
    });
  }

  //

  process(msg) {
    this.#handlers.message ||= [];
    this.#handlers.message.forEach((handler) => {
      handler(msg);
    });
  }
}
