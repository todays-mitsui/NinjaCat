require 'addressable/uri'
#require 'cgi'
#require 'hpricot'
require 'net/http'
require 'net/https'
require 'open-uri'

class Addressable::URI
  def try(limit=10)
    return fetch(self, limit).code == "200"
  end

  def fetch(uri, limit)
    # HTTP リダイレクトが深すぎる場合は例外を発生させる
    raise ArgumentError, 'HTTP Redirect is too deep!' if limit == 0

    # 環境変数 HTTP_PROXY に設定されていれば Proxy 経由接続とみなす
    # ( Proxy 非考慮なら以下2行はコメントアウト )
    proxy_host, proxy_port = (ENV["HTTP_PROXY"] || '').sub(/http:\/\//, '').split(':')
    proxy = Net::HTTP::Proxy(proxy_host, proxy_port)

    uri = uri.normalize
    http = proxy.new(uri.host, uri.inferred_port)       # <= 日本語 URL 対応 ( Proxy 考慮 )
    http.open_timeout = 10
    http.read_timeout = 20
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    res = http.request(Net::HTTP::Get.new(uri.path))

    # レスポンス判定
    case res
    when Net::HTTPSuccess      # 2xx はそのまま
      res
    when Net::HTTPRedirection  # 3xx は再度 Fetch
      fetch(Addressable::URI.join("#{uri.scheme}://#{uri.host}:#{uri.port}", encode_ja(res['location'])), limit - 1)
    else                       # その他はそのまま
      res
    end
  end

  # 日本語のみ URL エンコード
  def encode_ja(url)
    ret = ""
    url.split(//).each do |c|
      if  /[-_.!~*'()a-zA-Z0-9;\/\?:@&=+$,%#]/ =~ c
        ret.concat(c)
      else
        ret.concat(CGI.escape(c))
      end
    end
    return ret
  end
end

