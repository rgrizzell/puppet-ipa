#
# == Define: easy_ipa::backup
#
# Backup FreeIPA from cron
#
# == Parameters
#
# [*title*]
#   The resource title is used as part of the the name for the cronjob.
# [*type*]
#   Backup type. Either 'full' (offline) or 'data' (online).
# [*timestamp*]
#   Keep the default timestamp in the backup directory. Valid values are true 
#   (default) and false. Set this to false if you have and external system (e.g. 
#   bacula) that fetches the backups periodically and handles versioning on its 
#   own.
# [*monthday*]
# [*weekday*]
# [*hour*]
# [*minute*]
#   These are standard parameters for the cron resource
# [*email*]
#   Email to send cron notifications to. Defaults to $::servermonitor.
#
define easy_ipa::backup
(
    Enum['full','data'] $type,
                        $hour,
                        $minute,
                        $weekday = undef,
                        $monthday = undef,
                        $email = $::servermonitor,
    Boolean             $timestamp = true,
)
{

    $script = 'ipa-backup-wrapper.sh'
    $command = "${script} ${type} ${timestamp}"

    ensure_resource('file', $script, {
        'ensure'  => 'present',
        'name'    => "/usr/local/bin/${script}",
        'content' => template("easy_ipa/${script}.erb"),
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
    })

    cron { "ipa-${title}-backup":
        user        => 'root',
        command     => $command,
        monthday    => $monthday,
        weekday     => $weekday,
        hour        => $hour,
        minute      => $minute,
        environment => [ 'PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin', "MAILTO=${email}" ],
        require     => File[$script],
    }
}
