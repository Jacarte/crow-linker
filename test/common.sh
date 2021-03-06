function get_variants(){
  NAME=$1
  FOLDER=$2

  VARIANTS=($(find "$FOLDER" -name "*_\[*.bc"))
}

function check4functions(){
  ORIGINAL=$1
  VARIANTS=$2

  DATAF="data.txt"
  echo -n "" > $DATAF
  for l in $( /usr/local/opt/llvm/bin/llvm-nm "$ORIGINAL" | grep -E " T " | awk '{print $3}') # Get defined functions in original
  do
    # check for this function in variants
     /usr/local/opt/llvm/bin/llvm-extract --func=$l "$ORIGINAL" -o t.bc
    echo -n $l " " "$ORIGINAL" " " >> $DATAF
    md5sum t.bc | awk '{print $1}' >> $DATAF

    for v in ${VARIANTS[@]}
    do

       /usr/local/opt/llvm/bin/llvm-extract --func=$l "$v" -o t.bc
      echo -n $l " " "$v" " " >> $DATAF
      md5sum t.bc | awk '{print $1}' >> $DATAF
      /usr/local/opt/llvm/bin/llvm-dis t.bc -o t.ll

    done

  done

    FUNCTIONS=$(uniq -c -f2 $DATAF | grep -E  "[ \t]+1[ \t]+" | awk '{print $2}' | uniq | awk '{printf "%s,", $1}') # get functions
    FUNCTIONS=$(echo "$FUNCTIONS" | sed -e "s/.$//g")


    UNIQUE_VARIANTS=$(uniq -c -f2 $DATAF | grep -E  "[ \t]+1[ \t]+" | awk '{printf "%s,", $3}') # get variants
    UNIQUE_VARIANTS=$(echo "$UNIQUE_VARIANTS" | sed -e "s/.$//g")
}