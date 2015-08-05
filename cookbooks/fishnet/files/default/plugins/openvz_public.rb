Ohai.plugin(:OpenvzPublic) do
  provides 'ipaddress'

  require_plugin 'network'

  collect_data do
    addresses = network['interfaces'].map { |name, i| i['addresses'].keys }.flatten
    without_privates = addresses.delete_if do |address|
      # Does this IP address look like a private one? If so, delete it
      !address =~ (/^10\.|^172\.1[6-9]\.|^172\.2\d\.|^172\.3[0-1]\.|^192\.168/)
    end

    # Set the public address to be the first one
    ipaddress without_privates.first
  end

end
