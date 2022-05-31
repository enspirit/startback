export default class MockWebSocket {
  constructor(baseUrl) {
    this.constructor.instance = this;
    this.baseUrl = baseUrl;
    this.listeners = {};
  }

  addEventListener(event, cb) {
    this.listeners[event] ||= [];
    this.listeners[event].push(cb);
  }

  send(data) {
    this.lastMessage = data;
  }

  emit(event, data) {
    this.listeners[event] ||= [];
    this.listeners[event].forEach(cb => cb(data));
  }

  static reset() {
    this.constructor.instance = null;
  }
}
