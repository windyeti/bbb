namespace :client do
  task create: :environment do
    rows = CSV.read("#{Rails.public_path}/shop.csv", headers: true)
    rows.each do |row|
      datd = {
      "client": {
        name: row["Имя"].present? ? row["Имя"] : "Unknown",
        surname: "Unknown",
        middlename: "Unknown",
        registered: true,
        email: row["Email / Телефон"],
        password: row["Email / Телефон"],
        type: "Client::Individual",
      }
    }
      api_create_client(data)
    end

  end

  def api_create_client(client)
    api_key = Rails.application.credentials[:shop][:api_key]
    password = Rails.application.credentials[:shop][:password]
    domain = Rails.application.credentials[:shop][:domain]

    url_api_category = "http://#{api_key}:#{password}@#{domain}/admin/clients.json"

    RestClient.post( url_api_category, data.to_json, {:content_type => 'application/json', accept: :json}) do |response, request, result, &block|
      sleep 1
      case response.code
      when 201
        p 'code 201 - ok'
      when 422
        p 'code 422'
        pp JSON.parse(response.body)
        # File.open("#{Rails.public_path}/errors_update.txt", 'a') do |file|
        #   file.write "#{id}\n"
        # end
      else
        response.return!(&block)
      end
    end
  end
end
