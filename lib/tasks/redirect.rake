namespace :redirect do
  task short_url: :environment do
    rows = CSV.read("#{Rails.public_path}/redir.csv", headers: true)
    CSV.open("#{Rails.public_path}/short_redir.csv", "a+") do |csv|
      rows.each do |row|
        csv << [row['Параметр: OLDLINK'], "https://#{Rails.application.credentials[:shop][:domain]}/product/#{row['Название товара в URL']}"]
      end
    end
  end

  task redirect_xlsx: :environment do
    id_prop_OLDLINK = get_id_oldlink
    book = Spreadsheet::Workbook.new
    sheet = book.create_workssheet(name: "redirect")
    count = 0
    loop do
      response = api_get_products(page)
      body = JSON.parse(response.body)
      p body.size
      break if body.size == 0
      page += 1
      body.each do |product|
        newlink = "https://#{Rails.application.credentials[:shop][:domain]}/product/" + product["permalink"]
        oldlink = product["characteristics"].find {|char| char["property_id"] == id_prop_OLDLINK}
        oldlink = oldlink.nil? ? nil : oldlink["title"]
        if oldlink.present?
          sheet.row(count).push(oldlink, newlink)
          count += 1
        end
      end
      book.write 'short_redir.xls'
    end
  end

  task redirect_csv: :environment do
    products = []
    page = 1
    id_prop_OLDLINK = get_id_oldlink

    CSV.open("#{Rails.public_path}/short_redir.csv", "a+") do |csv|
      loop do
        response = api_get_products(page)
        body = JSON.parse(response.body)
        p body.size
        break if body.size == 0
        page += 1
        body.each do |product|
          newlink = "https://#{Rails.application.credentials[:shop][:domain]}/product/" + product["permalink"]
          oldlink = product["characteristics"].find {|char| char["property_id"] == id_prop_OLDLINK}
          oldlink = oldlink.nil? ? nil : oldlink["title"]
          csv << [oldlink, newlink] if oldlink.present?
        end
      end
    end
  end

  def get_id_oldlink
    page_for_find_OLDLINK = 1
    loop do
      response = api_get_products(page_for_find_OLDLINK)
      body = JSON.parse(response.body)
      break if body.size == 0
      body.each do |product|
        pp product['properties']
        prop = product['properties'].find {|prop| prop["title"] == "OLDLINK"}
        id_prop_OLDLINK = prop["id"] if prop.present?
        break
      end
      break if id_prop_OLDLINK.present?
      page_for_find_OLDLINK += 1
    end

    if id_prop_OLDLINK.nil?
      p "НЕТ Параметра OLDLINK"
      return nil
    else
      p "Параметр OLDLINK #{id_prop_OLDLINK}"
    end
    id_prop_OLDLINK
  end

  def api_get_products(page)
    api_key = Rails.application.credentials[:shop][:api_key]
    password = Rails.application.credentials[:shop][:password]
    domain = Rails.application.credentials[:shop][:domain]

    url_api_category = "http://#{api_key}:#{password}@#{domain}/admin/products.json?per_page=100&page=#{page}"

    RestClient.get( url_api_category )
  end

  task destroy: :environment do
    redirects = []
    page = 1
    loop do
      response = api_get_redirects(page)
      body = JSON.parse(response.body)
      p body.size
      break if body.size == 0
      redirects += body
      page += 1
    end
    sleep 60
    p redirects.count

    redirects.each do |redirect|
      if redirect["new_url"].match(/\/product\//)
        api_destroy_redirect(redirect["id"])
        # p redirect
        # break
      end
    end
  end

  def api_get_redirects(page)
    api_key = Rails.application.credentials[:shop][:api_key]
    password = Rails.application.credentials[:shop][:password]
    domain = Rails.application.credentials[:shop][:domain]

    url_api_category = "http://#{api_key}:#{password}@#{domain}/admin/redirects.json?per_page=250&page=#{page}"

    RestClient.get(url_api_category)
  end

  def api_destroy_redirect(id)
    api_key = Rails.application.credentials[:shop][:api_key]
    password = Rails.application.credentials[:shop][:password]
    domain = Rails.application.credentials[:shop][:domain]

    url_api_category = "http://#{api_key}:#{password}@#{domain}/admin/redirects/#{id}.json"

    RestClient.delete( url_api_category, {:content_type => 'application/json', accept: :json}) do |response, request, result, &block|
      sleep 1
      case response.code
      when 200
        p 'code 200 - sleep 0.6'
        sleep 0.6
      when 422
        p 'code 422'
      else
        response.return!(&block)
      end
    end
  end
end
