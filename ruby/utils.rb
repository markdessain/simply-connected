
def to_csv(data, file_name)
  CSV.open(file_name, "wb") do |csv|
    csv << data.first.keys # adds the attributes name on the first line
    data.each do |hash|
      csv << hash.values
    end
  end
end
