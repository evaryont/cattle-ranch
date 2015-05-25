if %w(jessie wheezy).include? node['lsb']['codename']
  apt_repository "#{node['lsb']['codename']}-backports" do
    uri          'http://http.debian.net/debian'
    distribution "#{node['lsb']['codename']}-backports"
    components   [ 'main' ]
  end
end
