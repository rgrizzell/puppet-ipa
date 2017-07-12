
# puppet-ipa

## Features backported:
Original fork from huit/puppet-ipa.

Commit: ee0a7cb624560c0766c144a829522fbd270aadf4

### Features across Forks

#### Compare with BitBrew/puppet-ipa

##### url
https://github.com/BitBrew/puppet-ipa/commit/3f44970102039843df29628b8df5a14537493d15

##### changes

- No longer hard coded to use `::fqdn` in various places.
- Adds IPA directory restore capability.

#### Compare with kallies/puppet-ipa branch 'merge'

##### url
https://github.com/kallies/puppet-ipa/commit/f5f4fc4d89aee8156b6b798030d94e5c587c4c7d

##### changes
- Readme updates.
- Lint fixes.
- Adds 'ipa-server-dns' package at init.pp
- Adds `::ipa::master` new parameter named `ip_address`.

## Compare with dvadgama/puppet-ipa

##### url
https://github.com/dvadgama/puppet-ipa/commit/84450bdb5b5eb4666ab7a14264824bd45b88191a

##### changes
- Lint fixes.
- Adds `::ipa::init.pp` new parameter named `enable_firewall`.
- Adds `::ipa::init.pp` new parameter named `enable_hostname`.
- Adds 'ipa-server-dns' package at init.pp (if `ipa::dns`).

## Desired Changes
From dvadgama:
- all

From kallies:
- Adds `::ipa::master` new parameter named `ip_address`.

From BitBrew:
- No longer hard coded to use `::fqdn` in various places.

From jpuskar:
- spec tests
- vagrantfile

