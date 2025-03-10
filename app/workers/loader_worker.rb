class LoaderWorker
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 2, backtrace: true

  def perform(file_import_id, offset, limit)
    file_import = FileImport.find_by(id: file_import_id)
    return unless file_import

    file = file_import.file.download
    csv = CSV.parse(file, headers: true, header_converters: :symbol)
    rows = csv[offset, limit] || []

    jobs = rows.map.with_index(offset + 1) do |row, row_number|
      data = row.to_h.merge(file_import_id: file_import.id, row_number: row_number)
      [data] # Arguments for ProductRowWorker
    end

    # Push in bulk to Sidekiq (avoids 1000 Redis calls)
    Sidekiq::Client.push_bulk('class' => ProductRowWorker, 'args' => jobs)
  end
end