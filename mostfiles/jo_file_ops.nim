
# status: working
# source-machine: ndell-mint19
# source-scripts: insertTextInFIle
# author: joris bollen
# script-type: nim
#	birth-date      prog.name				version   update-machine
#	2020-02-25      jo_file_ops.nim     see var   ndell-mint19


import std/[os, strutils, dirs, files, private/osdirs, paths]


var versionfl:float = 1.5

# var debugbo: bool = true
var debugbo: bool = true

template log(messagest: string) =
  # replacement for echo that is only evaluated when debugbo = true
  if debugbo: 
    echo messagest


proc searchNthSubInString(stringst,subst:string,occurit:int, 
            directionst:string = "forward",
            startposit:Natural=0): int =

  # UNIT INFO
  # search forward or backward for the occurence of a substring 
  # in a string and return its position (starting from from startposit)

  #echo "================================="
  #echo "starting searchNth..."
  ##echo "stringst = " & stringst
  #echo "subst = " & subst
  #echo "occurit = " & $occurit
  #echo "directionst = " & directionst
  #echo "startposit = " & $startposit
  
  var positionit:int
  var startna:Natural = 0
  var lastna: Natural = len(stringst)
  
  if startposit != 0:
    startna = startposit
    lastna = startposit
  
  for passit in 1..occurit:
  
    if directionst == "forward":
      positionit = find(stringst, subst, startna)
    elif directionst == "backward":
      positionit = rfind(stringst, subst, 0, lastna)
    #echo "positionit = " & $positionit
    if positionit >= 0:
      startna = positionit + 1
      if positionit >= 1:
        lastna = positionit - 1
    elif positionit == -1:
      return -1
  return positionit

  
proc backupFile(filepathst:string): string =
  # copy the given file to one with the suffix .bak
  
  var 
    fulldirst: string
    filest:string
    bakfilest:string
    bakfilepathst:string
  
  (fulldirst, filest) = splitPath(filepathst)
  bakfilest = filest & ".bak"
  bakfilepathst = joinPath(fulldirst, bakfilest)
  copyFile(filepathst,bakfilepathst)
  return bakfilepathst


proc getValueFromKey*(allargsq:seq[string], separatorst, keyst:string): string =
  # UNIT INFO
  # Retrieve a value from a key-value-sequence based on key and
  # separator
  var 
    ikeyst, ivaluest:string
    key_valsq: seq[string]
  
  for item in allargsq:
    # (ikeyst,ivaluest) = item.split(separatorst)
    key_valsq = item.split(separatorst)
    ikeyst = key_valsq[0]
    ivaluest = key_valsq[1]
    if ikeyst == keyst:
      return ivaluest
  
  

  
  
proc alterTextFile*(operationst, targetfilepathst, locating_stringst:string, 
          directionst:string, occurit: int,
          line_orientationst: string, operationparamsq:seq[string]) =

  #[
  UNIT INFO:
  Alter a text-file (targetfile) by means of an operation.
  Use a locating-string to determine the locating-point. The 
  line-orientation indicates before, on or after the 
  location-point that the operation must be done.
  Loc-string is found by searching in certain direction (forward or
  backward) and determining the wished occurence of the 
  search-string.
  Operations:
  insertions-params; a sequence of strings that form the new lines.
  deletions-params: a number of lines to be erased.
  replacement-params: strings to-replace and replace-to
  ]#


  var 
    backupfile: File
    backupfilepathst: string
    positionit: int
    # filets: TaintedString
    filets: string
    filecontentst:string
    insertionpointit:int
    enteredbo: bool = false

  
  # quit if file non-existant
  if not fileExists(targetfilepathst):
    echo "\pFollowing file does not exist: " & targetfilepathst
    echo "Exiting function alterTextFile..."
    quit(QuitSuccess)

  log("\poperation = " & operationst)
  log("locating_string = " & locating_stringst)
  log("operationparamsq = " & $operationparamsq)

  # backup the target-file
  backupfilepathst = backupFile(targetfilepathst)
  
  # open the backup-file for reading
  if open(backupfile, backupfilepathst): 
    try:
      filets = readAll(backupfile)
      filecontentst = $filets
      #echo filecontentst

    except:
      echo "=========er ging iets mis=========="
      raise
  else:
    echo "Could not open target-file!"

  defer: backupfile.close()
  
  # go to the file-location where to insert line(s)
  positionit = searchNthSubInString(filecontentst, locating_stringst, occurit,
                    directionst)

  echo "Locating-string found at character-position (-1 = not found): " & $positionit
  
  
  # Full line-operations expect the locating-string starting at
  # the start of the sentence.
  var startposit:int
  var endposit:int  
  
  try:
    case operationst    # concerning lines
    of "insertions":
      log("performing insertion at (if any..):")
      case line_orientationst
      of "before":
        insertionpointit = searchNthSubInString(filecontentst, "\n",
                1, "backward", positionit) + 1      
        log("insertionpointit = " & $insertionpointit)

        for elem in operationparamsq:
          filecontentst.insert(elem & "\p", insertionpointit)
          insertionpointit += len(elem) + len("\p")

      of "on":  # single prepend; does not go to the front!
        filecontentst.insert(operationparamsq[0], positionit)
        log("inserted at: " & $positionit)

    
      of "after":
        insertionpointit = searchNthSubInString(filecontentst, "\n",
                1, "forward", positionit) + 1
        log("insertionpointit = " & $insertionpointit)

        for elem in operationparamsq:
          filecontentst.insert(elem & "\p", insertionpointit)
          insertionpointit += len(elem) + len("\p")
      else:
        echo "Invalid orientation (choose from before, on -or- after)"


    of "deletions":
      log("performing deletions..")
      var numberoflinesit:int = parseint(operationparamsq[0])

      case line_orientationst
      of "on":
        #echo "orient = on"
        startposit = searchNthSubInString(filecontentst, "\n",
                1, "backward", positionit) + 1      
        endposit = searchNthSubInString(filecontentst, "\n",
              numberoflinesit, "forward", positionit)
        log("startposit and endposit: " & $startposit & "  " & $endposit)
        filecontentst.delete(startposit..endposit)
      
      of "after":
        #echo "orient = after"
        startposit = searchNthSubInString(filecontentst, "\n",
              1, "forward", positionit) + 1
        log("startposit =" & $startposit)
        endposit = searchNthSubInString(filecontentst, "\n",
              numberoflinesit + 1, "forward", positionit)
        log("endposit = " & $endposit)
        filecontentst.delete(startposit..endposit)
      
      of "before":
        #echo "orient = before"
        endposit = searchNthSubInString(filecontentst, "\n",
                1, "backward", positionit)
        startposit = searchNthSubInString(filecontentst, "\n",
              numberoflinesit + 1, "backward", positionit) + 1
        log("startposit and endposit: " & $startposit & "  " & $endposit)

        filecontentst.delete(startposit..endposit)


    of "replacement":
      # replacement allways has orientation: on
      log("performing replacement..")
      var currentlinest:string
      var replacedlinest: string
      var to_replacest: string = operationparamsq[0]
      var replace_tost: string = operationparamsq[1]
    
    
      # seek previous line-marker
      startposit = searchNthSubInString(filecontentst, "\n",
              1, "backward", positionit) + 1
      log("startposit = " & $startposit)
      
      # seek next line-marker
      endposit = searchNthSubInString(filecontentst, "\n",
              1, "forward", positionit)
      log("endposit = " & $endposit)
      # copy the current line
      currentlinest = filecontentst[startposit .. endposit]
      log("currentlinest = " & currentlinest)
      # delete the current line
      filecontentst.delete(startposit..endposit)
      log("to-repl =" & to_replacest)
      log("rep-to =" & replace_tost)
      # replace the current line
      replacedlinest = currentlinest.replace(to_replacest, replace_tost)
      log("repl.linest = " & replacedlinest)
      # insert the replaced line
      filecontentst.insert(replacedlinest, startposit)
      if currentlinest == replacedlinest:
        log("NO NET replacements WERE MADE!")


  except IOError:
    echo "IO error!"
  
  except RangeDefect:
    echo "\p\p+++++++ search-config not found +++++++++++\p"
    echo "You have probably entered a search-config that could not be found. \p" &
        "Re-examine you search-config. \p" &
        "The problem originated probably in the above EDIT FILE-block"
    let errob = getCurrentException()
    echo "\p******* Technical error-information ******* \p" 
    echo repr(errob) & "\p****End exception****\p"
  
  except:
    let errob = getCurrentException()
    echo "\p******* Unanticipated error ******* \p" 
    echo repr(errob) & "\p****End exception****\p"
      
  # finally:
    #echo filecontentst
    # writeFile(targetfilepathst, filecontentst)

  #echo filecontentst
  writeFile(targetfilepathst, filecontentst)

# echo "jo_file_ops " & $(versionfl) & " is called..."



proc myWalkDir(dirst: string) = 
  for filest in walkDirRec(dirst, relative = true, yieldFilter = {pcDir}):
    echo filest


proc copyDirWithStem*(sourcedirst, tardirst: string, sample_permissionsbo = false) = 
  # Recurrently copy sourcedirst to tardirst
  # Copy also the stem-dir of the sourcedirst (aot copyDir)
  # Keeps persmissions from source-tree

  var 
    dirstemst: string =  lastPathPart(sourcedirst)
    newdirst: string = joinPath(tardirst, dirstemst)

  createDir(newdirst)
  if sample_permissionsbo:
    copyDirWithPermissions(sourcedirst, newdirst)
  else:
    copyDir(sourcedirst, newdirst)



when isMainModule:
  # pass

  # myWalkDir(getAppDir())

  # copyDirWithStem("/home/bruik/testing/testdoel1", "/home/bruik/testing/doel")

  # echo getValueFromKey(@["jan-pieters", "wim-jansen"], "-", "janus")

# test searchNthSubInString
#var posit : int = 0
#var stringst: string = "de-kat-is-de-kattigste-kat-van-de-wereld"
#var subst: string = "kat"
#posit = searchNthSubInString2(stringst,subst, 2, "backward",22)
#echo "Position = " & $posit
#-----------end test----


#echo getValueFromKey(@["arg1;;aap", "arg2;;noot", "arg3;;mies"], ";;","arg2")

#operationst, targetfilepathst, locating_stringst:string, 
          #directionst:string, occurit: int,
          #line_orientationst: string, operationparamsq:seq[string]

   #alterTextFile("insertions", "some_config.txt", "opdracht", 
   #          "forward", 2, "on", @["winstgevende "])

   #alterTextFile("insertions", "some_config.txt", "opdracht", 
   #          "forward", 1, "after", @["aap", "noot", "mies"])

   #alterTextFile("insertions", "some_config.txt", "opdracht", 
   #          "forward", 1, "before", @["aap", "noot", "mies"])

   #alterTextFile("deletions", "some_config.txt", "opdracht", 
   #          "forward", 1, "before", @["2"])

   #alterTextFile("deletions", "some_config.txt", "12", 
   #          "forward", 1, "on", @["1"])

   #alterTextFile("deletions", "some_config.txt", "opdracht", 
   #          "forward", 1, "after", @["2"])


  alterTextFile("replacement", "some_config.txt", "opdracht", 
            "forward", 1, "on", @["de","een"])
