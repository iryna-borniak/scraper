class ScrapesController < ApplicationController
  before_action :authenticate_user!

  def index
    @result = scrape_website if params[:scrape].present? && params[:scrape][:url].present?
  end

  private

  def scrape_website
    scraper_service = ScraperService.new(params[:scrape][:url])

    scraper_service.scrape_url
  end
end
