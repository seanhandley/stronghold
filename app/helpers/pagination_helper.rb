module PaginationHelper
  def pagination(collection)
    paginate collection, theme:            'twitter-bootstrap-3',
                         pagination_class: 'pagination-sm'
  end
end