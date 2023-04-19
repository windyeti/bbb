namespace :parsing do
  task create_structure: :environment do
    url_source = "#{Rails.application.credentials[:shop][:old_domain]}"
    selector_top_level = '.table-nav .table-nav__items .table-nav__item > a'
    selector_other_level = '.content .content__container .content__row .row .col-xs-6.col-sm-4 > a'

    create_structure(
      {
        link: url_source,
        category_path: 'Каталог'
      },
      selector_top_level,
      selector_other_level,
      true
    )

    # !!!!! Бренды !!!!!!
    #
    # cat_brands = Category.find_by(name: "БРЕНДЫ")
    #
    # doc = get_doc("https://molecule.ru/index.php?dispatch=molecule_categories_brand.view&category_id=457")
    # doc_alphabets = doc.css(".ty-features-all .ty-features-all__group")
    # doc_alphabets.each do |doc_alphabet|
    #   alphabet_name = doc_alphabet.at(".ty-subheader").text.strip rescue nil
    #   next if alphabet_name.nil?
    #
    #   cat_alphabet = Category.create(
    #     name: alphabet_name,
    #     link: "",
    #     category_path: "#{cat_brands.category_path}/#{alphabet_name}",
    #     )
    #   cat_brands.subordinates << cat_alphabet
    #
    #   doc_brands = doc_alphabet.css(".ty-features-all__list .ty-features-all__list-item a")
    #
    #   doc_brands.each do |doc_brand|
    #     name = doc_brand.text.strip
    #     url = doc_brand['href']
    #     doc_cat = get_doc(url)
    #
    #     cat_brand = Category.create(
    #       name: name,
    #       link: url,
    #       category_path: "#{cat_alphabet.category_path}/#{name}",
    #       mtitle: doc_cat.at('title') ? doc_cat.at('title').text.strip : nil,
    #       mdesc:  doc_cat.at('meta[name="description"]') ? doc_cat.at('meta[name="description"]')['content'] : nil,
    #       mkeywords: doc_cat.at('meta[name="keywords"]') ? doc_cat.at('meta[name="keywords"]')['content'] : nil,
    #       )
    #     cat_alphabet.subordinates << cat_brand
    #   end
    # end
  end
end
