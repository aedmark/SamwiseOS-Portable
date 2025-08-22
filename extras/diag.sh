delay 800

printf "===== SamwiseOS Core Test Suite v0.0.5 Initializing ====="
printf "\n \nThis script tests all non-interactive core functionality with maximum paranoia."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n--- Phase 1: Setting up test users/groups ---"
printf "\n \nCreating users: diagUser, testuser, sudouser, limitedsudo..."
useradd diagUser
testpass
testpass
useradd testuser
testpass
testpass
useradd sudouser
testpass
testpass
useradd limitedsudo
testpass
testpass
useradd paradoxuser
testpass
testpass
useradd comm_user1
testpass
testpass
useradd comm_user2
testpass
testpass
useradd sudouser2
testpass
testpass
useradd recursive_test_user
testpass
testpass

printf "\n \nCreating groups: testgroup, recursive_test_group, harvest_festival..."
groupadd testgroup
groupadd recursive_test_group
delay 200

printf "\n \nSetting up primary diagnostic workspace..."
mkdir -p /home/diagUser/diag_workspace/
chown diagUser /home/diagUser/diag_workspace/
chgrp testgroup /home/diagUser/diag_workspace/
chmod 775 /home/diagUser/diag_workspace/

cp /etc/sudoers /etc/sudoers.bak
delay 200
echo "sudouser ALL" >> /etc/sudoers
echo "sudouser2 ls" >> /etc/sudoers
printf "\n \nSetup complete."
printf "\n---------------------------------------------------------------------"

printf "\n \n--- Phase 2: Creating diagnostic assets ---"
cd /
printf "\n \nCreating basic FS assets..."
mkdir -p src mv_test_dir overwrite_dir find_test/subdir zip_test/nested_dir "a dir with spaces"
mkdir -p recursive_test/level2/level3
printf "\nInflating text/diff assets..."
echo -e "line one\nline two\nline three" > diff_a.txt
echo -e "line one\nline 2\nline three" > diff_b.txt
delay 200
printf "\nBuilding permissions assets..."
echo "I should not be executable" > exec_test.sh ; chmod 600 exec_test.sh
touch preserve_perms.txt; chmod 700 preserve_perms.txt
printf "\n \nDispensing data processing assets..."
delay 200
echo -e "zeta\nalpha\nbeta\nalpha\n10\n2" > sort_test.txt
echo "The quick brown fox." > text_file.txt
echo -e "apple\nbanana\napple\napple\norange\nbanana" > uniq_test.txt
echo -e "id,value,status\n1,150,active\n2,80,inactive\n3,200,active" > awk_test.csv
printf "\n \nGenerating xargs assets..."
delay 200
printf "\nZipping assets..."
echo "file one content" > zip_test/file1.txt
echo "nested file content" > zip_test/nested_dir/file2.txt
delay 200
printf "\nScripting assets..."
echo '#!/bin/oopis_shell' > /home/root/arg_test.sh
echo 'echo "Arg 1: $1, Arg 2: $2, Arg Count: $#, All Args: $@" ' >> /home/root/arg_test.sh
chmod 777 /home/root/arg_test.sh
delay 200
printf "\nSorting assets..."
touch -d "2 days ago" old.ext
touch -d "1 day ago" new.txt
echo "short" > small.log
echo "this is a very long line" > large.log
delay 200
printf "\nAssembling recursive test assets..."
echo "I am a secret" > recursive_test/secret.txt
echo "I am a deeper secret" > recursive_test/level2/level3/deep_secret.txt
delay 200
printf "\nElecting state management assets..."
echo "Original State" > state_test.txt
echo "Asset creation complete."
delay 200
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 3: Testing Core FS Commands ====="
delay 200
printf "\n \n--- Test: diff, cp -p, mv ---"
diff diff_a.txt diff_b.txt
cp -p preserve_perms.txt preserve_copy.sh
echo "Verifying preserved permissions:"
ls -l preserve_perms.txt preserve_copy.sh
mv exec_test.sh mv_test_dir/
ls mv_test_dir/
delay 200
printf "\n \n--- Test: rename (file and directory) ---"
echo "rename test file" > old_name.txt
rename old_name.txt new_name.txt
echo "Verifying file rename:"
ls new_name.txt
check_fail "ls old_name.txt"
mkdir old_dir
mv old_dir new_dir
printf "\n \nVerifying directory rename:"
ls -d new_dir/
check_fail "ls -d old_dir"
delay 200
echo "--- Test: rename failure conditions ---"
echo "another file" > another_file.txt
check_fail "rename new_name.txt another_file.txt"
check_fail "rename new_name.txt mv_test_dir/another_location.txt"
rm -r new_name.txt another_file.txt new_dir
printf "\n \n Rename tests complete."
delay 400
printf "\n \n --- Test: touch -d and -t ---"
touch -d "1 day ago" old_file.txt
touch -t 202305201200.30 specific_time.txt
ls -l old_file.txt specific_time.txt
printf "\n \n--- Test: ls sorting flags (-t, -S, -X, -r) ---"
printf "\nSorting by modification time (newest first):"
ls -lt
printf "\n \nSorting by size (largest first):"
ls -lS
delay 200
printf "\n \nSorting by extension:"
ls -lX
delay 200
printf "\n \nSorting by name in reverse order:"
ls -lr
printf "\n \n--- Test: cat -n ---"
cat -n diff_a.txt
delay 500
printf "\n \n--- Test: cd into a file (should fail) ---"
echo "this is a file" > not_a_directory.txt
delay 200
check_fail "cd not_a_directory.txt"
delay 200
rm not_a_directory.txt
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 4: Testing Group Permissions & Ownership (Expanded) ====="
delay 200
usermod -aG testgroup testuser
groups testuser
mkdir -p /tmp/no_exec_dir
chmod 644 /tmp/no_exec_dir
delay 500
cd /home/diagUser/diag_workspace
delay 200
echo "Initial content" > group_test_file.txt
delay 200
chown diagUser group_test_file.txt
chgrp testgroup group_test_file.txt
delay 200
chmod 664 group_test_file.txt
delay 200
su testuser testpass
printf "\n \n--- Test: Group write permission ---"
cd /home/diagUser/diag_workspace
delay 200
echo "Append by group member" >> group_test_file.txt
cat group_test_file.txt
logout
delay 500
printf "Logging in as guest"
delay 500
su Guest
echo "--- Test: 'Other' permissions (should fail) ---"
check_fail "echo 'Append by other user' >> /home/diagUser/diag_workspace/group_test_file.txt"
delay 200
printf "\n \n--- Test: Permission Edge Cases ---"
logout
delay 200
su testuser testpass
delay 200
check_fail "chmod 777 /home/diagUser/diag_workspace/group_test_file.txt"
check_fail "cd /tmp/no_exec_dir"
delay 200
logout
delay 200
su diagUser testpass
delay 200
cd /home/diagUser/diag_workspace
delay 500
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 4.5: Testing Recursive Ownership & Group Permissions ====="
delay 200
logout
delay 200
mkdir -p /home/Guest/recursive_chown_test/subdir
echo "level 1 file" > /home/Guest/recursive_chown_test/file1.txt
echo "level 2 file" > /home/Guest/recursive_chown_test/subdir/file2.txt
printf "\n \nInitial state:"
ls -lR /home/Guest/recursive_chown_test
delay 400
printf "\n \n--- Test: Recursive chown (-R) ---"
chown -R recursive_test_user /home/Guest/recursive_chown_test
printf "\n \nState after recursive chown:"
ls -lR /home/Guest/recursive_chown_test
delay 400
printf "\n \n--- Test: Recursive chgrp (-R) ---"
chgrp -R recursive_test_group /home/Guest/recursive_chown_test
printf "\n \nState after recursive chgrp:"
ls -lR /home/Guest/recursive_chown_test
delay 400
printf "\n \nRecursive ownership tests complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 5: Testing High-Level Committee Command ====="
delay 200
printf "\n \n--- Executing committee command ---"
committee --create harvest_festival --members comm_user1,comm_user2
delay 400
printf "\n \n--- Verifying results ---"
printf "\nChecking group memberships:"
groups comm_user1
groups comm_user2
printf "\n \nChecking directory and permissions:"
ls -l /home/ | grep "project_harvest_festival"
delay 400
printf "\n \n--- Test: Member write access (should succeed) ---"
su comm_user1 testpass
echo "I solemnly swear to bring a pie." > /home/project_harvest_festival/plan.txt
cat /home/project_harvest_festival/plan.txt
delay 400
logout
delay 200
printf "\n \n--- Test: Non-member access (should fail) ---"
delay 200
su Guest
check_fail "ls /home/project_harvest_festival"
check_fail "cat /home/project_harvest_festival/plan.txt"
delay 400
printf "\n \nCommittee command test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 6: Testing Sudo & Security Model ====="
delay 200
logout
delay 200
su sudouser testpass
printf "\n \nAttempting first sudo command (password required)..."
sudo echo "Sudo command successful."
testpass
delay 200
printf "\n \nAttempting second sudo command (should not require password)..."
sudo ls /home/root
logout
delay 200
su Guest
check_fail "sudo ls /home/root"
printf "\n \n--- Test: Granular sudo permissions ---"
logout
delay 200
su sudouser2 testpass
printf "\n \nAttempting allowed specific command (ls)..."
sudo ls /home/root
testpass
delay 200
printf "\n \nAttempting disallowed specific command (rm)..."
check_fail "sudo rm -f /home/Guest/README.md"
logout
delay 200
su diagUser testpass
cd /home/diagUser/diag_workspace
printf "\n \nGranular sudo test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 7: Testing Scripting & Process Management ====="
delay 200
logout
delay 200
cd /home/root
printf "\n \n--- Test: Script argument passing ---"
run ./arg_test.sh first "second arg" third
printf "\n \n--- Test: Background jobs (ps, kill) ---"
delay 5000 &
ps
ps | grep delay | awk '{print $1}' | xargs -I {} kill {}
ps
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 8: Testing Data Processing & Text Utilities ======="
delay 200
cd /
printf "\n \n--- Test: sort (-n, -r, -u) ---"
sort -r sort_test.txt
sort -n sort_test.txt
sort -u sort_test.txt
delay 400
printf "\n \n--- Test: wc (-l, -w, -c) ---"
wc text_file.txt
wc -l -w -c text_file.txt
printf "\n \n--- Test: head/tail (-n, -c) ---"
head -n 1 text_file.txt
tail -c 5 text_file.txt
delay 400
printf "\n \n--- Test: grep flags (-i, -v, -c) ---"
grep -i "FOX" text_file.txt
grep -c "quick" text_file.txt
grep -v "cat" text_file.txt
printf "\n \n--- Test: xargs and pipe awareness ---"
su diagUser testpass
cd /home/diagUser/diag_workspace
rm -f file1.tmp file2.tmp file3.tmp
touch file1.tmp file2.tmp file3.tmp
ls -1 *.tmp | xargs -I {} rm {}
check_fail "ls file1.tmp"
printf "\n \nxargs deletion verified."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 9: Testing 'find' and Archival (zip/unzip) ====="
delay 200
printf "\n \n--- Test: find by name, type, and permissions ---"
logout
mkdir -p find_test/subdir
touch find_test/a.txt find_test/b.tmp find_test/subdir/c.tmp
chmod 777 find_test/a.txt
find find_test -name "*.tmp"
find find_test -type d
find find_test -perm 777
delay 400
printf "\n \n--- Test: zip/unzip ---"
mkdir -p zip_test/nested_dir
echo "file one content" > zip_test/file1.txt
echo "nested file content" > zip_test/nested_dir/file2.txt
zip my_archive.zip ./zip_test
rm -r -f zip_test
unzip my_archive.zip .
ls -R zip_test
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 10: Testing Pager, Calculator, and Date Parsing ====="
delay 200
printf "\n \n--- Test: bc command (pipe and argument) ---"
echo "5 * (10 - 2) / 4" | bc
bc "100 + 1"
check_fail "bc '5 / 0'"
delay 400
printf "\n \n--- Test: Pager integration (non-interactive pipe-through) ---"
echo -e "Line 1\nLine 2\nLine 3" > pager_test.txt
cat pager_test.txt | more | wc -l
cat pager_test.txt | less | wc -l
printf "\n \nPager pass-through test complete."
printf "\n \n--- Test: Input Redirection (<) ---"
echo "hello redirect" > input_redir.txt
cat < input_redir.txt
delay 400
rm pager_test.txt input_redir.txt
printf "\n \nInput redirection test complete."
delay 200
printf "\n \n--- Test: expr command ---"
expr "10 + 5"
expr "(10 + 5) * 2"

printf "\n \n--- Test: Date parsing pipeline ---"
date | awk '{print $5}' | cut -c 3-4
printf "\n \nExpression and date tests complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 11: Testing Data Transformation & Integrity Commands ====="
delay 200
printf "\n \n--- Test: rmdir ---"
mkdir empty_dir
rmdir empty_dir
check_fail "ls empty_dir"
mkdir non_empty_dir
touch non_empty_dir/file.txt
check_fail "rmdir non_empty_dir"
rm -r non_empty_dir
printf "\n \nrmdir tests complete."
delay 200
printf "\n \n--- Test: base64 (encode/decode) ---"
echo "The Tao is eternal." > b64_test.txt
base64 b64_test.txt > b64_encoded.txt
base64 -d b64_encoded.txt > b64_decoded.txt
delay 200
cat b64_decoded.txt
delay 200
rm b64_test.txt b64_encoded.txt b64_decoded.txt
printf "\n \nbase64 tests complete."
delay 200
printf "\n \n--- Test: xor (encrypt/decrypt) ---"
echo "Harmony and order." > xor_test.txt
xor diag_pass xor_test.txt > xor_encrypted.txt
xor diag_pass xor_encrypted.txt
rm xor_test.txt xor_encrypted.txt
printf "\n \nxor tests complete."
delay 200
printf "\n \n--- Test: ocrypt (secure encrypt/decrypt) ---"
echo "A truly secure message." > ocrypt_test.txt
printf "\n \nEncrypting with correct key..."
ocrypt diag_secure_pass ocrypt_test.txt ocrypt_encrypted.txt
printf "\n \nVerifying successful decryption with correct key..."
ocrypt -d diag_secure_pass ocrypt_encrypted.txt ocrypt_decrypted.txt
grep "A truly secure message." ocrypt_decrypted.txt
printf "\n \nVerifying decryption failure with WRONG key (this should succeed)..."
check_fail "ocrypt -d wrong_password ocrypt_encrypted.txt"
rm ocrypt_test.txt ocrypt_encrypted.txt ocrypt_decrypted.txt
printf "\n \nocrypt secure tests complete."
delay 200
printf "\n \n--- Test: cksum and sync ---"
echo "A well-written program is its own Heaven." > cksum_test.txt
cksum cksum_test.txt
sync
delay 400
echo "A poorly-written program is its own Hell." >> cksum_test.txt
cksum cksum_test.txt
rm cksum_test.txt
printf "\n \ncksum and sync tests complete."
delay 200
printf "\n \n --- Test: csplit ---"
echo -e "alpha\n" > csplit_test.txt
echo -e "bravo\n" >> csplit_test.txt
echo -e "charlie\n" >> csplit_test.txt
echo -e "delta\n" >> csplit_test.txt
echo -e "echo" >> csplit_test.txt
delay 400
csplit csplit_test.txt 3
ls xx*
rm -f xx00 xx01 csplit_test.txt
printf "\n \ncsplit test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 12: Testing Underrepresented Commands (Data/System) ====="
delay 200
printf "\n \n--- Test: uniq (-d, -u) ---"
echo -e "apple\nbanana\napple\napple\norange\nbanana" > uniq_test.txt
sort uniq_test.txt | uniq -d
sort uniq_test.txt | uniq -u
printf "\n \n--- Test: awk scripting ---"
printf "\n \nPrinting active users with values over 100 from csv"
echo -e "id,value,status\n1,150,active\n2,80,inactive\n3,200,active" > awk_test.csv
awk -F, '/,active/ { print "User " $1 " is " $3 }' awk_test.csv
printf "\n \n--- Test: shuf (-i, -e) ---"
shuf -i 1-5 -n 3
shuf -e one two three four five
delay 400
printf "\n \n--- Test: tree (-L, -d) ---"
mkdir -p recursive_test/level2/level3
echo "I am a secret" > recursive_test.txt
echo "I am a deeper secret" > recursive_test/level2/level3/deep_secret.txt
tree -L 2 ./recursive_test
tree -d ./recursive_test
printf "\n \n--- Test: du (recursive) and grep (-R) ---"
du recursive_test/
grep -R "secret" recursive_test/
printf "\n \nUnderrepresented data command tests complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 13: Testing Shell & Session Commands ====="
delay 200
printf "\n \n--- Test: date ---"
date
printf "\n \n--- Test: df -h ---"
df -h
printf "\n \n--- Test: du -s ---"
du -s .
printf "\n \n--- Test: history -c ---"
history
delay 200
history -c
delay 200
history
delay 400
printf "\n \n--- Test: alias/unalias ---"
alias myls="ls -l"
myls
unalias myls
check_fail "myls"
printf "\n \n--- Test: set/unset ---"
set MY_VAR="Variable Test Passed"
echo $MY_VAR
unset MY_VAR
echo $MY_VAR
printf "\n \n--- Test: printscreen ---"
printscreen screen.txt
cat screen.txt
delay 200
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 14: Testing Edge Cases & Complex Scenarios (Expanded) ====="
delay 200
printf "\n \n--- Test: Filenames with spaces ---"
mkdir "my test dir"
echo "hello space" > "my test dir/file with spaces.txt"
ls "my test dir"
cat "my test dir/file with spaces.txt"
mv "my test dir" "your test dir"
ls "your test dir"
rm -r "your test dir"
delay 200
check_fail "ls 'my test dir'"
printf "\n \nSpace filename tests complete."
delay 200

printf "\n \n--- Test: Advanced find commands (-exec, -delete, operators) ---"
mkdir -p find_exec_test/subdir
touch find_exec_test/file.exec
touch find_exec_test/subdir/another.exec
touch find_exec_test/file.noexec
printf "\n \n--- Test -exec to change permissions ---"
find ./find_exec_test -name "*.exec" -exec chmod 777 {} \;
ls -l find_exec_test/
ls -l find_exec_test/subdir/
printf "\n \n--- Test -delete and -o (OR) ---"
delay 200
find ./find_exec_test -name "*.noexec" -o -name "another.exec" -delete
ls -R find_exec_test
rm -r find_exec_test
printf "\n \nAdvanced find tests complete."
delay 200

printf "\n \n--- Test: Complex pipes and append redirection (>>) ---"
echo -e "apple\nbanana\norange\napple" > fruit.txt
cat fruit.txt | grep "a" | sort | uniq -c > fruit_report.txt
printf "\n \n--- Initial Report ---"
cat fruit_report.txt
echo "One more apple" >> fruit_report.txt
printf "\n \n--- Appended Report ---"
cat fruit_report.txt
rm fruit.txt fruit_report.txt
printf "\n \nPiping and redirection tests complete."
delay 200

printf "\n \n--- Test: Logical OR (||) and interactive flags ---"
check_fail "cat nonexistent_file.txt" || echo "Logical OR successful: cat failed as expected."
echo "YES" > yes.txt
echo "n" > no.txt
touch interactive_test.txt
rm -i interactive_test.txt < yes.txt
check_fail "ls interactive_test.txt"
touch another_file.txt
delay 200
printf "\n \nInteractive Copy Test"
mkdir overwrite_dir
cp -i another_file.txt overwrite_dir/another_file.txt < yes.txt
delay 200
cat ./overwrite_dir/another_file.txt
delay 200
printf "\n \nDid it work?"
delay 200
rm -r no.txt yes.txt another_file.txt overwrite_dir
printf "\n \nInteractive flag and logical OR tests complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 15: Testing Paranoid Security & Edge Cases ====="
delay 200
printf "\n \n--- Test: Advanced 'awk' with BEGIN/END blocks ---"
echo -e "10 alpha\n20 bravo\n30 charlie" > awk_data.txt
awk 'BEGIN { print "Report Start" } { print "Item " NR ":", $2 } END { print "Report End" }' awk_data.txt
rm awk_data.txt
delay 200
printf "\n \n--- Test: Scripting scope (ensure child script cannot modify parent shell) ---"
echo 'set CHILD_VAR="i am from the child"' > set_var.sh
chmod 700 ./set_var.sh
run ./set_var.sh
check_fail -z "echo $CHILD_VAR"
rm set_var.sh
printf "\n \nScripting scope test complete."
delay 200
printf "\n \n--- Test: 'find' and 'xargs' with spaced filenames ---"
rm -f "a file with spaces.tmp"
touch "a file with spaces.tmp"
find . -name "*.tmp" | xargs -I {} rm "{}"
check_fail "ls \"a file with spaces.tmp\""
echo "'find' and 'xargs' with spaces test complete."
delay 200
printf "\n \n--- Test: Input redirection and empty file creation ---"
> empty_via_redir.txt
echo "some data" > input.txt
cat < input.txt
rm empty_via_redir.txt input.txt
printf "\n \nRedirection tests complete."
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 16: Testing 'run' Command & Script Execution ====="
delay 200
printf "\n \n--- Test: Basic script execution ---"
echo 'echo "Hello from a run script!"' > simple_test.sh
chmod 755 simple_test.sh
run ./simple_test.sh
rm simple_test.sh
printf "\n \nBasic execution test complete."
delay 200
printf "\n \n--- Test: Script argument passing ---"
echo '#!/bin/oopis_shell' > arg_passing_test.sh
echo 'echo "Arg 1: $1, Arg 2: $2, Arg Count: $#, All Args: $@" ' >> arg_passing_test.sh
chmod 755 arg_passing_test.sh
run ./arg_passing_test.sh first "second arg" third
rm arg_passing_test.sh
printf "\n \nArgument passing test complete."
delay 200
printf "\n \n--- Test: Script environment sandboxing ---"
echo 'set CHILD_VAR="i am from the child"' > scope_test.sh
chmod 755 ./scope_test.sh
run ./scope_test.sh
check_fail -z "echo $CHILD_VAR"
rm scope_test.sh
printf "\n \nScript sandboxing test complete."
delay 400
printf "\n \n--- 'run' command diagnostics finished ---"
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 17: Testing Symbolic Link Infrastructure ====="
delay 200
printf "\n \n--- Test: Symlink creation and display ---"
echo "This is the original target file." > original_target.txt
ln -s original_target.txt my_link
printf "\n \nVerifying link display with 'ls -l':"
ls -l my_link
printf "\n \n--- Test: Symlink content resolution via 'cat' ---"
cat my_link
delay 200
printf "\n \n--- Test: 'rm' behavior on symlinks vs. targets ---"
printf "\n \nRemoving the link 'my_link'..."
rm my_link
printf "\n \nVerifying original file still exists:"
ls original_target.txt
delay 200
printf "\n \nRecreating link and removing the target..."
ln -s original_target.txt my_link
rm original_target.txt
printf "\n \nVerifying link is now dangling (ls should still show it):"
ls -l my_link
delay 200
check_fail "cat my_link"
printf "\n \nDangling link test complete."
delay 200
printf "\n \n--- Test: Symlink infinite loop detection (CRUCIAL) ---"
ln -s link_b link_a
ln -s link_a link_b
printf "\n \nAttempting to cat a circular link (should fail gracefully)..."
check_fail "cat link_a"
printf "\n \nLoop detection test complete."
delay 200
echo "Symbolic link tests complete."
echo "---------------------------------------------------------------------"
delay 200

printf "\n \n===== Phase 18: Advanced Job Control & Signal Handling ====="
delay 200
printf "\n \n--- Test: Starting a long-running background job ---"
delay 30000 &
printf "\n \n--- Running pipeline diagnostics ---"
delay 200
printf "\n \n--- 1. Output of 'ps' ---"
ps > ps_output.tmp
cat ps_output.tmp
printf "\n \n--- 2. Output of 'ps | grep delay' ---"
cat ps_output.tmp | grep "delay 30000" > grep_output.tmp
cat grep_output.tmp
printf "\n \n--- 3. Output of 'ps | grep delay 30000 | awk' ---"
cat grep_output.tmp | awk '{print $1}' > awk_output.tmp
cat awk_output.tmp
printf "\n \n--- End of pipeline diagnostics ---"
JOB_ID=$(cat awk_output.tmp)
printf "\n \nStarted background job with PID: $JOB_ID"
rm ps_output.tmp grep_output.tmp awk_output.tmp
delay 200
kill -STOP $JOB_ID
printf "\n \n--- Test: Verifying job is 'Running' (R) with 'ps' and 'jobs' ---"
ps | grep "$JOB_ID" | grep 'R'
jobs
printf "\n \nJob status is correctly reported as 'R'."
delay 200
printf "\n \n--- Test: Pausing the job with 'kill -STOP' ---"
kill -STOP $JOB_ID
printf "\n \nSignal -STOP sent to job $JOB_ID."
delay 1000
printf "\n \n--- Test: Verifying job is 'Stopped' (T) ---"
ps | grep "$JOB_ID" | grep 'T'
jobs
printf "\n \nJob status is correctly reported as 'T'."
delay 400
printf "\n \n--- Test: Resuming the job with 'bg' ---"
bg %$JOB_ID
printf "\n \n'bg' command sent to job $JOB_ID."
delay 400
printf "\n \n--- Test: Verifying job is 'Running' (R) again ---"
ps | grep "$JOB_ID" | grep 'R'
jobs
printf "\n \nJob status is correctly reported as 'R' after resuming."
delay 400
printf "\n \n--- Test: Terminating the job with 'kill' ---"
kill -KILL $JOB_ID
printf "\n \nSignal -KILL sent to job $JOB_ID."
delay 1000
printf "\n \n--- Test: Verifying job has been terminated ---"
check_fail -z "ps | grep '$JOB_ID'"
jobs
printf "\n \nJob successfully terminated and removed from process lists."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 19: Testing Stream & Text Manipulation Commands ====="
delay 200
printf "\n \n--- Test: nl (Number Lines) Command ---"
echo -e "Line 1\n\nLine 3" > nl_test.txt
echo "Testing nl on a file with blank lines:"
nl nl_test.txt
delay 200
printf "\n \nTesting nl on piped input:"
cat nl_test.txt | nl
rm nl_test.txt
printf "\n \nnl test complete."
delay 200
printf "\n \n--- Test: sed (Stream Editor) Command ---"
printf "\n \nCreate a test file for substitution..."
delay 400
echo "The quick brown fox jumps over the lazy dog." > sed_test.txt
echo "The fox is a fox." >> sed_test.txt
printf "\n \nOriginal content:"
cat sed_test.txt
delay 200
printf "\n \nTesting single substitution:"
cat sed_test.txt | sed 's/fox/cat/'
delay 200
printf "\n \nTesting global substitution:"
cat sed_test.txt | sed 's/fox/cat/g'
rm sed_test.txt
printf "\n \nsed test complete."
delay 400
printf "\n \nCreate a test file for cutting..."
delay 200
echo "first:second:third:fourth" > cut_test.txt
echo "apple,orange,banana,grape" >> cut_test.txt
echo "one;two;three;four" >> cut_test.txt
delay 200
printf "\n \n--- Test: cut with colon delimiter ---"
cut -d: -f1,3 cut_test.txt
delay 200
printf "\n \n--- Test: cut with comma delimiter from pipe ---"
cat cut_test.txt | grep "apple" | cut -d, -f2,4
delay 200
printf "\n \n--- Test: cut with semicolon delimiter ---"
cut -d';' -f2,3,4 cut_test.txt
delay 200
printf "\n \n--- Test: check_fail on missing fields flag ---"
check_fail "cut -d, cut_test.txt"
delay 200
rm cut_test.txt
printf "\n \n'cut' command diagnostics finished."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 20: Testing 'tr' Command Suite ====="
delay 200
printf "\n \n--- Test: tr - Basic translation (lower to upper) ---"
echo "hello world" | tr 'a-z' 'A-Z'
delay 200
printf "\n \n--- Test: tr - Character class translation ---"
echo "test 123" | tr '[:lower:]' '[:upper:]'
delay 200
printf "\n \n--- Test: tr -d (delete) with character class ---"
echo "abc-123-def" | tr -d '[:digit:]'
delay 200
printf "\n \n--- Test: tr -s (squeeze-repeats) ---"
echo "hellloooo     woooorld" | tr -s 'o'
delay 200
printf "\n \n--- Test: tr -c (complement) ---"
echo "123abc456" | tr -c '[:digit:]' '_'
delay 200
printf "\n \n--- Test: tr -cs (complement and squeeze) ---"
echo "###Hello... World!!!" | tr -cs '[:alnum:]' '_'
delay 200
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 21: Testing 'comm' Command Suite ====="
delay 200
printf "\n \n--- Test: comm - Creating sorted test files ---"
echo -e "apple\nbanana\ncommon\npear" > comm_a.txt
echo -e "banana\ncommon\norange\nstrawberry" > comm_b.txt
delay 200

printf "\n \n--- Test: comm - Default (three columns) ---"
comm comm_a.txt comm_b.txt
delay 200

printf "\n \n--- Test: comm - Suppress column 1 (-1) ---"
comm -1 comm_a.txt comm_b.txt
delay 200

printf "\n \n--- Test: comm - Suppress column 2 (-2) ---"
comm -2 comm_a.txt comm_b.txt
delay 200

printf "\n \n--- Test: comm - Suppress column 1 and 3 (-13) ---"
comm -13 comm_a.txt comm_b.txt
delay 200

printf "\n \n--- Test: comm - Suppress column 1 and 2 (-12) ---"
comm -12 comm_a.txt comm_b.txt
delay 200

printf "\n \n--- Cleaning up comm test files ---"
rm comm_a.txt comm_b.txt
printf "\n \ncomm test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 22: Testing Binder Command Suite ====="
delay 200

printf "\n \n--- Setting up binder test environment ---"
mkdir -p binder_test/docs binder_test/assets
echo "research data" > binder_test/docs/research.txt
echo "project notes" > binder_test/notes.txt
echo "asset" > binder_test/assets/icon.svg
delay 400

printf "\n \n--- Test: binder create ---"
binder create project_alpha
ls project_alpha.binder
delay 400

printf "\n \n--- Test: binder add (with sections) ---"
binder add project_alpha.binder ./binder_test/docs/research.txt -s documents
binder add project_alpha.binder ./binder_test/notes.txt -s general
binder add project_alpha.binder ./binder_test/assets/icon.svg -s assets
delay 400

printf "\n \n--- Test: binder list ---"
binder list project_alpha.binder
delay 400

printf "\n \n--- Test: binder exec ---"
printf "\n \nExecuting 'cksum' on all files in the binder:"
binder exec project_alpha.binder -- cksum {}
delay 400

printf "\n \n--- Test: binder remove ---"
binder remove project_alpha.binder ./binder_test/notes.txt
delay 400

printf "\n \n--- Test: binder list (after removal) ---"
binder list project_alpha.binder
delay 400

printf "\n \n--- Cleaning up binder test environment ---"
rm -r -f binder_test
rm project_alpha.binder
printf "\n \nBinder command suite test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 23: Testing Agenda Command (Non-Interactive) ====="
delay 200

printf "\n \n--- Test: Scheduling a job with sudo ---"
sudo agenda add "* * * * *" "echo agenda_test"
delay 2000

printf "\n \n--- Test: Listing the job ---"
agenda list

printf "\n \n--- Test: Verifying schedule file ownership (should be root) ---"
printf "\n \nChecking if agenda daemon created the schedule file..."
delay 2000
printf "\n \nAttempting to check file ownership (may show error if file doesn't exist):"
ls -l /etc/agenda.json || echo "Note: /etc/agenda.json not found - this is expected if no jobs were persisted"

printf "\n \n--- Test: Removing the job with sudo ---"
sudo agenda remove 1
delay 500

printf "\n \n--- Test: Verifying job removal ---"
agenda list

rm /etc/agenda.json || echo "Note: /etc/agenda.json was not found during cleanup."

printf "\n \nAgenda command test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase 24: Testing Brace Expansion Features ====="
delay 200

printf "\n \n--- Test: Comma expansion {a,b,c} ---"
printf "\n \nTesting basic comma expansion:"
echo {hello,world,test}
delay 200

printf "\n \n--- Test: File operations with comma expansion ---"
touch test_file.txt
cp test_file.txt{,.bak}
ls test_file*
rm test_file.txt test_file.txt.bak
printf "\n \nFile copy with brace expansion complete."
delay 200

printf "\n \n--- Test: Directory creation with comma expansion ---"
mkdir {dir1,dir2,dir3}
ls -d dir*
rmdir dir1 dir2 dir3
printf "\n \nDirectory creation with brace expansion complete."
delay 200

printf "\n \n--- Test: Numeric sequence expansion {1..5} ---"
printf "\nTesting numeric sequence:"
echo {1..5}
delay 200

printf "\n \n--- Test: Reverse numeric sequence {5..1} ---"
printf "\nTesting reverse numeric sequence:"
echo {5..1}
delay 200

printf "\n \n--- Test: Alphabetic sequence expansion {a..e} ---"
printf "\nTesting alphabetic sequence:"
echo {a..e}
delay 200

printf "\n \n--- Test: Reverse alphabetic sequence {e..a} ---"
printf "\nTesting reverse alphabetic sequence:"
echo {e..a}
delay 200

printf "\n \n--- Test: File creation with sequence expansion ---"
touch file{1..3}.txt
ls file*.txt
rm file1.txt file2.txt file3.txt
printf "\n \nFile creation with sequence expansion complete."
delay 200

printf "\n \n--- Test: Complex brace expansion with paths ---"
mkdir -p test_dir/{sub1,sub2,sub3}
ls -R test_dir/
rm -r test_dir
printf "\n \nComplex path expansion complete."
delay 200

printf "\n \n--- Test: Mixed expansion types ---"
printf "\nTesting mixed comma and sequence:"
echo prefix_{1..3,a,b}_suffix
delay 200

printf "\n \nBrace expansion tests complete."
logout

echo "===== Phase 25: Testing Magical Commands (cast) ====="
delay 200

printf "\n \n--- Test: cast ward ---"
echo "This is a secret message." > secret_missive.txt
printf "\n \nWarding the missive for 10 seconds..."
chmod 777 secret_missive.txt
cast ward secret_missive.txt 10s
delay 500

printf "\n \nVerifying permissions are now read-only..."
ls -l secret_missive.txt | grep 'r--r--r--'
su Guest
printf "\n \nAttempting to overwrite warded file (should fail with a specific magical error)..."
check_fail "echo 'overwrite attempt' >> secret_missive.txt"
delay 200

printf "\n \nWaiting for ward to expire (12 seconds)..."
delay 12000

printf "\n \nAttempting to write to the file again (should now succeed)..."
echo "The ward has fallen." >> secret_missive.txt
delay 200

printf "\n \nVerifying content of the missive:"
cat secret_missive.txt
grep "The ward has fallen." secret_missive.txt
delay 200

printf "\n \nCleaning up magical artifacts..."
printf "\n \nWard spell test complete."
delay 400
echo "---------------------------------------------------------------------"
logout
rm -f secret_missive.txt

printf  "\n ===== Phase X: Testing Filesystem Torture & I/O Gauntlet ====="
delay 200

printf "\n \n--- Test: Handling of obnoxious filenames ---"
mkdir -p "./a directory with spaces and.. special'chars!"
touch "./a directory with spaces and.. special'chars!/-leading_dash.txt"
echo "obnoxious" > "./a directory with spaces and.. special'chars!/test.txt"
delay 200
ls -l "./a directory with spaces and.. special'chars!"
cat "./a directory with spaces and.. special'chars!/test.txt"
rm -r -f "./a directory with spaces and.. special'chars!"
check_fail "ls './a directory with spaces and.. special'chars!'"
printf "\n \nObnoxious filename tests complete."
delay 300
printf "\n \n--- Test: File ownership vs. permissions paradox ---"
delay 200
touch paradox.txt
chown paradoxuser paradox.txt
chmod 000 paradox.txt
su paradoxuser testpass
check_fail "cat /paradox.txt"
printf "\n \nPermission paradox test complete."
delay 200
logout
delay 200
su diagUser testpass
cd /home/diagUser/diag_workspace
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase Z: Testing Process & State Integrity Under Stress ====="
delay 200

printf "\n \n--- Test: Background process race condition ---"
echo "one" > race.txt &
echo "two" > race.txt &
echo "three" > race.txt &
delay 400
printf "\n \nRace condition test initiated. Final content of race.txt:"
cat race.txt
rm race.txt
printf "\n \nRace condition test complete."
delay 200
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase Alpha: Core Command & Flag Behavior ====="
delay 200

printf "\n \n--- Test: diff Command ---"
echo -e "line one\nline two\nline three" > diff_a.txt
echo -e "line one\nline 2\nline three" > diff_b.txt
diff diff_a.txt diff_b.txt
rm diff_a.txt diff_b.txt
printf "\n \ndiff test complete."
delay 200

printf "\n \n--- Test: cp -p (Preserve Permissions) ---"
touch preserve_perms.txt
chmod 700 preserve_perms.txt
delay 200
cp -p preserve_perms.txt preserve_copy.sh
printf "\n \nVerifying preserved permissions:"
ls -l preserve_perms.txt preserve_copy.sh
rm preserve_perms.txt preserve_copy.sh
printf "\n \ncp -p test complete."
delay 200

printf "\n \n--- Test: touch with Time-Stamping ---"
touch -d "1 day ago" old_file.txt
touch -t 202305201200.30 specific_time.txt
printf "\n \nVerifying timestamps:"
ls -l old_file.txt specific_time.txt
rm old_file.txt specific_time.txt
printf "\n \ntouch timestamp test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase Beta: Group Permissions & Sudo ====="
delay 200
logout
delay 200
echo "--- Test: Group Permissions ---"
delay 200
usermod -aG testgroup testuser
delay 1000
touch /home/diagUser/diag_workspace/group_test_file.txt
chown diagUser /home/diagUser/diag_workspace/group_test_file.txt
chgrp testgroup /home/diagUser/diag_workspace/group_test_file.txt
chmod 664 /home/diagUser/diag_workspace/group_test_file.txt
delay 200
su testuser testpass
cd /home/diagUser/diag_workspace
printf "\n \nAppending to file as group member (should succeed)..."
echo "appended" >> /home/diagUser/diag_workspace/group_test_file.txt
cat /home/diagUser/diag_workspace/group_test_file.txt
logout
su Guest
printf "\n \nAppending to file as Guest (should fail)..."
check_fail "echo 'appended by guest' >> /home/diagUser/diag_workspace/group_test_file.txt"
printf "\n \nGroup permissions test complete."
delay 200

printf "\n \n===== Phase Delta: Advanced Data & Process Management ====="
delay 200
logout
su diagUser testpass
cd /home/diagUser/diag_workspace

printf "\n \n--- Test: sort Flags ---"
echo -e "10\n2\napple\nbanana\napple" > sort_test.txt
echo "Numeric sort:"
sort -n sort_test.txt
echo "Reverse sort:"
sort -r sort_test.txt
echo "Unique sort:"
sort -u sort_test.txt
delay 200
rm sort_test.txt
printf "\n \nsort test complete."
delay 200

printf "\n \n--- Test: find with -exec and -delete ---"
mkdir find_exec_test
delay 200
touch find_exec_test/test.exec
touch find_exec_test/test.noexec
printf "\n \nChanging permissions with find -exec..."
find ./find_exec_test -name "*.exec" -exec chmod 777 {} \;
ls -l find_exec_test
delay 200
printf "\n \nDeleting with find -delete..."
find ./find_exec_test -name "*.noexec" -delete
ls -l find_exec_test
rm -r find_exec_test
printf "\n \nfind actions test complete."
delay 200

printf "\n \n--- Test: Pagers (more, less) Non-Interactive ---"
echo -e "line 1\nline 2\nline 3" > pager_test.txt
printf "\n \nPiping to 'more'..."
cat pager_test.txt | more | wc -l
printf "\n \nPiping to 'less'..."
cat pager_test.txt | less | wc -l
rm pager_test.txt
printf "\n \nPager test complete."
delay 200

printf "\n \n--- Test: Input Redirection (<) ---"
echo "Redirected input" > input_redir.txt
cat < input_redir.txt
rm input_redir.txt
printf "\n \nInput redirection test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase Theta: Filesystem Integrity & Edge Cases ====="
delay 200

printf "\n \n--- Test: rmdir on Non-Empty Directory ---"
mkdir non_empty_dir
touch non_empty_dir/file.txt
check_fail "rmdir non_empty_dir"
rm -r non_empty_dir
printf "\n \nrmdir on non-empty test complete."
delay 200

printf "\n \n--- Test: File I/O with Special Characters ---"
mkdir "a directory with spaces and.. special'chars!"
touch "a directory with spaces and.. special'chars!/-leading_dash.txt"
echo "Special content" > "a directory with spaces and.. special'chars!/-leading_dash.txt"
cat "a directory with spaces and.. special'chars!/-leading_dash.txt"
rm -r "a directory with spaces and.. special'chars!"
printf "\n \nSpecial characters test complete."
delay 200

printf "\n \n--- Test: xargs with Quoted Arguments ---"
rm -f "a file with spaces.tmp" "a file with spaces.tmp.bak"
touch "a file with spaces.tmp"
ls *.tmp | xargs -I {} mv {} {}.bak
ls *.bak
delay 200
rm *.bak
printf "\n \nxargs with quotes test complete."
delay 400
echo "---------------------------------------------------------------------"

printf "\n \n===== Phase Gamma: Testing Diff and Patch Integration ====="
delay 200

printf "\n \n--- Test: Creating base files for diff and patch ---"
echo -e "The original first line.\nA second line, which will remain.\nThe third line is the charm." > original_document.txt
echo -e "The first line, now modified.\nA second line, which will remain.\nThe third line is the charm." > modified_document.txt
printf "\n \nBase files created."
delay 200

printf "\n \n--- Test: Generating a patch file with a custom utility ---"
diff -u original_document.txt modified_document.txt > changes.diff
printf "\n \nPatch file 'changes.diff' generated. Contents:"
cat changes.diff
delay 200

printf "\n \n--- Test: Applying the patch to the original file ---"
patch original_document.txt changes.diff
printf "\n \nPatch applied."
delay 200

printf "\n \n--- Test: Verifying the patched file (should show no differences) ---"
check_fail -z "diff original_document.txt modified_document.txt"
printf "\n \nVerification complete. If no failure was reported, the test was successful."
delay 200

printf "\n \n--- Cleaning up patch test files ---"
rm original_document.txt modified_document.txt changes.diff
printf "\n \nPatch integration test complete."
delay 400

printf "\n \n--- Phase Omega: Final Cleanup ---"
logout
delay 200
cd /
delay 300
removeuser -f diagUser
removeuser -f sudouser
removeuser -f testuser
removeuser -f comm_user1
removeuser -f comm_user2
removeuser -f limitedsudo
removeuser -f paradoxuser
removeuser -f recursive_test_user
removeuser -f sudouser2
delay 200
rm -r -f /home/diagUser
rm -r -f /home/sudouser
rm -r -f /home/testuser
rm -r -f /home/comm_user1
rm -r -f /home/comm_user2
rm -r -f /home/limitedsudo
rm -r -f /home/paradoxuser
rm -r -f /home/recursive_test_user
rm -r -f /home/sudouser2
rm -r -f /home/sudouser2
rm -r -f /find_test
rm -r -f /overwrite_dir
rm -r -f /recursive_test
rm -r -f /zip_test
rm -r -f /tmp/*
rm -r -f /home/Guest/recursive_chown_test
rm -f /awk_test.csv
rm -f /interactive_test.txt
rm -f /link_a
rm -f /link_b
rm -f /my_archive.zip
rm -f /my_link
rm -f /paradox.txt
rm -f /uniq_test.txt
rm -f /screen.txt

delay 200

groupdel testgroup
groupdel recursive_test_group
groupdel harvest_festival

delay 500
printf "\n \n===== OopisOS Planner Command Test Suite ====="
delay 500

printf "\n \n--- Phase 1: Setup and User Creation ---"
printf "\n \nCreating test users 'plan_user1' and 'plan_user2'..."
useradd plan_user1
testpass
testpass
delay 200
useradd plan_user2
testpass
testpass
delay 200
printf "\n \nTest users created."
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 2: User-Level Planner Test (As plan_user1) ---"
su plan_user1 testpass
delay 200
printf "\n \nSwitched to plan_user1. Creating a personal planner..."
planner create personal_goals
delay 200
printf "\n \nVerifying personal planner file was created in ~/.plans/..."
ls /home/plan_user1/.plans/
delay 300
printf "\n \nAdding and completing a personal task..."
planner personal_goals add "Organize all my binders"
planner personal_goals done 1
delay 200
logout
delay 200
printf "\n \nLogged out from plan_user1."
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 3: Committee Integration Test (As root) ---"
printf "\nCreating a new committee with our test users..."
committee --create harvest_fest --members plan_user1,plan_user2
delay 300
printf "\n \nVerifying that a planner was automatically created..."
ls /home/project_harvest_fest/
delay 200
printf "\n \nChecking contents of the auto-generated planner..."
cat /home/project_harvest_fest/harvest_fest.planner
delay 500
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 4: Shared Planner & Permissions Test ---"
printf "\nSwitching to plan_user2 to test shared planner access..."
su plan_user2 testpass
delay 200
printf "\n \nAdding a task to the shared 'harvest_fest' planner (should succeed)..."
planner /home/project_harvest_fest/harvest_fest.planner add "Book Lil' Sebastian"
delay 200
printf "\n \nAssigning a task to plan_user1..."
planner /home/project_harvest_fest/harvest_fest.planner assign plan_user1 2
delay 200
logout
delay 200
printf "\n \nSwitching to plan_user1 to complete the assigned task..."
su plan_user1 testpass
delay 200
planner /home/project_harvest_fest/harvest_fest.planner done 2
delay 200
logout
delay 200
printf "\n \nLogged out from both users."
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 5: Gamification and Scoring Test (As root) ---"
printf "\nChecking the productivity scores..."
score
delay 500
printf "\n \nVerified scores. plan_user1 should have 2 points."
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 6: Linking & Scheduling Test (As root)---"
printf "\nCreating a system-wide project for linking/scheduling tests..."
planner create operation_sparrow
delay 200
printf "\n \nCreating a dummy file to link to a task..."
touch /etc/briefing.md
delay 200
planner operation_sparrow add "Review briefing document"
planner operation_sparrow link 1 /etc/briefing.md
planner operation_sparrow schedule 1 "* * * * *"
delay 300
printf "\n \nDisplaying project to verify link and schedule annotations:"
planner operation_sparrow
delay 500
printf "\n \nVerifying that the task was added to the main agenda..."
cat /etc/agenda.json
delay 500
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 7: Final Permission Checks (Negative Testing) ---"
printf "\nSwitching to plan_user2..."
su plan_user2 testpass
delay 200
printf "\n \nAttempting to modify plan_user1's personal planner (should fail)..."
check_fail "planner /home/plan_user1/.plans/personal_goals.planner add \"Snoop on plans\""
delay 300
logout
delay 200
echo "Logged out from plan_user2."
echo "----------------------------------------------------------------------"

printf "\n \n--- Phase 8: Comprehensive Cleanup ---"
printf "\nRemoving test users..."
removeuser -f plan_user1
removeuser -f plan_user2
delay 200
printf "\n \nRemoving test project files and directories..."
rm -f /etc/projects/operation_sparrow.json
rm -f /etc/briefing.md
rm -f /*.txt
rm -f /large.log
rm -f /preserve_copy.sh
rm -f /small.log
rm -f /old.ext
rm -r -f /home/project_harvest_fest
rm -r -f /home/project_harvest_festival
rm -f /home/root/arg_test.sh
rm -f /home/root/paradox.txt
rm -r -f /home/plan_user1
rm -r -f /home/plan_user2
rm -r -f '/a dir with spaces'
rm -r -f /mv_test_dir
rm -f /var/log/scores.json
cp -f /etc/sudoers.bak /etc/sudoers
rm -f /etc/sudoers.bak

groupdel harvest_fest
delay 300
printf "\n \nVerifying cleanup..."
check_fail "ls /etc/projects/operation_sparrow.json"
check_fail "ls /home/project_harvest_fest"
check_fail "cat /var/log/scores.json"

printf "\n \n===== Planner Command Test Suite Complete! ====="

listusers
delay 200
cd /home/root

delay 400
printf "\n \n---------------------------------------------------------------------"
echo ""
echo "      ===== SamwiseOS Core Test Suite v0.0.5 Complete ======="
echo " "
delay 500
echo "  ======================================================"
delay 150
echo "  ==                                                  =="
delay 150
echo "  ==           SamwiseOS Core Diagnostics             =="
delay 150
echo "  ==            ALL SYSTEMS OPERATIONAL               =="
delay 150
echo "  ==                                                  =="
delay 150
echo "  ======================================================"

printf "\n \n"
delay 400
printf "\n \n(As usual, you've been a real pantload!)"
beep
delay 650
printf "\n \n"
play E6 20n; play F6 32n; play F#6 32n; play A6 32n; play D7 64n
delay 200