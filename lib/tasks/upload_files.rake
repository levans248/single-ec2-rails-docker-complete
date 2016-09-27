namespace :docker do
  desc "upload files, build images, and start containers for first deployment"
  task :first_deploy do
    sh "config/deploy/deploy.sh"
  end

  desc "task that will handle continuous integration with zero downtime"
  task :deploy, [:nginx_service_name, :webapp_service_name] do |t, args|
    if args.nginx_service_name == nil || args.webapp_service_name == nil
      puts "Please enter the service name of both nginx and the webapp when calling the rake task"
      puts "Syntax: rails docker:deploy[nginx_service_name,webapp_service_name]"
    else
      sh "config/deploy/push_update.sh #{args.nginx_service_name} #{args.webapp_service_name}"
    end
  end
end