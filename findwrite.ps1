function IsFolderWritable ($test_folder, $verbose) {

	if($verbose -eq $null)
    {
        $verbose = $false
    }

	# Check if folder is a folder
	If (-Not (Test-Path $test_folder -pathType container)) { 
		throw "Given path is not a container: "+$test_folder
	}
	
	# Create random test file name
	$test_tmp_filename = "writetest-"+[guid]::NewGuid()
	$test_filename = (Join-Path $test_folder $test_tmp_filename)
	
	Try { 
		# Try to add a new file
		[io.file]::OpenWrite($test_filename).close()
		Write-Host -ForegroundColor Green "[+] Writable:" $test_folder
		
		# Remove test file
		Remove-Item -ErrorAction SilentlyContinue $test_filename
		
		if (Test-Path $test_filename and $verbose) { 
			Write-Host -ForegroundColor Yellow "[*] Failed to delete test file: " $test_filename
		}
	}
	Catch {
		# Report error?
		if ($verbose) { 
			Write-Host -ForegroundColor Red "[-] Not writable: " $test_folder
		}
	}
}	

function IsFolderWritableRecursive ($test_folder, $verbose) {
	$files = Get-ChildItem -Path $test_folder -Recurse -Force -ErrorAction SilentlyContinue | where {$_.PSIsContainer}
	foreach ($file in $files)
	{
		IsFolderWritable -test_folder $file.FullName -verbose $verbose
	}
}