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
  end
end
