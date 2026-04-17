require_relative "../../lib/ok_computer_checks/notify_check"
require_relative "../../lib/ok_computer_checks/database_integrity_check"

OkComputer.logger = Rails.logger
OkComputer.mount_at = "health"

OkComputer::Registry.register "postgresql", OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register "database_integrity", OkComputerChecks::DatabaseIntegrityCheck.new
OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new
OkComputer::Registry.register "notify", OkComputerChecks::NotifyCheck.new

OkComputer.make_optional %w[version]
