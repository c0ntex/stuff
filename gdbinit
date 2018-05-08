##
## my gdbinit file
##

#source ~/vulndev/utils/peda/peda.py
#source ~/vulndev/utils/exploitable/exploitable.py
source ~/vulndev/utils/gef.py


##
# Function to print the bins
## 

# print av->bins
define bin
  set $i=0
  while $i < 254
    p *av->bins[$i]
    set $i=$i+1
  end
end

## print av->next->bins
define binn
  set $i=0
  while $i < 254
    p *av->next->bins[$i]
    set $i=$i+1
  end
end

