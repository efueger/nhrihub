require 'rspec/core/shared_context'
require_relative './terms_of_reference_admin_spec_helper'

module TermsOfReferenceContextAdminSpecHelper
  extend RSpec::Core::SharedContext
  def model
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion
  end

  def filesize_selector
    '#terms_of_reference_version_filesize'
  end

  def filesize_context
    page.find('#terms_of_reference_version_filesize')
  end

  def filetypes_selector
    '#terms_of_reference_version_filetypes'
  end

  def filetypes_context
    page.find('#terms_of_reference_version_filetypes')
  end

  def admin_page
    nhri_admin_path('en')
  end
end
