# aws-rhel7-partitioning
This script addresses the CIS RHEL7 benchmark requirements for separate partitions.
1.1.2 Ensure separate partition exists for /tmp (Scored)
  1.1.3 Ensure nodev option set on /tmp partition (Scored)
  1.1.4 Ensure nosuid option set on /tmp partition (Scored)
  1.1.5 Ensure noexec option set on /tmp partition (Scored)
1.1.6 Ensure separate partition exists for /var (Scored)
1.1.7 Ensure separate partition exists for /var/tmp (Scored)
  1.1.8 Ensure nodev option set on /var/tmp partition (Scored)
  1.1.9 Ensure nosuid option set on /var/tmp partition (Scored)
  1.1.10 Ensure noexec option set on /var/tmp partition (Scored)
1.1.11 Ensure separate partition exists for /var/log (Scored)
1.1.12 Ensure separate partition exists for /var/log/audit (Scored)
1.1.13 Ensure separate partition exists for /home (Scored)
  1.1.14 Ensure nodev option set on /home partition (Scored)

Launch 2 instances from the same RHEL7 AMI and wait for it to pass status checks. 
Stop both instances, detach the volume from one instance and attach it to the other instance.
Obtain the UUID of the original root partition. It should be the same for both instances. Replace the UUID value in the script.
Execute the script on the instance with both volumes attached.
Follow the instructions given at the end of the script based on which volume is partitioned.
