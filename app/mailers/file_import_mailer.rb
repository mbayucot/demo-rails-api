class FileImportMailer < ApplicationMailer
  default from: "no-reply@example.com" # Replace with your sender email

  def import_success(file_import)
    @file_import = file_import
    mail(
      to: file_import.user.email,
      subject: "File Import Completed Successfully"
    )
  end

  def import_failed(file_import)
    @file_import = file_import
    mail(
      to: file_import.user.email,
      subject: "File Import Failed"
    )
  end
end