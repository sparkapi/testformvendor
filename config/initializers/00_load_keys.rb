KEY_CONFIG = YAML::load(File.read("#{Rails.root}/config/keys.yml"))[Rails.env]
