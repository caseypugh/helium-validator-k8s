server=$1
cmd=$2
user=loris
runner_path=/home/$user/actions-runner

if [[ $cmd == "install" ]]; then
  echo "Adding loris user"
  ssh $server "adduser $user && \ 
          groupadd docker && \
          usermod -aG docker $user"

  echo; echo "Paste the token from self-hosted runner page https://github.com/caseypugh/helium-validator/settings/actions/add-new-runner?arch=x64&os=linux"
  read token

  echo; echo "Installing action runner..."
  su="sudo su $user -c"
  ssh $server "$su \"mkdir -p $runner_path && \
    cd $runner_path && \
    curl -O -L https://github.com/actions/runner/releases/download/v2.277.1/actions-runner-linux-x64-2.277.1.tar.gz && \
    tar xzf $runner_path/actions-runner-linux-x64-2.277.1.tar.gz && \
    ./config.sh --url https://github.com/caseypugh/helium-validator --token $token\""

  echo; echo "Starting runner service..."
  ssh $server "cd $runner_path && ./svc.sh install && ./svc.sh start"

  echo; echo "Finished!"
fi

if [[ $cmd == "uninstall" ]]; then
  ssh $1 "cd $runner_path && ./svc.sh uninstall; cd ..; rm -rf actions-runner"
fi