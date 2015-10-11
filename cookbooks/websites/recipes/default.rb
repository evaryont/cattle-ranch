# For each domain listed, configure the HTTP server for domain-scope
# configuration and be ready to accept subconfigurations. This is mostly to
# avoid trying to deal with multiple sites across different configuration files.
node['websites']['domains'].each do |domain|
  if node['ranchhand']['httpd'] == 'nginx'
    domain_d_parent_dir = "#{node['nginx']['dir']}/domains"
    domain_d_conf_dir   = "#{domain_d_parent_dir}/#{domain}.d"
    domain_template     = 'domain_nginx.erb'
    file_group          = node['nginx']['group']
    file_owner          = node['nginx']['user']
    sites_avail_conf    = "#{node['nginx']['dir']}/sites-available/#{domain}_domain"
  else
    Chef::Log.fatal! "Unsupported http server. I don't know how to deal with #{node['ranchhand']['httpd']}!"
  end

  directory domain_d_parent_dir do
    owner file_owner
    group file_group
    mode '0755'
  end

  directory domain_d_conf_dir do
    owner file_owner
    group file_group
    mode '0755'
  end

  # Try to find a TLS certificate for the configured domain
  if data_bag('ssl').include? domain
    domain_cert = certificate_manage domain do
      cert_path node['ranchhand']['ssl_cert_dir']
      owner file_owner
      group file_group
      nginx_cert true
      data_bag 'ssl'
      data_bag_type 'encrypted'
    end
  else
    # But if it doesn't exist, that's no big deal. Less HTTPS, yeah, but I'm not
    # going to mandate it. (Yet. TODO: Let's Encrypt client setup)
    domain_cert = nil
  end

  domain_template_vars = {'cert'         => domain_cert,
                          'domain'       => domain,
                          'domain_d_dir' => domain_d_conf_dir}

  template sites_avail_conf do
    source    domain_template
    owner     file_owner
    group     file_group
    variables domain_template_vars
  end
end

# Include each recipe as needed
node['websites']['recipes'].each do |recipe_name|
  include_recipe "websites::#{recipe_name}"
end
