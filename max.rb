require 'rubygems'
require 'bundler/setup'
require 'json'
Bundler.require(:default)
Dotenv.load
include ESpeak

Pocketsphinx.disable_logging

lights_controller = Hue::Client.new

voice_opts = {speed: 150}

name = "Max"
Speech.new("Hello, my name is #{name}", voice_opts).speak

#config = Pocketsphinx::Configuration::KeywordSpotting.new('name')
config = Pocketsphinx::Configuration.default
config["kws"] = File.expand_path("keywords.txt")
config["kws_threshold"] = 1e-10
config["lm"] = nil
recognizer = Pocketsphinx::LiveSpeechRecognizer.new(config)

greeting = Speech.new("yes", voice_opts)
access_token = ENV.fetch('WIT_ACCESS_TOKEN')
Wit.init

Speech.new("#{name} is ready for commands.", voice_opts).speak

wit_callback = Proc.new do|response|
  begin
    response = JSON.parse(response)

    response["outcomes"].each do |outcome|
      #next if outcome["confidence"] < 0.5
      case outcome["intent"]
      when "party_time"
        lights_controller.lights.each do |l|
          l.on!
          l.set_state({
            brightness: 255,
            on: true,
            effect: "colorloop",
          }, 10)
        end
      when "turn_on_lights"
        lights_controller.lights.each do |l| 
          l.on!
          l.set_state({brightness: 254}, 10)
        end
      when "dim_bedroom_lights"
        if outcome["entities"] && outcome["entities"]["brightness"]
          value = outcome["entities"]["brightness"].first["value"]
          new_brightness = (value.to_i/100.0) * 255

          out = lights_controller.lights[2].set_state({brightness: new_brightness.to_i}, 10)
          puts "Light response: #{out.inspect}"
        end
      when "get_time"
        Speech.new("It's #{Time.now.strftime("%l %M %p")}", voice_opts).speak
      end
    end
  rescue => e
    puts "Exception! #{e.message}"
  end
end

begin
  recognizer.recognize do |speech|
    sleep 0.25

    if !@sleep || speech == "wakeup #{name}"
      case speech
      when /thankyou/
        Speech.new("you're welcome", voice_opts).speak
      when /sleep #{name}/
        puts "Going to sleep"
        @sleep = true
      when /wakeup #{name}/
        Speech.new("I'm awake!", voice_opts).speak
        @sleep = false
      else
        greeting.speak
        Wit.voice_query_auto_async access_token, wit_callback
      end
    end
  end
ensure
  Wit.close
end
