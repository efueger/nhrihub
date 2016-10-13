namespace :corporate_services do
  desc "populate all models within the corporate services module"
  task :populate => [:populate_sp, :populate_accred_groups]

  desc "re-initialize strategic plans"
  task :populate_sp => :environment do
    StrategicPlan.destroy_all
    #StrategicPriority.destroy_all
    #PlannedResult.destroy_all
    #Outcome.destroy_all
    #Activity.destroy_all
    #PerformanceIndicator.destroy_all
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    current_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))

    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan_id => previous_strategic_plan.id)
      2.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        2.times do
          o = FactoryGirl.create(:outcome, :planned_result => pr)
          2.times do
            a = FactoryGirl.create(:activity, :outcome => o)
            2.times do
              FactoryGirl.create(:performance_indicator, :activity => a)
            end
          end
        end
      end
    end

    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan_id => current_strategic_plan.id)
      2.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        2.times do
          o = FactoryGirl.create(:outcome, :planned_result => pr)
          2.times do
            a = FactoryGirl.create(:activity, :outcome => o)
            2.times do
              FactoryGirl.create(:performance_indicator, :activity => a)
            end
          end
        end
      end
    end
  end

  desc "set up accreditation required doc groups"
  task :populate_accred_groups => :environment do
    titles = ["Statement of Compliance", "Enabling Legislation", "Organization Chart", "Annual Report", "Budget"]
    titles.each do |title|
      AccreditationDocumentGroup.create(:title => title)
    end
  end
end
