#! /usr/bin/bash
set -eox pipefail

# set up ssh keygen                                                             
if [ -n ${HOME}/.ssh ]; then                                                    
    echo "${HOME}/.ssh exists"                                                  
else                                                                            
    mkdir -p ${HOME}/.ssh                                                       
fi                                                                              
if [ -n ${HOME}/.ssh/config ]; then                                             
    echo "${HOME}/.ssh/config exists. Truncating contents."                     
    truncate -s 0 ${HOME}/.ssh/config                                           
else                                                                               
    touch ${HOME}/.ssh/config                                                      
fi                                                                                 
#play_alert # scream                                                                
read -p 'What is the email address to associate with this GitHub account?' githubEmail
ssh-keygen -t ed25519 -C "$githubEmail"                                            
eval "$(ssh-agent -s)"                                                             
ssh-add ~/.ssh/id_ed25519 
