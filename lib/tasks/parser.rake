# require 'capybara/dsl'
# include Capybara::DSL

namespace :product do

  task start: :environment do
    get_category(Category.first)
  end

  def get_category(category)
    p "GUARD --> #{category.parsing}"
    p category.name
    return if category.parsing

    category.subordinates.each do |subordinate|
      get_category(subordinate)
    end

    Rake::Task['product:get_product_links'].invoke(category.link, category.category_path)
    Rake::Task['product:get_product_links'].reenable
    category.update(parsing: true)
  end

  task :get_product_links, [:category_url, :category_path_name] => :environment do |_t, args|
    category_url = /\/$/.match(args[:category_url]) ? args[:category_url] : "#{args[:category_url]}/"
    category_path_name = args[:category_path_name]

    selector = ".ui-items__item .item-c__title"
    doc = get_doc(category_url)
    product_urls = doc.css(selector).map {|a| "#{Rails.application.credentials[:shop][:old_domain]}#{a['href']}"}

    pagination = doc.css('.catalog-pg__pagination a').map {|a| a['href'].split("=").last.to_i}.max

    if pagination.present?
      (2..pagination).each do |page|
        new_url = "#{category_url}?page=#{page}"
        new_doc = get_doc(new_url)
        product_urls += new_doc.css(selector).map {|a| "#{Rails.application.credentials[:shop][:old_domain]}#{a['href']}"}
      end
    end
p product_urls
p product_urls.count
Category.find_by(category_path: category_path_name).update(amount: product_urls.count)
#     Rake::Task['product:get_product'].invoke(product_urls, category_path_name)
#     Rake::Task['product:get_product'].reenable
  end

  task :get_product, [:products_urls_in_category, :category_path_name] => :environment do |_t, args|
    category_path_name = args[:category_path_name]
    args[:products_urls_in_category].each do |product_link|

      fid = product_link
      tovs = Tov.where(fid: fid)

      if tovs.present?
        tovs.each do |tov|
          p '==== UPDATE ===='
          next if tov.p4.split(' ## ').include?(category_path_name)
          update_product(tov, category_path_name)
        end
        next
      end

      p "START <<<< начали собирать данные по продукту #{product_link}"
      begin
        doc = get_doc(product_link)
      rescue
        p "Нет такой страницы #{product_link}"
        next
      end

      # vars = Services::GetVars.new(doc).call

      title = doc.at('h1.product-single__title').text.strip

      sku = doc.at('h1.product-single__title').text.strip rescue nil

      price = doc.at('h1.product-single__title').text.strip rescue 0
      oldprice = doc.at('h1.product-single__title').text.strip rescue nil

      desc = get_desc(doc)

      images = get_images(doc)
      p1 = get_props(doc)
      quantity = nil
      categories = category_path_name.split('/')
      mtitle = doc.at('title').text.strip rescue nil
      mdesc = doc.at('meta[name="description"]')['content'] rescue nil
      mkeyw = doc.at('meta[name="keywords"]')['content'] rescue nil

      data = {
        fid: fid,
        sku: sku,
        title: title,
        price: price,
        oldprice: oldprice,
        sdesc: nil,
        desc: desc,
        pict: images,
        quantity: quantity,
        p1: p1,
        p4: category_path_name,
        link: product_link,
        cat: categories[1],
        cat1: categories[2],
        cat2: categories[3],
        cat3: categories[4],
        cat4: categories[5],
        mtitle: mtitle,
        mdesc: mdesc,
        mkeyw: mkeyw,
      }

      reviews = []
      doc_reviews = doc.css(".comments .comments__list .comments__post")
      if doc_reviews
        reviews = doc_reviews.map do |doc_review|
          author = doc_review.at(".comments__post-author").text.strip
          text = doc_review.at(".comments__post-text").text.strip
          rating = doc_review.css(".comments__post-rate i").count
          date_published = doc_review.at(".comments__post-date").text.strip
          {
            text: text,
            author: author,
            rating: rating,
            date_published: date_published,
          }
        end
      end

      if vars.present?
        vars.each do |var|
          pp data
          # create_product(data, reviews)
        end
      else
        pp data
        # create_product(data, reviews)
      end

      p "END <<<< закончили собирать данные на продукт:: #{product_link}"
    end
    p "Total: #{Tov.count}"
  end

  def update_product(tov, category_path_name)
    if tov.update(p4: "#{tov.p4} ## #{category_path_name}")
      p "---- update товара #{tov.fid} -- p4: #{tov.p4} -- всего: #{Tov.count}}"
    else
      p "!!!!ОШИБКА UPDATE!!!!! товара #{tov.fid} -- TIME: #{Time.now}"
    end
  end

  def create_product(data, reviews = [])
    tov = Tov.new(data)
    if tov.save
      pp tov
      reviews.reverse.each do |review|
        tov.reviews.create({
                             text: review[:text],
                             author: review[:author],
                             rating: review[:rating],
                             date_published: review[:date_published],
                           })
      end
      p "+++++ создан товар #{tov.fid} -- всего: #{Tov.count}"
    else
      p "!!!!ОШИБКА!!!!! товара #{tov.fid}"
    end
  end
end
