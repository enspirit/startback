const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'client.js',
    library: 'StartbackWebsocket',
  },
  resolve: {
  },
};
