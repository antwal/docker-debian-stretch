# Debian 9.x Minimal Base

- Provides working sysvinit, syslogd, cron, anacron, at, and logrotate.
- syslogd is configured to output to the docker log system by default.

# Environment Variables

This environment variable is available for your use:

- `DEBBASE_SYSLOG` defaults to `stdout`, which redirects all syslog activity
  to the Docker infrastructure.  If you instead set it to `internal`, it will
  use the default Debian configuration of logging to `/var/log` within the
  container.  The configuration is applied at container start time by
  adjusting the `/etc/syslog.conf` symlink to point to either `syslog.conf.internal` or
  `syslog.conf.stdout`.  `syslog.conf.internal` is the default from the system.
  `dpkg-divert` is used to force all packages' attempts to write to `/etc/syslog.conf`
  to instead write to `/etc/syslog.conf.internal`.

- `DEBBASE_TIMEZONE`, if set, will configure the `/etc/timezone` and `/etc/localtime`
 files in the container to the appropriate timezone.  Set this to the desired timezone;
 for instance, `Europe/Rome`.
