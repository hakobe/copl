// Generated by CoffeeScript 1.7.1
(function() {
  var ml;

  ml = require('./ml');

  ml("|- let fact = fun self -> fun n -> if n < 2 then 1 else n * self self (n - 1) in fact fact 3");

}).call(this);
