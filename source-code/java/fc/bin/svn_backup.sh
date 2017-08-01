#!/bin/bash
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#

export SSH_AUTH_SOCK=/tmp/keyring-Ycp1MD/ssh
export SSH_AGENT_PID=3378

mail_recipient="kester.allen@nasa.gov"

loc_backup_dir=/path/to/svn-backups/
nfs_backup_dir=/path/to/nfs-svn-backups/

backup_start=$(date +'%H:%M %F')
backup_start_sec=$(date +%s)

# Do the SVN dump on host
#
dump_code_start=$(date +'%H:%M')
dump_code_start_sec=$(date +%s)
echo "start svn code dump at $dump_code_start"
ssh host '/usr/local/bin/svnadmin dump -q /code           | gzip >| svn-dump_code.dat.gz' || { echo "$0: host svn code dump failed with error $?" | mail -s "$0 error" $mail_recipient; exit 1; }

dump_data_start=$(date +'%H:%M')
dump_data_start_sec=$(date +%s)
echo "start svn data dump at $dump_data_start"
ssh host '/usr/local/bin/svnadmin dump -q /data      | gzip >| svn-dump_data.dat.gz' || { echo "$0: host svn data dump failed with error $?" | mail -s "$0 error" $mail_recipient; exit 1; }

dump_test_start=$(date +'%H:%M')
dump_test_start_sec=$(date +%s)
echo "start svn test dump at $dump_test_start"
ssh host '/usr/local/bin/svnadmin dump -q /test | gzip >| svn-dump_test.dat.gz' || { echo "$0: host svn test dump failed with error $?" | mail -s "$0 error" $mail_recipient; exit 1; }


# Copy backup files (svn-dump_{code,data,test}.dat.gz) to the local backup directory:
#
copy_start=$(date +'%H:%M')
copy_start_sec=$(date +%s)
today=$(date +'%Y-%m-%d')
for name in 'code' 'data' 'test'; do
    from_file_base=svn-dump_${name}.dat.gz 
    from_file=host:$from_file_base
    to_file=${loc_backup_dir}svn-dump_${name}-${today}.dat.gz 
    this_copy_start=$(date +'%H:%M')
    echo "start copying $from_file to $to_file at $this_copy_start"

    scp $from_file $to_file || { echo "$0: The scp to copy ${name} failed with error $?" | mail -s  "$0: error" $mail_recipient; exit 1; }

    ssh host ls -lh $from_file_base
    ls -lh $to_file
done

# Remove old backup files from the local backup directory:
#
clean_start=$(date +'%H:%M')
clean_start_sec=$(date +%s)
echo "start clean at $clean_start"
clean_svn_backup_dir.sh $loc_backup_dir || { echo "$0: Directory clean failed with error $?" | mail -s  "$0: error" $mail_recipient; exit 1; }

# Mirror the local backup directory to the NFS diretory:
#
mirror_start=$(date +'%H:%M')
mirror_start_sec=$(date +%s)
echo "start mirror at $mirror_start"
rsync -vv -a --no-g --delete $loc_backup_dir $nfs_backup_dir 

# Check for rsync errors and mail out final status:
#
rsync_exit_code=$?
script_finish=$(date +'%H:%M')
script_finish_sec=$(date +%s)
if [[ $rsync_exit_code -ne 23 && $rsync_exit_code -ne 0 ]]; then
    echo "$0: rsync mirroring failed with error $rsync_exit_code" | mail -s  "$0: error" $mail_recipient
    exit 1
else
    file_sizes=$(check_svn_dump_files.sh)

    script_end_sec=$(date +%s)
    mins_total=$((($script_finish_sec-$backup_start_sec)/60))
    mins_dump_code=$((($dump_data_start_sec-$dump_code_start_sec)/60))
    mins_dump_data=$((($dump_test_start_sec-$dump_data_start_sec)/60))
    mins_dump_test=$((($copy_start_sec     -$dump_test_start_sec)/60))
    mins_copy=$((($clean_start_sec-$copy_start_sec)/60))
    mins_clean=$((($mirror_start_sec-$clean_start_sec)/60))
    mins_mirror=$((($script_finish_sec-$mirror_start_sec)/60))

    report="Time report: $mins_total total minutes. Breakdown:
    $mins_dump_code $mins_dump_data $mins_dump_test Subversion code,data,test dump
    $mins_copy SCP from host to host
    $mins_clean Clean 
    $mins_mirror Rsync mirror to NFS
$file_sizes"

    echo $report

    echo $report | mail -s "SVN backup report" $mail_recipient
fi

exit 0
