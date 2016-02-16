# component hierarchy
# internal_document_uploader template: #uploader_template (includes primary_fileupload decorator)
#   docs                     template: #files
#     doc                    template: #template-download (contains document_template as a partial)
#       archivedoc           template: #document_template (includes archive_fileupload decorator here)
#         uploadfiles
#           uploadfile
#   uploadfiles
#     uploadfile
#
Ractive.DEBUG = false

$ ->

  # these options apply to the primary fileupload
  window.fileupload_options =
    permittedFiletypes: window.permitted_filetypes
    maxFileSize: parseInt(window.maximum_filesize)
    failed: (e,data)->
      if data.errorThrown != 'abort'
        alert("The upload failed for some reason")
    prependFiles : false
    filesContainer: '.files'
    downloadTemplateId: '#template-download'
    uploadTemplateContainerId: '#uploads'
    fileInput: '#primary_fileinput'
    #replaceFileInput: false # this doesn't seem to cause any problem, and it solves problems caused by replacing the file input!
    replaceFileInput: true
    url : 'internal_documents.json',
    paramName : 'internal_document[file]',
    uploadTemplateId : '#upload_template' 
    uploadTemplate : Ractive.parse($('#upload_template').html())
    done: (e, data)->
      if e.isDefaultPrevented()
          return false
      # 'this' is the upload form
      # $this.data is a jQuery widget
      that = $(@).data('blueimp-fileupload') || $(@).data('fileupload')
      current_locale = that.options.current_locale()
      getFilesFromResponse = data.getFilesFromResponse || that.options.getFilesFromResponse
      file = data.result.file
      ractive = Ractive.getNodeInfo(@).ractive # it's the internal_documents_uploader ractive instance
      ractive.add_file(file)
      upload_file = Ractive.getNodeInfo(data.context[0]).ractive
      upload_file.parent.remove_upload_file(upload_file._guid)
      that._trigger('completed', e, data)
      that._trigger('finished', e, data)
    add : (e, data) ->
      if e.isDefaultPrevented()
        return false
      $this = $(@)
      that = $this.data('blueimp-fileupload') or $this.data('fileupload')
      _(data.files).each (file)->
        file_attrs =
          lastModifiedDate: file.lastModifiedDate
          name : file.name
          size: file.size
          type: file.type
          title: ""
          revision: ""
          document_group_id: ""
          fileupload: data
          primary : true
        internal_document_uploader.
          unshift('upload_files', file_attrs).
          then(
            new_upload = internal_document_uploader.findAllComponents('uploadfile')[0] # the uploadfile ractive instance
            #new_upload.set('fileupload', data) # so ractive can configure/control upload with data.submit()
            #new_upload.set('document_group_id', "")
            data.context = $(new_upload.find('*')) # the DOM node associated with the uploadfile ractive instance
            #$this.fileupload('option', 'formData', ->new_upload.get('formData')) # pass formData from ractive instance to jquery fileupload
            # using the jquery.fileupload animation, based on the .fade class,
            # better to use ractive easing TODO
            #that._transition(data.context) # make the DOM node appear on the page
            data.context.addClass('in')
            new_upload.validate_file_constraints()
          )
      return

  PrimaryFileUpload = (node)->
    $(node).fileupload _.extend({}, fileupload_options)
    teardown : ->
      id = Ractive.getNodeInfo(node).ractive.get('id')
      $(node).fileupload "destroy"
      $(node).fileupload _.extend({}, fileupload_options)
    update : ->
      id = Ractive.getNodeInfo(node).ractive.get('id')
      $(node).fileupload "destroy"
      $(node).fileupload _.extend({}, fileupload_options)

  EditInPlace = (node,id)->
    edit = new InpageEdit
      object : @
      on : node
      focus_element : 'input.title'
      success : (response, statusText, jqxhr)->
         ractive = @.options.object
         @.show() # before updating b/c we'll lose the handle
         if ractive.findParent('doc') # an archive file was updated
           ractive.parent.set(response)
         else
           ractive.set(response)
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : ->
      edit.off()

  Popover = (node)->
    $(node).popover
      html : true,
      title : ->
        $('#detailsTitle').html()
      content : ->
        data = Ractive.getNodeInfo(@).ractive.get()
        ractive = new Ractive
          template : '#detailsContent'
          data : data
        ractive.toHTML()
      template : $('#popover_template').html()
      trigger: 'hover'
    teardown: ->
      $(node).off('mouseenter')

  DocDeleter = (node)->
    $(node).on 'click', (event)->
      ev = $.Event(event)
      context = $(event.target).closest('table.document')
      data = $(event.target).closest('.fileupload').data()
      $(event.target).
        closest('.fileupload').
        fileupload('option','destroy')( ev, $.extend({
                                                    context: context,
                                                    type: 'DELETE'
                                                }, data))
    teardown : ->
      $(node).off 'click'

  Ractive.decorators.primary_fileupload = PrimaryFileUpload # for the archive file upload
  Ractive.decorators.inpage_edit = EditInPlace
  Ractive.decorators.doc_deleter = DocDeleter
  Ractive.decorators.popover = Popover

  UploadFile = Ractive.extend
    template : "#upload_template"
    computed :
      formData : ->
        [ {name : 'internal_document[title]', value : @get('title')}
          {name : 'internal_document[revision]', value : @get('revision')}
          {name : 'internal_document[filesize]', value : @get('size')}
          {name : 'internal_document[original_type]', value : @get('type')}
          {name : 'internal_document[original_filename]', value : @get('name')}
          {name : 'internal_document[lastModifiedDate]', value : @get('lastModifiedDate')}
          {name : 'internal_document[document_group_id]', value : @get('document_group_id')}
        ]
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
    validate_file_constraints : -> # the attributes that are checked when a file is added
      extension = @get('name').split('.').pop()
      @set('unconfigured_filetypes_error', permitted_filetypes.length == 0)
      @set('filetype_error', permitted_filetypes.indexOf(extension) == -1)
      @set('filesize_error', @get('size') > maximum_filesize)
      !@get('filetype_error') && !@get('filesize_error') && !@get('unconfigured_filetypes_error')
    cancel_upload : ->
      @parent.remove(@)
    duplicated_title_in_this_upload : ->
      false
    duplicated_title_with_existing_file : -> #returns true for duplicate found
      false
    duplicate_primary_file : ->
      @duplicated_title_in_this_upload() || @duplicated_title_with_existing_file()
    submit : ->
      unless @duplicate_primary_file() || !@validate_file_constraints()
        @get('fileupload').formData = @get('formData')
        @get('fileupload').submit()

  UploadFiles = Ractive.extend
    template: "{{#upload_files}}<uploadfile title='{{title}}' revision='{{revision}}' size='{{size}}' type='{{type}}' name='{{name}}' lastModifiedDate='{{lastModifiedDate}}' document_group_id='{{document_group_id}}' />{{/upload_files}}"
    components:
      uploadfile : UploadFile
    remove : (uploadfile)->
      index = _(@findAllComponents(uploadfile)).indexOf(uploadfile)
      @splice('upload_files',index,1)
    remove_upload_file : (upload_file_guid)->
      guids = _(@findAllComponents('uploadfile')).map('_guid')
      index = _(guids).indexOf(upload_file_guid)
      @splice('upload_files',index,1)

  ArchiveDoc = Ractive.extend
    template: '#document_template'
    oninit : ->
      @remove_errors()
    computed :
      file : -> false
      archive_file : -> true
    remove_errors : ->
      @set
        title_error: false
        revision_error: false
    validate : ->
      @_validate_nonblank_title()
    _validate_nonblank_title : ->
      @set('title', @get('title').trim())
      @set("title_error", @get('title') == "" )
      !@get('title_error')

  Doc = Ractive.extend
    template: '#template-download'
    oninit : ->
      @set('archive_upload_files',[])
    computed :
      file : -> true
      archive_file : -> false
      stripped_title : ->
        @get('title').replace(/\s/g,"").toLowerCase()
      title_edit_permitted : ->
        true
    components :
      archivedoc : ArchiveDoc
    download_file : ->
      window.location = @get('url')
    remove_errors : ->
      @set("title_error", false)
      @set("revision_error", false)
    validate : ->
      @_validate_title() && @_validate_revision()
    _validate_title : ->
      @set('title', @get('title').trim())
      if @get('title') == ""
        @set("title_error",true)
        false
      else
        true
    _validate_revision : ->
      @set('revision', @get('revision').trim())
      if @get('revision') == ""
        @set("revision_error",true)
        false
      else
        true
    add_file : (file)->
      @set(file)

  Docs = Ractive.extend
    template: '#files'
    components:
      doc : Doc
    docs_without : (doc)->
      _(@findAllComponents('doc')).reject((this_doc)-> this_doc.get('id') == doc.get('id'))

  uploader_options =
    el: '#container'
    template : '#uploader_template'
    data:
      files : files
      upload_files : []
      _ : _ # use underscore for sorting
    components :
      docs : Docs
      uploadfiles : UploadFiles
    computed :
      stripped_titles : ->
        _(@findAllComponents('doc')).map (doc)->doc.get('stripped_title')
    select_file : ->
      @find('#primary_fileinput').click()
    add_file : (file)->
      @unshift('files',file)
    start_upload : ->
      flash.notify()
      _(@findAllComponents('uploadfile')).each (uploadfile)->
        uploadfile.submit()
    flash_hide : ->
      @event.original.stopPropagation()
      flash.hide()

  window.start_page = ->
    window.internal_document_uploader = new Ractive uploader_options

  start_page()

  # this is a hack to workaround a jquery-fileupload-ui bug
  # that causes multiple cancel events, due to multiple event
  # handlers being attached
  #$('#uploads').on 'click', 'i.cancel', (event)->
    #event.preventDefault()
    #template = $(event.currentTarget).closest('.template-upload,.template-download')
    #data = template.data('data') || {}
    #data.context = data.context || template
    #if data.abort
      #data.abort()
    #else
      #data.errorThrown = 'abort'
      ##this._trigger('fail', event, data)
      #$(@).closest('.fileupload').data('blueimp-fileupload').options.fail(event)
  window.replaceFileInput = (input) ->
    inputClone = input.clone(true)
    fileInputClone = inputClone
    $('<form></form>').append(inputClone)[0].reset()
    input.after(inputClone).detach()
    $.cleanData input.unbind('remove')
    input = inputClone
    return