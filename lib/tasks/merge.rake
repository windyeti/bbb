namespace :merge do
  task csv: :environment do
    file_path_pre = "#{Rails.public_path}/product_pre.csv"
    file_path_output = "#{Rails.public_path}/product_output.csv"
    FileUtils.rm_rf Dir.glob(file_path_pre) if File.exist?(file_path_pre)
    FileUtils.rm_rf Dir.glob(file_path_output) if File.exist?(file_path_output)
    rows = CSV.read("#{Rails.public_path}/shop.csv", headers: true)
    old_headers = rows.first.to_hash.keys
    new_headers = []

    parsing_param_headers = Tov.all
      .map(&:p1)
      .map {|p1| p1.split(" --- ")}
      .map {|par| par unless par.include?('?')}
      .compact
      .flatten
      .map {|param| param.split(": ")[0]}
      .uniq
      .map {|name| "Параметр: #{name}"}
    p parsing_param_headers
    p old_headers
    p parsing_param_headers - old_headers
    parsing_param_headers.each {|p_p_h| old_headers << p_p_h unless old_headers.include?(p_p_h)}
    new_headers = old_headers + ["Параметр: fid", "Параметр: OLDLINK"]
    p new_headers

    CSV.open(file_path_pre, "a+") do |csv|
      csv << new_headers
      rows.each {|row| csv << row}
    end

    rows_pre = CSV.read(file_path_pre, headers: true)

    CSV.open(file_path_output, "a+") do |csv|
      already = []
      csv << new_headers
      rows_pre.each do |row|
        next if already.include?(row["ID товара"])
        sku = row["Артикул"]

        tov = Tov.find_by(
          sku: sku,
        )
        if tov.present?
          row["Параметр: fid"] = tov.fid
          row["Параметр: OLDLINK"] = tov.fid
          row["Тег title"] = tov.mtitle
          row["Мета-тег keywords"] = tov.mkeyw
          row["Мета-тег description"] = tov.mdesc
          row["Размещение на сайте"] = tov.p4
          row["Полное описание"] = tov.desc if row["Полное описание"].nil?
          row["Изображения"] = tov.pict

          if tov.p1.present?
            tov
            .p1.split(" --- ")
            .each do |param|
              ar = param.split(": ")
              name_header = "Параметр: #{ar[0]}"
              row[name_header] = ar[1] if row[name_header].nil?
              # if (ar[0].present? && ar[1].present?) && (!ar[0].include?('?') && !ar[1].include?('?'))
              # end
            end
          end
          # tov.update(check: true)
          csv << row
        end
        already << row["ID товара"]
      end
    end
  end
end
