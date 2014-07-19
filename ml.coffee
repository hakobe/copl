util = require('util')
grammer = require('./grammer')
parser = grammer.parser

class Node
  constructor: (@type, @children, @value) ->

  toString: () ->
    str = switch @type
      when 'DEFVAR'
        "#{ @children[0].value } = #{ @children[1].toString().replace(/(?:^\(|\)$)/g, '') }"
      when 'APPLY'
        "#{ @children[0].toString() } #{ @children[1].toString() }"
      when 'LET'
        "(let #{ @children[0].toString() } in #{ @children[1].toString() })"
      when 'LETREC'
        "(let rec #{ @children[0].toString() } in #{ @children[1].toString() })"
      when 'IF'
        "(if #{ @children[0].toString() } then #{ @children[1].toString() } else #{ @children[2].toString() })"
      when 'LT'
        "(#{ @children[0].toString() } < #{ @children[1].toString() })"
      when 'PLUS'
        "(#{ @children[0].toString() } + #{ @children[1].toString() })"
      when 'MINUS'
        "(#{ @children[0].toString() } - #{ @children[1].toString() })"
      when 'TIMES'
        "(#{ @children[0].toString() } * #{ @children[1].toString() })"
      when 'INT'
        "#{ @value }"
      when 'BOOL'
        "#{ @value }"
      when 'FUN'
        "(fun #{ @children[0].toString() } -> #{ @children[1].toString() })"
      when 'VAR'
        "#{ @value }"
      else
        throw "Illigal Node"

class DTNode
  constructor: (@rule, @vars, @env, @premises) ->

  toString: (indentSize) ->
    indentSize ?= 0
    indent = ''
    indent += ' ' for i in [0...indentSize]

    env = @env.map( (def) => def.toString() ).join(', ')
    env += ' ' if env

    str = switch @rule
      when 'E-Int'
        "#{ env }|- #{ @vars.i } evalto #{ @vars.i } by E-Int {}"
      when 'E-Bool'
        "#{ env }|- #{ @vars.b } evalto #{ @vars.b } by E-Bool {}"
      when 'E-Fun'
        "#{ env }|- fun #{ @vars.c.x.toString() } -> #{ @vars.c.e.toString() } evalto #{ @vars.c.toString() } by E-Fun {}"
      when 'E-Var1'
        "#{ env }|- #{ @vars.x } evalto #{ @vars.v } by E-Var1 {}"
      when 'E-Var2'
        "#{ env }|- #{ @vars.x } evalto #{ @vars.v2 } by E-Var2 {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-App'
        "#{ env }|- #{ @vars.e1.toString() } #{ @vars.e2.toString() } evalto #{ @vars.v } by E-App {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-AppRec'
        "#{ env }|- #{ @vars.e1.toString() } #{ @vars.e2.toString() } evalto #{ @vars.v } by E-AppRec {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Let'
        "#{ env }|- let #{ @vars.def.toString() } in #{ @vars.e2.toString() } evalto #{ @vars.v } by E-Let {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-LetRec'
        "#{ env }|- let rec #{ @vars.def.toString() } in #{ @vars.e2.toString() } evalto #{ @vars.v } by E-LetRec {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-IfT'
        "#{ env }|- if #{ @vars.e1.toString() } then #{ @vars.e2.toString() } else #{ @vars.e3.toString() } evalto #{ @vars.v } by E-IfT {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-IfF'
        "#{ env }|- if #{ @vars.e1.toString() } then #{ @vars.e2.toString() } else #{ @vars.e3.toString() } evalto #{ @vars.v } by E-IfF {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Plus'
        "#{ env }|- #{ @vars.e1.toString() } + #{ @vars.e2.toString() } evalto #{ @vars.i3 } by E-Plus {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Minus'
        "#{ env }|- #{ @vars.e1.toString() } - #{ @vars.e2.toString() } evalto #{ @vars.i3 } by E-Minus {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Times'
        "#{ env }|- #{ @vars.e1.toString() } * #{ @vars.e2.toString() } evalto #{ @vars.i3 } by E-Times {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Lt'
        "#{ env }|- #{ @vars.e1.toString() } < #{ @vars.e2.toString() } evalto #{ @vars.b3 } by E-Lt {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'B-Plus'
        "#{ @vars.i1 } plus #{ @vars.i2 } is #{ @vars.i3 } by B-Plus {}"
      when 'B-Minus'
        "#{ @vars.i1 } minus #{ @vars.i2 } is #{ @vars.i3 } by B-Minus {}"
      when 'B-Times'
        "#{ @vars.i1 } times #{ @vars.i2 } is #{ @vars.i3 } by B-Times {}"
      when 'B-Lt'
        "#{ @vars.i1 } less than #{ @vars.i2 } is #{ @vars.b3 } by B-Lt {}"
      else
        new "Illegal Derivation"
    str.replace(/^/mg, indent);

class Def
  constructor: (@name, @value) ->

  toString: () ->
    "#{ @name } = #{ @value.toString() }"

class Closure
  constructor: (@env, @x, @e) ->

  toString: () ->
    env = @env.map( (def) => def.toString() ).join(', ')
    "(#{ env })[fun #{ @x.toString() } -> #{ @e.toString() }]"

class RecClosure
  constructor: (@env, @name, @c) ->

  toString: () ->
    env = @env.map( (def) => def.toString() ).join(', ')
    "(#{ env })[rec #{ @name } = fun #{ @c.x.toString() } -> #{ @c.e.toString() }]"


parser.yy = { Node: Node };

derive = (node, env) ->

  switch node.type
    when 'ENVE'
      env = node.children[0].children.map( (n) =>
        [v, dtn] = derive(n, [])
        v
      )
      derive(node.children[1], env)
    when 'INT'
      [node.value, new DTNode('E-Int', {i:node.value}, env, [])]
    when 'BOOL'
      [node.value, new DTNode('E-Bool', {b:node.value}, env, [])]
    when 'FUN'
      c = new Closure(env, node.children[0], node.children[1])
      [c, new DTNode('E-Fun', {c:c}, env, [])]
    when 'VAR'
      x = node.value
      def = env[(env.length - 1)]
      if def.name == x
        [def.value, new DTNode('E-Var1', {x:def.name, v:def.value}, env, []) ]
      else
        [v2, dtn] = derive(node, env[0..-2])
        [v2, new DTNode('E-Var2', {x:x, v2:v2}, env, [dtn]) ]
    when 'APPLY'
      [v, dtn1] = derive(node.children[0], env)
      if v instanceof Closure
        c = v
        [v2, dtn2] = derive(node.children[1], env)
        [v, dtn3] = derive(c.e, c.env.concat([ new Def(c.x.value, v2) ]))
        [v, new DTNode(
          'E-App',
          {e1:node.children[0], e2:node.children[1], v:v},
          env,
          [dtn1, dtn2, dtn3]
        )]
      else if v instanceof RecClosure
        c = v.c
        [v2, dtn2] = derive(node.children[1], env)
        [v, dtn3] = derive(c.e, c.env.concat([ new Def(v.name, v), new Def(c.x.value, v2) ]))
        [v, new DTNode(
          'E-AppRec',
          {e1:node.children[0], e2:node.children[1], v:v},
          env,
          [dtn1, dtn2, dtn3]
        )]
    when 'DEFVAR'
      x = node.children[0].value
      [v, dtn] = derive(node.children[1], env)
      [new Def(x, v), dtn]
    when 'LET'
      [def, dtn1] = derive(node.children[0], env)
      [v, dtn2] = derive(node.children[1], env.concat([ def ]))
      [v, new DTNode(
        'E-Let',
        {def:node.children[0], e2:node.children[1], v:v},
        env,
        [ dtn1, dtn2 ]
      )]
    when 'LETREC'
      [def, dtn1] = derive(node.children[0], env)
      recDef = new Def(def.name, new RecClosure(env, def.name, def.value))
      [v, dtn2] = derive(node.children[1], env.concat([ recDef ]))
      [v, new DTNode(
        'E-LetRec',
        {def:node.children[0], e2:node.children[1], v:v},
        env,
        [ dtn2 ]
      )]
    when 'IF'
      [b, dtn1] = derive(node.children[0], env)
      if b
        [v, dtn2] = derive(node.children[1], env)
        [v, new DTNode(
          "E-IfT",
          {e1:node.children[0], e2:node.children[1], e3:node.children[2], v:v},
          env,
          [ dtn1, dtn2 ]
        )]
      else
        [v, dtn2] = derive(node.children[2], env)
        [v, new DTNode(
          "E-IfF",
          {e1:node.children[0], e2:node.children[1], e3:node.children[2], v:v},
          env,
          [ dtn1, dtn2 ]
        )]
    when 'PLUS'
      [i1, dtn1] = derive(node.children[0], env)
      [i2, dtn2] = derive(node.children[1], env)
      i3 = i1 + i2
      [i3, new DTNode(
        "E-Plus",
        {e1:node.children[0], e2:node.children[1], i3:i3},
        env,
        [
          dtn1,
          dtn2,
          new DTNode("B-Plus", {i1:i1, i2:i2, i3:i3}, env, [] )
        ],
      )]
    when 'MINUS'
      [i1, dtn1] = derive(node.children[0], env)
      [i2, dtn2] = derive(node.children[1], env)
      i3 = i1 - i2
      [i3, new DTNode(
        "E-Minus",
        {e1:node.children[0], e2:node.children[1], i3:i3},
        env,
        [
          dtn1,
          dtn2,
          new DTNode("B-Minus", {i1:i1, i2:i2, i3:i3}, env, [] )
        ],
      )]
    when 'TIMES'
      [i1, dtn1] = derive(node.children[0], env)
      [i2, dtn2] = derive(node.children[1], env)
      i3 = i1 * i2
      [i3, new DTNode(
        "E-Times",
        {e1:node.children[0], e2:node.children[1], i3:i3},
        env,
        [
          dtn1,
          dtn2,
          new DTNode("B-Times", {i1:i1, i2:i2, i3:i3}, env, [] )
        ],
      )]
    when 'LT'
      [i1, dtn1] = derive(node.children[0], env)
      [i2, dtn2] = derive(node.children[1], env)
      b3 = i1 < i2
      [b3, new DTNode(
        "E-Lt",
        {e1:node.children[0], e2:node.children[1], b3:b3},
        env,
        [
          dtn1,
          dtn2,
          new DTNode("B-Lt", {i1:i1, i2:i2, b3:b3}, env, [] )
        ],
      )]
    else
      throw "Illegal Token"
    
inspect = (obj) ->
  console.log( util.inspect(obj, { depth: null }) )

main = ->
  tree = parser.parse("|- let fact = fun self -> fun n -> if n < 2 then 1 else n * self self (n - 1) in fact fact 3")
  [v, dtn] = derive(tree, [])
  console.log(dtn.toString())

main()
