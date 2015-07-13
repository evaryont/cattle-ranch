template '/etc/nginx/sites-available/blog' do
  source 'blog_nginx.erb'
end

nginx_site 'blog' do
  enble true
end
