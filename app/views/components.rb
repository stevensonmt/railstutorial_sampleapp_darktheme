# app/views/components.rb
require 'opal'
require 'hyper-react'
if React::IsomorphicHelpers.on_opal_client?
  require 'opal-jquery'
  require 'browser'
  require 'browser/interval'
  require 'browser/delay'
  require 'browser/socket'
  # add any additional requires that can ONLY run on client here
end

require_tree './components'
