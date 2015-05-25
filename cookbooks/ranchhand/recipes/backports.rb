if %w(jessie wheezy).include? node['lsb']['codename']
  apt_repository "#{node['lsb']['codename']}-backports" do
    uri          'http://http.debian.net/debian'
    distribution "#{node['lsb']['codename']}-backports"
    components   [ 'main' ]
  end

  # install the latest OpenSSH from the backports repository
  apt_package 'openssh-client' do
    action :upgrade
    default_release "#{node['lsb']['codename']}-backports"
  end
  apt_package 'openssh-sftp-server' do
    action :upgrade
    default_release "#{node['lsb']['codename']}-backports"
  end
  apt_package 'openssh-server' do
    action :upgrade
    default_release "#{node['lsb']['codename']}-backports"
  end
end
