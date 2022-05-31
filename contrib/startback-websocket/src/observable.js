export default class Observable {
  #observers

  constructor() {
    this.#observers = {};
  }

  on(event, cb) {
    this.#observers[event] ||= [];
    this.#observers[event].push(cb);
  }

  emit(event, data) {
    this.#observers[event] ||= [];
    this.#observers[event].forEach(cb => {
      if (!cb) {
        return;
      }
      try {
        cb(data);
      } catch (err) {
        console.error('Error while calling event handler for', event);
        console.error(err);
      }
    });
  }
}
