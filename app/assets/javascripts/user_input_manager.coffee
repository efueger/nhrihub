class @UserInputManager
  constructor : ->
    @user_input_claimant = null
    @undo = null
  claim_user_input_request : (user_input_claimant,undo)->
    #console.log "claim ui with: "+undo
    if @user_input_claimant
      @terminate_user_input_request()
    @user_input_claimant = user_input_claimant
    @undo = undo
  terminate_user_input_request : ->
    #console.log "terminate ui claim for: "+@undo
    if @user_input_is_active()
      @user_input_claimant[@undo]()
  user_input_is_active : ->
    !_.isNull(@user_input_claimant) && !_.isNull(@undo)
  reset : ->
    #console.log "reset ui claim for: "+@undo
    @user_input_claimant = null
    @undo = null

@UserInput = new UserInputManager
