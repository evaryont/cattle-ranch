# create file for loop block device
file '/mailbag.img' do
  owner "root"
  group "root"
  mode "00600"
  action :create_if_missing
  notifies :run, "execute[set-file-size]", :immediately
end
# Set file size for loop file, 7GB file
execute "set-file-size" do
  command "/usr/bin/truncate -s 7168M /mailbag.img"
  action :nothing
end

encrypted_volume "/encrypted" do
  volume  "/mailbag.img"
  fstype  "ext3"
end

include_recipe 'mailbag::smtp'
include_recipe 'mailbag::imap'
