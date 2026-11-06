# Базовий контролер адмін-панелі: доступ лише для користувачів з роллю admin.
module Admin
  class BaseController < ApplicationController
    PER_PAGE = 15
    before_action :require_admin!

    private

    def paginate(scope)
      total = scope.count
      @total_pages = [(total / PER_PAGE.to_f).ceil, 1].max
      @page = params[:page].to_i.clamp(1, @total_pages)
      scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    end
  end
end
