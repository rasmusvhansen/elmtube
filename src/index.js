'use strict';

require('./styles.scss');

const { Elm } = require('./Main');
const main = document.querySelector('.main');
var app = Elm.Main.init({ node: main });

// app.ports.toJs.subscribe(data => {
//   console.log(data);
// });
// Use ES2015 syntax and let Babel compile it for you
var testFn = inp => {
  let a = inp + 1;
  return a;
};
