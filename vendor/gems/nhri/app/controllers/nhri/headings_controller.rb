class Nhri::HeadingsController < ApplicationController
  def index
    @headings = Nhri::Heading.all
  end

  def create
    @heading = Nhri::Heading.create(heading_params)
    render :json => @heading, :status => 200
  end

  def destroy
    heading = Nhri::Heading.find(params[:id])
    heading.destroy
    head :ok
  end

  def update
    heading = Nhri::Heading.find(params[:id])
    if heading.update(heading_params)
      render :json => heading, :status => 200
    else
      head :internal_server_error
    end
  end

  def show
    indicator_associations = [:reminders => [:user, :remindable],
                              :notes => [:author, :editor, :notable],
                              :file_monitor => [:user, :indicator],
                              :text_monitors => [:author, :indicator],
                              :numeric_monitors => [:author, :indicator]]
    @heading = Nhri::Heading.includes(:human_rights_attributes =>
                                                   [:structural_indicators => indicator_associations,
                                                    :process_indicators => indicator_associations,
                                                    :outcomes_indicators => indicator_associations],
                                      :all_attribute_structural_indicators =>indicator_associations,
                                      :all_attribute_process_indicators =>indicator_associations,
                                      :all_attribute_outcomes_indicators =>indicator_associations
                                      ).find(params[:id])
  end

  private
  def heading_params
    params[:heading][:human_rights_attributes_attributes] = params[:heading][:human_rights_attributes_attributes].reject{|k,v| v[:description].blank? }
    params.require(:heading).permit(:title, :human_rights_attributes_attributes => [:heading_id, :id, :description])
  end
end
