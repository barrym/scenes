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
      puts if num % 5 == 0
    end

    puts "\nThis will REBUILD the database first\n\n"
    puts "Or 0/q to quit"

    loop do
      input = Readline::readline('> ').strip

      if scene = scenes[input.to_i]
        Rake::Task['db:migrate:reset'].invoke
        Scenes::Scene[scene].play
        break
      elsif %w(0 q).include? input.downcase
        break
      else
        matched = scenes.find_all {|opt| (opt[1] =~ /#{input}/i) && input != '' }
        unless matched.empty?
          matched.sort.each do |option|
            puts " %3d - %s" % [option[0], option[1]]
          end
        else
          puts "What?"
        end
      end
    end
  end
end

namespace :scenes do

  # Based on http://blog.leetsoft.com/2006/5/29/easy-migration-between-databases
  desc "Saves a snapshot of the system as a reloadable scene"
  task :save => :environment do
    scene_data = {}

    interesting_tables.each do |tbl|
      klass = tbl.classify.constantize
      scene_data[tbl] = YAML.dump klass.find(:all).collect(&:attributes)
    end

    puts "\n\nEnter a name for this scene:"
    name = Readline::readline('> ').strip

    FileUtils.mkdir_p(RAILS_ROOT + "/scenes/saved")
    file_name = name.gsub(/\W/, '_').downcase

    yaml_file = "/scenes/saved/#{file_name}.yml"

    File.open(RAILS_ROOT + yaml_file, "w") do |f|
      f.write YAML.dump(scene_data)
    end

    File.open(RAILS_ROOT + "/scenes/saved/#{file_name}.rb", "w") do |f|
      f.write <<DATA
Scenes::Scene.named("#{name}") {
  YAML.load_file(RAILS_ROOT + "#{yaml_file}").each do |scene_data|
    tbl = scene_data[0]
    fixtures = YAML.load(scene_data[1])
    unless fixtures.empty?
      fixtures.each do |fixture|
        ActiveRecord::Base.connection.execute "INSERT INTO \#{tbl} (\#{fixture.keys.join(",")}) VALUES (\#{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})"
      end
    end
  end
}
DATA
    end
    puts "Saved"
  end

  def interesting_tables
    ActiveRecord::Base.connection.tables.sort - %w(schema_migrations schema_info sessions public_exceptions)
  end

end
