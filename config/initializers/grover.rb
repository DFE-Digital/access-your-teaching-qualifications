Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "0",
      bottom: "0",
      left: "0",
      right: "0"
    },
  launch_args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu"],
  }
  config.use_jpeg_middleware = false
  config.use_png_middleware = false
  config.ignore_path = ->(path) do
    path !~ /^\/qualifications\/certificates\/(eyts|rtps|induction|mq|npq|qts)/i
  end
end
