/** Websocket handling */

const client = new StartbackWebsocket.HubClient("ws://localhost:9292/ws");

client.on('open', (event) => {
  console.log('Connected to the ws hub endpoint of todo app');
  console.log('...subscribing to notifications');
  client.room('notifications').execute('subscribe', {});
});

client.connect();

/** Vue app */

const app = Vue.createApp({
  data() {
    return {
      title: 'Startback TODO App',
      todos: []
    }
  },
  template: `
    <ul>
      <h1>{{title}}</h1>
      <li v-for="todo in todos" :key="todo.id">
        {{todo.description}}
      </li>
    </ul>
  `,
  created() {
    this.loadTodos();
    this.connectToHub();
  },
  methods: {
    loadTodos() {
      fetch('/api/todos/', {
        headers: {
          'Accept': 'application/json'
        }
      }).then(async (res) => {
        this.todos = await res.json();
      });
    },
    connectToHub() {
      const room = client.room('notifications');

      room.on('message', (msg) => {
        const { type, data } = msg.body
        if (type === 'StartbackTodo::Event::TodoCreated') {
          this.todos.push(data);
        }
      })
    }
  }
})

app.mount('#app');
