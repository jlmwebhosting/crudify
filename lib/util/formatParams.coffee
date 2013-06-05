hasField = require './hasField'

reserved = ["skip","limit","sort","populate"]

validArg = (v) -> v?
validNumber = (v) -> validArg(v) and typeof(v) in ["number","string"] and !isNaN(v)
validField = (v) -> validArg(v) and typeof(v) is 'string' and v.length > 0
isTrue = (v) -> (v is true) or (v is 'true')
getField = (v) ->
  return v[1...] if (v[0] is '-')
  return v

###
skip can be a number or string of a number greater than 0
limit can be a number or string of a number greater than 0
sort can be a field name optionally prefixed with + or - to set sort order
populate can be a field name
###

module.exports = (params={}, model) ->
  out =
    skip: null
    limit: null
    populate: []
    sort: []
    conditions: {}
    flags: {}

  # check for our standard params

  if validNumber params.skip
    skip = parseInt params.skip
    out.skip = skip if skip > 0 # dont bother with jokers

  if validNumber params.limit
    limit = parseInt params.limit
    out.limit = limit if limit > 0 # dont bother with jokers

  # Sort by field
  sortField = (field) ->
    if validField field
      actualField = getField field
      if hasField model, actualField
        out.sort.push field

  if Array.isArray params.sort
    sortField f for f in params.sort
  else
    sortField params.sort

  # Populate field
  popField = (field) ->
    if validField field
      actualField = getField field
      if hasField model, actualField
        out.populate.push field

  if Array.isArray params.populate
    popField f for f in params.populate
  else
    popField params.populate

  # .where() all unreserved query params that are also model fields
  for name, val of params when !(name in reserved) and validField(name) and hasField(model, name)
    if validArg val
      out.conditions[name] = val

  return out