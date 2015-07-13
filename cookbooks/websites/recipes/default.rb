# Include each recipe as needed
node['websites']['recipes'].each do |recipe_name|
  include_recipe "websites::#{recipe_name}"
end
