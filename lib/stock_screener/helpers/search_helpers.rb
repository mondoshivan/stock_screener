module SearchHelpers
  def search_uri(hash)
    parameters = URI.encode_www_form(hash)
    return "/search?#{parameters}"
  end
end