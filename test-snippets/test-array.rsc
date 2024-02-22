:local scripts

:set scripts {"lease";"buttons"}

:foreach script in=$scripts do={
  :put $script;
}
