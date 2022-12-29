std_msgs/Header header # This can also define the frame
uint8 POINTS=0
uint8 CIRCLE=1
uint8 SQUARE=2
uint8 RECTANGLE=3
uint8 geofence_type

geometry_msgs/Point[] corners # [POINTS] 3> points, local or gps
geometry_msgs/Point origin # [CIRCLE/SQUARE]
float32 radius # [CIRCLE/SQUARE] in meters. if x meters, square will be 2x by 2x

bool no_fly_zone # If false, the inner area is allowed, if not, outer side
bool altitude_absolute # If false, it will be from the launch altitude
