require 'optics-agent'
require './app'

agent = OpticsAgent::Agent.new
agent.configure do
    schema Schema
    debug true
end

use agent.rack_middleware

run App
