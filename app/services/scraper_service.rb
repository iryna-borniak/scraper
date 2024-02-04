require "nokogiri"
require "httparty"

class ScraperService
  def initialize(url)
    @url = url
  end

  def scrape_url
    headers = {
      "accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
      "accept-encoding" => "gzip, deflate, br",
      "accept-language" => "zh-CN,zh;q=0.9,zh-TW;q=0.8,en-US;q=0.7,en;q=0.6,ja;q=0.5",
      "cache-control" => "max-age=0",
      "cookie" => "arms_uid=dc7f001b-fc08-4249-9f47-24555fd47912; cna=siJAHqC/XGcCAS7b5lFCn7ge; taklid=e955eed8c4714cb3ad9edfbc679b72a9; _bl_uid=87lnUsaR0aOn9jabemX0jyv5394F; xlly_s=1; t=919db115909d24f3ed2f1b38440a16f3; __cn_logon__=false; cookie2=11165ae7472b5ceee3d707efc9ecea74; _tb_token_=e13394e57b0ee; _csrf_token=1706912337267; x5sec=7b22733b32223a2233323339356337663437653666363233222c226c61707574613b32223a226530623861323437303662316663366531383335386261353863313438316238434b6d4839713047454b6e37795054372f2f2f2f2f774577397179704b673d3d227d; _m_h5_c=ed143c2dc5c4df30ee582fc9312bd5fd_1706927136543%3B0879e1b9e0c49a06902484db0dfa5809; mtop_partitioned_detect=1; JSESSIONID=2F4396E7F16BB50D8B5D4D6630C31B43; _m_h5_tk=d381aba2f280fa03aa72842170c2696d_1706928222756; _m_h5_tk_enc=02b64e79eba07a64c1d94794745a323c; tfstk=eAPWqst6k3x5eH9kcg_4lkWcQzhQwu1ZwegLSydyJbh-RBagAzlUJYpvk4m4a0zrwk9QflgE2QHpDj3I-43pw4LAMmZJTYrUO-AQSyVPrX7oZzcn9GSN_WaurXDe_H2A_muYXASNb15VeEhCVGyykgrGxFOl-pWzRiOvGBe_KElHoppLGqQoXziroqVjPYitHmOLzSgSFcUR4TRZfnrBdEMMOqiNlZ9HKCjW9HDvJrRneq04_Z_XVpD-oqiNlZ9HKY3muA7fl39h.; isg=BE5ONlIQpwTXzBMknLV5s-irnyQQzxLJ-wU7aHiXvdEM2-414Fte2QeZFx-3Qwrh",
      "sec-fetch-mode" => "navigate",
      "sec-fetch-site" => "same-origin",
      "sec-fetch-user" => "?1",
      "upgrade-insecure-requests" => "1",
      "user-agent" => "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    }

    unparsed_page = HTTParty.get(@url, headers: headers)
    parsed_page = Nokogiri::HTML(unparsed_page.body)

    {
      title: extract_title(parsed_page),
      description: extract_description(parsed_page),
      image_src: extract_image_src(parsed_page),
      products: extract_products(parsed_page)
    }
  end

  private

  def extract_title(parsed_page)
    parsed_page.css(".title-text").text
  end

  def extract_description(parsed_page)
    parsed_page.css('meta[name="description"]').attr("content")
  end

  def extract_image_src(parsed_page)
    parsed_page.css(".J_ImageFirstRender").attr("src")
  end

  def extract_products(parsed_page)
    products = parsed_page.to_s.scan(/"skuMap":\s*\{(.*)\}/)
    final_products = {}

    products.join.scan(/"([^"]+)":\{([^}]+)\}/) do |product_name, product_details|
      final_products[product_name] = product_details.scan(/"price":"([^"]+)"/).flatten.first
    end

    final_products
  end
end
