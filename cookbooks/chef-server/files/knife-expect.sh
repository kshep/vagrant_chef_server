#!/usr/bin/expect

spawn knife configure -i

expect "Where should I put the config file?"
send "/home/vagrant/.chef/knife.rb\r"

expect "Please enter the chef server URL:"
send "\r"

expect "Please enter a clientname for the new client:"
send "vagrant\r"

expect "Please enter the existing admin clientname:"
send "\r"

expect "Please enter the location of the existing admin client's private key:"
send "/home/vagrant/.chef/webui.pem\r"

expect "Please enter the validation clientname:"
send "\r"

expect "Please enter the location of the validation key:"
send "/home/vagrant/.chef/validation.pem\r"

expect "Please enter the path to a chef repository"
send "\r"

expect "Created client\[vagrant\]"
