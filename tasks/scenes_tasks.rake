require 'readline'

desc "List and play scenes - path= (searches recursively)"
task :scenes => :environment do

  pattern = "#{ENV['path']}/**/*.rb" if ENV['path']
  
  Scenes::load(pattern)

  scenes = {}
  Scenes::Scene.list.each_with_index do |scene, n|
    scenes[n+1] = scene
  end

  if scenes.empty?
    puts "\nNo scenes available\n\n"
  else
    puts "\nAvailable Scenes"
    puts "----------------\n\n"

    scenes.sort.each do |num, name|
      puts " %3d - %s" % [num, name]
    end

    puts "\nThis will REBUILD the database first\n\n"
    puts "Or 0/q to quit"

    loop do
      input = Readline::readline('> ').strip

      if scene = scenes[input.to_i]
        Rake::Task['db:reset'].invoke
        Scenes::Scene[scene].play
        break
      elsif %w(0 q).include? input.downcase
        break
      else
        matched = scenes.find_all {|opt| (opt[1] =~ /#{input}/i) && input != '' }
        unless matched.empty?
          matched.sort.each do |option|
            puts "#{option[0]} - #{option[1]}"
          end
        else
          puts "What?"
        end
      end
    end
  end
end
