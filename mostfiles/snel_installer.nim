
# status: working
# source-machine: ndell-mint19
# source-scripts: none
# author: joris bollen
# script-type: nim
#	birth-date      prog.name				     version   update-machine
#	2020-02-13      snel_installer.nim   see var   ndell-mint19


# script-operation:
# simple installer of files
# uses installation-definition-file in which sources and targets are placed
# ---------------------------------------------------
# Format of the installation-definition-file (def-file):
# it contains multiple blocks starting with specific tasks
# see manual for more info.


# Please consult the def-file for project-specific info.
# ----------------------------------------------------

# ADAP HIS


# ADAP NOW


# ADAP FUT
# naming of entries in the defile, like:
  # dir===/somdir
  # line_orientatien==="after"
# functionalize main-code
# implement a dry run mode (instead of def-file-validation)
  # dry run means testing the def-file without making changes.
  # it is not a full validation but it can find some definition-faults.
# create a higher loop in which multiple packages can be installed.
  # use a higer folder for:
    # executable 
    # and higher install-order-config.txt
# add permissions-section
# reverse order = removal of installation
# add def-file validation
# conditional operations
  # create a block for test-variables which can 
  # later be used for conditional operations

#=============================================


var 
  versionfl:float = 2.43
  ask_confirmationbo: bool = true

  arg_def_filest: string
  arg_levelit: int


# import std/[os, strutils, parseopt, paths]
import std/[os, strutils, parseopt, tables, dirs, files]
import jo_file_ops



proc yes(question: string): bool =
  echo question, " (y/n)"
  while true:
    case readLine(stdin)
    of "y", "Y", "yes", "Yes": return true
    of "n", "N", "no", "No": return false
    else: echo "Please be clear: yes or no"
  


proc confirmInstall(askbo: bool): bool =

  # report status and ask followup-action
  echo "\n==============================="
  echo "Program Snel_Installer " & $(versionfl) & " is running..."     
  echo "Make sure to run snel_installer with sufficient rights."

  if askbo:
    if yes("Do you want to continue?"):
      echo "continuing..."
      result = true

    else:
      echo "aborting Snel_Installer...goodbye!"
      # quit(QuitSuccess)     # no longer needy
      result = false
  else:
    result = true



proc expandVars(inputst, varsepst: string, variableta: OrderedTable[string, string]): string = 
  #[
    Substitute in inputst all the vars surrounded by varsepst based on the
    key-value-list in variableta 
  ]#

  var 
    fullkeyst: string
    tekst = inputst

  for keyst, valst in variableta:
    fullkeyst = varsepst & keyst & varsepst
    if fullkeyst in tekst:
      tekst = tekst.replace(fullkeyst, valst)

  result = tekst



proc updateVarUsageTable(inputst, varsepst: string, variableta: OrderedTable[string, string], 
                  varusageta: var OrderedTable[string, bool]) = 
  #[
    Update the var-usage-table varusageta if the fullkey is found in the inputst.
  ]#

  var 
    fullkeyst: string

  # echo varusageta

  for keyst in variableta.keys:
    fullkeyst = varsepst & keyst & varsepst
    if fullkeyst in inputst:
      varusageta[keyst] = true
      # echo "-----varusage---- ", fullkeyst, "      ", inputst



proc installFromDef(install_def_filest: string, call_levelit: int = 0): bool = 
  #[
    Install files based on the definition passed as argument in the program-call.
    Calling installs can be done recurrently with CALL OTHER INSTALLATIONS
    Call-level is zero-based; upcount every subordinate call with 1.

  ]#


  var
    def_filenamest: string = install_def_filest
    completionbo: bool = false
    myfile: File
    blockheadar: array[0..5, string] = [
        "VARIABLES TO SET", 
        "DIRECTORIES TO CREATE",
        "TARGET-LOCATION AND SOURCE-FILES TO COPY",
        "EDIT FILE (ADD, DELETE, REPLACE LINES)",
        "EXECUTE SHELL-COMMANDS - IN ORDER",
        "CALL OTHER INSTALLATIONS"]
    blockphasest: string = ""
    blocklineit: int
    blockseparatorst = ">----------------------------------<"
    targetdirpathst: string
    targetfilepathst: string
    sourcedirpathst: string
    sourcefilepathst: string
    sourcefilest: string
    editfileprops:array[6,string]
    ops_paramsq:seq[string] = @[]
    lastline: string
    all_argst: string
    argumentsq: seq[string] = @[]
    linux_setexebo: bool= false
    linux_use_sudobo: bool = false
    varsepst: string
    varsta = initOrderedTable[string, string]()
    var_usageta = initOrderedTable[string, bool]()
    varlinesq: seq[string] = @[]
    pathst: string
    linest: string
    lineit: int
    copybranchbo: bool = false
    samplepermissionsbo: bool = false
    reportst: string


  echo "\pCurrent directory: ", getAppDir()

  echo "\pTrying to open file: " & def_filenamest & "\p"

  if open(myfile, def_filenamest):    # try to open the def-file
    try:

      # walk thru the lines of the file
      # first pass of two passes to retrieve the variables
      # (substitute the values in the next pass)
      echo "\n=====Begin processing===="
      for line in myfile.lines:
        lastline = line

        # check for block-header
        if line in blockheadar:
          blockphasest = line
          if blockphasest == "VARIABLES TO SET":
            echo "\p" & blockphasest
          blocklineit = 0
        elif line != "":
        
          blocklineit += 1
          if line != blockseparatorst:   # block-separating string

            if blockphasest == "VARIABLES TO SET":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:  # read the separator-string
                # handle arguments
                all_argst = line.split("---")[1]
                varsepst = all_argst.split("=")[1]
              else:
                varlinesq = line.split("=")
                # fill the variable-table
                varsta[varlinesq[0]] = varlinesq[1]
                # preset the var-usage-table to false (later to be tested)
                var_usageta[varlinesq[0]] = false
                echo line

            elif blockphasest != "":
              # use this part for scan of variable-usage
              updateVarUsageTable(line, varsepst, varsta, var_usageta)

          else:
            # then the former block is completed
            blockphasest = ""


      # update the nested-var usage
      for keyst, valst in varsta:
        updateVarUsageTable(valst, varsepst, varsta, var_usageta)        

      # substitute the var-table itself for nested vars and echo a report if present
      var newvalst: string
      for keyst, valst in varsta:
        newvalst = expandVars(valst, varsepst, varsta)
        varsta[keyst] = newvalst
        if valst != newvalst:
          reportst &= "\p" & keyst & ": " & newvalst

      if reportst != "":
        echo "\pVariables with nested vars:" & reportst


      # echo non-used vars if present
      reportst = ""
      for keyst, valst in varsta:
        if var_usageta[keyst] == false:
          reportst &= "\p" &  keyst & ": " & valst

      if reportst != "":
        echo "\pThese variables are never used:" & reportst



      # walk thru the lines of the file
      # second pass to do the other block-phases
      myfile.setFilePos(0)    # reset to first line
      lineit = 1
      for line in myfile.lines:

        # substitute the variable-values from the first pass here
        linest = expandVars(line, varsepst, varsta)
        lastline = linest


        # check for block-header
        if linest in blockheadar:
          blockphasest = linest
          if blockphasest != "VARIABLES TO SET":
            echo "\p" & blockphasest
          blocklineit = 0
        elif linest != "":
        
          blocklineit += 1
          if linest != blockseparatorst:   # block-separating string
              
            if blockphasest == "DIRECTORIES TO CREATE":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard
              else:
                pathst = expandTilde(linest)
                if not dirExists(pathst):   
                  createDir(pathst)     # proc creates subdirs also
                  echo "creating directory: " & pathst

            elif blockphasest == "TARGET-LOCATION AND SOURCE-FILES TO COPY":

              if blocklineit == 1:  # comment-line
                discard

              elif blocklineit == 2:    # handle arguments
                if linest != "arguments---none":
                  all_argst = linest.split("---")[1]
                  argumentsq = all_argst.split(",,")
                  #echo repr argumentsq
                  if jo_file_ops.getValueFromKey(argumentsq, "=", "linux_set_exe") == "1":
                    echo "linux_set_exebo = true"
                    linux_setexebo = true
                  if jo_file_ops.getValueFromKey(argumentsq, "=", "linux_use_sudo") == "1":
                    echo "linux_use_sudobo = true"
                    linux_use_sudobo = true
                  if jo_file_ops.getValueFromKey(argumentsq, "=", "copy_branch") == "1":
                    echo "copybranchbo = true"
                    copybranchbo = true
                  if jo_file_ops.getValueFromKey(argumentsq, "=", "sample_permissions") == "1":
                    echo "samplepermissionsbo = true"
                    samplepermissionsbo = true


              elif blocklineit == 3:
                targetdirpathst = expandTilde(linest)
              elif blocklineit == 4:
                sourcedirpathst = expandTilde(linest)
                if copybranchbo:
                  copyDirWithStem(sourcedirpathst, targetdirpathst, samplepermissionsbo)
                  echo "Copying branch: ", sourcedirpathst, " to: ", targetdirpathst

              else:
                if not copybranchbo:
                  sourcefilest = linest
                  sourcefilepathst = joinPath(sourcedirpathst, sourcefilest)                
                  echo "copying: " & sourcefilepathst & "   to:   " & targetdirpathst
                  targetfilepathst = joinPath(targetdirpathst, sourcefilest)
                  if dirExists(targetdirpathst):
                    if fileExists(sourcefilepathst):
                      copyfile(sourcefilepathst,targetfilepathst)
                      if linux_setexebo:
                        var prependst:string = ""
                        if linux_use_sudobo: prependst = "sudo "
                        discard execShellCmd(prependst & "chmod +x " & targetfilepathst)
                    else:
                      echo "The following file does not exist:\p", sourcefilepathst
                      echo "Occured at def-line-nr: ", $lineit
                      echo "\pInstallation ended prematurely!"
                      quit(QuitSuccess)
                  else:
                    echo "The following directory does not exist:\p", targetdirpathst
                    echo "Occured at def-line-nr: ", $lineit
                    echo "\pInstallation ended prematurely!"
                    quit(QuitSuccess)


            elif blockphasest == "EDIT FILE (ADD, DELETE, REPLACE LINES)":

              #echo "----edit-test----"
              #echo blocklineit
              if blocklineit != 4: 
                echo linest

              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard      
              elif blocklineit in 3..8:     # read the fixed parameters (x7)
                editfileprops[blocklineit - 3]=linest
                if blocklineit == 4:
                  pathst = expandTilde(linest)
                  echo pathst
              elif blocklineit > 8:     # read the dynamic parameters
                if linest != "end-of-edit-block-here":
                  ops_paramsq.add(linest)
                else:
                  jo_file_ops.alterTextFile(
                        operationst = editfileprops[0],
                        targetfilepathst = pathst, 
                        line_orientationst = editfileprops[5], 
                        locating_stringst = editfileprops[4], 
                        occurit = parseint(editfileprops[3]),
                        directionst = editfileprops[2],
                        operationparamsq = ops_paramsq)
                  echo "\p" & editfileprops[0] & " performed on: " & pathst & "\p"


            elif blockphasest == "EXECUTE SHELL-COMMANDS - IN ORDER":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard
              else:
                echo "Running command: " & linest
                discard execShellCmd(linest)


            elif blockphasest == "CALL OTHER INSTALLATIONS":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard
              else:
                echo "*********************************************************************"
                echo "Executing subordinate installation seq. nr. " & $(blocklineit - 2) & ": " & linest
                echo "*********************************************************************"
                discard execShellCmd(getAppFilename() & " " & linest & " --level:" & $(call_levelit + 1))
            
          else:
            # when the former block is completed
            blockphasest = ""
            ops_paramsq = @[]     # reset dynamic params
            # set arguments to none:
            linux_setexebo = false
            linux_use_sudobo = false
            copybranchbo = false
            samplepermissionsbo = false

        lineit += 1
      
      completionbo = true
      result = completionbo
      echo "\p===End of processing====\p"
      

    except IOError:
      echo "IO error!"
    
    except:
      let errob = getCurrentException()
      echo "\p******* Unanticipated error ******* \p" 
      echo "In block-phase: " & blockphasest & "\p"
      echo "Last def-file-line read: " & lastline & "\p"
      echo "Occured at def-line-nr: ", $lineit
      echo repr(errob) & "\p****End exception****\p"
        
    finally:
      close(myfile)
  else:
    echo "Could not open file! \pThe argument provided is not a valid file. "




proc loadCommandLineArgs() = 
  
  # Load the args appended after the calling executable
  # and write them to module-level variables.

  # possible format: "-ab -e:5 --foo --bar=20 file.txt"

  var
    optob = initOptParser()
    passit: int = 0

  arg_levelit = 0

  while true:
    optob.next()
    case optob.kind
    of cmdEnd:
      if passit == 0:
        echo "\n==============================="
        echo "Program Snel_Installer " & $(versionfl) & " is running..."             
        echo "\pYou did not append an install-definition-file as argument!"
        echo "Please provide one."
        echo "Quiting..."
        quit(QuitSuccess)
      break

    of cmdArgument:
      # echo "Argument: ", optob.key
      arg_def_filest = optob.key

    of cmdShortOption, cmdLongOption:
      # not yet used
      if optob.val == "":
        echo "Option: ", optob.key
      else:
        # echo "Option and value: ", optob.key, ", ", optob.val
        case optob.key:
          of "level":
            arg_levelit = parseInt(optob.val)
            echo "Call-level = ", arg_levelit

    passit += 1

  if arg_levelit == 0: echo "\pCall-level = 0"




proc dummy() = 
  discard



# **********************************************************
var for_realbo: bool = true


if for_realbo:   # run the actual program

  loadCommandLineArgs()
  if arg_levelit > 0: ask_confirmationbo = false
  if confirmInstall(ask_confirmationbo):

    if installFromDef(arg_def_filest, arg_levelit):
      echo "Installation has been completed!"
    else:
      echo "Installation ended prematurely!"

else:   # perform tests

  # proc expandVars
  var 
    varsta = initOrderedTable[string, string]()
    inputst = "i am #tes# the #stal# files"
  
  varsta["stal"] = "installable"
  varsta["tes"] = "testing"

  echo inputst
  echo expandVars(inputst, "#", varsta)


