$EPHESOFT_CONFIG_FILEPATH = "C:\PowershellFileMonitor\demo\config\config.xml"
$OLD_CONFIG_FILEPATH = "C:\PowershellFileMonitor\demo\old_config.xml"
$LOG_PATH = "C:\PowershellFileMonitor\demo\logs"
$DIFF_LOG_PATH = "C:\PowershellFileMonitor\demo\diff"
$MAX_LOGS = 100
$LOG_FILE_SIZE = 100


function main() {
  if (!(Test-Path $OLD_CONFIG_FILEPATH)) {
    #Write-Warning "Old config file not found to compare."
    copy_config
  } else {
    generate_config_report
    rotate_logs_and_diff
    copy_config
  }
}

function generate_config_report() {
  $timestamp = (Get-Date -f yyyy-MM-dd_HH-mm-ss)
  $diff_filename = "config_xml-$timestamp.diff"
  $output_location = Join-Path $DIFF_LOG_PATH $diff_filename 
  
  if ( (Get-FileHash $OLD_CONFIG_FILEPATH).hash -ne (Get-FileHash $EPHESOFT_CONFIG_FILEPATH).hash) {
    #Write-Host "Difference found"
    $message = "$timestamp `t True"
    fc.exe $OLD_CONFIG_FILEPATH $EPHESOFT_CONFIG_FILEPATH | Out-File $output_location
    #Compare-Object -ReferenceObject (Get-Content $OLD_CONFIG_FILEPATH) -DifferenceObject (Get-Content $EPHESOFT_CONFIG_FILEPATH) | Format-List | Out-File $output_location
  } else {
    $message = "$timestamp `t False"
    #Write-Host "Difference not found"
  }
  update_log_file($message)
}

function copy_config() {
  Copy-Item $EPHESOFT_CONFIG_FILEPATH $OLD_CONFIG_FILEPATH
}

function update_log_file($message) {
    $latest_file = Get-ChildItem -Path $LOG_PATH | Sort-Object LastAccessTime -Descending | Select-Object -First 1
    $filename = Join-Path $LOG_PATH $latest_file.Name

    if ( !($latest_file) ) {
        $filename = create_log_file
    }
    $log_file = line_count($filename)
    if ($( line_count($filename) ) -ge $LOG_FILE_SIZE) {
        $filename = create_log_file
    }
    Add-Content $filename $message

}

function create_log_file() {
    $base_filename = "config_monitor"
    $timestamp = (Get-Date -f yyyyMMdd_HH-mm-ss)
    $filename = Join-Path $LOG_PATH "$base_filename_$timestamp.log"
	#Write-Host "Creating log file: $filename"
	$headers = "Last Checked at `t File Changed?"
    $headers | Out-File $filename
    #New-Item "$filename" -ItemType File -Value ($headers + [Environment]::NewLine)
    return $filename
}

function line_count($filename) {
    $count = Get-Content $filename | Measure-Object -Line
    return $count.Lines
}

function number_files($path) {
    $number_files = Get-ChildItem $path -Recurse -File | Measure-Object | %{$_.Count}
    return $number_files
}


function rotate_logs_and_diff(){
  #Write-Host "Removing old log files"
  $log_files = Get-ChildItem "$LOG_PATH\*.log" -Recurse -File | Sort-Object CreationTime -Descending
  $log_files_count = $log_files | Measure-Object | %{$_.Count} 
  if ( $log_files_count -ge $MAX_LOGS ) {
    $log_files_to_delete = $log_files | Select-Object -Last ($log_files.count - $MAX_LOGS)
    $log_files_to_delete | Foreach-Object { Remove-Item $_ }
  }

  $diff_files = Get-ChildItem "$DIFF_LOG_PATH\*.diff" -Recurse -File | Sort-Object CreationTime -Descending
  $diff_files_count = $diff_files | Measure-Object | %{$_.Count} 
  if ( $diff_files_count -ge $MAX_LOGS ) {
    $diff_files_to_delete = $diff_files | Select-Object -Last ($diff_files.count - $MAX_LOGS)
    $diff_files_to_delete | Foreach-Object { Remove-Item $_ }
  }
}


main
