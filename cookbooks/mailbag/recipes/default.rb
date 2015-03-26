encrypted_volume "/encrypted" do
  volume  "/raw_test_volume.img"
  fstype  "ext3"
end

include_recipe 'mailbag::smtp'
include_recipe 'mailbag::imap'
