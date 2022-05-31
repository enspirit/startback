import Observable from './observable';

export default class Client extends Observable {
  #baseUrl
  #ws

  constructor(baseUrl) {
    super();
    this.#baseUrl = baseUrl;
  }

  send(data) {
    this.#ws.send(data);
  }

  connect() {
    if (this.#ws) {
      throw new Error('Already connected');
    }
    this.#ws = new WebSocket(this.#baseUrl);

    // our websocket client emits at least the original events
    const events = ['close', 'error', 'message', 'open'];
    events.forEach((eventName) => {
      this.#ws.addEventListener(eventName, (data) => {
        this.emit(eventName, data);
      });
    });
  }
}
