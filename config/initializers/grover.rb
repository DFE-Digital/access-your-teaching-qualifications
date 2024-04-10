Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "0",
      bottom: "0",
      left: "0",
      right: "0"
    }
  }
  config.use_jpeg_middleware = false
  config.use_png_middleware = false
  config.ignore_path = ->(path) do
    path !~ /^\/qualifications\/certificates\/(eyts|itt|induction|mq|npq|qts)/
  end
end
