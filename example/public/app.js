/** Websocket handling */

const client = new StartbackWebsocket.HubClient("ws://localhost:9292/ws");

client.on('open', (event) => {
  console.log('Connected to the ws hub endpoint of todo app');
  console.log('...subscribing to notifications');
  client.room('notifications')
    .execute('subscribe')
    .then((reply) => {
      if (reply.body.success === true) {
        console.log('...subscription successful')
      } else {
        console.log('...subscription failed', msg)
      }
    });
});

client.connect();

/** Vue app */

const app = Vue.createApp({
  data() {
    return {
      title: 'Startback TODO App',
      todos: [],
      newTodo: '',
    }
  },
  template: `
    <ul>
      <h1>{{title}}</h1>
      <li v-for="todo in todos" :key="todo.id">
        {{todo.description}}
      </li>
      <li>
        <input type="text" v-model="newTodo"/>
        <button @click="createTodo">Add</button>
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
    createTodo(description) {
      fetch('/api/todos/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          id: crypto.randomUUID(),
          description: this.newTodo
        })
      }).then(() => {
        this.newTodo = ''
      })
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
