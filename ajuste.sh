#Ajustes nas tag hosts e user nos scripts yaml
sed -i.bkp   '1,/\ \ user:..*/s/\ \ user:..*/  user: charles.a/' *.yaml
sed -i.bkp-hosts   "s/\-\ \hosts:..*/\-\ hosts: all/g" *.yaml
mv -v  *.bkp* ./backup

