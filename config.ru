require "bundler"
Bundler.require

Envyable.load("./config/env.yml")

require "./bot"
run WhatsAppBot
