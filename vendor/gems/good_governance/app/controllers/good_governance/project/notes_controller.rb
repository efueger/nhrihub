require 'notes_controller'

class GoodGovernance::Project::NotesController < NotesController
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  private
  def note_params
    params[:note][:notable_id] = params[:project_id]
    params[:note][:notable_type] = "GoodGovernance::Project"
    super
  end
end
