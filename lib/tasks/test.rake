namespace :p do

  # require 'capybara/dsl'
  # include Capybara::DSL

  task t: :environment do
    link = "https://www.greenfactory.su/#!/Stabilizirovanny-mokh/c/111922251"
    # doc = get_doc(link)
    selector_other_level = '.grid-product'
    p all(selector_other_level).map {|a| a['href']}
  end

  task ttt: :environment do
    link = "https://www.truborezoff.ru/shop/product/shvedskii-kliuch-super-ego-tipa-s-2"
    doc = get_doc(link)
    p addition_field_brand = doc.at(".product-intro__addition .product-intro__addition-item .product-intro__addition-link").parent.inner_html.remove(/Бренд:/).strip rescue nil
  end

  task t4: :environment do
    link = "https://www.truborezoff.ru/shop/product/svarochnyi-fen-phenom"
    doc = get_doc(link)
  p get_addition_field_brand(doc)
  end

  task uniq: :environment do
    a = Tov.all.map(&:title)
    p a.uniq.
      map { | e | [a.count(e), e] }.
      select { | c, _ | c > 1 }.
      sort.reverse.
      map { | c, e | "#{e}:#{c}" }
  end

  task vars: :environment do
    @urls = []
    url = "https://skipshop.ru/products/detskiy-rastushchiy-stul-konek-gorbunok-nebesniy"
    current_level = 3
    deep_level = 0
    get_urls(url, current_level, deep_level)
    p @urls
  end

  def get_urls(url, current_level, deep_level)
    p '-----------------------'
    p url
    p current_level
    p deep_level
    doc = get_doc(url)
    urls = doc.css(".variant-chooser_margin input.js-variant-select").map {|item| item['value']}
    @urls += urls

    next_level = current_level + 1
    return nil if next_level > deep_level
    urls.each do |url|
      get_urls(url, next_level, deep_level)
    end
  end
end
