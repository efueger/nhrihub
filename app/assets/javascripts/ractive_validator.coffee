class @Validator
  constructor : (validatee)->
    if typeof validatee != 'object'
      throw new Error "No ractive object has been provided to ractive validator"
    @validatee = validatee
  validation_criteria : ->
    @validatee.get('validation_criteria')
  validate : ->
    attributes = _(@validation_criteria()).keys()
    valid_attributes = _(attributes).map (attribute)=> @validate_attribute(attribute)
    !_(valid_attributes).any (valid)->!valid
  validate_attribute : (attribute)->
    params = @validation_criteria()[attribute]
    [criterion,param] = if _.isArray(params) then params else [params]
    @[criterion].call(@,attribute,param)
  notBlank : (attribute)->
    @validatee.set(attribute, @validatee.get(attribute).trim()) unless _.isNull(@validatee.get(attribute))
    @validatee.set(attribute+"_error", _.isEmpty(@validatee.get(attribute)))
    !@validatee.get(attribute+"_error")
  lessThan : (attribute,param)->
    @validatee.set(attribute+"_error", @validatee.get(attribute) > param)
    !@validatee.get(attribute+"_error")
  numeric : (attribute)->
    @validatee.set(attribute+"_error", _.isNaN(parseInt(@validatee.get(attribute))))
    !@validatee.get(attribute+"_error")
  nonZero : (attribute)->
    @validatee.set(attribute+"_error", parseInt(@validatee.get(attribute)) == 0)
    !@validatee.get(attribute+"_error")
  match : (attribute,param)->
    value = @validatee.get(attribute)
    if _.isArray(param)
      if @nonEmpty("unconfigured_validation_parameter",param)
        match = _(param).any (val)->
          re = new RegExp(val)
          re.test value
      else
        # don't trigger match error if params are empty
        match = true
    else
      re = new RegExp(param)
      match = re.test value
    @validatee.set(attribute+"_error", !match)
    !@validatee.get(attribute+"_error")
  nonEmpty : (attribute,param)->
    @validatee.set(attribute+"_error", _.isEmpty(param))
    !@validatee.get(attribute+"_error")
  remove_attribute_error : (attribute)->
    @validatee.set(attribute+"_error",false)
