require "rake"
def generate_password
  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
end
namespace :user do
  desc "Create a new RESO Member user"
  task :create, [:email, :fullname, :password] => :environment do |t,args|
    password = args[:password] || generate_password
    u = User.new(password: password,
             email: args[:email],
             fullname: args[:fullname])
    u.save!
    puts "Created user #{args[:fullname]} with email #{args[:email]} and password \"#{password}\""
  end
  desc "Delete a RESO Member user"
  task :drop, [:email] => :environment do |t,args|
    User.where(email: args[:email]).delete_all
    puts "Deleted user #{args[:email]}"
  end
  desc "Change a password for a RESO Member user"
  task :password, [:email, :password] => :environment do |t,args|
    u = User.where(email: args[:email]).first
    u.password = args[:password]
    u.save!
    puts "Changed password for #{args[:email]} to \"#{args[:password]}\""
  end
end
