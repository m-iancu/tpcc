# upload new limits.conf
sudo scp $SCP_ARGS -ostricthostkeychecking=no limits.conf $SSH_USER@$1:~
sudo ssh $SSH_ARGS -ostricthostkeychecking=no $SSH_USER@$1 'sudo cp ~/limits.conf /etc/security/limits.conf'
# Install tpcc
sudo ssh $SSH_ARGS -ostricthostkeychecking=no $SSH_USER@$1 'rm -rf ~/tpcc; rm ~/tpcc.tar.gz; sudo yum install -y java'
sudo scp $SCP_ARGS -ostricthostkeychecking=no tpcc.tar.gz $SSH_USER@$1:~
sudo ssh $SSH_ARGS -ostricthostkeychecking=no $SSH_USER@$1 'tar -zxvf tpcc.tar.gz'
# upload loader and execute scripts
sudo scp $SCP_ARGS -ostricthostkeychecking=no loader$2.sh $SSH_USER@$1:~/loader.sh
sudo scp $SCP_ARGS -ostricthostkeychecking=no execute$2.sh $SSH_USER@$1:~/execute.sh
sudo ssh $SSH_ARGS -ostricthostkeychecking=no $SSH_USER@$1 'ulimit -a'
