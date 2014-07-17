util = require('util')
grammer = require('./grammer')
parser = grammer.parser

class Node
  constructor: (@type, @children, @value) ->

  toString: () ->
    str = switch @type
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

class DTNode
  constructor: (@rule, @vars, @premises) ->

  toString: (indentSize) ->
    indentSize ?= 0
    indent = ''
    indent += ' ' for i in [0...indentSize]

    str = switch @rule
      when 'E-Int'
        "#{ @vars.i } evalto #{ @vars.i } by E-Int {}"
      when 'E-Bool'
        "#{ @vars.b } evalto #{ @vars.b } by E-Bool {}"
      when 'E-IfT'
        "if #{ @vars.e1.toString() } then #{ @vars.e2.toString() } else #{ @vars.e3.toString() } evalto #{ @vars.v } by E-IfT {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-IfF'
        "if #{ @vars.e1.toString() } then #{ @vars.e2.toString() } else #{ @vars.e3.toString() } evalto #{ @vars.v } by E-IfF {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Plus'
        "#{ @vars.e1.toString() } + #{ @vars.e2.toString() } evalto #{ @vars.i3 } by E-Plus {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Minus'
        "#{ @vars.e1.toString() } - #{ @vars.e2.toString() } evalto #{ @vars.i3 } by E-Minus {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Times'
        "#{ @vars.e1.toString() } * #{ @vars.e2.toString() } evalto #{ @vars.i3 } by E-Times {\n" +
          @premises.map( (p) => p.toString(2) ).join(";\n") + "\n}"
      when 'E-Lt'
        "#{ @vars.e1.toString() } < #{ @vars.e2.toString() } evalto #{ @vars.b3 } by E-Lt {\n" +
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
        new "Illigal Derivation"
    str.replace(/^/mg, indent);

parser.yy = { Node: Node };

derive = (node) ->
  switch node.type
    when 'INT'
      [node.value, new DTNode('E-Int', {i:node.value}, [])]
    when 'BOOL'
      [node.value, new DTNode('E-Bool', {b:node.value}, [])]
    when 'IF'
      [b, dtn1] = derive(node.children[0])
      if b
        [v, dtn2] = derive(node.children[1])
        [v, new DTNode(
          "E-IfT",
          {e1:node.children[0], e2:node.children[1], e3:node.children[2], v:v},
          [
            dtn1,
            dtn2
          ]
        )]
      else
        [v, dtn2] = derive(node.children[2])
        [v, new DTNode(
          "E-IfF",
          {e1:node.children[0], e2:node.children[1], e3:node.children[2], v:v},
          [
            dtn1,
            dtn2
          ]
        )]
    when 'PLUS'
      [i1, dtn1] = derive(node.children[0])
      [i2, dtn2] = derive(node.children[1])
      i3 = i1 + i2
      [i3, new DTNode(
        "E-Plus",
        {e1:node.children[0], e2:node.children[1], i3:i3},
        [
          dtn1,
          dtn2,
          new DTNode("B-Plus", {i1:i1, i2:i2, i3:i3}, [] )
        ],
      )]
    when 'MINUS'
      [i1, dtn1] = derive(node.children[0])
      [i2, dtn2] = derive(node.children[1])
      i3 = i1 - i2
      [i3, new DTNode(
        "E-Minus",
        {e1:node.children[0], e2:node.children[1], i3:i3},
        [
          dtn1,
          dtn2,
          new DTNode("B-Minus", {i1:i1, i2:i2, i3:i3}, [] )
        ],
      )]
    when 'TIMES'
      [i1, dtn1] = derive(node.children[0])
      [i2, dtn2] = derive(node.children[1])
      i3 = i1 * i2
      [i3, new DTNode(
        "E-Times",
        {e1:node.children[0], e2:node.children[1], i3:i3},
        [
          dtn1,
          dtn2,
          new DTNode("B-Times", {i1:i1, i2:i2, i3:i3}, [] )
        ],
      )]
    when 'LT'
      [i1, dtn1] = derive(node.children[0])
      [i2, dtn2] = derive(node.children[1])
      b3 = i1 < i2
      [b3, new DTNode(
        "E-Lt",
        {e1:node.children[0], e2:node.children[1], b3:b3},
        [
          dtn1,
          dtn2,
          new DTNode("B-Lt", {i1:i1, i2:i2, b3:b3}, [] )
        ],
      )]
    else
      inspect(node)
      throw "Illigal Node"
    
inspect = (obj) ->
  console.log( util.inspect(obj, { depth: null }) )

main = ->
  tree = parser.parse("if 4 < 5 then 2 + 3 else 8 * 8")
  [v, dtn] = derive(tree)
  inspect(tree);
  inspect(dtn);
  console.log(dtn.toString())

main()
