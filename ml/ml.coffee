class Token
  constructor: (@type, @token) ->

class Node
    constructor: (@tokens) ->

class Int extends Node
class Bool extends Node
class Value extends Node
class Exp extends Node
class Prim extends Node

tokenize = (code) ->
  tokens = []

  i = 0
  chunk = ''

  identifierToken = () ->
    m = chunk.match(/^[a-z]+/)
    return null unless m
    i += m[0].length
    switch m[0]
      when 'evalto' then new Token('EVALTO', 'evalto')
      when 'if'     then new Token('IF',     'if')
      when 'then'   then new Token('THEN',   'then')
      when 'else'   then new Token('ELSE',   'else')
      when 'true'   then new Token('TRUE',   'true')
      when 'false'  then new Token('FALSE',  'false')
      else null # identifier

  intToken = () ->
    m = chunk.match(/^\d+/)
    return null unless m

    i += m[0].length
    new Token('INT', m[0])

  whitespaceToken = () ->
    m = chunk.match(/^\s+/)
    return null unless m

    i += m[0].length
    null

  symbolToken = () ->
    m = chunk.match(/^(?:\+|\-|\*|\<|\(|\))/)
    return null unless m

    i += 1
    switch m[0]
      when '+' then new Token('OPPLUS',  '+')
      when '-' then new Token('OPMINUS', '-')
      when '*' then new Token('OPTIMES', '*')
      when '<' then new Token('OPLT',    '<')
      when '(' then new Token('LPAREN',  '(')
      when ')' then new Token('RPAREN',  ')')

  while chunk = code[i..]
    token = \
      identifierToken() or
      whitespaceToken() or
      symbolToken() or
      intToken()
    tokens.push(token) if token

  tokens;

parse = (tokens) ->
  [1,2,3]

expand = (tree) ->
  true


main = ->
  expand(parse(tokenize("1+(1 + 3) + if 4 < 5 then 1 else 100 evalto 6")))

main()
