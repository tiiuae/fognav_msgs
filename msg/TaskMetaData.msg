std_msgs/Header header

string task_id

uint8 TASK_GO_TO=0
uint8 TASK_GO_TO_AND_LAND=1
uint8 TASK_LAND=2
uint8 TASK_WAIT=3
uint8 TASK_RETURN_TO_LAUNCH=4

uint8 task_type
# This is a placeholder for configuration of the task types. 
# In future, each task type will have its own configuration mapped to this array.
float64[8] params

uint8 YAW_USE_FROM_TASK=0
uint8 YAW_TOWARDS_WAYPOINT=1
uint8 YAW_TOWARDS_HOME=2
uint8 YAW_AWAY_FROM_HOME=2
uint8 YAW_ALONG_TRAJECTORY=3
uint8 YAW_TOWARDS_WAYPOINT_YAW_FIRST=4
uint8 YAW_HOLD_CURRENT=5
uint8 yaw_mode

uint8 TASK_STATUS_NOT_STARTED=0
uint8 TASK_STATUS_ONGOING=1
uint8 TASK_STATUS_ABORTED=2
uint8 TASK_STATUS_CANCELED=3
uint8 TASK_STATUS_SUCCESSFUL=255

uint8 status
string behavior_tree
