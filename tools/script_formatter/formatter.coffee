fs = require 'fs'
readline = require 'readline'
CSON = require 'cson'

reader = readline.createInterface
  input: fs.createReadStream './script.txt'

script = []
current_type = undefined
current_role = undefined
current_node = undefined
current_options = undefined

reader.on 'line', (line) ->
  # comment
  if line[0] is '#'
    return

  # conclude options block for the current node
  # wont return, will continue to parse the line
  if current_options? and not ( line.startsWith(' ') or line.startsWith("\t") )
    parsed_options = CSON.parse current_options
    for key of parsed_options
      current_node[key] = parsed_options[key]

  # line breaker means a new nodes block
  if line is ''
    current_type = undefined
    current_role = undefined
    current_node = undefined
    current_options = undefined
    return

  # first line of a nodes block, define the type, wont really create the node
  if current_type is undefined
    # waiting for a symbol
    switch line
      when 'v'
        current_type = 'video'
      when 'n'
        current_type = 'narrate'
      # TODO
      # when 'options'
      else
        current_type = 'line'
        current_role = line
    return
  else
    # setting options for the last node
    if line.startsWith(' ') or line.startsWith("\t")
      current_options ?= ''
      current_options += ( line + "\n" )
      return

    # creating another node, in the same block, with the same type and character
    else
      # clear current options
      current_options = undefined

      new_id = script.length + 1
      node =
        id: new_id
        type: current_type
        next: new_id + 1
      switch current_type
        when 'video'
          node.video = line
        when 'narrate'
          node.text = line
        when 'line'
          node.role = current_role
          node.text = line
        # TODO
        # when 'options'

      script.push node
      current_node = script[script.length - 1]

reader.on 'close', ->
  # remove `next` for the last node
  delete script[script.length - 1].next

  fs.writeFile './script.cson', CSON.createCSONString(script), (err) ->
    if err?
      console.log err
    else
      console.log 'DONE'
