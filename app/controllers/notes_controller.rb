class NotesController < ApplicationController
  def create
    note = Note.new(note_params)
    note.author = note.editor = current_user
    if note.save
      render :json => Note.where(:notable_id => note.notable_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    note = Note.find(params[:id])
    note.editor = current_user
    if note.update_attributes(note_params)
      strategic_priorities = note.notable.outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities
      render :json => strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    note = Note.find(params[:id])
    notable = note.notable
    if note.destroy
      render :json => notable.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def note_params
    params.require(:note).permit(:text, :editor_id, :author_id, :notable_id, :notable_type)
  end
end