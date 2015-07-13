# Include each recipe as needed
node['websites']['recipes'].each do |recipe_name|
  include_recipe "website::#{recipe_name}"
end
