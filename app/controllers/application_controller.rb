class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def store_return_location
    referer = request.referer
    return unless referer.present? && same_origin?(referer)
    session[:return_to] = referer
  end

  # Use this after successful POST/PATCH/DELETE to go back, falling back to `fallback`.
  def redirect_back_or_to(fallback, status: :see_other, allow_other_host: false)
    url = session.delete(:return_to)
    if url.present? && (allow_other_host || same_origin?(url))
      redirect_to url, status: status
    else
      redirect_to fallback, status: status
    end
  end

  # Prevent open redirects by only allowing same-origin URLs.
  def same_origin?(url)
    uri = URI.parse(url)
    # Treat relative URLs as same-origin to allow safe internal redirects
    return true if uri.host.nil? && uri.scheme.nil?
    uri.host == request.host && uri.scheme == request.scheme && uri.port == request.port
  rescue URI::InvalidURIError
    false
  end
end
