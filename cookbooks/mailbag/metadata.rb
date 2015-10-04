name             'mailbag'
maintainer       'Colin Shea'
maintainer_email 'colin@shea.at'
license          'all_rights'
description      'Set up a mailserver according to my tastes'
long_description 'A bunch of recipes that create a very specific flavor of mailserver'
version          '0.1.33'

depends 'postfix'
depends 'dovecot'
depends 'encrypted_volume'
depends 'encrypted_blockdevice'
depends 'filesystem'
depends 'lvm'
depends 'opendkim'
depends 'onddo-spamassassin'
depends 'clamav'
