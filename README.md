# PowershellFileMonitor
This is a powershell script to monitor a file in Windows and log the changes. The script is launched on regular intervals using Windows Task Scheduler.

#### Configuration
EPHESOFT_CONFIG_FILEPATH: Defines the absolute path of the file to be monitored
OLD_CONFIG_FILEPATH: Defines the absolute path to save the old copy of the file to be monitored in next run
LOG_PATH: Defines the absolute path of the logs directory to keep the log 
DIFF_LOG_PATH: Defines the absolute path of the diff directory to keep the changes made for references.
MAX_LOGS: Defines the maximum log files to keep to save the space
LOG_FILE_SIZE: Defines the maximum line each file can contain
