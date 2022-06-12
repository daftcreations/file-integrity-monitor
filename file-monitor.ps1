Function FIleMonitor{
    Write-Host ""
    Write-Host "FILE INTEGRITY MONITORING TOOL"
    Write-Host ""
    Write-Host "What would you like to do?"
    Write-Host "a). Collect hashes"
    Write-Host "b). Start monitor based on hash file"
    $userSelection = Read-Host -Prompt "Select 'a' or 'b'"

    if ($userSelection.ToLower() -eq 'a'){

        # prompt user for target file or directory and verify if it is present or not
        Write-Host ""
        $target = Read-Host -Prompt "Enter file or directory name"
        if (Test-Path -Path $target){
        

            # prompt user to ask filename of hash file
            $outputHashFile = Read-Host -Prompt "Enter filename to store hashes"
            if(Test-Path -Path $outputHashFile){Remove-Item -Path $outputHashFile}

            Write-Host ""
            Write-Host "Collecting file hashes ..."

            # Get file paths inside of a directory
            $filepaths = (Get-ChildItem -Path $target -Recurse).FullName
        
            # for each file calculate hash and store it in the file
            foreach ($f in $filepaths){
                $hash = Get-FileHash -Path $f -Algorithm SHA512

                # store filepath and hash value in output file
                if ($hash.Path -ne $null){ "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath $outputHashFile -Append }
            }
        
            Write-Host "Finished! Hashes are stored at $($outputHashFile)"
        }
        else {Write-Host "'$($target)' not found!"}
    }
    elseif ($userSelection.ToLower() -eq 'b'){

    
        Write-Host ""
    
        # prompt user for target file or directory

        $target = Read-Host -Prompt "Enter file or directory to be monitored"

        if(Test-Path -Path $target){
            # prompt user for hash files
            $hashFile = Read-Host -Prompt "Enter filename where all hashes are stored"

            if (Test-Path -Path $hashFile){
            
                $logs = Read-Host -Prompt "Enter filename to store logs"
            
                if($logs -eq ""){
                    $logs = "logs.txt"
                }

                if(Test-Path -Path $logs){
                    Remove-Item -Path $logs
                }
                Write-Host "";Write-Host ""
                Write-Host "FILE MONITORING STARTED ..."
            
                Write-Host ""
                # stores filepath in a list
                $filePaths = @{}
                foreach ($f in (Get-Content -Path $hashFile)){
                    $filePaths.Add($f.Split("|")[0], $f.Split("|")[1])
                }

                Copy-Item -Path $hashFile -Destination "C:\Windows\Temp\tmpHash.txt"

                while($true){
            
                    # add file path and hashes in a dictionary
                    $fileDictionary = @{}

                    $hashes = Get-Content -Path "C:\Windows\Temp\tmpHash.txt"
                    foreach ($h in $hashes){
                        $fileDictionary.Add($h.Split("|")[0], $h.Split("|")[1])
                    }
                
                    # Check if files are added or not

                    $files = (Get-ChildItem -Path $target -Recurse).FullName
                
                    foreach($f in $files){

                        $newHash = Get-FileHash -Path $f -Algorithm SHA512

                        # calculate hash of each file and check if hash is present or not to find out if any file has been added.
                        if($newHash.Path -ne $null){
                            if($filePaths["$($newHash.Path)"] -eq $null){

                                Write-Host "$($newHash.Path) has been created!"
                                "Created |$($newHash.Path)| $(Get-Date)" | Out-File -FilePath $logs -Append
                                $filePaths.Add("$($newHash.Path)", "$($newHash.Hash)")
                            }
                        }
                    }

                    # Check if files have been deleted or not
                    $tmpDict = @{}

                    foreach ($p in $filePaths.Keys){
                        
                        # checks if the file path is present or not in the file dictionary
                        if(Test-Path -Path $p -ErrorAction Ignore){}
                        else{
                            Write-Host "$($p) has been deleted!!!"
                            "Deleted |$($p)| $(Get-Date)" | Out-File -FilePath $logs -Append

                            # add the path which is not present in the dictionary in a tmp dictionary
                            $tmpDict.Add("$($p)", " ")
                        }
                    }

                    # remove the file path in file dictionary from the original dictionary
                    foreach($p in $tmpDict.Keys){
                        $filePaths.Remove($p)
                    }

                    # calculate hash values of target folder which to be monitored
                    $files = Get-Content -Path $hashFile

                    # monitor file integrity
                    foreach ($f in $files){
                
                        if (Test-Path -Path $f.Split("|")[0]){

                            $hash = (Get-FileHash -Path $f.Split("|")[0] -Algorithm SHA512)
                    
                            # condition for file integrity check
                            if ($fileDictionary["$($hash.Path)"] -ne $hash.Hash){
                        
                                # hash of changed file
                                $newHash = Get-FileHash -Path "$($hash.Path)" -Algorithm SHA512
                        
                                Write-Host "$($hash.Path) has been changed!!"

                            
                                "Changed |$($hash.Path)| $(Get-Date)" | Out-File -FilePath $logs -Append
                            
                                (Get-Content -Path "C:\Windows\Temp\tmpHash.txt").Replace("$($newHash.Path)|$($fileDictionary["$($hash.Path)"])", "$($newHash.Path)|$($newHash.Hash)") | Set-Content -Path "C:\Windows\Temp\tmpHash.txt"
                            }
                        }
                    }
                    Start-Sleep -Seconds 1
                }
            }else {Write-Host "'$($hashFile)' not found!"}
        }else {Write-Host "'$($target)' not found!"}
    }else {Write-Host "Please select a option from 'a' and 'b'"}
}

FileMonitor
