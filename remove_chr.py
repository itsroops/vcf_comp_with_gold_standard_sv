import re
import sys

def rem_chr():
    """
    Removing the letters 'chr' from the chromosome numbers in order to make it compatible for comparison
            
    Parameters: 
    No input parameter
            
    Returns:
    Does not return anything
            
    """
    f = open(sys.argv[1],"r")
    k = f.read()
    k2 = re.sub('chr([1-9XYMUE])',r'\1',k)
    if sys.argv[2]=='Y' or sys.argv[2]=='y':
        f_name=sys.argv[1]
        f2 = open(f_name,"w")
        f2.write(k2)
    else:
        f_name=sys.argv[1].split(".vcf")[0]+"_modified.vcf"
        f2 = open(f_name,"w")
        f2.write(k2)
    f.close()
    f2.close()
    exit(f_name)

if __name__=='__main__':
    rem_chr()
