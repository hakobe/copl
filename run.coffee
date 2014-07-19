ml = require('./ml')
[v, dtn] = ml("|- let fact = fun self -> fun n -> if n < 2 then 1 else n * self self (n - 1) in fact fact 3")
console.log(dtn.toString())
