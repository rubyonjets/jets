// Configure your import map in config/importmap.rb. Read more: https://github.com/boltops-tools/importmap-jets
import jquery from 'jquery'
window.$ = jquery
import Jets from "@rubyonjets/ujs-compat"
Jets.start()
