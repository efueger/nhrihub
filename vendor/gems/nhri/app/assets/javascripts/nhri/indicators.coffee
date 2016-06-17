$ ->
  Attribute = Ractive.extend
    template : "<div class='col-md-2' style='width:{{column_width}}%'> {{description}} </div>"
    computed :
      column_width : ->
        l = @parent.get('human_rights_attributes').length
        100/l

  Attributes = Ractive.extend
    template : "{{#human_rights_attributes}} <attribute description='{{description}}' /> {{/human_rights_attributes}}"
    components :
      attribute : Attribute

  FileUpload = (node)->
    $(node).fileupload
      dataType: 'json'
      type: 'post'
      add: (e, data) -> # data includes a files property containing added files and also a submit property
        upload_widget = $(@).data('blueimp-fileupload')
        ractive = data.ractive = Ractive.
          getNodeInfo(upload_widget.element[0]).
          ractive
        # ractive is the file_monitor ractive instance
        data.context = upload_widget.element.closest(".monitor")
        ractive.set('fileupload', data) # so ractive can configure/control upload with data.submit()
        #ractive.set('original_filename', data.files[0].name)
        ractive.findComponent("selectedFile").set( _.extend({},data.files[0]) )
        ractive.validate_file_constraints()
        return
      done: (e, data) ->
        data.ractive.update_file(data.jqXHR.responseJSON)
        return
      formData : ->
        @ractive.formData()
      uploadTemplateId: '#upload_template'
      uploadTemplateContainerId: '#selected_file_container'
      downloadTemplateId: '#download_file_template'
      permittedFiletypes: permitted_filetypes
      maxFileSize: parseInt(maximum_filesize)
    teardown : ->
      #noop for now

  Ractive.decorators.file_upload = FileUpload

  SelectedFile = Ractive.extend
    #template : "<span id='selected_file'>{{name}}</span>"
    template : "#upload_template"
    deselect_file : ->
      @parent.remove_selected_file()
      @reset()
      @set('filetype_error', false)
      @set('filesize_error', false)
      @set('file_error', false)

  MonitorPopover = (node)->
    indicator = @
    $(node).popover
      html : true,
      title : ->
        $('#detailsTitle').html()
      content : ->
        data = indicator.get()
        if data.monitor_format == "numeric"
          template = "#numericMonitorDetailsContent"
        else if data.monitor_format == "text"
          template = "#textMonitorDetailsContent"
        else
          template = "#fileMonitorDetailsContent"
        ractive = new Ractive
          template : template
          data : data
        ractive.toHTML()
      template : $('#popover_template').html()
      trigger: 'hover'
    teardown: ->
      $(node).off('mouseenter')

  window.file_monitor = new Ractive
    el: "#file_monitor"
    template : "#file_monitor_template"
    computed :
      url : ->
        if @get('persisted')
          Routes.nhri_indicator_file_monitor_path(current_locale, @get('indicator_id'), @get('id'))
        else
          Routes.nhri_indicator_file_monitors_path(current_locale, @get('indicator_id'))
      persisted : ->
        !_.isUndefined @get('id')
      save_method : ->
        if @get('persisted')
          'put'
        else
          'post'
    decorators :
      popover : MonitorPopover
    components :
      selectedFile : SelectedFile
    formData : ->
      'monitor[original_filename]' : @findComponent('selectedFile').get('name')
      'monitor[original_type]' : @findComponent('selectedFile').get('type')
      'monitor[filesize]' : @findComponent('selectedFile').get('size')
    onModalClose : ->
      @findComponent('selectedFile').reset()
      @set
        'file_error' : false
        'filesize_error' : false
        'filetype_error' : false
    validate_file_constraints : ->
      if _.isUndefined(@get('fileupload')) || _.isEmpty(@get('fileupload').files)
        @set('file_error',true)
        @findComponent('selectedFile').set('file_error',true)
        !@get('file_error')
      else
        @set('file_error',false)
        @findComponent('selectedFile').set('file_error',false)
        file = @get('fileupload').files[0]
        size = file.size
        extension = file.name.split('.').pop()
        @set('filetype_error', permitted_filetypes.indexOf(extension) == -1 )
        @set('filesize_error', size > maximum_filesize )
        @findComponent('selectedFile').set('filesize_error',@get('filesize_error'))
        @findComponent('selectedFile').set('filetype_error',@get('filetype_error'))
        !@get('filetype_error') && !@get('filesize_error')
    save_file : ->
      if @validate_file_constraints()
        $('.fileupload').fileupload('option',{method : @get('save_method'), url:@get('url'), formData:@formData()})
        @get('fileupload').submit()
    update_file : (response)->
      @findComponent('selectedFile').reset()
      @set(response)
    download_file : ->
      window.location = @get('url')
    remove_selected_file : ->
      @get('fileupload').files=[]

  Indicator = Ractive.extend
    template : "#indicator_template"
    computed :
      monitors_count : ->
        if @get('monitor_format') == "numeric"
          @get('numeric_monitors').length
        else if @get('monitor_format') == "text"
          @get('text_monitors').length
        else if _.isNumber @get('file_monitor.id')
          1
        else
          0
      reminders_count : ->
        @get('reminders').length
      notes_count : ->
        @get('notes').length
      create_reminder_url : ->
        Routes.nhri_indicator_reminders_path(current_locale,@get('id'))
      create_note_url : ->
        Routes.nhri_indicator_notes_path(current_locale,@get('id'))
    show_monitors_panel : ->
      type = @get('monitor_format')
      if type == 'file'
        if _.isNull(@get('file_monitor'))
          file_monitor.reset({indicator_id : @get('id')})
        else
          file_monitor.set(@get('file_monitor'))
        $('#file_monitor_modal').modal('show')
      else
        monitors.set
          numeric_monitors : @get('numeric_monitors')
          text_monitors : @get('text_monitors')
          numeric_monitor_explanation : @get('numeric_monitor_explanation')
          monitor_format : @get('monitor_format')
          indicator_id : @get('id')
          source : @
        $("##{type}_monitors_modal").modal('show')
    delete_indicator : (event,obj)->
      data = [{name:'_method', value: 'delete'}]
      url = Routes.nhri_heading_indicator_path(current_locale,@get('heading_id'),@get('id'))
      $.ajax
        method: 'post'
        url: url
        data: data
        success: @delete_callback
        context: @
    delete_callback : ->
      @parent.remove_indicator(@get('id'))
    edit_indicator : ->
      new_indicator.set(@get())
      new_indicator.set('source',@)
      $('#new_indicator_modal').modal('show')
    , Remindable, Notable

  NatureHumanRightsAttribute = Ractive.extend
    template : "#nature_attribute_template"
    components :
      indicator : Indicator
    new_indicator : ->
      new_indicator.set
        title : ""
        nature : @get('nature')
        human_rights_attribute_id : @get('human_rights_attribute_id')
        heading_id : @get('heading_id')
        monitor_format : ""
        id : null
      $('#new_indicator_modal').modal('show')
    remove_indicator : (id)->
      nature = @get('nature')
      indicators = nature+'_indicators'
      indicator_ids = _(@get(indicators)).map (i)-> i.id
      index = indicator_ids.indexOf(id)
      @splice(indicators,index,1)

  NatureAllHumanRightsAttributes = Ractive.extend
    template : "#nature_all_attributes_template"
    components :
      indicator : Indicator
    new_indicator : ->
      new_indicator.set
        title : ""
        nature : @get('nature')
        human_rights_attribute_id : null
        heading_id : @get('heading_id')
        monitor_format : ""
        id : null
      $('#new_indicator_modal').modal('show')
    remove_indicator : (id)->
      nature = @get('nature')
      indicators = 'all_human_rights_attribute_'+nature+'_indicators'
      indicator_ids = _(@get(indicators)).map (i)-> i.id
      index = indicator_ids.indexOf(id)
      @splice(indicators,index,1)

  Nature = Ractive.extend
    template : "#nature_template"
    computed :
      collection_name : ->
        "all_attribute_"+@get('name')+"_indicators"
      all_attribute_indicators : ->
        @get(@get('collection_name'))
    components :
      natureHumanRightsAttribute : NatureHumanRightsAttribute
      natureAllHumanRightsAttributes : NatureAllHumanRightsAttributes

  Natures = Ractive.extend
    template : "#natures_template"
    components :
      nature : Nature

  window.heading = new Ractive
    el: "#heading"
    template : "#heading_template"
    data:
      id : heading_data.id
      human_rights_attributes : heading_data.human_rights_attributes
      natures : natures
      all_attribute_structural_indicators : heading_data.all_attribute_structural_indicators
      all_attribute_process_indicators : heading_data.all_attribute_process_indicators
      all_attribute_outcomes_indicators : heading_data.all_attribute_outcomes_indicators
    components :
      attributes : Attributes
      natures : Natures
    add_indicator : (indicator)->
      nature = indicator.nature
      if _.isNull(indicator.human_rights_attribute_id)
        @push("all_attribute_#{nature}_indicators",indicator)
      else
        attribute_index = _(@get('human_rights_attributes').map (o)->o.id).indexOf(indicator.human_rights_attribute_id)
        @push("human_rights_attributes.#{attribute_index}.#{nature}_indicators",indicator)

# position the labels in the corner box, it depends on column height
  window.position_labels = ->
    height = $('.row-eq-height').height()
    width = $('#corner').width()
    ll_vert_pos = (height/2) + (height-50)/3
    ll_right_pos = 51-(height-50)/8
    hr_left_pos = 44+(height-50)/44
    $('#low-left').css('top', ll_vert_pos+'px').css('right',ll_right_pos+'px').show()
    $('#high-right').css('bottom',height/2+'px').css('left',hr_left_pos+'px').show()
  position_labels()
